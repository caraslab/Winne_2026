function tblNorm = normalize_to_untrained_bydepth_bybatch(originalFile, outputFile)
% normalize_to_untrained_bydepth_bybatch(originalFile, outputFile)
%
% Description:
%   Reads a CSV of depth-wise positional measurements with metadata and normalizes
%   measurement values to the Untrained baseline within each IHC batch. For each
%   batch grouping (Batch 1; Batches 2–4; Batch 5), computes the mean Untrained
%   value for each measurement column (Pos1..PosN) across subjects, then expresses
%   all values in that batch as percent of the corresponding Untrained mean.
%   Writes the normalized table to a new CSV.
%
% Inputs:
%   originalFile  - String. Path to the input CSV. Must contain metadata variables
%                  'SubjectID', 'Group', 'Batch', 'IHCMethod', 'Sex', 'Age',
%                  'TimePerfused', and measurement columns (e.g. Pos1..PosN).
%   outputFile    - String. Path where normalized CSV will be saved.
%
% Outputs:
%   tblNorm       - Table containing normalized measurement values with the same
%                  variables and row order as the input.
%
%   Written by ML Caras Jun 2025

% Read in the original data
tbl = readtable(originalFile);

% Define metadata columns
metaCols = {'SubjectID','Group','Batch','IHCMethod','Sex','Age','TimePerfused'};

% Identify measurement columns
allVars = tbl.Properties.VariableNames;
measCols = setdiff(allVars, metaCols,'stable');

% Initialize output table
tblNorm = tbl;

% Compute and apply normalization per Batch

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
    meanVec = mean(baseValues, 1,'omitnan');

    % Normalize all rows of this method:
    dataVals = tbl{idxBatch, measCols};
    normVals = (dataVals./meanVec)*100; %Percent of untrained


    % Store normalized values
    tblNorm{idxBatch, measCols} = normVals;
end

% 6. Write out the normalized table
writetable(tblNorm, outputFile);

fprintf('Normalization complete. Output saved to %s\n', outputFile);
end