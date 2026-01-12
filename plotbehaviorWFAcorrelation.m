function plotbehaviorWFAcorrelation(datafile, param, ytext, figsavepath)
% plotbehaviorWFAcorrelation(datafile, param, ytext, figsavepath)
%
% Description:
%   Reads a table containing AreaWFA and a behavioral metric, removes rows with
%   missing AreaWFA values, and plots the relationship as a scatter with a linear
%   regression line. Selects Pearson correlation if both variables pass a normality
%   test (lillietest); otherwise uses Spearman correlation. Displays correlation
%   statistics in the plot title and saves the figure as a vectorized PDF.
%
% Inputs:
%   datafile     - String. Path to CSV/XLSX file containing 'AreaWFA' and the
%                 behavioral metric specified by param.
%   param        - String. Variable name in tbl to correlate with AreaWFA.
%   ytext        - String. Y-axis label for the behavioral metric.
%   figsavepath  - String. Full path/filename for the output figure (PDF).
%
%   Written by ML Caras Aug 2025

%Read in data
tbl = readtable(datafile);

%Define data to plot
x = tbl.AreaWFA;
y = tbl.(param);

%Remove rows with missing values
idx = ~isnan(x);
x = x(idx);
y = y(idx);

%Plot the points
plot(x,y,'o','MarkerFaceColor','k','MarkerSize',10);
hold on

%Plot regression
p = polyfit(x,y,1);
f = polyval(p,x);
plot(x,f,'k-','linewidth',1.5);

%Calculate correlation
hX = lillietest(x);  hY = lillietest(y);
if ~hX && ~hY
    method = 'Pearson';
else
    method = 'Spearman';
end

%Compute correlation
[r, p] = corr(x, y, 'Type', method);
stats = struct('r', r, 'p', p, 'method', method, 'n', numel(x));

% Format plot
xlabel('% A1 with WFA'); 
ylabel(ytext);
title(sprintf('%s r=%.2f, p=%.3f', method, r, p));
myformat


%Save figure as PDF vector file
exportgraphics(gcf, figsavepath, 'ContentType', 'vector');


