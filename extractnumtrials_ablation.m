function resultTbl = extractnumtrials_ablation(summaryFile, sheetName, matFolder, outCSV, ndays)
% extractnumtrials_ablation(summaryFile, sheetName, matFolder, outCSV, ndays)
%
% Description:
%   Reads an Excel subject summary file. For each subject, loads the corresponding
%   MAT file containing a 'Session' struct array and extracts the total number of
%   trials completed per day (numel(sess(j).Data)) for the first ndays sessions.
%   Compiles trial counts and subject metadata into a table and writes the result
%   to CSV.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   outCSV       - String. Path where output table will be saved as a CSV.
%   ndays        - Numeric scalar. Number of training days/sessions to extract.
%
% Outputs:
%   resultTbl    - Table containing SubjectID, Treatment, Sex, Age, AreaWFA, and
%                 daily trial counts (Num Trials Day1..DayN).
%
%   Written by ML Caras Aug 2025

% Read summary and filter subjects
opts     = detectImportOptions(summaryFile, 'Sheet', sheetName);
opts.VariableNamingRule = 'preserve';
summary  = readtable(summaryFile, opts);

% Preallocate arrays
n  = numel(summary.SubjectID);

subjects = cell(n,1);
treatments = cell(n,1);
sexes = cell(n,1);
ages = cell(n,1);
areaWFA = cell(n,1);


numtrials = nan(n,ndays);

% Loop through each subject
for i = 1:n
    subjID = summary.SubjectID(i);
    subjtrials = nan(1,8);

    % Construct filename
    fname = sprintf('SUBJ-ID-%d_allSessions.mat', subjID);
    fpath = fullfile(matFolder, fname);
    if ~isfile(fpath)
        warning('File not found: %s', fpath);
        continue;
    end
    data = load(fpath, 'Session');
    sess = data.Session;
    if isempty(sess)
        warning('Empty output for %s', fname);
        continue;
    end

    %Check for the correct number of sessions
    if numel(sess) <ndays
        warning('Not enough sessions for %s', fname);
    end

    %For each session, calculate the total number of trials completed
     
    for j = 1:ndays

        %Extract number of trials
        subjtrials(j) = numel(sess(j).Data);
    end

    %Append to larger array
    numtrials(i,:) = subjtrials;

    subjects{i} = num2str(subjID);
    treatments{i} = summary.Treatment{i};
    sexes{i} = summary.Sex{i};
    ages{i} = num2str(summary.Age(i));
    areaWFA{i} = num2str(summary.AreaWFA(i));

end

% Build report table
metaTbl = table(subjects, treatments, sexes, ages, areaWFA,...
    'VariableNames', {'SubjectID','Treatment','Sex','Age','AreaWFA'});

sessNames = compose("Num Trials Day%d", 1:ndays);  
dataTbl   = array2table(numtrials, 'VariableNames', sessNames);

resultTbl = [metaTbl dataTbl];

% Write to CSV
writetable(resultTbl, outCSV);
fprintf('Num trials report saved to %s\n', outCSV);
end