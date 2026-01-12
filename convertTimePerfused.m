function tbl = convertTimePerfused(inputCSV)
% convertTimePerfused(inputCSV)
%
% Description:
%   Reads a CSV file containing a 'TimePerfused' column formatted as 'h:mm a'
%   (e.g., '6:30 AM' or '6:30 PM'). Converts these values to decimal hours since
%   midnight and overwrites the TimePerfused column with the converted numeric
%   values. Writes the updated table back to the same CSV file.
%
% Inputs:
%   inputCSV   - String. Path to the CSV file to process (overwritten in place).
%
% Outputs:
%   tbl        - Table. Updated table with numeric values in 'TimePerfused'.
%
%   Written by ML Caras Aug 2025

% Verify the file exists
if ~isfile(inputCSV)
    error('File not found: %s', inputCSV);
end

% Read the CSV into a table
opts = detectImportOptions(inputCSV);
tbl  = readtable(inputCSV, opts);

% Ensure the TimePerfused column exists
if ~ismember('TimePerfused', tbl.Properties.VariableNames)
    error('Input table must contain a ''TimePerfused'' column.');
end

% Convert TimePerfused strings to datetime
% Handle both char and string arrays
timeData = tbl.TimePerfused;
timeData = string(timeData);
t = datetime(timeData, ...
    'InputFormat', 'h:mm a', ...  % e.g. '6:30 AM'
    'Locale', 'en_US');       % ensure AM/PM parsing

% Compute decimal hours since midnight
HoursPerfused = hour(t) + minute(t)/60;
tbl.TimePerfused = HoursPerfused;

% Write the updated table back to the same CSV file
writetable(tbl, inputCSV);
fprintf('Updated ''TimePerfused'' in %s\n', inputCSV);
end