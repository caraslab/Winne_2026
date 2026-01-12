function aggregate_plotprofiles(dataDir, savename)
% aggregate_plotprofiles(dataDir, savename)
%
% Description:
%   Loops over all CSV files in a directory and computes the row-wise mean
%   intensity across columns for each file (i.e., average across hemisphere/slice
%   combinations). Aggregates these row-means into a single table with one row per
%   subject and one column per row position (Pos1..PosN). Saves the aggregated table
%   as a CSV.
%
% Inputs:
%   dataDir    - String. Path to folder containing subject CSV files.
%   savename   - String. Full path/filename for the output aggregated CSV.
%
% Outputs:
%   T          - Table with variables:
%                SubjectID  - String subject identifier parsed from filename.
%                Pos1..PosN - Row-wise mean intensities (one column per position).
%
%   Written by ML Caras Jun 2025

    files = dir(fullfile(dataDir, '*.csv'));
    if isempty(files)
        error('No CSV files found in %s', dataDir);
    end

    nFiles = numel(files);
    rowMeans = cell(nFiles,1);
    subjIDs  = strings(nFiles,1);
    maxLen    = 0;

    % First pass: read and compute row-wise means
    for i = 1:nFiles
        fname = files(i).name;
        % extract subject ID robustly from filename
        tok = regexp(fname, '(?<=_)\d+(?=\.csv$)', 'match', 'once');
        if isempty(tok)
            subjIDs(i) = erase(fname, '.csv');
        else
            subjIDs(i) = tok;
        end

        T0 = readtable(fullfile(dataDir, fname));
        M0 = table2array(T0);
        m   = mean(M0, 2, 'omitnan');  % row-wise mean across columns
        m = m(~isnan(m));
        rowMeans{i} = m;
        maxLen = max(maxLen, numel(m));
    end

    % Preallocate matrix for aggregated means
    mat = nan(nFiles, maxLen);
    for i = 1:nFiles
        m = rowMeans{i};
        mat(i,1:numel(m)) = m(:)';
    end

    % Build table with dynamic position column names
    varNames = arrayfun(@(k) sprintf('Pos%d', k), 1:maxLen, 'UniformOutput', false);
    T = array2table(mat, 'VariableNames', varNames);
    T = addvars(T, subjIDs, 'Before', 1, 'NewVariableNames', 'SubjectID');

    % Write to CSV
    writetable(T, savename);
    fprintf('Aggregated data saved to %s\n', savename);
end