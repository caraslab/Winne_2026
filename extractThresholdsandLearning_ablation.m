function resultTbl = extractThresholdsandLearning_ablation(summaryFile, sheetName, matFolder, outCSV, ndays)
% extractThresholdsandLearning_ablation(summaryFile, sheetName, matFolder, outCSV, ndays)
%
% Description:
%   Reads an Excel subject summary file. For each subject, loads the corresponding
%   MAT file containing an 'output' struct array and extracts out(i).fitdata.threshold
%   for the first ndays sessions. Computes percent improvement from Day1 to DayN and
%   computes learning rate as the slope (dB/log(day)) from a linear regression of
%   threshold versus log10(day). Compiles thresholds and subject metadata into a
%   table and writes the result to CSV.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   outCSV       - String. Path where output table will be saved as a CSV.
%   ndays        - Numeric scalar. Number of training days/sessions to extract.
%
% Outputs:
%   resultTbl    - Table containing SubjectID, Treatment, Sex, Age, AreaWFA,
%                 Improvement, LearningRate, and Threshold Day1..DayN.
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


thresholds = nan(n,ndays);
improvement = nan(n,1);
learningrate = nan(n,1);


% Loop through each subject
for i = 1:n
    subjID = summary.SubjectID(i);
    threshs = nan(1,8);

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
    if numel(out) <ndays
        warning('Not enough sessions for %s', fname);
    end

    %Extract thresholds and append to matrix
    for j = 1:ndays
        threshs(j) = out(j).fitdata.threshold;
    end

    thresholds(i,:) = threshs;

    %Calculate final improvement
    improvement(i) = 100*(threshs(ndays) - threshs(1))/threshs(1);

    if numel(out) < ndays
        slope = NaN;
    else
        %Calculate learning rate (slope in dB/log(day))
        x = 1:ndays;
        xlog = log10(x);

        %Calculate the regression line
        p = polyfit(xlog,threshs,1);
        yfit = polyval(p,xlog);
        slope = p(1);

        % %Plot to verify
        % plot(xlog,threshs,'s','Markersize', 12);
        % hold on
        % %Plot the regression line
        % plot(xlog,yfit,'k-','linewidth',2);
    end

    learningrate(i) = slope;

    subjects{i} = num2str(subjID);
    treatments{i} = summary.Treatment{i};
    sexes{i} = summary.Sex{i};
    ages{i} = num2str(summary.Age(i));
    areaWFA{i} = num2str(summary.AreaWFA(i));

end

% Build report table
metaTbl = table(subjects, treatments, sexes, ages, areaWFA, improvement, learningrate,...
    'VariableNames', {'SubjectID','Treatment','Sex','Age','AreaWFA','Improvement','LearningRate'});

sessNames = compose("Threshold Day%d", 1:ndays);  % creates ["Session1",…,"Session8"]
dataTbl   = array2table(thresholds, 'VariableNames', sessNames);

resultTbl = [metaTbl dataTbl];

% Write to CSV
writetable(resultTbl, outCSV);
fprintf('Threshold report saved to %s\n', outCSV);
end