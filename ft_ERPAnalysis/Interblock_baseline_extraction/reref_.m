% Define input and output directories
inputDir = 'D:\OExpOut\processed_data\ft_subSovCond';
outputDir = 'D:\OExpOut\processed_data\ft_subSovCond_rerefMastoid';

% Check if output directory exists, if not, create it
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Get list of .mat files in input directory
matFiles = dir(fullfile(inputDir, '*.mat'));

% Loop over each .mat file
for i = 1:length(matFiles)
    if contains(matFiles(i).name, 'Nbl')    continue;   end
%     if ~contains(matFiles(i).name, 'wake_night')   continue;  end
%     if ~contains(matFiles(i).name, 'AO')   continue;  end

    % Define the output file path and check if it already exists
    [~, name, ~] = fileparts(matFiles(i).name);
    ft_file_path = sprintf('%s\\%s.mat',outputDir,name);
    if exist(ft_file_path, 'file')    continue;   end

    % Load the EEG data
    inputFile = fullfile(inputDir, matFiles(i).name);
    data = load(inputFile); 
    fieldName = fieldnames(data);
    EEG_avg = data.(fieldName{1});

    % FieldTrip mastoid rereferencing
    cfg = [];
    cfg.reref = 'yes';
    cfg.refchannel = {'E100', 'E57'};
    cfg.refmethod = 'avg';
    ft_data = ft_preprocessing(cfg, EEG_avg);

    % Save rereferenced data to output directory
    save(ft_file_path,"ft_data");
end
