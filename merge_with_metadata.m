function Tmerged = merge_with_metadata(aggregatedFile, metadataFile, sheetname)
% Tmerged = merge_with_metadata(aggregatedFile, metadataFile)
%
% Description:
%   Reads an aggregated data CSV and a metadata CSV, merges
%   the metadata fields (Group, IHC Method, Sex, Age, Time Perfused) into the aggregated
%   data table, and reorders the columns so that metadata appear immediately
%   to the right of SubjectID.
%
% Inputs:
%   aggregatedFile – string; path to CSV with aggregated WFA intensity. Must
%                    contain variable 'SubjectID'.
%   metadataFile   – string; path to xlsx file with subject-level metadata.
%   sheetname      - string; provides the name of sheet in the metadatafile
%                    that contains the metadata of interest. (different sheets contain
%                    metadata for different experiments). Sheet must
%                    contain variables 'SubjectID', 'Group', 'Batch', 'IHC
%                    Method', 'Sex', 'Age', and 'TimePerfused'. Other columns will be ignored.
%
% Outputs:
%   Tmerged        – MATLAB table original intensity columns and metadata
%                    combined
%
%  Saves a csv file with the merged data to the data directory.
%
% Written by ML Caras June 2025


% Read compiled intensity data
Tagg = readtable(aggregatedFile);

%Inspect the metadata files variable import options
opts = detectImportOptions(metadataFile, 'Sheet', sheetname);

%Force the TimePerfused column to come in as datetime, using the known format
opts = setvaropts(opts, 'TimePerfused',  'Type', 'datetime', ...
    'InputFormat','hh:mm a');    % e.g. “8:10 PM”

% Read metadata and clean up variable names
Tmeta = readtable(metadataFile,opts);

% Verify required metadata columns exist
requiredMeta = {'SubjectID','Group','Batch','IHCMethod','Sex','Age','TimePerfused'};
missing = setdiff(requiredMeta, Tmeta.Properties.VariableNames);
if ~isempty(missing)
    error('Metadata table is missing required columns: %s', strjoin(missing,', '));
end

% Select only the required metadata columns
Tmeta = Tmeta(:, requiredMeta);

% Merge tables on SubjectID (inner join to keep only matching subjects)
Tmerged = innerjoin(Tagg, Tmeta, 'Keys', 'SubjectID');

% Reorder columns: SubjectID, metadata, then all other vars
metaVars  = {'Group','Batch','IHCMethod','Sex','Age','TimePerfused'};
allVars   = Tmerged.Properties.VariableNames;
otherVars = setdiff(allVars, [{'SubjectID'}, metaVars], 'stable');
Tmerged   = Tmerged(:, [{'SubjectID'}, metaVars, otherVars]);

%Save merged table to CSV
writetable(Tmerged, aggregatedFile);

end