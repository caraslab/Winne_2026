function [TposSubj, TnegSubj] = pnn_densities(pvposFile, pvnegFile, outPrefix, groups, colors, layersToInclude)
% [TposSubj, TnegSubj] = summarize_pnn_counts_by_hslice(pvposFile, pvnegFile, outPrefix, groups, colors, layersToInclude)
%
% Description:
%   Loads PV+ and PV− CSVs (same schema), filters to specified layers,
%   then for each subset (PV+ and PV−) computes:
%     1) per-(SubjectID × Hemisphere × Slice) PNN counts
%     2) per-subject mean of those counts (averaging across hemispheres/slices)
%   Finally, plots group means ± SEM (bars) with overlaid subject points,
%   and saves the per-subject tables to CSV.
%
% Inputs:
%   pvposFile       – string; PV+ CSV path
%   pvnegFile       – string; PV− CSV path
%   outPrefix       – string; prefix for output CSVs (files: <prefix>_PVpos.csv, <prefix>_PVneg.csv)
%   groups          – cellstr; group order for summarizing/plotting
%   colors          – N×3 RGB in [0,1], N = numel(groups)
%   layersToInclude – optional cellstr (default {'L4','L5','L6'})
%
% Outputs:
%   TposSubj        – table (PV+) with SubjectID | Group | MeanCount_per_HemiSlice
%   TnegSubj        – table (PV−) with SubjectID | Group | MeanCount_per_HemiSlice
%
% Written by ML Caras June 2025

%Uppercase
layersToInclude = upper(string(layersToInclude));

% Load
Tpos = readtable(pvposFile, 'TextType','string');
Tneg = readtable(pvnegFile, 'TextType','string');

%Filter data to only include the layers we want
Tpos.Layer = upper(string(Tpos.Layer));
Tneg.Layer = upper(string(Tneg.Layer));
Tpos = Tpos( ismember(Tpos.Layer, layersToInclude), : );
Tneg = Tneg( ismember(Tneg.Layer, layersToInclude), : );
Tall = [Tpos;Tneg]; %concatenate for full analysis

% Compute per-subject mean counts across Hemisphere×Slice blocks
TposSubj = perSubjectMeanCounts(Tpos);
TnegSubj = perSubjectMeanCounts(Tneg);
TallSubj = perSubjectMeanCounts(Tall);

% Keep only requested groups (and order them)
TposSubj = orderGroups(TposSubj, groups);
TnegSubj = orderGroups(TnegSubj, groups);
TallSubj = orderGroups(TallSubj,groups);

%Convert to density values (PNNs/mm^3)
area = 0.99437*0.930*0.012; %mm^3 L4-L6 over 12 um depth span
TposSubj.PNNDensity = TposSubj.MeanCount_per_HemiSlice/area;
TnegSubj.PNNDensity = TnegSubj.MeanCount_per_HemiSlice/area;
TallSubj.PNNDensity = TallSubj.MeanCount_per_HemiSlice/area;


% Plot bars ± SEM + subject points
figure; hold on;
set(gcf,'color','w')
tiledlayout(1,3);
nexttile;
plotBars(TposSubj, groups, colors, 'PV+ PNNs');
nexttile;
plotBars(TnegSubj, groups, colors, 'PV− PNNs');
nexttile;
plotBars(TallSubj, groups, colors, 'All PNNs');

%Save figure
savename = sprintf('%s_Plot.pdf', outPrefix);
exportgraphics(gcf, savename, 'ContentType','vector');

% Save CSVs
writetable(TposSubj, sprintf('%s_PVpos.csv', outPrefix));
writetable(TnegSubj, sprintf('%s_PVneg.csv', outPrefix));
writetable(TallSubj, sprintf('%s_PVall.csv', outPrefix));
fprintf('Saved: %s_PVpos.csv, %s_PVneg.csv\n and %s_PVall.csv\n', outPrefix, outPrefix, outPrefix);


end




%----------------- Helpers -----------------%

function Tout = perSubjectMeanCounts(Tin)
% Count per (SubjectID × Hemisphere × Slice)
G = findgroups(Tin.SubjectID, Tin.Hemisphere, Tin.Slice);
countsHS = splitapply(@numel, Tin.SubjectID, G); % number of rows = PNN count
S = splitapply(@(x) x(1), Tin.SubjectID, G);
grp = splitapply(@(x) x(1), Tin.Group,     G);

Ths = table(S, grp, countsHS, 'VariableNames', ...
    {'SubjectID','Group','Count_per_HemiSlice'});

% Mean across Hemi×Slice within Subject
Gs = findgroups(Ths.SubjectID);
subjID = splitapply(@(x) x(1), Ths.SubjectID, Gs);
subjGrp= splitapply(@(x) x(1), Ths.Group,     Gs);
meanCnt= splitapply(@mean, Ths.Count_per_HemiSlice, Gs);

Tout = table(subjID, subjGrp, meanCnt, 'VariableNames', ...
    {'SubjectID','Group','MeanCount_per_HemiSlice'});
end

function T = orderGroups(T, groups)
keep = ismember(T.Group, groups);
T = T(keep, :);
[~, ord] = ismember(T.Group, groups);
T.Order = ord;
T = sortrows(T, 'Order');
T.Order = [];
end

function plotBars(Tsubj, groups, colors, ttl)
ax = gca;
axes(ax);
hold on;

nG = numel(groups);
if size(colors,1) ~= nG
    error('colors must be %d×3.', nG);
end

% Compute group means/SEMs
grpMean = nan(nG,1);
grpSEM  = nan(nG,1);
for i = 1:nG
    vals = Tsubj.PNNDensity( Tsubj.Group == groups{i} );
    grpMean(i) = mean(vals, 'omitnan');
    grpSEM(i)  = std(vals, 0, 'omitnan') / sqrt(sum(~isnan(vals)));
end

%Plot bars
b = bar(1:nG, grpMean, 'FaceColor','flat','FaceAlpha',0.3);
b.CData = colors;
hold on;

errorbar(1:nG, grpMean, grpSEM, 'k', 'LineStyle','none', 'LineWidth',1.25,'CapSize',0);


%Plot points
rng(1);
for i = 1:nG
    vals = Tsubj.PNNDensity( Tsubj.Group == groups{i} );
    x = i + (rand(size(vals))-0.5)*0.18;
    scatter(x, vals, 48, 'filled', ...
        'MarkerFaceColor', colors(i,:), ...
        'MarkerEdgeColor','none', ...
        'MarkerFaceAlpha', 0.4);
end

%Format
myformat;
set(gca, 'XTick', 1:nG, 'XTickLabel', groups);
xlim([0.5, nG+0.5]);
ylabel('PNNs/mm^3');
title(ttl);

end