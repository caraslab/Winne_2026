function plotLearningTrajectories(summaryFile, sheetName, groupFilter, matFolder, colors, figsavepath, outCSV)
% plotLearningTrajectories(summaryFile, sheetName, groupFilter, matFolder, colors, figsavepath, outCSV)
%
% Description:
%   Reads an Excel subject summary file and filters subjects by specified groups.
%   For each subject in each group, loads the corresponding MAT file containing an
%   'output' struct array, extracts out(i).fitdata.threshold for each session, and
%   plots threshold trajectories across training day for individual subjects. Saves
%   the figure as a vectorized PDF and writes the subject-by-day threshold table to CSV.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   groupFilter  - Cell array of strings. Groups to include, in desired plot order.
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   colors       - Matrix of RGB color values (nGroups × 3).
%   figsavepath  - String. Path where figure will be saved.
%   outCSV       - String. Path where output table will be saved as a CSV.
%
%   Written by ML Caras Aug 2025

% Read summary and filter subjects
opts     = detectImportOptions(summaryFile, 'Sheet', sheetName);
summary  = readtable(summaryFile, opts);
mask     = ismember(summary.Group, groupFilter);
subjects = summary.SubjectID(mask);
groups   = summary.Group(mask);
ugroups = unique(groups);

%Initialize figure
figure;

subs = [];
days = [];
thrsh = [];

% Loop through each subject
for i = 1:numel(subjects)
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

    %Preallocate
    threshvec = nan(numel(out),1);

    % Extract thresholds
    for k = 1:numel(out)
        threshvec(k) = out(k).fitdata.threshold;
    end


    % Plot the trajectory
    x = [1:numel(out)]';
    y = threshvec;

    %Pick the right color
    grp = groups(i);
    [~, idx] = ismember(grp, ugroups);
    clr = colors(idx,:);

    plot(x,y,'s-','linewidth',2,'Markersize', 12, 'MarkerFaceColor',clr,'Color',clr);

    hold on

    % Save the trajectory
    s = repmat(subjID,numel(x),1);

    subs = [subs;s];
    days = [days;x];
    thrsh = [thrsh;y];

end

%Format the plot
xlabel('Adaptive training day')
ylabel('Threshold (dB)')
myformat
set(gca,'xscale','log','XMinorTick','off')
xlim = [0.9 7.1];
set(gca,'xlim',xlim)

%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'ThresholdByDay.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');

%Generate table
resultTbl = table(subs, days, thrsh, ...
    'VariableNames', {'SubjectID','Day','Threshold'});

% Write to CSV
writetable(resultTbl, outCSV);
fprintf('Results table saved as CSV: %s\n', outCSV);

end