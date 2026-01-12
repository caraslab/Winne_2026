function plotAblationDuringPLData(datafile,cutoff,clrs,figsavepath)
% plotAblationDuringPLData(datafile, cutoff, clrs, figsavepath)
%
% Description:
%   Reads a table of behavioral data (one row per subject) and summarizes PL
%   thresholds by treatment. Reorders treatments to plot 'Saline' first (if present),
%   excludes chABC subjects with AreaWFA >= cutoff, and plots individual subject
%   threshold trajectories (ThresholdDay1..ThresholdDay8) with overlaid group means
%   and a regression line fit to mean threshold versus log10(day). Generates a second
%   summary figure showing mean ± SEM with overlaid points for LearningRate,
%   Improvement, Starting Threshold (Day 1), and Final Threshold (Day 8). Saves both
%   figures as vectorized PDFs in figsavepath.
%
% Inputs:
%   datafile     - String. Path to CSV/XLSX file containing Treatment, AreaWFA,
%                 ThresholdDay1..ThresholdDay8, LearningRate, and Improvement.
%   cutoff       - Numeric scalar. AreaWFA cutoff applied only to chABC rows
%                 (keeps rows with AreaWFA < cutoff).
%   clrs         - Matrix of RGB color values (nTreatments × 3).
%   figsavepath  - String. Path where figures will be saved.
%
%   Written by ML Caras Aug 2025


%Read in data
tbl = readtable(datafile);
treatments = unique(tbl.Treatment);
% Find "Saline" and force it to the top
idx = find(strcmp(treatments, 'Saline'));
treatments = treatments([idx, setdiff(1:numel(treatments), idx)]);


measCols = arrayfun(@(x) sprintf('ThresholdDay%d', x), 1:8, 'UniformOutput', false);

%Initialize
grpslopes = cell(numel(treatments),1);
grpimprovement = cell(numel(treatments),1);
grpstart = cell(numel(treatments),1);
grpfinal = cell(numel(treatments),1);

figure;

%For each treatment
for i = 1:numel(treatments)
    
    %Filter table
    isTreatment = ismember(tbl.Treatment, treatments{i});
    tblFilt = tbl(isTreatment, :);

    %Exclude chABC subjects whose WFA area exceeds a cutoff
    if contains(treatments{i},'chABC')
        idx = tblFilt.AreaWFA < cutoff;
        tblFilt = tblFilt(idx,:);
    end

    %Extract thresholds
    thresholds = tblFilt{:,measCols};

    numSubj = size(thresholds,1);
    nDays = size(thresholds,2);
    x = 1:nDays;
  

    %Plot each subject's data
    for j = 1:numSubj

        ax(i) = subplot(1,numel(treatments),i); %#ok<AGROW>
        y = thresholds(j,:);
        plot(x,y,'-','color',clrs(i,:),'linewidth',0.5);
        hold on
    end

    %Plot daily average threshold
    aves = mean(thresholds,1);
    plot(x,aves,'s','color',clrs(i,:),'markersize',11,'markerfacecolor',clrs(i,:))

    %Create and plot overall regression line
    xlog = log10(x);
    p = polyfit(xlog,aves,1);
    f = polyval(p,xlog);
    plot(x,f,'-','linewidth',2,'color',clrs(i,:));
    
    %return to command window
    [treatments{i}]
    p

    %Format plot
    set(gca,'xscale','log')
    axis square
    xlabel('Adaptive Training Day')
    ylabel('Threshold (dB)')
    title(treatments{i})
    myformat

    

    %Save key values
    grpslopes{i} = tblFilt.LearningRate;
    grpimprovement{i} = tblFilt.Improvement;
    grpstart{i} = tblFilt.ThresholdDay1;
    grpfinal{i} = tblFilt.ThresholdDay8;

    %Link the axes
    linkaxes(ax)

end

%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'ablation_duringPL_trajectories.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');


%Initialize the next figure
figure;

%Calculate and plot the mean +/- SEM learning rates with overlaid points
subplot(2,2,1)
barnpoint(treatments,clrs,grpslopes,'Learning rate (dB/log(day)');
set(gca,'XAxisLocation','origin')

%Calculate and plot the mean +/- SEM improvement with overlaid points
subplot(2,2,2)
barnpoint(treatments,clrs,grpimprovement,'Improvement (dB)');

%Calculate and plot the mean +/- SEM starting threshold with overlaid points
s(1) = subplot(2,2,3);
barnpoint(treatments,clrs,grpstart,'Starting Threshold (dB)');
set(gca,'XAxisLocation','origin')

%Calculate and plot the mean +/- SEM final threshold with overlaid points
s(2) = subplot(2,2,4);
barnpoint(treatments,clrs,grpfinal,'Final Threshold (dB)');
set(gca,'XAxisLocation','origin')

linkaxes(s)
set(gcf,'position',[440,1,610,697]);

%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'ablation_duringPL_barandpoints.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');
end




%PLOT BAR AND POINTS
function barnpoint(grps,clrs,grpdata,ytext)

means = nan(numel(grps),1);
sems = nan(numel(grps),1);

for i = 1:numel(grps)
    vals = grpdata{i};
    means(i) = mean(vals);
    sems(i) = std(vals) / sqrt(numel(vals));
end

%bar
hb = bar(1:numel(grps), means, 'FaceColor', 'flat','FaceAlpha', 0.3);
hb.CData = clrs;
hold on;

%errorbars
for i = 1:numel(grps)
    he = errorbar(i, means(i), sems(i),...
        'Color', hb.CData(i,:),...
        'LineStyle', 'none',...
        'LineWidth', 2);
end


%overlay individual points
for i = 1:numel(grps)
    x = i + (rand(size(grpdata{i})) - 0.5) * 0.5;  % jitter
    scatter(x, grpdata{i}, 72, 'filled',...
        'MarkerFaceColor', clrs(i,:), ...
        'MarkerEdgeColor','none', ...
        'MarkerFaceAlpha',0.4);
end

%format
hold off;
set(gca, 'XTick', 1:numel(grps), 'XTickLabel', grps);
ylabel(ytext);
myformat

end



