function tblNorm = normalize_to_untrained_bybatch(originalFile, outputFile)
% tblNorm = normalize_to_untrained(originalFile, outputFile)
%
% Description:
%   Reads a CSV of positional measurements with metadata, computes the mean
%   of all measurement values in the Untrained group (irrespective of position)
%   separately for each IHC Batch, normalizes each measurement to that mean
%   (expressed as percent), and writes the result to a new CSV.
%
% Inputs:
%   originalFile – string; path to the input CSV. Must contain variables
%                  'SubjectID', 'Group', 'IHCMethod', 'Sex', 'Age', and
%                  measurement columns (e.g., Pos1…PosN).
%   outputFile   – string; path where the normalized CSV will be written.
%
% Outputs:
%   tblNorm      – MATLAB table containing the normalized data, with the
%                  same variables and row order as the input.
%
% Written by ML Caras June 2025

% Read in the original data
tbl = readtable(originalFile);

% Define metadata columns
metaCols = {'SubjectID','Group','Batch','IHCMethod','Sex','Age','TimePerfused'};

% Identify measurement columns
allVars = tbl.Properties.VariableNames;
measCols = setdiff(allVars, metaCols,'stable');

% Initialize output table
tblNorm = tbl;

% Compute and apply normalization per IHCMethod

for i = 1:3

    switch i
        case 1
            batch = 1;
        case 2
            batch = 2:4;
        case 3
            batch = 5;
    end

    % Rows for this batch
    idxBatch = ismember(tbl.Batch, batch);

    % Rows in the Untrained group for baseline
    idxBase = idxBatch & strcmp(tbl.Group, 'Untrained');

    % Extract all measurement values for baseline and compute overall mean
    baseValues = tbl{idxBase, measCols};
    overallMean = mean(baseValues(:), 'omitnan');


    % Normalize all rows of this batch:
    dataVals = tbl{idxBatch, measCols};
    normVals = dataVals ./ overallMean .* 100; %Percent of untrained


    % Store normalized values
    tblNorm{idxBatch, measCols} = normVals;
end

% Write out the normalized table
writetable(tblNorm, outputFile);

fprintf('Normalization complete. Output saved to %s\n', outputFile);
end