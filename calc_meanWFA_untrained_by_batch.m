function calc_meanWFA_untrained_by_batch(inCSV, outCSV)
% calc_meanWFA_untrained_by_batch(inCSV,outCSV)
%
% Calculates per-subject average WFA intensities from plot profile data.
% Returns a table with just the data from untrained animals.
% 
% Inputs
%   inCSV  - path to CSV with data (rows = subjects)
%   outCSV - path to output CSV
%
% Written by ML Caras June 2025


% Load table
T = readtable(inCSV);

% Define variables
allVars   = T.Properties.VariableNames;
MetaVars  = {'SubjectID','Group','Batch','IHCMethod','Sex','Age','TimePerfused'};
MeasVars = setdiff(allVars, MetaVars, 'stable');

% Compute per-animal mean across intensity columns
T.MeanWFA = mean(T{:, MeasVars}, 2, 'omitnan');

% Filter the data
isSelGroup = ismember(T.Group, 'Untrained');
tblFilt = T(isSelGroup, :);
Tout = tblFilt(:,[MetaVars,'MeanWFA']);


% Output table
writetable(Tout, outCSV);
fprintf('Saved per-animal means to %s\n', outCSV);

end
