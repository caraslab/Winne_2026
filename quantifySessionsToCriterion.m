function resultTbl = quantifySessionsToCriterion(summaryFile, sheetName, groupFilter, matFolder, outCSV, criterion)
% resultTbl = quantifySessionsToCriterion(summaryFile, sheetName, groupFilter, matFolder, outCSV, criterion)
%
% Description:
%   Reads an Excel subject summary file and filters subjects by specified groups.
%   For each subject in each group, loads the corresponding MAT file containing an
%   'output' struct array, and computes the number of sessions required for the performance metric
%   to reach or exceed a specified criterion. If the threshold is never met, NaN is recorded.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   groupFilter  - Cell array of strings. Groups to include, in desired plot order.
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   outCSV       - String. Path where output datatable will be saved.
%   criterion    - Numeric scalar. Performance threshold (e.g. 2 for d').
%
%
% Outputs:
%   resultTbl    - MATLAB table with columns:
%                    • SubjectID            – Subject numeric identifier
%                    • SessionsToThreshold  – Number of sessions to reach/exceed threshold (NaN if not reached)
%                    • AchievedThreshold    – Logical indicating if threshold was reached
%
% Written by ML Caras Aug 2025


% Read subject summary and filter by group
opts = detectImportOptions(summaryFile, 'Sheet', sheetName);
subjTbl = readtable(summaryFile, opts);
isTarget = ismember(subjTbl.Group, groupFilter);
subjIDs  = subjTbl.SubjectID(isTarget);
groups = subjTbl.Group(isTarget);

% Prepare result arrays
nSubjects = numel(subjIDs);
sessionsReq = nan(nSubjects,1);
achieved = false(nSubjects,1);

% Loop through each subject
for k = 1:nSubjects
    id = subjIDs(k);
    fullID = sprintf('SUBJ-ID-%d_allSessions.mat', id);
    filePath = fullfile(matFolder, fullID);
    if ~isfile(filePath)
        warning('File not found: %s', filePath);
        continue;
    end
    data = load(filePath, 'output');
    if ~isfield(data, 'output')
        warning('No ''output'' struct in %s', filePath);
        continue;
    end
    outStruct = data.output;

    % Extract second element of dprimemat for each session
    nSess = numel(outStruct);
    perf = nan(nSess,1);
    for i = 1:nSess
        dp = outStruct(i).dprimemat;
        if numel(dp) >= 2 && isnumeric(dp(2))
            perf(i) = dp(2);
        else
            perf(i) = NaN;
        end
    end

    % Find first session meeting threshold
    idx = find(perf >= criterion, 1, 'first');
    if ~isempty(idx)
        sessionsReq(k) = idx;
        achieved(k) = true;
    end
end

% Build output table
resultTbl = table(subjIDs, groups, sessionsReq, achieved, ...
    'VariableNames', {'SubjectID','Group','SessionsToCriterion','AchievedCriterion'});

% Write to CSV
writetable(resultTbl, outCSV);
fprintf('Results table saved as CSV: %s\n', outCSV);
end

% Helper validators
function mustBeFolder(folder)
if ~isfolder(folder)
    error('"%s" is not a valid folder.', folder);
end
end
