function exportTbl = plotDprimeByTrial(summaryFile, sheetName, groupFilter, matFolder, colors, figsavepath, outCSV, windowsize)
% exportTbl = plotDprimeByTrial(summaryFile, sheetName, groupFilter, matFolder, colors, figsavepath, outCSV, windowsize)
%
% Description:
%   Reads an Excel subject-summary file and filters subjects by the specified
%   groups. For each subject it loads the corresponding MAT file, 
%   computes d′ using a moving window across concatenated sessions 
%   and exports results. It also plots mean and sem+/- d' across the moving 
%   windows for each experimental group.
%
% Inputs:
%   summaryFile  - String. Path to the subject summary Excel file.
%   sheetName    - String. Sheet name in summaryFile (e.g. 'IHC').
%   groupFilter  - Cell array of strings. Groups to include, in desired plot order.
%   matFolder    - String. Folder containing MAT files named 'SUBJ-ID-<ID>_allSessions.mat'.
%   colors       - Matrix of RGB color values
%   figsavepath  - String. Path where figure will be saved.
%   outCSV       - String. Path where output datatable will be saved.
%   windowsize    — positive integer. Number of trials per sliding window.

% Output:
%   exportTbl     — MATLAB table with variables:
%                     • SubjectID       – subject numeric ID
%                     • Group           – group label
%                     • Window1,…,WindowN – d′ values for each window
%
% Written by ML Caras Aug 2025



% Read subject summary and filter groups
opts    = detectImportOptions(summaryFile, 'Sheet', sheetName);
subjTbl = readtable(summaryFile, opts);

% Use the provided order for groups
groups  = groupFilter;
nGroups = numel(groups);

% Container for each group
perfByGroup = cell(nGroups,1);

% For each group...
for i = 1:nGroups

    %Pull out subjects belonging to that group
    grp      = groups{i};
    mask     = ismember(subjTbl.Group, grp);
    subjIDs  = subjTbl.SubjectID(mask);
    nSubj    = numel(subjIDs);
   

    %Collect d' vectors for this group
    perfList = cell(nSubj,1); %Initiate cell array

    %For each subject
    for j = 1:nSubj
        id       = subjIDs(j);
        matName  = sprintf('SUBJ-ID-%d_allSessions.mat', id);
        matPath  = fullfile(matFolder, matName);
        if ~isfile(matPath)
            warning('File not found: %s', matPath);
            continue;
        end
        
        %Load the session data
        data     = load(matPath, 'Session');
        if ~isfield(data, 'Session')
            warning('No ''Session'' in %s', matPath);
            continue;
        end

        %Calculate dprime along a sliding window
        dpvec = slidingdprime(data.Session,windowsize);
        perfList{j} = dpvec'; %transpose
    end

    % Determine max length of dprime vector across subjects
    maxLen = max(cellfun(@length, perfList));

    % Create a data matrix 
    M = nan(numel(perfList), maxLen);

    for j = 1:numel(perfList)
        len = numel(perfList{j});
        M(j,1:len) = perfList{j};
    end

    %Append matrix to group cell
    perfByGroup{i} = M;
end


%Calculate mean and SEM dprime vectors for each group
maxwindows = max(cellfun(@(M) size(M,2), perfByGroup));
means = nan(nGroups, maxwindows);
sems  = nan(nGroups, maxwindows);

for i = 1:nGroups
    M = perfByGroup{i};
    % Mean ignoring NaNs
    means(i,1:size(M,2)) = nanmean(M,1);
    % SEM: std/sqrt(n)
    sems(i,1:size(M,2))  = nanstd(M,0,1) ./ sqrt(sum(~isnan(M),1));
end



%Plot mean ± SEM for each group
figure;
hold on;

[~,c] = find(isnan(means),1,'first');
xlim = c-1;
x = 1:xlim;

handles = [];

for i = 1:nGroups
    he(i) = shadedErrorBar(x, means(i,1:xlim), sems(i,1:xlim),'-',1);
    he(i).mainLine.Color = colors(i,:);
    he(i).mainLine.LineWidth = 2;
    he(i).patch.FaceColor = colors(i,:);
    he(i).edge(1).Color = colors(i,:);
    he(i).edge(2).Color = colors(i,:);

    handles = [handles,he(i).mainLine];
end

hold off;

%format plot
xlabel('Go Trial Number');
ylabel('d''');
l = legend(handles,groups);
set(l,'Location','best')
myformat

%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'dprime-by-trial.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');



% Compile and export data

% Reconstruct subject IDs per group
subjIDsByGroup = cell(nGroups,1);
for i = 1:nGroups
    mask  = ismember(subjTbl.Group, groups{i});
    subjIDsByGroup{i}   = subjTbl.SubjectID(mask);
end

%Pre-allocate
maxwindows = size(means,2);
nRows       = sum(cellfun(@numel, subjIDsByGroup));
subjectList = nan(nRows,1);
groupList   = cell(nRows,1);
dprimeAll   = nan(nRows, maxwindows);

%Fill row-by-row
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
for s = 1:maxwindows
    exportTbl.(sprintf('Window%d',s)) = dprimeAll(:,s);
end

% 5) Write to CSV
writetable(exportTbl, outCSV);
fprintf('Exported per-subject d'' data to %s\n', outCSV);








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculate dprime using a sliding window
function dprimevec = slidingdprime(Session,windowsize)
%Concatenate data across session into one long vector
ttvec =[];
hitvec = [];
favec = [];

for i = 1:numel(Session)

    %Pull out data
    ttype = [Session(i).Data(:).TrialType]';
    resps = [Session(i).Data(:).ResponseCode]';

    %Decode responses
    fabit = Session(i).Info.Bits.fa;
    hitbit = Session(i).Info.Bits.hit;

    hits = bitget(resps,hitbit);
    fas = bitget(resps,fabit);

    ttvec = [ttvec;ttype]; %0 = GO, %1 = NOGO
    hitvec = [hitvec;hits];
    favec= [favec;fas];
end

% Calculate d' using a sliding window
hitratevec = [];
faratevec = [];
dprimevec = [];

steps = find(ttvec == 0);

for i = 1:numel(steps)
    if steps(i) <= length(ttvec) - windowsize

        idx = steps(i):steps(i)+windowsize-1;
    else
        break
    end

    window_tts = ttvec(idx);
    window_hits = hitvec(idx);
    window_fas = favec(idx);

    n_go = numel(window_tts(window_tts == 0));
    n_nogo = numel(window_tts(window_tts == 1));

    n_hits = sum(window_hits);
    n_fas = sum(window_fas);

    hitrate = n_hits/n_go;
    farate = n_fas/n_nogo;

    %Adjust to avoid infinite values
    if hitrate > 0.95
        hitrate = 0.95;
    end

    if hitrate < 0.05
        hitrate = 0.05;
    end

    if farate > 0.95
        farate = 0.95;
    end

    if farate < 0.05
        farate = 0.05;
    end

    z_hit = norminv(hitrate);
    z_fa = norminv(farate);
    dprime = z_hit-z_fa;

    hitratevec = [hitratevec;hitrate];
    faratevec = [faratevec;farate];
    dprimevec = [dprimevec;dprime];

end

