function plotDprimeBySession(summaryFile, sheetName, groupFilter, matFolder,colors,figsavepath, outCSV)
% plotDprimeBySession(summaryFile, sheetName, groupFilter, matFolder,colors,figsavepath, outCSV)
%
% Description:
%   Reads an Excel subject summary file and filters subjects by specified groups.
%   For each subject in each group, loads the corresponding MAT file containing an
%   'output' struct array, and computes the mean ± SEM d' value across
%   subjects for each session. Plots all groups on the same axes.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   groupFilter  - Cell array of strings. Groups to include, in desired plot order.
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   colors       - Matrix of RGB color values
%   figsavepath  - String. Path where figure will be saved.
%   outCSV       - String. Path where output datatable will be saved.
%
%   Written by ML Caras Aug 2025

% Read subject summary and filter groups
opts    = detectImportOptions(summaryFile, 'Sheet', sheetName);
subjTbl = readtable(summaryFile, opts);

% Use the provided order for groups
groups  = groupFilter;
nGroups = numel(groups);
% Container for each group's performance matrix
perfByGroup = cell(nGroups,1);

for i = 1:nGroups
    grp      = groups{i};
    mask     = ismember(subjTbl.Group, grp);
    subjIDs  = subjTbl.SubjectID(mask);
    nSubj    = numel(subjIDs);
    % Collect d' vectors for this group
    perfList = cell(nSubj,1);

    for j = 1:nSubj
        id       = subjIDs(j);
        matName  = sprintf('SUBJ-ID-%d_allSessions.mat', id);
        matPath  = fullfile(matFolder, matName);
        if ~isfile(matPath)
            warning('File not found: %s', matPath);
            continue;
        end
        data     = load(matPath, 'output');
        if ~isfield(data, 'output')
            warning('No ''output'' in %s', matPath);
            continue;
        end
        outStruct = data.output;
        nSess     = numel(outStruct);
        dp        = nan(nSess,1);
        % Extract the second element of dprimemat
        for k = 1:nSess
            vec = outStruct(k).dprimemat;
            dp(k) = vec(2);
        end
        perfList{j} = dp;
    end

    % Determine max sessions across subjects
    maxSess = max(cellfun(@numel, perfList));
    M = nan(numel(perfList), maxSess);
    for j = 1:numel(perfList)
        len = numel(perfList{j});
        M(j,1:len) = perfList{j};
    end
    perfByGroup{i} = M;
end

% Compute mean and SEM per session for each group
maxSessions = max(cellfun(@(M) size(M,2), perfByGroup));
means = nan(nGroups, maxSessions);
sems  = nan(nGroups, maxSessions);
for i = 1:nGroups
    M = perfByGroup{i};
    % Mean ignoring NaNs
    means(i,1:size(M,2)) = nanmean(M,1);
    % SEM: std/sqrt(n)
    sems(i,1:size(M,2))  = nanstd(M,0,1) ./ sqrt(sum(~isnan(M),1));
end

sessions = 1:maxSessions;

% Plot mean ± SEM with squares and lines for each group
figure;
hold on;
for i = 1:nGroups
    he(i) = errorbar(sessions, means(i,:), sems(i,:),...
        's-', 'MarkerSize', 9,...
        'MarkerFaceColor', colors(i,:), ...
        'MarkerEdgeColor','none', ...
        'LineWidth',2,...
        'Color',colors (i,:),'CapSize',0);
    set(he(i),'DisplayName',groups{i});
end
hold off;

% Format plot
xlabel('Instrumental Training Day');
ylabel('d''');
legend('Location','best');
myformat
set(gca,'xlim',[0.5 5]);
set(gca,'xtick',[1:5]);
set(gca,'ytick',[0:3])

%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'dprime-by-session.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');


% Compile and export data

% Reconstruct subject IDs per group
subjIDsByGroup = cell(nGroups,1);
for i = 1:nGroups
    mask  = ismember(subjTbl.Group, groups{i});
    subjIDsByGroup{i}   = subjTbl.SubjectID(mask);
end

% Pre-allocate
maxSessions = size(means,2);
nRows       = sum(cellfun(@numel, subjIDsByGroup));
subjectList = nan(nRows,1);
groupList   = cell(nRows,1);
dprimeAll   = nan(nRows, maxSessions);

% Fill row-by-row
row = 1;
for i = 1:nGroups
    ids = subjIDsByGroup{i};
    M   = perfByGroup{i};
    for j = 1:numel(ids)
        subjectList(row)          = ids(j);
        groupList{row}            = groups{i};
        dprimeAll(row,1:size(M,2)) = M(j,:);
        row = row + 1;
    end
end

% Build export table
exportTbl = table(subjectList, groupList, ...
    'VariableNames', {'SubjectID','Group'});
for s = 1:maxSessions
    exportTbl.(sprintf('Session%d',s)) = dprimeAll(:,s);
end

% Write to CSV
writetable(exportTbl, outCSV);
fprintf('Exported per-subject d'' data to %s\n', outCSV);

end