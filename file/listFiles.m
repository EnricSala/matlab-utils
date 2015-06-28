function [ result ] = listFiles( base_path, type )
% Lists the files or dirs inside a folder
% Accepts type 'dirs' and 'files'

% Find all items
all_items = dir(base_path);

if strcmp('dirs', type)
    % Only take dirs
    dir_items = [all_items(:).isdir];
    all_dirs = {all_items(dir_items).name};
    
    % Remove '.' and '..'
    all_dirs(ismember(all_dirs,{'.','..'})) = [];
    result = sort(all_dirs)';
    
elseif strcmp('files', type)
    % Only take files
    file_items = ~[all_items(:).isdir];
    all_files = {all_items(file_items).name};
    result = sort(all_files)';
    
else
    error(['unkown scan type: ' type]);
end
end
