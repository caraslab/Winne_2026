function plotAblationDuringPLnumtrials(datafile,cutoff,clrs,figsavepath,varargin)
% plotAblationDuringPLFAs(datafile, cutoff, clrs, figsavepath)
%
% Description:
%   Reads a CSV/Excel table of behavioral data (one row per subject) and:
%     1) Splits subjects by Treatment (forcing 'Saline' to be plotted first).
%     2) For treatments containing the substring 'chABC', excludes subjects whose
%        WFA area exceeds the provided cutoff (i.e., keeps rows with AreaWFA < cutoff).
%     3) For each treatment, extracts daily FA rates,
%        plots individual subject trajectories (x = days 1–8, log10 x-axis), and overlays the
%        per-day group mean.
%     4) Saves the trajectories figure as a vector PDF: 'ablation_duringPL_FAtrajectories.pdf'.
%
% Inputs:
%   datafile   - String. Path to the table file to read (e.g., .csv or .xlsx)
%   cutoff     - Numeric scalar. WFA area cutoff used only for 'chABC' rows (keep rows
%                with AreaWFA < cutoff).
%   clrs       - N×3 numeric array. RGB colors (rows in [0,1]) used per treatment, where
%                N equals the number of unique treatments after reordering.
%   figsavepath- String. Folder where the two PDF figures will be written.
%
% Written by ML Caras 2025

%Read in data
tbl = readtable(datafile);
treatments = unique(tbl.Treatment);

% Find "Saline" and force it to the top
idx = find(strcmp(treatments, 'Saline'));
treatments = treatments([idx, setdiff(1:numel(treatments), idx)]);


if nargin > 4
    dayvec = varargin{1};
else
    dayvec = 1:8;
end

measCols = arrayfun(@(x) sprintf('NumTrialsDay%d', x), dayvec, 'UniformOutput', false);

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

    %Extract numTrials
    numtrials= tblFilt{:,measCols};

    numSubj = size(numtrials,1);
    %nDays = size(FArates,2);
    x = dayvec;

    %Plot daily average num trials completed
    ax(i) = subplot(1,numel(treatments),i); %#ok<AGROW>
    aves = mean(numtrials,1);
    stdevs = std(numtrials,1);
    sems = stdevs/sqrt(numel(stdevs));
    errorbar(x,aves,sems,'s-','color',clrs(i,:),'markersize',11,'markerfacecolor',clrs(i,:))

  
    % %Plot each subject's data
    % for j = 1:numSubj
    % 
    %     ax(i) = subplot(1,numel(treatments),i); %#ok<AGROW>
    %     y = FArates(j,:);
    %     plot(x,y,'-','color',clrs(i,:),'linewidth',0.5);
    %     hold on
    % 
    %     % %Plot daily average FA rate
    %     % aves = mean(FArates,1);
    %     % stds = stdev(FArates,1);
    %     % sems = stds/sqrt(numel(stds));
    %     % errorbar(x,aves,sems,'s-','color',clrs(i,:),'markersize',11,'markerfacecolor',clrs(i,:))
    % 
    %     %Format plot
    %     if nargin <= 4
    %         set(gca,'xscale','log')
    %     end
    % end

    %Format plot
    axis square
    xlabel('Adaptive Training Day')
    ylabel('Num. Trials Completed')
    title(treatments{i})
    myformat




end

%Link the axes
linkaxes(ax)
set(gca,'ylim',[200 500])


%save figure
fig1 = gcf;
if nargin > 4
    figname = 'ablation_afterPL_numtrials.pdf';
else
    figname = 'ablation_duringPL_numtrials.pdf';
end


fname = fullfile(figsavepath,figname);
exportgraphics(fig1, fname, 'ContentType','vector');


end






