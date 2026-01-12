function plotSessionsToCriterion(resultTbl,dataFilter,colors,figsavepath)
% plotSessionsToCriterion(resultTbl,dataFilter,colors,figsavepath)
%
% Description:
%   Takes a results table containing subject IDs, group assignments, 
%   and the number of sessions required to reach a performance threshold. 
%   Generates a bar plot of the mean ± SEM sessions-to-threshold for each 
%   group, with individual data points overlaid.
%  
% Input:
%   resultsTbl - Table with variables:
%       • SubjectID           – Numeric or string identifier
%       • Group               – Categorical or cell array of group names
%       • SessionsToCriterion – Numeric scalar or NaN per subject
%   dataFilter  - Cell array of strings with group names in order
%   colors      - RGB matrix of color values for each group
%   figsavepath - String. Path where figures will be saved.
%
% Written by ML Caras Aug 2025


% Validate input
if ~istable(resultTbl) || ~all(ismember({'Group','SessionsToCriterion'}, resultTbl.Properties.VariableNames))
    error('Input must be a table with ''Group'' and ''SessionsToCriterion'' variables.');
end

% Turn the Group column into an ordered categorical
resultTbl.Group = categorical(resultTbl.Group,dataFilter, 'Ordinal', true);

% Use the categories() in that exact order
groups = categories(resultTbl.Group);

nGroups = numel(groups);
means = zeros(nGroups,1);
sems  = zeros(nGroups,1);
dataByGroup = cell(nGroups,1);

% Compute statistics per group
for i = 1:nGroups
    grp = groups{i};
    mask = strcmp(string(resultTbl.Group), grp);
    vals = resultTbl.SessionsToCriterion(mask);
    vals = vals(~isnan(vals));  % exclude NaNs
    dataByGroup{i} = vals;
    means(i) = mean(vals);
    sems(i)  = std(vals) / sqrt(numel(vals));
end

%Create bar plot with SEM and individual data points
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
xlabel('Group'); ylabel('Sessions to Criterion');
myformat

%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'sessions-to-criterion-barplot.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');

end