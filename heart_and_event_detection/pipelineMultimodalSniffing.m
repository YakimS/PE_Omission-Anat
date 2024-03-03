%function pipelineMultimodalSniffing(basename)

addpath(genpath('C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\raw'))
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2021.0'

eeglab
%% read respiration data and save the respirattion trace and all breath 

imagesFolder = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\raw';
folderPath = "C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\raw";
savePath = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\';
orig_files_output_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\orig';
prepro_output_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\prepro';

files = dir(folderPath);
subjects_num = ["BBS01","BBS02","BBS03","BBS04","BBS05","BBS06","BBS07","BBS08","BBS09","BBS10","BBS11", ...
                "BBS12","BBS13","BBS14","BBS15","BBS16","BBS17" ...
                "BBS18","BBS19","BBS20","BBS21","BBS22","BBS23","BBS24","BBS25", ...
                "BBS26","BBS27","BBS28","BBS29","BBS30","BBS31","BBS32","BBS33","BBS35","BBS36","BBS37","BBS38"];

%%
for i_s = 1:numel(subjects_num)
    %%%% read triggers from EEG file
    % import EEG and PIB data for the odor sniff test
    foldername_sniff = sprintf("%s SNIFF", subjects_num(i_s)); % 'odor';
    parentFolder = sprintf("%s\\%s",folderPath,subjects_num(i_s));
    matchingFolderPath = findFolderWithSubstring(parentFolder, foldername_sniff);
    matchingFolderPath = sprintf('%s\\',matchingFolderPath);
    EEG = dataimportAndPreprocessMultimodalSniffing(matchingFolderPath,subjects_num(i_s),orig_files_output_dir,prepro_output_dir);
end

%%
function EEG = dataimportAndPreprocessMultimodalSniffing(folderpath_raw,sub_name,orig_output_dir,prepro_output_dir)
    %%%%%%%%% IMPORT  %%%%%%%%%%%%%
    BIPlocfile = 'PIB.sfp';
    
    fprintf('\nProcessing %s.\n\n', sub_name);
    folderpath_raw = strrep(folderpath_raw, '"', '''');
    EEG = pop_readegimff(folderpath_raw,'datatype','EEG');
    PIB = pop_readegimff(folderpath_raw,'datatype','PIB','chanlocfile',BIPlocfile);
    
    % add ECG channel to EEG structure
    EEG.data(end+1:end+numel(PIB.chanlocs),:)= PIB.data;
    EEG.nbchan = size(EEG.data,1);
    for PIBchan = 1:numel(PIB.chanlocs)
        EEG.chanlocs(end+1).labels = PIB.chanlocs(PIBchan).labels;
    end
    
    EEG.setname = sprintf('%s_orig',sub_name);
    EEG.filename = sprintf('%s_orig.set',sub_name);
    EEG.filepath = orig_output_dir;
    
    fprintf('Saving %s%s.\n', EEG.filepath, EEG.filename);
    pop_saveset(EEG,'filename', EEG.filename, 'filepath',orig_output_dir,'version','7.3');

    %%%%%%%%% PREPROCESSING  %%%%%%%%%%%%%
    EEG = pop_readegimff(folderpath_raw,'datatype','EEG');
    chanlocfile = 'GSN-HydroCel-257.sfp';
    chanlocpath = which(chanlocfile);
    EEG = fixegilocs(EEG,chanlocpath);

    %  remove external electrodes, 
%     chanexcl = [1:82,88,89,94,95,99,107,113,114,119,120,121,125,126,127,128]; % TODO
%     fprintf('Removing excluded channels.\n');
%     EEG = pop_select(EEG,'nochannel',chanexcl);

    % lpfilter
    lpfreq = 30;
    fprintf('Low-pass filtering above %dHz...\n',lpfreq);
    EEG = pop_eegfiltnew(EEG, [], lpfreq, 66, 0, [], 1);
    
    % hpfilter 
    hpfreq = 0.5;
    fprintf('High-pass filtering below %dHz...\n',hpfreq);
    EEG = pop_eegfiltnew(EEG, [], hpfreq, 3300, true, [], 1);

    % add ECG channel to EEG structure
    EEG.data(end+1:end+numel(PIB.chanlocs),:)= PIB.data;
    EEG.nbchan = size(EEG.data,1);
    for PIBchan = 1:numel(PIB.chanlocs)
        EEG.chanlocs(end+1).labels = PIB.chanlocs(PIBchan).labels;
    end
    
    EEG.setname = sprintf('%s_preProcessed',sub_name);
    EEG.filename = sprintf('%s_preProcessed.set',sub_name);
    EEG.filepath = prepro_output_dir;
    
    fprintf('Saving %s%s.\n', EEG.filepath, EEG.filename);
    pop_saveset(EEG,'filename', EEG.filename, 'filepath',prepro_output_dir,'version','7.3');
end

function matchingFolderPath = findFolderWithSubstring(parentFolder, searchString)
    % Use the dir function to list all items in the parent folder
    dirInfo = dir(parentFolder);

    % Initialize the matching folder path as empty
    matchingFolderPath = '';

    % Loop through the items in the parent folder
    for i = 1:numel(dirInfo)
        currentItem = dirInfo(i);
        if currentItem.isdir && ~strcmp(currentItem.name, '.') && ~strcmp(currentItem.name, '..')
            % Check if the item is a directory and not '.' or '..'
            currentFolderPath = fullfile(parentFolder, currentItem.name);
            if contains(currentItem.name, searchString)
                % Check if the folder name contains the search string
                matchingFolderPath = currentFolderPath;
                return; % Return the path of the matching folder and exit
            else
                % Recursively search in subfolders
                subfolderMatch = findFolderWithSubstring(currentFolderPath, searchString);
                if ~isempty(subfolderMatch)
                    matchingFolderPath = subfolderMatch;
                    return; % Return the path of the matching subfolder
                end
            end
        end
    end
end
