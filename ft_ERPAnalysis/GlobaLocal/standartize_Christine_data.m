restoredefaultpath
addpath D:\matlab_libs\fieldtrip-20230223
ft_defaults

%% get list of sub names

inputFolder = 'D:\GlobalLocal\Data'; 

% Get list of all .mat files in the input folder
files = dir(fullfile(inputFolder, '*.mat'));

% Initialize a cell array to hold unique subject IDs
subjectIDs = {};

% Loop through each file
for i = 1:length(files)
    filename = files(i).name;
    
    % Check if the filename has at least four underscores
    if count(filename, '_') < 4
        continue;  % Skip this file
    end
    
    % Extract the subject ID from the filename
    parts = split(filename, '_');
    subjectID = parts{1};
    
    % Add subject ID to the list if not already present
    if ~ismember(subjectID, subjectIDs)
        subjectIDs{end+1} = subjectID;
    end
end

% Format the subject IDs into the specified string format
formattedIDs = sprintf("{'%s'}", strjoin(subjectIDs, "','"'));

% Display the result
disp(formattedIDs);

%% transform Christines data to my format
% Define input and output folders
inputFolder = 'D:\GlobalLocal\Data\expomit_ctrl 041024';  % !!!!!!!!!!!!!!!!!!!!!!!!!NOTICEE!!!!!!!!!!!!!!!!!!! if not ctrl, comment out "Apply the offset" section
outputFolder = 'D:\GlobalLocal\ft_subSovCond_blPreO';  % Replace with your actual output folder 

% Get list of all .mat files in the input folder
files = dir(fullfile(inputFolder, '*.mat'));

% Initialize a structure to hold grouped data information
groupedDataInfo = struct();

% Loop through each file to determine groupings and output filenames
for i = 1:length(files)
    filename = files(i).name;
    
    % Check if the filename has at least four underscores
    if contains(filename, 'notrials')
        continue;  % Skip this file
    end
    
    % Extract parts of the filename
    parts = split(filename, '_');
    subjectID = parts{1};
    sleepOrWake = parts{3};  % 'wakepre' or 'sleep'
    mel = parts{4};  % 'mel+' or 'mel-'
    expomit = parts{5};  % 'expomit' or 'unexpomit' or 'expomitctrl'
    sleepStage = '';  % For sleep files, we will extract sleep stage
    
    % For sleep files, extract the sleep stage
    if contains(sleepOrWake, 'sleep')
        sleepStage = parts{6};
         if strcmp(sleepStage, 'R')
            sleepStage = 'REM';  % Rename 'R' to 'REM'
        end
        key = ['s_' subjectID '_' sleepStage '_' expomit];
    else
        key = ['s_' subjectID '_wake_night_' expomit];
    end
    
    % Store information for processing
    if isfield(groupedDataInfo, key)
        groupedDataInfo.(key) = [groupedDataInfo.(key), {filename}];
    else
        groupedDataInfo.(key) = {filename};
    end
end

% Process each group and save the combined data
keys = fieldnames(groupedDataInfo);
for i = 1:length(keys)
    key = keys{i};
    outputFilename = [key '.mat'];
    outputPath = fullfile(outputFolder, outputFilename);
    
    % Check if the output file already exists
    if isfile(outputPath)
        fprintf('Skipping %s, already exists.\n', outputFilename);
        continue;  % Skip to the next file
    end
    
    % Initialize cfg for ft_appenddata
    cfg = {};
%     cfg.keepsampleinfo='no';
    combinedData = [];
    
    % Loop through each file in the group and combine the data
    for j = 1:length(groupedDataInfo.(key))
        filename = groupedDataInfo.(key){j};
        filepath = fullfile(inputFolder, filename);
        
        % Load the data variable from the .mat file
        dataStruct = load(filepath);
        fieldNames = fieldnames(dataStruct);
        dataField = fieldNames{startsWith(fieldNames, 'data')};
        data = dataStruct.(dataField);
        data = rmfield(data,'trialinfo');

        if ~numel(data.trial) continue; end
        
        % Append data using FieldTrip's ft_appenddata
        if isempty(combinedData)
            combinedData = data;
        else
            combinedData = ft_appenddata(cfg, combinedData, data);
        end
    end

 
    if~( isempty(combinedData))

        %%%%% Apply the offset %%%%%%
        Fs = combinedData.fsample; % Extract the sampling rate from the data structure
        offset_in_samples = round(0.15 * Fs); % 150 ms = 0.15 seconds
        cfg = [];
        cfg.offset = -offset_in_samples; % Negative because we want to move backward to make 150ms the new zero
        combinedData = ft_redefinetrial(cfg, combinedData);

        % Manually add 150 ms padding to the end of each trial
        pad_time = 0.15; % Padding duration in seconds
        pad_samples = round(pad_time * Fs); % Convert to samples
        for trialIdx = 1:length(combinedData.trial)
            % Get original data and time
            trial_data = combinedData.trial{trialIdx};
            trial_time = combinedData.time{trialIdx};
    
            % Create padding
            zero_padding = zeros(size(trial_data, 1), pad_samples); % Zero padding for each channel
            time_padding = trial_time(end) + (1:pad_samples) / Fs; % Time vector for padding
    
            % Append padding to trial
            combinedData.trial{trialIdx} = [trial_data, zero_padding];
            combinedData.time{trialIdx} = [trial_time, time_padding];
        end

        
        % Define time limits
        cfg = [];
        cfg.toilim = [-2, 2]; % Cut trials to be between -2 and 2 seconds
        combinedData = ft_redefinetrial(cfg, combinedData);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Baseline-correction
        cfg.demean          = 'yes';
        cfg.baselinewindow  = [-0.1 0]; % [-1 -0.6]

                cfg.reref         = 'yes';
                cfg.refchannel = 'all'; % else the data linked to mastoid

        combinedData = ft_preprocessing(cfg,combinedData);

        
        % Save the combined data with the variable name 'ft_data'
        ft_data = combinedData;
        save(outputPath, 'ft_data');
        fprintf('Saved %s.\n', outputFilename);
    end
end
