function plot_perfusionTimes(normalizedFile, figsavepath, groups, colors)
% Tresults = plot_barandpoint_intensities(normalizedFile, outputFile, groups, colors)
%
% Description:
%   Reads a CSV of normalized data with metadata and  measurement columns,
%   computes per‐subject mean of the TimePerfused column,
%   calculates group means ± SEM, plots a bar graph of group means ± SEM
%   with overlaid transparent circles for individual subjects.
%
% Inputs:
%   normalizedFile – string; path to CSV with normalized data. Must contain
%                    variables 'SubjectID', 'Group', 'IHCMethod', 'Sex',
%                    'Age', and measurement columns (e.g., Pos1…PosN).
%   figsavepath     – string; path where the figure will be saved.
%
%
%   groups         – cell array of strings; names of the experimental
%                    groups to include (e.g. {'Untrained','PL-2d','PL-7d'}).
%
%   colors          -M x 3 matrix of RGB color values
%
% Requirements:
%   • MATLAB R2019b or newer
%   • No additional toolboxes required
%
% Written by ML Caras June 2025
close all;

% Initialize figure
f1 = figure; hold on;
set(gcf,'color','w')


% Read the normalized data
tbl = readtable(normalizedFile);

% Filter to only the requested groups
isSelGroup = ismember(tbl.Group, groups);
tblFilt = tbl(isSelGroup, :);


% Compute group statistics
nGroups     = numel(groups);
groupMeans  = zeros(nGroups,1);
groupSEMs   = zeros(nGroups,1);
for i = 1:nGroups
    idx = strcmp(tblFilt.Group, groups{i});
    vals = tblFilt.TimePerfused(idx);
    groupMeans(i) = mean(vals, 'omitnan');
    groupSEMs(i)  = std(vals, 'omitnan') / sqrt(sum(~isnan(vals)));
end


% Bar graph
b = barh(1:nGroups, groupMeans, 'FaceColor','flat','FaceAlpha', 0.3);
b.CData = colors;
hold on

% SEM error bars, in matching color lines
cx = 1:nGroups;
for k = 1:nGroups
    he = herrorbar(groupMeans(k),cx(k),groupSEMs(k));
    set(he(1),'Color',colors(k,:));
    set(he(1),'LineWidth',1.5)
end

% Overlay individual subject data
for i = 1:nGroups
    idx = strcmp(tblFilt.Group, groups{i});
    y = repmat(i, sum(idx), 1);
    x = tblFilt.TimePerfused(idx);

    %add x axis jitter
    rng('default'); %reproducibility
    jit = 0.2;
    y = y + (rand(size(x))-0.5)*jit;


    scatter(x, y, 36, 'filled', ...
        'MarkerFaceColor', colors(i,:), ...
        'MarkerEdgeColor','none', ...
        'MarkerFaceAlpha',0.2);
end

% Formatting
myformat
set(gca,'YTick',1:6)
set(gca,'YTickLabel',groups);
xlabel('Hours')
title('Perfusion Time')




%Save figure
exportgraphics(gcf, figsavepath, 'ContentType','vector');


end

