function tblNorm = normalize_PNNs(originalFile, outputPath)
% tblNorm = normalize_PNNs(originalFile, outputPath)
%
% Description:
%   Reads a CSV, normalizes PNN intensity ('mean') values to the mean of the
%   Untrained group *within IHC batch and cortical layer*, separately for
%   PV+ and PV− PNNs. Writes one CSV for PV+ and one for PV−.
%
% Inputs:
%   originalFile – string; path to the input CSV. Must contain variables:
%                  'SubjectID','Group','Batch','IHCMethod','Sex','Age',
%                  'TimePerfused','Hemisphere','Slice','Layer','PNN_TRUE',
%                  'PV_PNN','mean'.
%   outputPath   – string; folder where the normalized CSVs are written.
%
% Outputs:
%   tblNorm      – MATLAB table of the last-written subset (PV−), returned
%                  mainly for convenience/inspection. Files are written to disk.
%
% Written by ML Caras June 2025

% Read in table
tbl = readtable(originalFile, 'TextType','string');

% Keep only real PNNs
isPNN = tbl.PNN_TRUE;
isPNN(isnan(isPNN)) = 0;
tbl = tbl( logical(isPNN), : );

% Replace NaN PV flags with 0, make logical
tbl.PV_PNN(isnan(tbl.PV_PNN)) = 0;
isPV = logical(tbl.PV_PNN);

if ismember ('Layer', tbl.Properties.VariableNames)
    % Ensure Layer is string (e.g., "L2","L4"...)
    tbl.Layer = upper(string(tbl.Layer));
end


% Split into PV+ and PV−, loop over both
subsets = { tbl( isPV ,:), tbl(~isPV ,:) };
outnames = { 'PVpos_PNNs_normalized.csv', ...
    'PVneg_PNNs_normalized.csv' };

% Define batch groups
batchGroups = { [1], [2 3 4], [5] };

for s = 1:2
    tbltemp = subsets{s};
    tblNorm = tbltemp;  % initialize output for this subset

    %Normalize by Untrained mean within (BatchGroup × Layer)
    for b = 1:numel(batchGroups)
        thisBatches = batchGroups{b};
        idxBatch = ismember(tbltemp.Batch, thisBatches);

        if ~any(idxBatch); continue; end

        theseLayers = unique(tbltemp.Layer(idxBatch));

        for L = 1:numel(theseLayers)
            lyr = theseLayers(L);

            % Rows for this (batch group × layer)
            idxBL = idxBatch & tbltemp.Layer == lyr;

            % Baseline: Untrained within this (batch group × layer)
            idxBase = idxBL & strcmp(tbltemp.Group, 'Untrained');

            baseVals = tbltemp{idxBase, 'mean'};
            baseMean = mean(baseVals, 'omitnan');

            if isempty(baseVals) || isnan(baseMean)
                % No baseline available -> leave as NaN and warn
                warning('No Untrained baseline for batches %s, layer %s. Values left unchanged (NaN if missing).', ...
                    mat2str(thisBatches), lyr);
                continue
            end

            % Apply normalization: value / baseline * 100
            dataVals = tbltemp{idxBL, 'mean'};
            tblNorm{idxBL, 'mean'} = (dataVals ./ baseMean) * 100;
        end
    end

    %Write out this subset CSV
    outputFile = fullfile(outputPath, outnames{s});
    writetable(tblNorm, outputFile);
    fprintf('Normalization complete. Output saved to %s\n', outputFile);
end
end