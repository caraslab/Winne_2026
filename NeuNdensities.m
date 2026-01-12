function NeuNdensities(NeuNFile, clrs, outCSV)
% NeuNdensities(NeuNFile, clrs, outCSV)
%
% Description:
%   Reads a NeuN cell count table, converts counts to densities using a fixed ROI
%   volume (83 × 83 µm area over 12 µm depth), and summarizes NeuN+ cell density by
%   treatment group (Saline, penicillinase, chABC). Plots group mean ± SEM with
%   individual data points overlaid, saves the figure as a vectorized PDF in the
%   same folder as NeuNFile, and writes the updated density table to CSV.
%
% Inputs:
%   NeuNFile    - String. Path to CSV/XLSX file containing NeuN counts with metadata
%                variables 'SubjectID', 'Treatment', and 'Area' plus measurement columns.
%   clrs        - Matrix of RGB color values (3 × 3) corresponding to
%                {'Saline','penicillinase','chABC'}.
%   outCSV      - String. Path where output table will be saved as a CSV.
%
%   Written by ML Caras Aug 2025

%Read table
T = readtable(NeuNFile);

%Define metadata and measurement columns
metaCols = {'SubjectID','Treatment','Area'};
allVars  = T.Properties.VariableNames;
measCols = setdiff(allVars, metaCols,'stable');

%Convert cell counts to densities
area = 0.083*0.083*0.012; %mm^3 83× 83 µm ROI over 12 um depth span
T(:,measCols) = T(:,measCols)./area;

%Define treatment groups
groups = {'Saline','penicillinase','chABC'};

%Prepare storage for statistics
nGroups     = numel(groups);
means  = NaN(nGroups, 1);
sems   = NaN(nGroups, 1);

%Compute mean and SEM per group
for i = 1:nGroups
    g = groups{i};
    rows = strcmp(T.Treatment, g);
    data = T{rows, measCols};

    means(i, :) = mean(data,'all');
    sems(i, :)  = std(data, 0, 'all')./ sqrt(sum((data),'all'));
end

%Plot bars
b = bar(1:nGroups, means, 'FaceColor','flat','FaceAlpha',0.3);
b.CData = clrs;
hold on;

errorbar(1:nGroups, means, sems, 'k', 'LineStyle','none', 'LineWidth',1.25,'CapSize',0);


%Plot points
rng(1);
for i = 1:nGroups
    vals = table2array(T(strcmp(T.Treatment,groups{i}),measCols));
    vals = reshape(vals,numel(vals),1);
    x = i + (rand(size(vals))-0.5)*0.18;
    scatter(x, vals, 48, 'filled', ...
        'MarkerFaceColor', clrs(i,:), ...
        'MarkerEdgeColor','none', ...
        'MarkerFaceAlpha', 0.4);
end

%Format
myformat;
set(gca, 'XTick', 1:nGroups, 'XTickLabel', groups);
xlim([0.5, nGroups+0.5]);
ylabel('NeuN+ cells/mm^3');


%Save figure
[fpath,~,~] = fileparts(NeuNFile);
savename = fullfile(fpath,'NeuN-Density-Plot.pdf');
exportgraphics(gcf, savename, 'ContentType','vector');

%Export Table
writetable(T, outCSV);
fprintf('Saved: %s', outCSV);

