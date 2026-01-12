function stats = plotBehaviorIntensityCorrelation(behaviorfile, intensityfile, measureVar, outFig)
% plotBehaviorIntensityCorrelation(behaviorfile, intensityfile, measureVar, outFig)
%
% Description:
%   Reads two CSV files: one containing behavioral metrics by subject and one
%   containing MeanIntensity by subject. Merges tables on 'SubjectID', selects
%   a correlation method (Pearson if both variables pass a normality test via
%   lillietest; otherwise Spearman), computes correlation statistics, and plots
%   MeanIntensity versus the specified behavioral measure with a linear fit line.
%   Saves the figure as a vectorized PDF.
%
% Inputs:
%   behaviorfile   - String. Path to CSV file with 'SubjectID' and behavioral metrics.
%   intensityfile  - String. Path to CSV file with 'SubjectID' and 'MeanIntensity'.
%   measureVar     - String. Name of behavioral metric column to correlate (e.g. 'maxdprime').
%   outFig         - String. Full path/filename for the output figure (PDF).
%
% Outputs:
%   stats          - Struct with fields: r, p, method, and n (paired observations).
%
%   Written by ML Caras Aug 2025

% Read behavioral data and intensity data
opts1 = detectImportOptions(behaviorfile);  behTbl = readtable(behaviorfile, opts1);
opts2 = detectImportOptions(intensityfile); intTbl = readtable(intensityfile, opts2);

% Merge on SubjectID
behSel = behTbl(:, [{'SubjectID'}, {measureVar}]);
intSel = intTbl(:, {'SubjectID','MeanIntensity'});
merged = innerjoin(behSel, intSel, 'Keys', 'SubjectID');

X = merged.MeanIntensity; Y = merged{:, measureVar};

% Select correlation method by normality test
hX = lillietest(X);  hY = lillietest(Y);
if ~hX && ~hY
    method = 'Pearson';
else
    method = 'Spearman';
end

% Compute correlation
[r, p] = corr(X, Y, 'Type', method);
stats = struct('r', r, 'p', p, 'method', method, 'n', numel(X));

% Plot scatter and fit line
figure; hold on;
scatter(X, Y, 36, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');

% Fit line
coef = polyfit(X, Y, 1);
xf = linspace(min(X), max(X), 100);
yf = polyval(coef, xf);
plot(xf, yf, 'k-', 'LineWidth', 1.5);
hold off;

% Format plot
xlabel('Noramlized Intensity (%)');
ylabel(measureVar);
title(sprintf('%s r=%.4f, p=%.4f', ...
    method, r, p));
myformat
xmin = 0.95*min(X);
xmax = 1.05*max(X);
set(gca,'xlim',[xmin,xmax]);


% 6Save figure as PDF vector file
exportgraphics(gcf, outFig, 'ContentType', 'vector');
end