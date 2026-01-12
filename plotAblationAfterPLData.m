function plotAblationAfterPLData(datafile, cutoff, clrs, figsavepath)
% plotAblationAfterPLData(datafile, cutoff, clrs, figsavepath)
%
% Description:
%   Reads a table of behavioral data (one row per subject) and summarizes thresholds
%   after PL by treatment. For each treatment, optionally excludes chABC subjects with
%   AreaWFA >= cutoff, extracts thresholds for Days 8–10 (ThresholdDay8..ThresholdDay10),
%   and plots group mean ± SEM across days with errorbars. Saves the figure as a
%   vectorized PDF in figsavepath.
%
% Inputs:
%   datafile     - String. Path to CSV/XLSX file containing Treatment, AreaWFA, and
%                 ThresholdDay8..ThresholdDay10.
%   cutoff       - Numeric scalar. AreaWFA cutoff applied only to chABC rows
%                 (keeps rows with AreaWFA < cutoff).
%   clrs         - Matrix of RGB color values (nTreatments × 3).
%   figsavepath  - String. Path where figure will be saved.
%
%   Written by ML Caras Aug 2025


%Read in data
tbl = readtable(datafile);
treatments = unique(tbl.Treatment);

%Select the columns of interest
measCols = arrayfun(@(x) sprintf('ThresholdDay%d', x), 8:10, 'UniformOutput', false);

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

    nDays = size(thresholds,2);
    x = 1:nDays;

    %Plot daily average thresholds
    aves = mean(thresholds,1);
    sems = std(thresholds) / sqrt(size(thresholds,1));
    errorbar(x,aves,sems,'s-','color',clrs(i,:),'markersize',11,...
        'markerfacecolor',clrs(i,:),'markeredgecolor', clrs(i,:), 'LineWidth',2)
    hold on
  

    %Format plot
    axis square
    xlabel('Day')
    ylabel('Threshold (dB)')
    myformat
    set(gca,'xtick', 1:3,'xticklabel',{'8','9','10'},'xlim',[0.5 3.5])
    legend(treatments,'box','off','location','northwest')

end



%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'ablation_afterPL_trajectories.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');






