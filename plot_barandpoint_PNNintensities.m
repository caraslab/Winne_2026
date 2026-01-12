function plot_barandpoint_PNNintensities(inputFile, outputFile, groups, colors, ttext)
% Tresults = plot_barandpoint_PNNintensities(inputFile, outputFile, groups, colors)
%
% Description:
%   Reads a CSV with metadata and  measurement columns,
%   calculates group means ± SEM, plots a bar graph of group means ± SEM
%   with overlaid transparent circles for individual subjects, and
%   writes an output CSV preserving metadata plus the subject mean column.
%
% Inputs:
%   inputFile – string; path to CSV with normalized data. Must contain
%                    variables 'SubjectID', 'Group', 'IHCMethod', 'Sex',
%                    'Age', and 'PerfusionTime' as metadata columns.
%   outputFile     – string; path where the output CSV will be written.
%
%   groups         – cell array of strings; names of the experimental
%                    groups to include (e.g. {'Untrained','PL-2d','PL-7d'}).
%
%   colors          -M x 3 matrix of RGB color values
%
%   ttext           -String. Title for plot.
%
% Requirements:
%   • MATLAB R2019b or newer
%   • No additional toolboxes required
%
% Written by ML Caras June 2025

close all;

% Initialize figure
f1 = figure; hold on;
set(gcf,'color','w')
set(gcf,'position',[65   403   319   355])

% Read the normalized data
tbl = readtable(inputFile);

% Filter to only the requested groups
isSelGroup = ismember(tbl.Group, groups);
tblFilt = tbl(isSelGroup, :);

%Filter only to L4-6. No need to do this for S1 data because only L4-6 were
%analyzed to begin with
if ismember('Layer',tblFilt.Properties.VariableNames)
    islayer = ismember(tblFilt.Layer,{'L4','L5','L6'});
    tblFilt = tblFilt(islayer,:);
end

%Compute group statistics
nGroups     = numel(groups);
groupMeans  = zeros(nGroups,1);

for i = 1:nGroups
    idx = strcmp(tblFilt.Group, groups{i});
    vals = tblFilt.mean(idx);
    vals = log(vals); %log transform the data
    groupMeans(i) = mean(vals, 'omitnan');
end

%Swarmchart
xswarm = categorical(tblFilt.Group);
xswarm = reordercats(xswarm, groups); %order the categories
yswarm = log(tblFilt.mean); %log transform the data
hswarm = swarmchart(xswarm,yswarm,'.'); %build the swarmchart in log space and plot on linear axis for proper 
                                        %kernel density formation
hold on

%Add mean values
hmeans = scatter(categorical(groups), groupMeans, 100,...
    'white', 'filled','MarkerEdgeColor','black','LineWidth',3);

%Format plot
ylabel('Normalized WFA Intensity (%)')
title(ttext)
myformat;

%Adjust yticks
yt = log([25, 50, 100, 200, 400]); 
set(gca,'ylim',[log(20),yt(end)])
set(gca,'ytick',yt);
set(gca,'YTickLabel',compose('%.0f', exp(yt)));%display yticks as normalized intensity, rather than logtransformed values
ylim padded

%Recolor
[~, idx] = ismember(xswarm, groups);     % map each point to its group
cdata = colors(idx,:);                  % Nx3 color per point
hswarm.CData = cdata;


%Save figure
[fpath,fname,~] = fileparts(outputFile);
savename = fullfile(fpath,[fname,'.pdf']);
exportgraphics(gcf, savename, 'ContentType','vector');


%Write output CSV
writetable(tblFilt, outputFile);

end

