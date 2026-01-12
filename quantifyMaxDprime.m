function resultTbl = quantifyMaxDprime(summaryFile, sheetName, groupFilter, matFolder, outCSV)
% resultTbl = quantifyMaxDprime(summaryFile, sheetName, groupFilter, matFolder, outCSV)
%
% Description:
%   Reads an excel subject summary file and filters subjects by specified groups.
%   For each filtered subject, loads the corresponding MAT file containing an 'output'
%   struct array and determines the maximum dprime achieved.
%
% Inputs:
%   summaryFile  - String. Path to the Excel file with subject summary.
%   sheetName    - String. Name of the sheet/tab in the excel file to read (e.g. 'IHC').
%   groupFilter  - Cell array of strings. Subject groups to include (e.g. {'PL-2d','PL-7d'}).
%   matFolder    - String. Path to folder containing subject .mat files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   outCSV       - String. Path to file where results table will be saved.
%
% Outputs:
%   resultTbl    - MATLAB table with columns:
%                    • SubjectID            – Subject numeric identifier
%                    • Max dprime           – Maximum dprime achieved
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
maxdprime = nan(nSubjects,1);
finaldprime = nan(nSubjects,1);

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

    % Find max dprime
    maxdp = max(perf);
    if ~isempty(maxdp)
        maxdprime(k) = maxdp;
    end

    % Find final dprime
    finaldp = perf(end);
    if ~isempty(finaldp)
        finaldprime(k) = finaldp;
    end

end

% Build output table
resultTbl = table(subjIDs, groups, maxdprime,finaldprime, ...
    'VariableNames', {'SubjectID','Group','Maxdprime', 'Finaldprime'});

% Write to CSV
writetable(resultTbl, outCSV);
fprintf('Results table saved as CSV: %s\n', outCSV);
end

