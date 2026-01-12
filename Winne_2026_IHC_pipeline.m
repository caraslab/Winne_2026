%% WINNE 2026 IHC PIPELINE
% This pipeline contains code for preprocessing and analyzing imaging and 
% behavior data for Winne et al. 2026. This is pipeline 1 of 2, focused on
% the analysis of spatiotemporal dynamics of ECM integrity during auditory
% learning. Pipeline 2 of 2 is focused on the analysis of the behavioral
% consequences of enzymatic ECM digestion.  
% 
% Written by ML Caras. Finalized Jan 12, 2026.


%% Behavior Analysis- Instrumental: Calculate and plot mean +/- SEM dprime values as a function of session
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetName = 'IHC';
matFolder = 'Insert your path to /BehaviorFiles/';
figsavepath = 'Insert your path to the folder where figures should be saved';
outCSV = '/Insert your path/dprime-by-session.csv';
groupFilter = {'ST-0h','ST-4h','ST-24h'};
colors = select_colors_instrumental;
colors = colors(2:end,:); %excludes untrained color scheme for this plot

%Run Function
plotDprimeBySession(subjectsummary, sheetName, groupFilter, matFolder, colors, figsavepath, outCSV)

%% Behavior Analysis- Instrumental: Calculate and plot number of sessions animals needed to reach d'>=2
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetName = 'IHC';
matFolder = 'Insert your path to /BehaviorFiles/';
figsavepath = 'Insert your path to the folder where figures should be saved';
outCSV = '/Insert your path/sessions-to-criterion.csv';
groupFilter = {'ST-0h','ST-4h','ST-24h'}; 
criterion = 2;
colors = select_colors_instrumental;
colors = colors(2:end,:); %excludes untrained color scheme for this plot

%Calculate
resultTbl = quantifySessionsToCriterion(subjectsummary, sheetName, groupFilter, matFolder, outCSV, 2);


%Plot
plotSessionsToCriterion(resultTbl,groupFilter,colors,figsavepath);

%% Behavior Analysis- Instrumental: Calculate and plot mean +/- SEM dprime values as a function of trial, and calculate the number of trials needed to reach d'>= 2
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetName = 'IHC';
matFolder = 'Insert your path to /BehaviorFiles/';
figsavepath = 'Insert your path to the folder where figures should be saved';
outCSV = '/Insert your path/dprime-by-trial.csv';
windowsize = 75;
groupFilter = {'ST-0h','ST-4h','ST-24h'};  
colors = select_colors_instrumental;
colors = colors(2:end,:); %excludes untrained color scheme for this plot

%Calculate and plot
resultsTbl = plotDprimeByTrial(subjectsummary, sheetName, groupFilter, matFolder, colors, figsavepath, outCSV, windowsize);

outCSV = '/Users/mcaras/Documents/Manuscripts/2025-Winne/Data/Outputs/IHC/trials-to-criterion.csv';
plotTrialsToCriterion(resultsTbl, outCSV, colors,figsavepath)

%% Behavior Analysis- Instrumental: Calculate and plot the maximum and final d' achieved in a given session
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetName = 'IHC';
matFolder = 'Insert your path to /BehaviorFiles/';
figsavepath = 'Insert your path to the folder where figures should be saved';
outCSV = '/Insert your path/max-final-dprime.csv';
groupFilter = {'ST-0h','ST-4h','ST-24h'}; 
colors = select_colors_instrumental;
colors = colors(2:end,:); %excludes untrained color scheme for this plot

%Calculate
resultTbl = quantifyMaxDprime(subjectsummary, sheetName, groupFilter, matFolder, outCSV);

%Plot
plotMaxFinalDprime(resultTbl,groupFilter,colors,figsavepath)




%% Behavior Analysis - Adaptive: Extract starting and final thresholds and calculate improvement
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetName = 'IHC';
matFolder = 'Insert your path to /BehaviorFiles/';
figsavepath = 'Insert your path to the folder where figures should be saved';
outCSV = '/Insert your path/thresholds.csv';
groupFilter = {'PL-2d','PL-7d'};   
colors = select_colors_adaptive;
colors = colors(3:end,:); %excludes untrained and ST-4h color scheme for this plot

%Calculate
resultTbl = extractThresholdsandLearning(subjectsummary, sheetName, groupFilter, matFolder, outCSV);

%Plot
plotThresholdByGroup(resultTbl,groupFilter,colors,figsavepath)


%% Behavior Analysis - Adaptive: Plot learning trajectories
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetName = 'IHC';
matFolder = 'Insert your path to /BehaviorFiles/';
figsavepath = 'Insert your path to the folder where figures should be saved';
outCSV = '/Insert your path/ThresholdbyDay.csv';
groupFilter = {'PL-2d','PL-7d'};  
colors = select_colors_adaptive;
colors = colors(3:end,:); %excludes untrained and ST-4h color scheme for this plot


%Run Function
plotLearningTrajectories(subjectsummary, sheetName, groupFilter, matFolder, colors, figsavepath,outCSV);


%% Behavior Analysis - Representative psychometric fit and learning trajectory
clear all;
close all;
clc

subjectfile = 'Insert your path to /BehaviorFiles/SUBJ-ID-805_allSessions.mat';   %Fig 4
figsavepath = 'Insert your path to the folder where figures should be saved';

plotRepresentativeBehavior(subjectfile,figsavepath);

%% Behavior Analysis- Adaptive: Extract FA rates and merge with metadata
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetName = 'IHC';
matFolder = 'Insert your path to /BehaviorFiles/';
outCSV = '/Insert your path/IHC_FArates.csv';
ndays = 7;
groupFilter = {'PL-2d','PL-7d'};  

resultTbl = extractFARates_IHC(subjectsummary, sheetName, matFolder, outCSV, ndays,groupFilter);


%%
%% Intensity Preprocessing: Compile average WFA plot profiles
%Calculate a single average WFA plot profile for each animal, then compile
%these profiles from all animals into a single table and save to a CSV.
clear all;
close all;
clc

plotProfileDir = 'Insert your path to/WFA_PlotProfiles/A1/'; %Auditory cortex
savename = 'Insert your path/A1_WFA.csv';

%plotProfileDir = 'Insert your path to/WFA_PlotProfiles/S1/'; %Somatosensory cortex
%savename = 'Insert your path/S1_WFA.csv';

aggregate_plotprofiles(plotProfileDir, savename)

%% Intensity Preprocessing: Add metadata to compiled plot profiles
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetname = 'IHC';
compiledFile =  'Insert your path to/A1_WFA.csv'; %Auditory cortex
%compiledFile =  'Insert your path to/S1_WFA.csv'; %Somatosensory cortex

%Function
merge_with_metadata(compiledFile, subjectsummary,sheetname);


%% Intensity preprocessing: Convert perfusion times into hours
clear all;
close all;
clc

compiledFile =  'Insert your path to/A1_WFA.csv'; %Auditory cortex
%compiledFile =  'Insert your path to/S1_WFA.csv'; %Somatosensory cortex

tbl = convertTimePerfused(compiledFile);
%% Intensity Preprocessing: Determine average intensity values for untrained animals by IHC batch
clear all;
close all;
clc

compiledFile =  'Insert your path to/A1_WFA.csv'; 
outCSV = 'Insert your path/UntrainedWFAs.csv';

calc_meanWFA_untrained_by_batch(compiledFile, outCSV)

%%
%% Intensity Analysis 1: Normalize intensity values to the overall mean of the untrained group (ignores depth and layer). Done separately for each IHC batch.
clear all;
close all;
clc

compiledFile =  'Insert your path to/A1_WFA.csv'; %Auditory cortex
normalizedfile = 'Insert your path/A1_WFA_norm_overall_bybatch.csv';

%compiledFile =  'Insert your path to/S1_WFA.csv'; %Somatosensory cortex
%normalizedfile = 'Insert your path/S1_WFA_norm_overall_bybatch.csv';

normalize_to_untrained_bybatch(compiledFile, normalizedfile); %normalizes by IHC batch, with batches 2-4 grouped together

%% Intensity Analysis 1: Plot normalized intensity values across the cortical depth
clear all;
close all;

normalizedfile = 'Insert your path/A1_WFA_norm_overall_bybatch.csv'; %Auditory Cortex
%normalizedfile = 'Insert your path/S1_WFA_norm_overall_bybatch.csv'; %Somatosensory Cortex

%Untrained, 0 h, 4 h, and 24 h post instrumental training
    groups = {'Untrained', 'ST-0h', 'ST-4h', 'ST-24h'};
    colors = select_colors_instrumental;

%Untrained, Instrumental, adaptive 2-d, adaptive 7-d (all 4 h post session)
    % groups = {'Untrained', 'ST-4h','PL-2d','PL-7d'};
    % colors = select_colors_adaptive;

%Untrained and pseudotrained
    %groups = {'Untrained', 'ST-Unpaired'};
    %colors = select_colors_unpaired;

%Untrained and 4 h post intrumental trained (for S1)
    % groups = {'Untrained', 'ST-4h'}; %For S1
    % colors = select_colors_adaptive;
    % colors = colors(1:2,:);


plot_normalized_plotprofiles(normalizedfile, groups, colors); %saves fig to same directory as normalized file

%%
%% Intensity Analysis 2: Normalize intensity values to the mean of the untrained group by batch and layer. Done separately for each IHC batch.

clear all;
close all;
clc

compiledFile =  'Insert your path to/A1_WFA.csv'; %Auditory cortex
normalizedfile = 'Insert your path/A1_WFA_norm_bydepth_bybatch.csv';

%compiledFile =  'Insert your path to/S1_WFA.csv'; %Somatosensory cortex
%normalizedfile = 'Insert your path/S1_WFA_norm_bydepth_bybatch.csv';

normalize_to_untrained_bydepth_bybatch(compiledFile, normalizedfile); %normalizes by IHC batch, with batches 2-4 grouped together

%% Intensity Analysis 2: Plot mean+/- SEM normalized intensity values for a particular cortical depth range for each selected group (along with individua data points).
clear all;
close all;
clc

normalizedfile = 'Insert your path/A1_WFA_norm_bydepth_bybatch.csv'; %Auditory cortex
%outputFile = 'Insert your path/A1_WFA_norm_bydepth_L4-6.csv';

%normalizedfile = 'Insert your path/S1_WFA_norm_bydepth_bybatch.csv'; %Somatosensory cortex
%outputFile = ''Insert your path/S1_WFA_norm_bydepth_L4-6.csv';


 deeplayers = [176 737];     %410-1340 um, L4-6
 colArray = {deeplayers};
 ttext = 'Layers 4-6 (410-1340 um)';

%Instrumental training
    groups = {'Untrained', 'ST-0h', 'ST-4h', 'ST-24h'};
    colors = select_colors_instrumental;


%Adaptive training
    %groups = {'Untrained', 'ST-4h','PL-2d','PL-7d'};
    %colors = select_colors_adaptive;

%Pseudotraining
    % groups = {'Untrained', 'ST-Unpaired'};
    % colors = select_colors_unpaired;

%S1
    % groups = {'Untrained', 'ST-4h'};
    % colors = select_colors_adaptive;
    % colors = colors(1:2,:);

plot_barandpoint_intensities(normalizedFile, outputFile, colArray, groups, colors, ttext)

%%
%% Intensity Analysis 3: Evaluate correlation between a behavioral outcome and normalized staining intensity
clear all;
close all;
clc

behaviorfile = '/Insert your path to/max-final-dprime.csv';
intensityfile = 'Insert your path/A1_WFA_norm_bydepth_L4-6.csv';
measureVar = 'Maxdprime';
outFig = 'Insert your path/maxdprimeVsIntensity.pdf';

% behaviorfile = '/Insert your path to/max-final-dprime.csv';
% intensityfile = 'Insert your path/A1_WFA_norm_bydepth_L4-6.csv';
% measureVar = 'Finaldprime';
% outFig = 'Insert your path/finaldprimeVsIntensity.pdf';

% behaviorfile = '/Insert your path to/sessions-to-criterion.csv';
% intensityfile = 'Insert your path/A1_WFA_norm_bydepth_L4-6.csv';
% measureVar = 'SessionsToCriterion';
% outFig = 'Insert your path/sessions-to-criterionVsIntensity.pdf';

% behaviorfile = '/Insert your path to/trials-to-criterion.csv';
% intensityfile = 'Insert your path/A1_WFA_norm_bydepth_L4-6.csv';
% measureVar = 'FirstWindow';
% outFig = 'Insert your path/trials-to-criterionVsIntensity.pdf';

% behaviorfile = '/Insert your path to/thresholds.csv';
% intensityfile = 'Insert your path/A1_WFA_norm_bydepth_L4-6_adaptive.csv'; 
% measureVar = 'StartThresh';
% outFig = 'Insert your path/startThreshvsIntensity.pdf';

% behaviorfile = '/Insert your path to/thresholds.csv';
% intensityfile = 'Insert your path/A1_WFA_norm_bydepth_L4-6_adaptive.csv'; 
% measureVar = 'EndThresh';
% outFig = 'Insert your path/endThreshvsIntensity.pdf';

% behaviorfile = '/Insert your path to/thresholds.csv';
% intensityfile = 'Insert your path/A1_WFA_norm_bydepth_L4-6_adaptive.csv'; 
% measureVar = 'Improvement';
% outFig = 'Insert your path/ImprovementvsIntensity.pdf';

stats = plotBehaviorIntensityCorrelation(behaviorfile, intensityfile, measureVar, outFig);

%%
%% Intensity Analysis 4: Plot mean +/- perfusion time by group
clear all;
close all;
clc

normalizedFile = 'Insert your path to/A1_WFA_norm_bydepth.csv';
figsavepath = 'Insert your path/TimePerfused.pdf';

%Instrumental training
groups = {'Untrained', 'ST-0h', 'ST-4h', 'ST-24h', 'PL-2d','PL-7d'};
colors = select_colors_instrumental;
colors2 = select_colors_adaptive;
colors2 = colors2(3:4,:);
colors = [colors;colors2];


plot_perfusionTimes(normalizedFile, figsavepath, groups, colors)

%%
%% PNN Preprocessing: Compile data from all animals
clc
clear all;
close all;

%Auditory cortex
    inputFolder = 'Insert your path to/PNNs/A1/';
    outputCSV = 'Insert your path/A1_PNNs.csv';
    Tcompiled = compile_pnn_folder(inputFolder, outputCSV);

%Somatosensory cortex
    % inputFolder = 'Insert your path to/PNNs/S1/';
    % outputCSV = 'Insert your path/S1_PNNs.csv';
    % Tcompiled = compile_pnn_folder_v2(inputFolder, outputCSV);



%% PNN Preprocessing: Merge with metadata
clear all;
close all;
clc;

%Inputs
subjectsummary = 'Insert your path to Subject summary.xlsx';
sheetname = 'IHC';
compiledFile =  'Insert your path to/A1_PNNs.csv'; %Auditory cortex
%compiledFile =  'Insert your path to/S1_PNNs.csv'; %Somatosensory cortex

%Function
merge_with_metadata(compiledFile, subjectsummary,sheetname);

%% PNN Preprocessing: Filter data to only PNNs that exceed a define threshold intensity value, normalize  to the mean of the untrained group by IHC batch, layer, and PV+/PNN- status.
clear all;
close all;
clc

compiledFile =  'Insert your path to/A1_PNNs.csv'; %Auditory cortex
outputPath = 'Insert path where normalized output file should be saved';
tblNorm = normalize_PNNs(compiledFile, outputPath);

%compiledFile =  'Insert your path to/S1_PNNs.csv'; %Somatosensory cortex
%outputPath = 'Insert path where normalized output file should be saved';
%tblNorm = normalize_PNNs_v2(compiledFile, outputPath);


%% PNN Analysis: Plot mean +/- SEM intensity values for each group, separated by colocalization with PV+ cells 
clear all;
close all;
clc

%Auditory cortex
    inputFile =  '/Insert your path to/A1_PVpos_PNNs_normalized.csv'; %PV+ PNNs
    outputFile = '/Insert your path to/A1_PVpos_PNNs_normalized_pseudotraining.csv'; %PV+ PNNs
    ttext = 'A1 Layers 4-6, PV+ PNNs';
    
    % inputFile =  '/Insert your path to/A1_PVneg_PNNs_normalized.csv'; %PV- PNNs
    % outputFile = '/Insert your path to/A1_PVneg_PNNs_normalized_pseudotraining.csv'; %PV- PNNs
    % ttext = 'A1 Layers 4-6, PV- PNNs';

    %Instrumental training
    groups = {'Untrained', 'ST-0h', 'ST-4h', 'ST-24h'};
    colors = select_colors_instrumental;

    %Adaptive training
        % groups = {'Untrained', 'ST-4h','PL-2d','PL-7d'};
        % colors = select_colors_adaptive;

    %Pseudotraining
        % groups = {'Untrained', 'ST-Unpaired'};
        % colors = select_colors_unpaired;


%%%%%S1%%%%%
% inputFile =  '/Insert your path to/S1_PVpos_PNNs_normalized.csv'; %PV+ PNNs
% outputFile = '/Insert your path to/S1_PVpos_PNNs_normalized_pseudotraining.csv'; %PV+ PNNs
% ttext = ' S1 Layers 4-6, PV+ PNNs';

% inputFile =  '/Insert your path to/S1_PVneg_PNNs_normalized.csv'; %PV- PNNs
% outputFile = '/Insert your path to/S1_PVneg_PNNs_normalized_pseudotraining.csv'; %PV- PNNs
% ttext = 'S1 Layers 4-6, PV- PNNs';


%Instrumental training
    % groups = {'Untrained','ST-4h'};
    % colors = select_colors_instrumental;
    % colors(2,:) = colors(3,:);
    % colors(3:4,:) = [];


plot_barandpoint_PNNintensities(inputFile, outputFile, groups, colors, ttext)

%% PNN Analysis: Plot mean +/- PNN  densities for all PNNs, PV+ PNNs, and PV- PNNs
clear all;
close all;
clc

%Auditory cortex
    pvposFile =  'Insert your path to/A1_PVpos_PNNs_normalized.csv'; %PV+ PNNs
    pvnegFile =  'Insert your path to/A1_PVneg_PNNs_normalized.csv'; %PV- PNNs

    layersToInclude = {'L4','L5','L6'};
 
    groups = {'Untrained', 'ST-0h', 'ST-4h', 'ST-24h'};
    colors = select_colors_instrumental;
    outPrefix = '/Insert your path/A1_PNN_densities_instrumental';

    % groups = {'Untrained', 'ST-4h','PL-2d','PL-7d'};
    % colors = select_colors_adaptive;
    % outPrefix = '/Insert your path/IHC/A1_PNN_densities_adaptive';

    % groups = {'Untrained', 'ST-Unpaired'};
    % colors = select_colors_unpaired;
    % outPrefix = '/Insert your path/A1_PNN_densities_pseudotraining';

    Tcounts = pnn_densities(pvposFile, pvnegFile, outPrefix, groups, colors, layersToInclude);


%Somatosensory cortex
    pvposFile =  'Insert your path to/S1_PVpos_PNNs_normalized.csv'; %PV+ PNNs
    pvnegFile =  'Insert your path to/S1_PVneg_PNNs_normalized.csv'; %PV- PNNs

    groups = {'Untrained', 'ST-4h'}; %For S1
    colors = select_colors_adaptive;
    colors = colors(1:2,:);
    outPrefix = '/Insert your path/S1_PNN_densities_instrumental';


    Tcounts = pnn_densities_v2(pvposFile, pvnegFile, outPrefix, groups, colors);


%