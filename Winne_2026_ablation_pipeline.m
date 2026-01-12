%% ABLATION PIPELINE
% This pipeline contains code for preprocessing and analyzing imaging and 
% behavior data for Winne et al. 2026. This is pipeline 2 of 2, focused on 
% the analysis of the behavioral consequences of enzymatic ECM digestion. 
% Pipeline 1 of 2 is focused on the analysis of spatiotemporal dynamics of
% ECM integrity during auditory learning.   
% 
% Written by ML Caras. Finalized Jan 12, 2026.


%% Behavior Preprocessing: Extract thresholds, calculate learning rate and improvement, and merge with metadata
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to/Subject summary.xlsx';
matFolder = 'Insert your path to /BehaviorFiles/';

%During perceptual learning
    sheetName = 'Ablation During PL'; 
    outCSV = 'Insert your path/ablation_during_PL_thresholds.csv';
    ndays = 8;

%After perceptual learning
    % sheetName = 'Ablation After PL'; 
    % outCSV = 'Insert your path/ablation_after_PL_thresholds.csv';
    % ndays = 10;

resultTbl = extractThresholdsandLearning_ablation(subjectsummary, sheetName, matFolder, outCSV, ndays);

%% Behavior Preprocessing: Extract FA rates and merge with metadata

clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to/Subject summary.xlsx';
matFolder = 'Insert your path to /BehaviorFiles/';

%During perceptual learning
    sheetName = 'Ablation During PL'; 
    outCSV = 'Insert your path/ablation_during_PL_FArates.csv';
    ndays = 8;

% After perceptual learning
    % sheetName = 'Ablation After PL';
    % outCSV = 'Insert your path/ablation_after_PL_FArates.csv';
    % ndays = 10;

resultTbl = extractFARates_ablation(subjectsummary, sheetName, matFolder, outCSV, ndays);
%% Behavior Preprocessing: Extract trial numbers and merge with metadata
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to/Subject summary.xlsx';
matFolder = 'Insert your path to /BehaviorFiles/';

%During perceptual learning
    sheetName = 'Ablation During PL';
    outCSV = '/Insert your path/ablation_during_PL_numtrials.csv';
    ndays = 8;

%After perceptual learning
    % sheetName = 'Ablation After PL';
    % outCSV = '/Insert your path/ablation_after_PL_numtrials.csv';
    % ndays = 10;

resultTbl = extractnumtrials_ablation(subjectsummary, sheetName, matFolder, outCSV, ndays);


%%
%% Behavior Analysis- Ablations during instrumental Learning: Calculate and plot mean +/- SEM dprime values as a function of session
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to/Subject summary.xlsx';
sheetName = 'Ablation During IL';
groups = {'Saline','Penicillinase','chABC'};
matFolder = '/Insert your path to/InstrumentalLearningBehaviorFiles';
figsavepath = '/Insert your path/';
outCSV = 'Insert your path/dprime-by-session.csv';
   
%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5];%saline
clrs(2,:) = cmap(4,:); %penicillinase
clrs(3,:) = cmap(7,:); %chABC



%Run Function
plotDprimeBySession(subjectsummary, sheetName, groups, matFolder, clrs, figsavepath, outCSV)

%% Behavior Analysis- Ablations during instrumental learning: Calculate and plot number of sessions animals needed to reach d'>=2
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to/Subject summary.xlsx';
sheetName = 'Ablation During IL';
groups = {'Saline','Penicillinase','chABC'}; 
matFolder = '/Insert your path to/InstrumentalLearningBehaviorFiles';
figsavepath = '/Insert your path/';
outCSV = 'Insert your path/sessions-to-criterion.csv';
criterion = 2;

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(4,:); %pencillinase
clrs(3,:) = cmap(7,:); %chABC


%Calculate
resultTbl = quantifySessionsToCriterion(subjectsummary, sheetName, groups, matFolder, outCSV, 2);


%Plot
plotSessionsToCriterion(resultTbl,groups,clrs,figsavepath);

%% Behavior Analysis- Ablations during instrumental learning: Calculate and plot mean +/- SEM dprime values as a function of trial, and calculate the number of trials needed to reach d'>= 2
clear all;
close all;
clc


%Inputs
subjectsummary = 'Insert your path to/Subject summary.xlsx';
sheetName = 'Ablation During IL';
groups = {'Saline','Penicillinase','chABC'}; 
matFolder = '/Insert your path to/InstrumentalLearningBehaviorFiles';
figsavepath = '/Insert your path/';
outCSV = 'Insert your path/dprime-by-trial.csv';
outCSV2 = 'Insert your path/trials-to-criterion.csv';
windowsize = 75;

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(4,:); %pencillinase
clrs(3,:) = cmap(7,:); %chABC


%Calculate and plot
resultsTbl = plotDprimeByTrial(subjectsummary, sheetName, groups, matFolder, clrs, figsavepath, outCSV, windowsize);
plotTrialsToCriterion(resultsTbl, outCSV2, clrs,figsavepath)
%% Behavior Analysis- Ablations during instrumental learning: Calculate and plot the maximum and final d' achieved in a given session
clear all;
close all;
clc

%Inputs
subjectsummary = 'Insert your path to/Subject summary.xlsx';
sheetName = 'Ablation During IL';
groups = {'Saline','Penicillinase','chABC'}; 
matFolder = '/Insert your path to/InstrumentalLearningBehaviorFiles';
outCSV = 'Insert your path/max-final-dprime.csv';
figsavepath = '/Insert your path/';

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(4,:); %pencillinase
clrs(3,:) = cmap(7,:); %chABC


%Calculate
resultTbl = quantifyMaxDprime(subjectsummary, sheetName, groups, matFolder, outCSV);

%Plot
plotMaxFinalDprime(resultTbl,groups,clrs,figsavepath)

%%
%% Behavior Analysis- Ablation during perceptual learning: Plot threshold vs.day, improvement, final threshold, and learning rates by group
clear all;
close all;
clc


%Inputs
datafile = '/Insert your path to/ablation_during_PL_thresholds.csv';

cutoff = 2.55;  % lower bound of 95% CI for Penicillinase WFA distribution-- 
                % any chABC-treated animal for which the WFA area exceeds 
                % this value should be excluded from the group analyses

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(4,:);     %penicillinase
clrs(3,:) = cmap(7,:);     %chABC

figsavepath = 'Insert your path';

plotAblationDuringPLData(datafile,cutoff,clrs,figsavepath)

%% Behavior Analysis- Ablation during perceptual learning: Plot FA rate vs day
clear all;
close all;
clc

%Inputs
datafile = '/Insert your path to/ablation_during_PL_FArates.csv';
cutoff = 2.55;  % lower bound of 95% CI for Penicillinase WFA distribution-- 
                % any chABC-treated animal for which the WFA area exceeds 
                % this value should be excluded from this analysis

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(4,:); %pencillinase
clrs(3,:) = cmap(7,:); %chABC

figsavepath = 'Insert your path';

plotAblationDuringPLFAs(datafile,cutoff,clrs,figsavepath)

%% Behavior Analysis- Ablation during perceptual learning: Plot num trials vs day
clear all;
close all;
clc

%Inputs
datafile = '/Insert your path to/ablation_during_PL_numtrials.csv';
cutoff = 2.55;  % lower bound of 95% CI for Penicillinase WFA distribution-- 
                % any chABC-treated animal for which the WFA area exceeds 
                % this value should be excluded from this analysis


%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(4,:); %pencillinase
clrs(3,:) = cmap(7,:); %chABC

figsavepath = 'Insert your path';

plotAblationDuringPLnumtrials(datafile,cutoff,clrs,figsavepath)


%% Behavior Analysis- Ablation during perceptual learning: Plot correlation between behavior and area in A1 occupied by WFA
clear all;
close all;
clc

datafile = '/Insert your path to/ablation_during_PL_thresholds.csv';

% WFA coverage vs. Learning rate
    param = 'LearningRate';
    figsavepath = '/Insert your path to/WFAvsLearningRate.pdf';
    ytext = 'Learning Rate (dB/log(day))';

% WFA coverage vs. final threshold  
    % param = 'ThresholdDay8';
    % figsavepath = '/Insert your path to/WFAvsFinalThresh.pdf';
    % ytext = 'Final Threshold (dB)';

% WFA coverage vs. Improvement
    % param = 'Improvement';
    % figsavepath = '/Insert your path to/WFAvsImprovement.pdf';
    % ytext = 'Improvement (dB)';

% WFA coverage vs. starting threshold
    % param = 'ThresholdDay1';
    % figsavepath = '/Insert your path to/WFAvsStartThresh.pdf';
    % ytext = 'Starting Threshold (dB)';


plotbehaviorWFAcorrelation(datafile,param,ytext,figsavepath)

%% Behavior Analysis- Ablation during perceptual learning: Plot representative psychometric functions
clear all;
close all;
clc

chABC = load('/Insert your path/BehaviorFiles/SUBJ-ID-706_allSessions.mat'); %chABC
saline = load('/Insert your path/BehaviorFiles/SUBJ-ID-690_allSessions.mat'); %Saline
pase = load('/Insert your path/BehaviorFiles/SUBJ-ID-887_allSessions.mat'); %penicillinase

plot_ablation_pfs(chABC,saline,pase)
%%
%% Behavior Analysis- Ablation after perceptual learning: Plot final adaptive threshold and post-infusion thresholds
clear all;
close all;
clc

%Inputs
datafile = '/Insert your path/ablation_after_PL_thresholds.csv';
cutoff = 2.55;  % lower bound of 95% CI for Penicillinase WFA distribution-- 
                % any chABC-treated animal for which the WFA area exceeds 
                % this value should be excluded from this analysis

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(7,:); %chABC

figsavepath = '/Insert your path/';

plotAblationAfterPLData(datafile,cutoff,clrs,figsavepath)

%% Behavior Analysis- Ablation after perceptual learning: Plot FA rate vs day
clear all;
close all
clc


%Inputs
datafile = '/Insert your path/ablation_after_PL_FArates.csv';
cutoff = 2.55;  % lower bound of 95% CI for Penicillinase WFA distribution-- 
                % any chABC-treated animal for which the WFA area exceeds 
                % this value should be excluded from this analysis

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(7,:); %chABC

%Which days to plot
dayvec = [8:10];

figsavepath = '/Insert your path/';

plotAblationDuringPLFAs(datafile,cutoff,clrs,figsavepath,dayvec)

%% Behavior Analysis- Ablation after perceptual learning : Plot num trials vs day
clear all;
close all;
clc

%Inputs
datafile = '/Insert your path/ablation_after_PL_numtrials.csv';
cutoff = 2.55;  % lower bound of 95% CI for Penicillinase WFA distribution-- 
                % any chABC-treated animal for which the WFA area exceeds 
                % this value should be excluded from this analysis

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(7,:); %chABC

%Which days to plot
dayvec = [8:10];

figsavepath = '/Insert your path/';

plotAblationDuringPLnumtrials(datafile,cutoff,clrs,figsavepath,dayvec)

%% 



%% NeuN density analysis

close all;
clear all;
clc

%Inputs
NeuNFile = '/Insert your path/NeuNCellCounts.xlsx';
outCSV = 'Insert your path/NeuNDensities.csv';

%Color map
cmap = colormap('lines');
clrs(1,:) = [0.5 0.5 0.5]; %saline
clrs(2,:) = cmap(4,:);     %penicillinase
clrs(3,:) = cmap(7,:);     %chABC

NeuNdensities(NeuNFile,clrs,outCSV)