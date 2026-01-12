function resultTbl = extractFARates_ablation(summaryFile, sheetName, matFolder, outCSV, ndays)
% extractFARates_ablation(summaryFile, sheetName, matFolder, outCSV, ndays)
%
% Description:
%   Reads an Excel subject summary file. For each subject, loads the corresponding
%   MAT file containing a 'Session' struct array and computes the daily false alarm
%   (FA) rate from raw trial data (nogo trials; ResponseCode bit indicated by
%   sess(j).Info.Bits.fa). Compiles FA rates and subject metadata into a table and
%   writes the result to CSV.
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
%                 daily FA rates (FArate Day1..DayN).
%
%   Written by ML Caras Aug 2025

% Read summary and filter subjects
opts     = detectImportOptions(summaryFile, 'Sheet', sheetName);
summary  = readtable(summaryFile, opts);

% Preallocate arrays
n  = numel(summary.SubjectID);

subjects = cell(n,1);
treatments = cell(n,1);
sexes = cell(n,1);
ages = cell(n,1);
areaWFA = cell(n,1);


farates = nan(n,ndays);



% Loop through each subject
for i = 1:n
    subjID = summary.SubjectID(i);
    subjfas = nan(1,8);

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

    %For each session, calculate the FA rate. Note: We don't use the values
    %in the output structure here for this calculation because those values
    %have already been adjusted to avoid -Inf/Inf d' values. Instead, we
    %calculate the true FA rate from the original raw data here.
    for j = 1:ndays

        %Extract trial type and response codes
        ttype = [sess(j).Data(:).TrialType]';
        resps = [sess(j).Data(:).ResponseCode]';

        %Isolate nogo trials and corresponding responses
        idx = find(ttype == 1);
        ttype = ttype(idx);
        resps = resps(idx);

        %Find FAs
        fabit = sess(j).Info.Bits.fa;
        nfas = sum(bitget(resps,fabit));
        nNOGO = numel(ttype);

        %Calculate FA rate (percent)
        subjfas(j) = 100*(nfas/nNOGO);
    end

    %Append to larger array
    farates(i,:) = subjfas;

    subjects{i} = num2str(subjID);
    treatments{i} = summary.Treatment{i};
    sexes{i} = summary.Sex{i};
    ages{i} = num2str(summary.Age(i));
    areaWFA{i} = num2str(summary.AreaWFA(i));

end

% Build report table
metaTbl = table(subjects, treatments, sexes, ages, areaWFA,...
    'VariableNames', {'SubjectID','Treatment','Sex','Age','AreaWFA'});

sessNames = compose("FArate Day%d", 1:ndays);  % creates ["FArate Day1",…,"FArate Day8"]
dataTbl   = array2table(farates, 'VariableNames', sessNames);

resultTbl = [metaTbl dataTbl];

% Write to CSV
writetable(resultTbl, outCSV);
fprintf('FA report saved to %s\n', outCSV);
end