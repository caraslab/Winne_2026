function resultTbl = extractThresholdsandLearning(summaryFile, sheetName, groupFilter, matFolder, outCSV)
% extractThresholdsandLearning(summaryFile, sheetName, groupFilter, matFolder, outCSV)
%
% Description:
%   Reads an Excel subject summary file and filters subjects by specified groups.
%   For each subject in each group, loads the corresponding MAT file containing an
%   'output' struct array, and extracts the starting threshold (first session) and
%   final threshold (last session) from out(i).fitdata.threshold. Computes percent
%   improvement relative to the starting threshold, compiles results into a table,
%   and writes the table to CSV.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   groupFilter  - Cell array of strings. Groups to include, in desired order.
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   outCSV       - String. Path where output table will be saved as a CSV.
%
% Outputs:
%   resultTbl    - Table containing SubjectID, Group, StartThresh, EndThresh, and Improvement.
%
%   Written by ML Caras Aug 2025


% Read summary and filter subjects
opts     = detectImportOptions(summaryFile, 'Sheet', sheetName);
summary  = readtable(summaryFile, opts);
mask     = ismember(summary.Group, groupFilter);
subjects = summary.SubjectID(mask);
groups   = summary.Group(mask);

% Preallocate arrays
n    = numel(subjects);
startThresh = nan(n,1);
endThresh   = nan(n,1);
improvement = nan(n,1);

% Loop through each subject
for i = 1:n
    subjID = subjects(i);

    % Construct filename
    fname = sprintf('SUBJ-ID-%d_allSessions.mat', subjID);
    fpath = fullfile(matFolder, fname);
    if ~isfile(fpath)
        warning('File not found: %s', fpath);
        continue;
    end
    data = load(fpath, 'output');
    if ~isfield(data, 'output')
        warning('No ''output'' struct in %s', fname);
        continue;
    end
    out = data.output;
    if isempty(out)
        warning('Empty output for %s', fname);
        continue;
    end

    %Check for the correct number of sessions
    if numel(out) ~=2 && numel(out) ~=7
        warning('Invalid number of sessions for %s', fname);
    end

    % Extract  first threshold
    startThresh(i) = out(1).fitdata.threshold;

    % Extract final threshold
    endThresh(i)   = out(end).fitdata.threshold;
    improvement(i) = 100*(endThresh(i) - startThresh(i))/startThresh(i);

end

% Build report table
resultTbl = table(subjects, groups, startThresh, endThresh, improvement, ...
    'VariableNames', {'SubjectID','Group','StartThresh','EndThresh','Improvement'});


% Write to CSV
writetable(resultTbl, outCSV);
fprintf('Threshold report saved to %s\n', outCSV);
end