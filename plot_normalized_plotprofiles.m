function plot_normalized_plotprofiles(normalizedFile, groups, colors)
% plot_normalized_plotprofiles(normalizedFile, groups, colors)
%
% Description:
%   Reads a CSV of normalized positional measurements with metadata,
%   computes the mean and standard error of the mean (SEM) for each
%   measurement column within each specified experimental group, and
%   produces a single plot with mean ± SEM shading for each group.
%
% Inputs:
%   normalizedFile – string; path to the input CSV created by
%                    normalize_to_untrained. Must contain variables
%                    'SubjectID', 'Group', 'IHCMethod', 'Sex', 'Age',
%                    and measurement columns (e.g., Pos1…PosN).
%   groups         – cell array of strings; names of the experimental
%                    groups to include (e.g. {'Untrained','PL-2d','PL-7d'}).
%
%   colors          -M x 3 matrix of RGB color values
%
% Outputs:
%   Tstats         – MATLAB table with row for each group and columns:
%                      Group | Mean_Pos1 | SEM_Pos1 | Mean_Pos2 | SEM_Pos2 | …
%
% Written by ML Caras June 2025

% Read the normalized data
tbl = readtable(normalizedFile);

% Define metadata and measurement columns
metaCols = {'SubjectID','Group','Batch','IHCMethod','Sex','Age','TimePerfused'};
allVars  = tbl.Properties.VariableNames;
measCols = setdiff(allVars, metaCols,'stable'); %don't mess up the order!

% Filter to only the requested groups
isSelGroup = ismember(tbl.Group, groups);
tblFilt = tbl(isSelGroup, :);

% Prepare storage for statistics
nGroups     = numel(groups);
nMeas       = numel(measCols);
meanMatrix  = NaN(nGroups, nMeas);
semMatrix   = NaN(nGroups, nMeas);

% Compute mean and SEM per group
for i = 1:nGroups
    g = groups{i};
    rows = strcmp(tblFilt.Group, g);
    data = tblFilt{rows, measCols};
    meanMatrix(i, :) = mean(data, 1, 'omitnan');
    semMatrix(i, :)  = std(data, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(data),1));
end


% Plot transposed: Position on y, Value on x
fullRange = 1220;                         % cortical depth in µm
y   = 120+linspace(0, fullRange, nMeas);  % adjust for start of L2
figure; hold on;
set(gcf,'color','w')

% Preallocate for line handles
hLines = gobjects(nGroups,1);

for i = 1:nGroups
    x = meanMatrix(i,:);
    e = semMatrix(i,:);
    c = colors(i,:);

    % shade error region
    fill([x+e, fliplr(x-e)], [y, fliplr(y)], c, ...
        'FaceAlpha', 0.2, 'EdgeColor', 'none');

    % plot mean line
    hLines(i) = plot(x, y, 'LineWidth', 2, 'Color', c);
end

% Reverse the y-axis so position 1 is at the top
set(gca, 'YDir', 'reverse','TickDir','out','FontSize',16,'LineWidth',1.5);

ylabel('Cortical depth (um)');
xlabel('Normalized Intensity (%)');
legend(hLines, groups, 'Location','best');

%Save figure
set(gcf,'color','w')
[fpath,fname,~] = fileparts(normalizedFile);
savename = fullfile(fpath,['plot_',fname,'.pdf']);
exportgraphics(gcf, savename, 'ContentType','vector');

end