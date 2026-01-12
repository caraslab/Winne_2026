function plotTrialsToCriterion(resultsTbl, outCSV, colors,figsavepath)
% plotTrialsToCriterion(resultsTbl, outCSV, colors,figsavepath)
%
% Description:
%   Takes a results table with subject IDs, group assignments, and columns 'Window1',
%   'Window2', ..., and determines for each subject the first window in which the value
%   reaches or exceeds the performance threshold (d'>=2). It appends these values to the table,
%   exports the augmented table to CSV, and generates a bar plot of mean±SEM per group
%   with overlaid individual data points, using the specified color matrix.
%
% Inputs:
%   resultsTbl  - Table containing variables:
%                 • SubjectID (numeric or string)
%                 • Group     (categorical, string, or cell array of chars)
%                 • Window#   (numeric columns named 'Window1','Window2',...)
%   outCSV      - String. Path/filename for exporting the augmented table (CSV format).
%   colors      - Numeric matrix (nGroups × 3). RGB colors for each group in plotting order.
%   figsavepath - String. Path to directory where figure will be saved.
%   
% Written by ML Caras Aug 2025


% dprime for criterion
criterion = 2;

% Identify window columns
varNames   = resultsTbl.Properties.VariableNames;
winMask    = startsWith(varNames, 'Window');
winNames   = varNames(winMask);
dataMatrix = resultsTbl{:, winNames};  % subjects × windows

% Determine first trial reaching criterion per subject
nSubjects    = size(dataMatrix,1);
firstTrial  = nan(nSubjects,1);


for i = 1:nSubjects
    if any(dataMatrix(i,:)>= criterion)
        idx = find(dataMatrix(i,:) >= criterion, 1, 'first');
        firstTrial(i) = idx;
    end
end

% Append to table and export
resultsTbl.FirstWindow = firstTrial;
writetable(resultsTbl, outCSV);
fprintf('Exported augmented table to %s\n', outCSV);

% Compute group means and SEM
% Determine unique groups in original order
groups = unique(string(resultsTbl.Group), 'stable');
groups = cellstr(groups);
nGroups = numel(groups);

means = zeros(nGroups,1);
sems  = zeros(nGroups,1);
dataByGroup = cell(nGroups,1);

for g = 1:nGroups
    mask = ismember(string(resultsTbl.Group), groups{g});
    vals = resultsTbl.FirstWindow(mask);
    vals = vals(~isnan(vals));
    dataByGroup{g} = vals;
    means(g) = mean(vals);
    sems(g)  = std(vals) / sqrt(numel(vals));
end

%Plot bar with mean±SEM and overlaid points
figure;

%bar
hb = bar(1:nGroups, means, 'FaceColor', 'flat','FaceAlpha', 0.3);
hb.CData = colors;
hold on;

%errorbars
for i = 1:nGroups
    he = errorbar(i, means(i), sems(i),...
        'Color', hb.CData(i,:),...
        'LineStyle', 'none',...
        'LineWidth', 2,...
        'CapSize',5);
end


%overlay individual points
for i = 1:nGroups
    x = i + (rand(size(dataByGroup{i})) - 0.5) * 0.5;  % jitter
    scatter(x, dataByGroup{i}, 72, 'filled',...
        'MarkerFaceColor', colors(i,:), ...
        'MarkerEdgeColor','none', ...
        'MarkerFaceAlpha',0.4);
end

%format
hold off;
set(gca, 'XTick', 1:nGroups, 'XTickLabel', groups);
xlabel('Group');
ylabel('First Trial to Criterion');
myformat

%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'trials-to-criterion-barplot.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');


end
