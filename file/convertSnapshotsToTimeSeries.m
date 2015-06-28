function [ ] = convertSnapshotsToTimeSeries(input_dir, output_dir)

% Verify input and output folders exist
narginchk(2, 2)
IS_DIR = 7;
assert(exist(input_dir, 'dir') == IS_DIR, ...
    'Input directory does not exist: %s', input_dir);
assert(exist(output_dir, 'dir') == IS_DIR, ...
    'Output directory does not exist: %s', output_dir);

% Build UTC Date formatter
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;
pattern = 'yyyy-MM-dd-HH-mm';
formatter = SimpleDateFormat(pattern, Locale.ENGLISH);
formatter.setTimeZone(TimeZone.getTimeZone('UTC'));

% Find all subfolders
snap_dirs = listFiles(input_dir, 'dirs');
DIRS_AMOUNT = length(snap_dirs);
assert(DIRS_AMOUNT > 0, 'Could not find any Snapshot folder');

% Initialize variables
bar = waitbar(0, 'Finding Snapshot dirs...', 'Name', 'Converting Snapshots');
file_map = containers.Map();

% Iterate over the Snapshot folders
try
    for i = 1:DIRS_AMOUNT
        waitbar((i-1)/DIRS_AMOUNT, bar, ['Processing folder: ' snap_dirs{i}]);
        current_dir = fullfile(input_dir, snap_dirs{i});
        snap_files = listFiles(current_dir, 'files');
        
        % Iterate over snapshot files in this folder
        FILES_AMOUNT = length(snap_files);
        for j = 1:FILES_AMOUNT
            waitbar((i-1)/DIRS_AMOUNT + (j-1)/FILES_AMOUNT/DIRS_AMOUNT, bar);
            
            current_file_name = snap_files{j};
            current_file = fullfile(current_dir, current_file_name);
            
            % Get timestamp
            timestamp = extractUtcTimestamp(current_file_name, formatter);
            
            % Get data and clean tag ids
            table = readtable(current_file, 'ReadVariableNames', false, 'Format','%s%s');
            values = table.Var2;
            original_names = strtrim(table.Var1);
            clean_names = regexprep(original_names, '[^\w-]', '_');
            clean_names = regexprep(clean_names, '_+', '_');
            
            % Write data to files
            POINTS_AMOUNT = length(clean_names);
            for k = 1:POINTS_AMOUNT
                tag_id = clean_names{k};
                original_tag_id = original_names{k};
                
                if ~file_map.isKey(tag_id)
                    % Create new file and keep fileID
                    out_file = fullfile(output_dir, [tag_id '.csv']);
                    disp(['## Creating file ' out_file]);
                    fileID = fopen(out_file,'w');
                    file_map(tag_id) = fileID;
                    fprintf(fileID, '%s\n', original_tag_id);
                else
                    % Find existing fileID
                    fileID = file_map(tag_id);
                end
                fprintf(fileID, '%d,%s\n', timestamp, values{k});
            end
        end
    end
catch exception
    disp(exception)
end
closeFiles(file_map);
close(bar)
end

% Function to extract the timestamp from filename
function [ timestamp ] = extractUtcTimestamp(file, parser)
[~, clean_filename] = fileparts(file);
timestamp = int64(parser.parse(clean_filename).getTime());
end

% Function to close a map of name -> fileID
function [ ] = closeFiles(map)
file_names = map.keys;
for i = 1:length(file_names)
    try
        name = file_names{i};
        fileID = map(name);
        disp(['## Closing file ' name]);
        fclose(fileID);
    catch
        warning(['Error closing file: ' name]);
    end
end
end
