function plot_barandpoint_intensities(normalizedFile, outputFile, colArray, groups, colors, ttext)
% Tresults = plot_barandpoint_intensities(normalizedFile, outputFile, colRange, groups, colors)
%
% Description:
%   Reads a CSV of normalized data with metadata and  measurement columns,
%   computes per‐subject mean across a specified range of measurement columns,
%   calculates group means ± SEM, plots a bar graph of group means ± SEM
%   with overlaid transparent circles for individual subjects, and
%   writes an output CSV preserving metadata plus the subject mean column.
%
% Inputs:
%   normalizedFile – string; path to CSV with normalized data. Must contain
%                    variables 'SubjectID', 'Group', 'IHCMethod', 'Sex',
%                    'Age', and measurement columns (e.g., Pos1…PosN).
%   outputFile     – string; path where the output CSV will be written.
%
%   colArray       – cell array of 1 x 2 vectors containing the range of
%                    columns to average together. Arranged as 
%                   [startIdx, endIdx]. The different ranges correspond to 
%                   different cortical layers.
%
%   groups         – cell array of strings; names of the experimental
%                    groups to include (e.g. {'Untrained','PL-2d','PL-7d'}).
%
%   colors          -M x 3 matrix of RGB color values
%
%   ttext           -String. Title for plot.
%
% Outputs:
%   Tresults       – MATLAB table with original metadata and added column
%                    'MeanIntensity' (subject‐specific mean over specified range).
%
% Written by ML Caras June 2025
%===============================================================================
close all;

% Initialize figure
f1 = figure; hold on;
set(gcf,'color','w')


% Read the normalized data
tbl = readtable(normalizedFile);

% Define metadata columns and measurement columns
metaCols = {'SubjectID','Group','Batch','IHCMethod','Sex','Age','TimePerfused'};
allVars   = tbl.Properties.VariableNames;
measCols  = setdiff(allVars, metaCols, 'stable');

% Filter to only the requested groups
isSelGroup = ismember(tbl.Group, groups);
tblFilt = tbl(isSelGroup, :);

%Initialize Results Table
Tresults = tblFilt(:,metaCols);

%For each range of data 
for j = 1:numel(colArray)

    % Determine which measurement cols to average
    colRange = colArray{j};
    startIdx  = colRange(1);
    endIdx    = colRange(2);
    rangeCols = measCols(startIdx:endIdx);

    % Compute per‐subject mean over that range
    subjectMeans = mean(tblFilt{:, rangeCols}, 2, 'omitnan');
    tblFilt.MeanRange = subjectMeans;   % add to output table

    % Compute group statistics
    nGroups     = numel(groups);
    groupMeans  = zeros(nGroups,1);
    groupSEMs   = zeros(nGroups,1);
    for i = 1:nGroups
        idx = strcmp(tblFilt.Group, groups{i});
        vals = subjectMeans(idx);
        groupMeans(i) = mean(vals, 'omitnan');
        groupSEMs(i)  = std(vals, 'omitnan') / sqrt(sum(~isnan(vals)));
    end

    %Set up subplot
    f1;
    s = subplot(1,numel(colArray),j);

    % Bar graph
    b = bar(1:nGroups, groupMeans, 'FaceColor','flat','FaceAlpha', 0.3);
    b.CData = colors;
    hold on

    % SEM error bars, in matching color lines
    cx = 1:nGroups;
    for k = 1:nGroups
        errorbar( ...
            cx(k), groupMeans(k), groupSEMs(k), ...
            'LineStyle','none', ...
            'Color', b.CData(k,:), ...
            'LineWidth',1.5, ...
            'CapSize',5 );
    end

    % Overlay individual subject data
    for i = 1:nGroups
        idx = strcmp(tblFilt.Group, groups{i});
        x = repmat(i, sum(idx), 1);
        y = subjectMeans(idx);
 
        %add x axis jitter
        rng('default'); %reproducibility
        jit = 0.2;
        x = x + (rand(size(x))-0.5)*jit;


        scatter(x, y, 36, 'filled', ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor','none', ...
            'MarkerFaceAlpha',0.2);
    end

    % Formatting
    xlim([0.5, nGroups+0.5]);
    set(gca, 'XTick', 1:nGroups, 'XTickLabel', groups,...
        'Tickdir','out','LineWidth',1.5,'FontName','Arial',...
        'FontSize',14,'box','off');
    
    if j>1
        ylabel(s, '');  % only label first subplot
    else
        ylabel(s, 'Normalized Intensity (%)');
    end

   Tresults.MeanIntensity = subjectMeans;

    title(ttext);


    %append axes
    ax(j) = s;
end

%Link axes
linkaxes(ax)

%Save figure
set(gcf,'color','w')
set(gcf,'Position',[252   326   979   350])
[fpath,~,~] = fileparts(outputFile);
savename = fullfile(fpath,'plot_intensity_barandpoints.pdf');
exportgraphics(gcf, savename, 'ContentType','vector');


%Write output CSV
writetable(Tresults, outputFile);

end

