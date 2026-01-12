function plotThresholdByGroup(resultTbl,dataFilter,colors,figsavepath)
% plotThresholdByGroup(resultTbl, dataFilter, colors, figsavepath)
%
% Description:
%   Takes a results table containing subject IDs, group assignments, and threshold
%   metrics. For each metric (StartThresh, EndThresh, Improvement), computes the
%   mean ± SEM per group and generates a bar plot with individual subject values
%   overlaid. Saves each figure as a PDF in figsavepath.
%
% Inputs:
%   resultTbl    - Table. Must contain variables 'Group', 'StartThresh', 'EndThresh',
%                 and 'Improvement'.
%   dataFilter   - Cell array of strings. Group names to include, in desired plot order.
%   colors       - Matrix of RGB color values (nGroups × 3).
%   figsavepath  - String. Path where figures will be saved.
%
%   Written by ML Caras Aug 2025

% Validate input
if ~istable(resultTbl) || ~all(ismember({'Group','StartThresh','EndThresh','Improvement'}, resultTbl.Properties.VariableNames))
    error('Input must be a table with ''Group'' and ''StartThresh'' , ''EndThresh'' and ''Improvement'' variables.');
end

% Turn the Group column into an ordered categorical
resultTbl.Group = categorical(resultTbl.Group,dataFilter, 'Ordinal', true);

% Use the categories() in that exact order
groups = categories(resultTbl.Group);
nGroups = numel(groups);


for k = 1:3

    means = zeros(nGroups,1);
    sems  = zeros(nGroups,1);
    dataByGroup = cell(nGroups,1);

    %Select result
    switch k
        case 1
            results = resultTbl.StartThresh;
            ytext = 'Starting Threshold (dB)';
            figname = 'startThreshbyGroup.pdf';
        case 2
            results = resultTbl.EndThresh;
            ytext = 'Final Threshold (dB)';
            figname = 'finalThreshbyGroup.pdf';
        case 3
            results = resultTbl.Improvement;
            ytext = 'Improvement (dB)';
            figname = 'improvementbyGroup.pdf';
    end

    % Compute  statistics per group
    for i = 1:nGroups
        grp = groups{i};
        mask = strcmp(string(resultTbl.Group), grp);
        vals = results(mask);
        vals = vals(~isnan(vals));  % exclude NaNs
        dataByGroup{i} = vals;
        means(i) = mean(vals);
        sems(i)  = std(vals) / sqrt(numel(vals));
    end

    %Figure 1: Bar plot with SEM and individual data points
    figure;

    %bars
    hb = bar(1:nGroups, means, 'FaceColor','flat','FaceAlpha', 0.3);
    hb.CData = colors;
    hold on;

    %errorbars
    for i = 1:nGroups
        he(i) = errorbar(i, means(i), sems(i),...
            'LineStyle', 'none',...
            'LineWidth', 2,...
            'CapSize',5);

        set(he(i),'Color',colors(i,:))
    end

    %Overlay individual points
    for i = 1:nGroups
        x = i + (rand(size(dataByGroup{i})) - 0.5) * 0.5;  % jitter
        scatter(x, dataByGroup{i}, 72, 'filled',...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor','none', ...
            'MarkerFaceAlpha',0.4);
    end

    hold off;

    %Format
    set(gca, 'XTick', 1:nGroups, 'XTickLabel', groups);
    ylabel(ytext);
    myformat

    if k < 3
        set(gca,'XAxisLocation','top')
    end

    %save figure
    fig1 = gcf;
    fname = fullfile(figsavepath,figname);
    exportgraphics(fig1, fname, 'ContentType','vector');

end

end