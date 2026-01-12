function tblNorm = normalize_PNNs_v2(originalFile, outputPath)
% tblNorm = normalize_PNNs_v2(originalFile, outputPath)
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

% Read table
tbl = readtable(originalFile, 'TextType','string');

% Keep only real PNNs
isPNN = tbl.PNN_TRUE;
isPNN(isnan(isPNN)) = 0;
tbl = tbl( logical(isPNN), : );

% Replace NaN PV flags with 0, make logical
tbl.PV_PNN(isnan(tbl.PV_PNN)) = 0;
isPV = logical(tbl.PV_PNN);


% Split into PV+ and PV−, loop over both
subsets = { tbl( isPV ,:), tbl(~isPV ,:) };
outnames = { 'PVpos_PNNs_normalized.csv', ...
    'PVneg_PNNs_normalized.csv' };

% Define batch groups
batchGroups = { [1], [2 3 4], [5] };

%For each subset (PV+ or PV- PNNs)
for s = 1:2
    tbltemp = subsets{s};
    tblNorm = tbltemp;  % initialize output for this subset

    %Normalize by Untrained mean within BatchGroup
    for b = 1:numel(batchGroups)
        thisBatches = batchGroups{b};
        idxBatch = ismember(tbltemp.Batch, thisBatches);

        if ~any(idxBatch)
            continue;
        end


        % Baseline: Untrained within this batch group
        idxBase = idxBatch & strcmp(tbltemp.Group, 'Untrained');

        baseVals = tbltemp{idxBase, 'mean'};
        baseMean = mean(baseVals, 'omitnan');

        if isempty(baseVals) || isnan(baseMean)
            % No baseline available -> leave as NaN and warn
            warning('No Untrained baseline for batches %s. Values left unchanged (NaN if missing).', ...
                mat2str(thisBatches));
            continue
        end

        % Apply normalization: value / baseline * 100
        dataVals = tbltemp{idxBatch, 'mean'};
        tblNorm{idxBatch, 'mean'} = (dataVals ./ baseMean) * 100;

    end
    
    % Write out this subset CSV
    outputFile = fullfile(outputPath, outnames{s});
    writetable(tblNorm, outputFile);
    fprintf('Normalization complete. Output saved to %s\n', outputFile);
end
end