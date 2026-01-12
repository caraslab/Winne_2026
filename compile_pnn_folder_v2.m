function Tcompiled = compile_pnn_folder_v2(inputFolder, outputCSV)
% Tcompiled = compile_pnn_folder_v2(inputFolder, outputCSV)
%
% Description:
%   Scans a folder of per-subject CSV files in which each row describes a
%   single PNN. Each file has four columns:
%     (1) Region string encoding hemisphere, slice, and layer
%     (2) PNN_TRUE      – 1/0 flag for passing the threshold
%     (3) PV+PNN        – 1/0 flag for PV association
%     (4) mean          – WFA staining intensity for that PNN
%   This function parses column 1 into separate variables (Hemisphere,
%   Slice, Layer), adds a SubjectID parsed from the filename (3 digits),
%   and compiles rows from all files into a single table.
%
% Inputs:
%   inputFolder – string; path to the directory containing the subject CSVs.
%                 Filenames are expected to contain a 3-digit SubjectID,
%                 e.g., 'SUBJ-ID-358.csv' or '..._358.csv'.
%   outputCSV   – string; path where the compiled CSV will be written.
%
% Outputs:
%   Tcompiled   – MATLAB table with columns:
%                 SubjectID | Hemisphere | Slice | Layer | PNN_TRUE | PV_PNN | mean
%                 NOTE: The output column PV_PNN corresponds to the input
%                 header 'PV+PNN' (MATLAB variable names cannot contain '+').
%
% Written by ML Caras June 2025

    arguments
        inputFolder (1,1) string
        outputCSV   (1,1) string
    end

    % 1) Locate CSV files
    files = dir(fullfile(inputFolder, '*.csv'));
    if isempty(files)
        error('No CSV files found in folder: %s', inputFolder);
    end

    % 2) Storage for per-file tables
    allTabs = cell(numel(files),1);

    % 3) Process each file
    for k = 1:numel(files)
        fpath = fullfile(files(k).folder, files(k).name);

        % Extract 3-digit SubjectID from filename (first match)
        tok = regexp(files(k).name, '(\d{3})', 'tokens', 'once');
        if isempty(tok)
            warning('Skipping %s: could not parse 3-digit SubjectID from filename.', files(k).name);
            continue
        end
        subjectID = str2double(tok{1});

        % Read the file (keep as strings where helpful)
        T = readtable(fpath, 'TextType','string');

        % Basic validation / column access by position to be robust to headers
        if width(T) < 4
            warning('Skipping %s: expected at least 4 columns.', files(k).name);
            continue
        end

        % Column positions (1..4)
        colRegion   = 1;
        colPNNTrue  = 2;
        colPV       = 3;
        colMean     = 4;

        % Parse the Region column (e.g., 'LEFT2')
        m = regexp(T{:, colRegion}, '^(LEFT|RIGHT)\s*(\d+)$', 'tokens', 'once');
        hemi  = string(cellfun(@(c)c{1}, m, 'UniformOutput', false));
        slice = double(cellfun(@(c)str2double(c{2}), m));


        % Build a clean per-file table with standardized variable names
        Tclean = table();
        Tclean.SubjectID  = repmat(subjectID, height(T), 1);
        Tclean.Hemisphere = hemi;
        Tclean.Slice      = slice;
        Tclean.PNN_TRUE   = T{:, colPNNTrue};
        % MATLAB variable names cannot contain '+', so use PV_PNN internally.
        Tclean.PV_PNN     = T{:, colPV};
        Tclean.mean       = T{:, colMean};

        allTabs{k} = Tclean;
    end

    % 4) Concatenate all subjects
    allTabs = allTabs(~cellfun(@isempty, allTabs));
    if isempty(allTabs)
        error('No valid subject tables were constructed from: %s', inputFolder);
    end
    Tcompiled = vertcat(allTabs{:});

    % 5) Write compiled CSV
    writetable(Tcompiled, outputCSV);
   

    fprintf('Compiled %d files into %s (%d rows).\n', numel(files), outputCSV, height(Tcompiled));
end