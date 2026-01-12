function resultTbl = extractFARates_IHC(summaryFile, sheetName, matFolder, outCSV, ndays, groupFilter)
% extractFARates_IHC(summaryFile, sheetName, matFolder, outCSV, ndays, groupFilter)
%
% Description:
%   Reads an Excel subject summary file and filters subjects by specified groups.
%   For each subject, loads the corresponding MAT file containing a 'Session' struct
%   array and computes the daily false alarm (FA) rate from raw trial data
%   (nogo trials; ResponseCode bit indicated by sess(j).Info.Bits.fa). Compiles
%   subject metadata and FA rates across days into a table, computes mean FA across
%   days, and writes the table to CSV.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   outCSV       - String. Path where output table will be saved as a CSV.
%   ndays        - Numeric scalar. Number of training days/sessions to extract.
%   groupFilter  - Cell array of strings. Groups to include, in desired order.
%
% Outputs:
%   resultTbl    - Table containing SubjectID, Sex, Age, daily FA rates (Day1..DayN),
%                 and meanFA (mean across days).
%
%   Written by ML Caras Aug 2025

% Read summary and filter subjects
opts     = detectImportOptions(summaryFile, 'Sheet', sheetName);
summary  = readtable(summaryFile, opts);
mask     = ismember(summary.Group, groupFilter);
subs = summary.SubjectID(mask);

% Preallocate arrays
n  = numel(subs);

subjects = cell(n,1);
sexes = cell(n,1);
ages = cell(n,1);

farates = nan(n,ndays);


% Loop through each subject
for i = 1:n
    subjID = subs(i);
    subjfas = nan(1,ndays);

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

    %For each session, calculate the FA rate. Note: We don't use the values
    %in the output structure here for this calculation because those values
    %have already been adjusted to avoid -Inf/Inf d' values. Instead, we
    %calculate the true FA rate from the original raw data here.

    if numel(sess) >= ndays
        target = ndays;
    elseif numel(sess) < ndays
        target = numel(sess);
    end

    for j = 1:target

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
    try
    farates(i,:) = subjfas;
    catch
        error
    end

    subjects{i} = num2str(subjID);
    sexes{i} = summary.Sex{i};
    ages{i} = num2str(summary.Age(i));

end

meanFA =  mean(farates,2,'omitnan');

% Build report table
metaTbl = table(subjects, sexes, ages,...
    'VariableNames', {'SubjectID','Sex','Age'});

sessNames = compose("FArate Day%d", 1:ndays);  % creates ["FArate Day1",…,"FArate Day8"]
dataTbl   = array2table(farates, 'VariableNames', sessNames);

resultTbl = [metaTbl dataTbl];
resultTbl.meanFA = meanFA;

% Write to CSV
writetable(resultTbl, outCSV);
fprintf('FA report saved to %s\n', outCSV);
end