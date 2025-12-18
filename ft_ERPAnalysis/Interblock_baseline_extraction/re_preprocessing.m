clear
close all
%%
restoredefaultpath
addpath 'D:\matlab_libs\fieldtrip-20241219' % fieldtrip-20230223
ft_defaults
addpath 'D:\matlab_libs\eeglab2024.2' %%eeglab2023.0'f
eeglab nogui;
%% Exteact inter-block baseline from basic-preprocessed set files
input_set_dir = 'D:\\AnatArzData\Data\preProcessed';
set_output_dir = 'D:\OExpOut\processed_data';
ft_output_dir = 'D:\OExpOut\processed_data\ft_subSovCond';
events_dir = 'D:\AnatArzData\Data\imported\elaborated_events';
ica_input_dir = 'D:\AnatArzData\Data\ica';
event_statistics_dir = 'D:\OExpOut\event_statistics';
events_withN2events_dir = "D:\OExpOut\old\eventDetection\try2\imported_eventDetectionChan\no_filters\events_with_sleepevents";

new_sample_rate = 250;
% 
% subs = {'01','02','03','04','05','06','07','08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};%}; % wo ,'06','07','12'
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {'wake_morning','wake_night',"N2","N3","REM","tREM","pREM",'wake','N1'};
sovs = {'wake_night',"N2","N3","REM","N2wo",'N2wJKc','N2wJSs','N2wSsKc','N2EliwJKc','N2EliwJSs','N2EliwSsKc','N2Eliwo','N2wSsOrKc'}; % ,'wake_morning' % ,"N2woSs","N2woKc","N2wSs","N2wKc",
sovs = {'wake_night',"N1","N2","N3","REM"};%,'N2Eliwo','N2EliwJKc','N2EliwJSs'


% sovs = {'wake_night_mid1','wake_night_mid2','wake_night_mid3'};
% sovs = {'N2EliwJKc','N2EliwJSs','N2Eliwo'};
%%
% % blO means that the bl amplitude offset of the epochs are just before the O, and not the first event. 

% conds = {"NblT1","NblT2","NblT3","NblT4"}; %,
% epoch_range_rel_to_event = [-0.1,0.58];
% bl_range = 0; % s
% 
% standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
%                         set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)



% conds = {"NblAO","NblAOR","NblAOF"};
% % blO means that the bl amplitude offset of the epochs are just before the O, and not the first event. 
% 
% epoch_range_rel_to_event = [-0.1,1.16];
% bl_range = 0; % s
% 
% standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
%                         set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)

subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
conds = {"AO","AOR","AOF"};
epoch_range_rel_to_event = [-1.6,2.66];
bl_range = [-0.1,0]; % s
standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,[0,1],1)

%% Off response

subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
conds = {"BlockLastAOR","BlockLastAOF"};
sovs = {'wake_night',"N1","N2","N3","REM"}; % ,"N1","N2","N3","REM"
epoch_range_rel_to_event = [-1,3];
bl_range = [-0.1,0]; % s
standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,[0,1],1)

%%
subs = {'01','02','03','04','05','06','07','08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {'wake_morning','wake_night',"N2","N3","REM","tREM","pREM",'N1','N2Eliwo','N2EliwJKc','N2EliwJSs'};

% conds = {"T1","T2","T3","T4"};
% epoch_range_rel_to_event = [-0.1,0.58];
% bl_range = [-0.1,0]; % s
% standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
%                          set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)


sovs = {'wake_night','N1','N2','N3','REM'};
% conds = {"1stT2n500","1stT2n500","1stT3n500","1stT4n500","1stA500_1","1stA500_2","1stA500_3","1stA500_4","A500ofT500_1","A500ofT500_2","A500ofT500_3","A500ofT500_4"};
% conds = {"T1n500","T2n500","T3n500","T4n500"};
% conds = {"ATn500_1","AT500_9","ATn500_9"};
conds = {};
tones={"650", "845", "1098", "1428", "1856", "2413", "3137", "4079", "5302"}; %"500",
AT = {"T"}; % "A",
pos_in_trial = {"1","2","3","4"};
for tones_i =1:numel(tones)
    for AT_i =1:numel(AT)
        for pos_in_trial_i =1:numel(pos_in_trial)
            conds{end+1} = sprintf("%s%s_%s", AT{AT_i},tones{tones_i},pos_in_trial{pos_in_trial_i});
        end
    end
end
tones_diffs={"low", "mid", "high"}; %"500",
AT = {"T"}; % "A",
pos_in_trial = {"1","2","3","4"};
for tones_i =1:numel(tones_diffs)
    for AT_i =1:numel(AT)
        for pos_in_trial_i =1:numel(pos_in_trial)
            conds{end+1} = sprintf("%s_prev%s_%s", AT{AT_i},tones_diffs{tones_i},pos_in_trial{pos_in_trial_i});
        end
    end
end


% conds = {"T1n500","T2n500","T3n500","T4n500"};
epoch_range_rel_to_event = [-0.1,0.58];
bl_range = [0-0.002,0+0.002];
% bl_range = [0-0.05,0];
standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,[0,1],1)

% 
% conds = {"NblT1n500","NblT2n500","NblT3n500","NblT4n500","Nbl1stA500_1","Nbl1stA500_2","Nbl1stA500_3","Nbl1stA500_4","NblA500ofT500_1","NblA500ofT500_2","NblA500ofT500_3","NblA500ofT500_4"};
% % AT = {"NblA","NblT"};
% % for tones_i =1:numel(tones)
% %     for AT_i =1:numel(AT)
% %         for pos_in_trial_i =1:numel(pos_in_trial)
% %             conds{end+1} = sprintf("%s%s_%s", AT{AT_i},tones{tones_i},pos_in_trial{pos_in_trial_i});
% %         end
% %     end
% % end
% bl_range = 0;
% epoch_range_rel_to_event = [-0.1,0.58];
% standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
%                         set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)
%%
conds = {"AblT1","AblT2","AblT3","AblT4","AblOF","AblOR","AblO"};
% blO means that the bl amplitude offset of the epochs are just before the O, and not the first event. 

epoch_range_rel_to_event = [-0.1,1.16];
bl_range = [0.5,0.6]; % s


standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir)


%%
sovs = {'wake_night',"N1","N2","N3","REM"}; 
conds = {"intblk"};
epoch_range_rel_to_event = [0,5];
bl_range = 0; % ms
standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,[0,1],1)

%%
conds = {"NblAO","NblAOR","NblAOF"};
conds = {"NblAO"};
conds =  {"AO"};
sovs = {'wake_night',"N2","N3","REM"};
epoch_range_rel_to_event = [-1.6,2.66];
bl_range = 0; % ms
bl_range = [-0.1,1.16]; % s

create_subcond_epoched_smpIntblk(subs,sovs,conds, "intblk",epoch_range_rel_to_event,bl_range,new_sample_rate,ft_output_dir)


%% create 'intbkMid' conds (<5s mean)
length_of_bl_epoch_sec = 5;
samples_per_trial = 170;
post_onset_epoch_length = 0.58;

trials_per_interblock_period = floor(length_of_bl_epoch_sec * new_sample_rate / samples_per_trial);
cut_start_timepoint = floor(((length_of_bl_epoch_sec * new_sample_rate) - (trials_per_interblock_period * samples_per_trial)) / 2);

conds = {'intbkMid'};
for sub_i = 1:numel(subs)
    for sov_i=1:numel(sovs)
        if   strcmp(sovs{sov_i},'tREM') && strcmp(subs{sub_i},'36')|| ...
            (strcmp(sovs{sov_i},'wake_morning') && strcmp(subs{sub_i},'23')) 
            continue;
        end
%         % save .set of the sub's sov      
        set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},"intbk"));
        EEG_currSovEvent = pop_loadset('filename', set_output_file_name, 'filepath', set_output_dir);

        cfg = []; 
        cfg.dataset = sprintf('%s\\%s',set_output_dir,set_output_file_name);
        cfg.continuous = 'no';
        ft_data_all = ft_preprocessing(cfg);
        
        subSovCond_number_of_trials = length(ft_data_all.trial) * trials_per_interblock_period;

        % devide ft_data to trials_per_interblock_period sections
        new_ftdata_trial = cell(1, subSovCond_number_of_trials);
        idx = 1;
        for trial_i = 1:length(ft_data_all.trial)
            rand_trial = ft_data_all.trial{trial_i}; 
            % Divide into sections of size samples_per_trial
            for j = cut_start_timepoint : samples_per_trial : (samples_per_trial*trials_per_interblock_period)
                section = rand_trial(:, j:j+(samples_per_trial-1)); % Extract samples_per_trial columns
                new_ftdata_trial{idx} = section;
                idx = idx+1;
            end
        end
        ft_data_all.trial = new_ftdata_trial;

        % Creating the 1xsamples_per_trial double array
        new_timestamps = -0.1:(1/new_sample_rate):(post_onset_epoch_length-(1/new_sample_rate));
        new_ftdata_time = cell(1, subSovCond_number_of_trials);
        for trial_i = 1:subSovCond_number_of_trials
            new_ftdata_time{trial_i} = new_timestamps;
        end
        ft_data_all.time = new_ftdata_time;

        ft_data_all.hdr.nTrials = subSovCond_number_of_trials;
        
        % new ft_data.cfg.trl and ft_data.sampleinfo
        new_ftdata_cfg_trl = zeros(subSovCond_number_of_trials, 3);
        new_ftdata_cfg_trl(1,1) = 1;
        for trial_i = 2:subSovCond_number_of_trials
            new_ftdata_cfg_trl(trial_i,1) = (new_ftdata_cfg_trl(trial_i-1,1) + samples_per_trial);
        end
        new_ftdata_cfg_trl(:,2) = (new_ftdata_cfg_trl(:,1) + samples_per_trial -1);
        ft_data_all.cfg.trl = new_ftdata_cfg_trl;
        ft_data_all.sampleinfo = new_ftdata_cfg_trl(:, 1:end-1);

        if any(ismember(conds, 'intbkMid'))
            cfg = [];
            cfg.demean          = 'yes';
            cfg.baselinewindow  = [-0.1 0];
            cfg.trials = 1:size(ft_data_all.trial,2);
            ft_data = ft_preprocessing(cfg,ft_data_all);
    
            mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},'intbkMid'));
            ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
            save(ft_file_path,"ft_data");
        end
    end
end

%% Functions

substring = 'A5thT'; % Specify the substring to look for in file names
folderPaths = {'D:\OExpOut\processed_data\ft_subSovCond', ...
                'D:\OExpOut\processed_data\ft_processed', ...
                'D:\OExpOut\processed_data', ...
                'D:\OExpOut\spatioTemp\AdaptorOmission'
                };

for path_i=1:numel(folderPaths)
    folderPath = folderPaths{path_i};
    % Get a list of all files in the folder
    files = dir(folderPath);
    
    % Loop through the files
    for i = 1:length(files)
        % Check if the file name contains the specified substring
        if contains(files(i).name, substring)
            % Construct the full file path
            filePath = fullfile(folderPath, files(i).name);
            
            % Delete the file
            delete(filePath);
            
            % Optionally, display a message
            fprintf('Deleted: %s\n', filePath);
        end
    end
end

%%


replaceStringInFilenames("C:\OExpOut\processed_data", "interblock", "intbk");

function replaceStringInFilenames(directory, strToReplace, replacementStr)
    % Check if the specified directory exists
    if ~isfolder(directory)
        error('Directory does not exist: %s', directory);
    end

    % Get a list of all files in the directory
    files = dir(directory);
    
    % Iterate through each file
    for i = 1:length(files)
        % Skip directories
        if ~files(i).isdir
            oldName = files(i).name;
            % New filename with the specified string replaced
            newName = strrep(oldName, strToReplace, replacementStr);
            
            % Check if the name actually needs to be changed
            if ~strcmp(oldName, newName)
                % Full path for old and new filenames
                oldFilePath = fullfile(directory, oldName);
                newFilePath = fullfile(directory, newName);
                
                % Rename the file
                movefile(oldFilePath, newFilePath);
            end
        end
    end
end

% create 'intblksmp' per cond (<5s mean)
function create_subcond_epoched_smpIntblk(subs,sovs,conds, intblk_string,epoch_range_rel_to_event,bl_range,sample_rate,ft_output_dir)
    samples_per_trial = abs(epoch_range_rel_to_event(1)*sample_rate) + abs(epoch_range_rel_to_event(2)*sample_rate);
    for sub_i = 1:numel(subs)
        for sov_i=1:numel(sovs)
            if  (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_i},'33'))|| ...
                    (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_i},'36'))%|| ...
%                  (strcmp(sovs{sov_i},'tREM') && strcmp(subs{sub_i},'36'))|| ...
%                 (strcmp(sovs{sov_i},'wake_morning') && strcmp(subs{sub_i},'23'))
                continue;
            end
            
            % load intbk .set of the sub's sov      
            mat_intblk_file_name = load(sprintf("%s\\s_%s_%s_%s.mat",ft_output_dir,subs{sub_i}, sovs{sov_i},intblk_string));
            ft_data_all = mat_intblk_file_name.ft_data;
    
            for cond_i=1:numel(conds)
                intlbsmp_name = sprintf('intblksmp%s', conds{cond_i});
                mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},intlbsmp_name));
                ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
                if isfile(sprintf("%s.mat",ft_file_path)) continue; end
    
                %%% get sov-cond num of trials
                ft_sovcond_file_name = sprintf("%s\\s_%s_%s_%s.mat",ft_output_dir,subs{sub_i}, sovs{sov_i},conds{cond_i});
                EEG_currSovCond = load(ft_sovcond_file_name);
                subSovCond_number_of_trials = numel(EEG_currSovCond.ft_data.trial);
    
                % get random snippets from the interblockBL
                new_ftdata_trial = cell(1, subSovCond_number_of_trials);
                for trial_i = 1:subSovCond_number_of_trials
                    rand_trial_num = floor(1 + (numel(ft_data_all.trial).*rand(1,1)));
                    rand_start_in_trial = floor(1 + ((numel(ft_data_all.time{1}) - samples_per_trial).*rand(1,1)));
    
                    rand_trial = ft_data_all.trial{rand_trial_num}; 
                    new_ftdata_trial{trial_i} = rand_trial(:, rand_start_in_trial:rand_start_in_trial+(samples_per_trial-1)); 
                end
                ft_data_all.trial = new_ftdata_trial;
        
                % Creating the 1xsamples_per_trial double array
                new_timestamps = epoch_range_rel_to_event(1):(1/sample_rate):(epoch_range_rel_to_event(2)-(1/sample_rate));
                new_ftdata_time = cell(1, subSovCond_number_of_trials);
                for trial_i = 1:subSovCond_number_of_trials
                    new_ftdata_time{trial_i} = new_timestamps;
                end
                ft_data_all.time = new_ftdata_time;
        
                ft_data_all.hdr.nTrials = subSovCond_number_of_trials;
                
                % new ft_data.cfg.trl and ft_data.sampleinfo
                new_ftdata_cfg_trl = zeros(subSovCond_number_of_trials, 3);
                new_ftdata_cfg_trl(1,1) = 1;
                for trial_i = 2:subSovCond_number_of_trials
                    new_ftdata_cfg_trl(trial_i,1) = (new_ftdata_cfg_trl(trial_i-1,1) + samples_per_trial);
                end
                new_ftdata_cfg_trl(:,2) = (new_ftdata_cfg_trl(:,1) + samples_per_trial -1);
                ft_data_all.cfg.trl = new_ftdata_cfg_trl;
                ft_data_all.sampleinfo = new_ftdata_cfg_trl(:, 1:end-1);
        
                cfg = [];  
                if bl_range ~=0
                    cfg.demean          = 'yes';
                    cfg.baselinewindow  = bl_range;
                end
                cfg.trials = 1:size(ft_data_all.trial,2);
                ft_data = ft_preprocessing(cfg,ft_data_all);
        
                save(ft_file_path,"ft_data");
            end
        end
    end
end

function process_subject(subs,sub_i,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,EventDependentrTrialOffset)

    file_sleepwake_name = ''; digitStr = ''; % Pre-initialize all temporary variables

    % get files
    files_set = getSubSetFilesOfSOVs(input_set_dir,subs{sub_i},sovs);
    if numel(files_set) ==0
        error("No files for sub %s, in folder %s",subs{sub_i},input_set_dir);
    end

    % skip sub if all it's output files exists
    if doesAllFtOutputExists(sovs, conds,subs{sub_i},ft_output_dir) return; end

    for files_i = 1:length(files_set)
        EEG_sub_file = pop_loadset('filename', files_set(files_i).name, 'filepath', input_set_dir);

        if ~isempty(strfind(files_set(files_i).name, 'wake_morning'))   file_sleepwake_name = 'morning';
        elseif ~isempty(strfind(files_set(files_i).name, 'wake_night')) file_sleepwake_name = 'night';
        elseif   ~isempty(strfind(files_set(files_i).name, 'sleep'))      file_sleepwake_name = 'sleep';
        else    error('no sleep / wake_morning / wake_night string in the files name');   
        end

        [EEG_sub_file,EEG_ica] = load_EEGfile_with_old_ICA(ica_input_dir,subs{sub_i},file_sleepwake_name,EEG_sub_file);

        % load events and set files
        if contains(files_set(files_i).name,'sleep') % if sleep file, gets it's sleep file number
            match = regexp(files_set(files_i).name, 'sleep(\d)', 'tokens');
            if ~isempty(match)
                digitStr = match{1}{1};
            else
                error('Incorrect format of sleep file number')
            end
            events_file_pattern = fullfile(events_dir, sprintf('*%s*%s*%s*',subs{sub_i},file_sleepwake_name,digitStr));
        else
            events_file_pattern = fullfile(events_dir, sprintf('*%s*%s*',subs{sub_i},file_sleepwake_name));
        end
        files_events = dir(events_file_pattern);
        if length(files_events) > 1  error('More than one file found. Please check the file pattern or directory.'); end
        sub_ses_events_filepath = fullfile(events_dir, files_events(1).name);
         
        sub_ses_orijFile_events = load(sub_ses_events_filepath);
        sub_ses_orijFile_events = sub_ses_orijFile_events.events;
        if numel(sub_ses_orijFile_events) ~= numel(EEG_sub_file.event)
            error('events array dont match')
       end
        
        for events_type_i=1:numel(conds)
            currSes_currCond_eventsIDs = eventHandler(conds{events_type_i},sub_ses_orijFile_events);
            if isempty(currSes_currCond_eventsIDs) continue; end
            for sov_i=1:numel(sovs)
                mat_output_file_name = char(sprintf("s_%s_%s_%s.mat",  subs{sub_i}, sovs{sov_i}, conds{events_type_i}));
                if isfile(fullfile(ft_output_dir, mat_output_file_name)) continue; end

                % find event in the curr sov 
                currSes_currCond_eventsIDs_int = intersect_events_in_sov(sovs{sov_i},files_set(files_i).name,currSes_currCond_eventsIDs,sub_ses_orijFile_events);
                if contains(sovs{sov_i},'N2w') || contains(sovs{sov_i},'N2Eli')
                    currSes_currCond_eventsIDs_int = extractEventDependentTrials(events_withN2events_dir,sovs{sov_i},subs{sub_i},currSes_currCond_eventsIDs_int,EventDependentrTrialOffset);
                end                    
                if isempty(currSes_currCond_eventsIDs_int) || numel(currSes_currCond_eventsIDs_int)==1 continue;  end % if == 1, it creates issues with epochs.
                
                matching_indices = ismember([sub_ses_orijFile_events.event_id], currSes_currCond_eventsIDs_int);
                %filtered_events = sub_ses_orijFile_events(matching_indices);
                matching_rows = find(matching_indices);
                matching_rows(cellfun(@isempty, {EEG_sub_file.urevent(matching_rows).duration})) = [];

                if (strcmp(sovs{sov_i},'wake_night_beg')) || (strcmp(sovs{sov_i},'wake_morning_beg'))
                    matching_rows = matching_rows(1:numel(matching_rows)/5);
                elseif (strcmp(sovs{sov_i},'wake_night_end')) || (strcmp(sovs{sov_i},'wake_morning_end'))
                    matching_rows = matching_rows(4*numel(matching_rows)/5:end);
                elseif strcmp(sovs{sov_i},'wake_night_mid1')
                    matching_rows = matching_rows(1*numel(matching_rows)/5:2*numel(matching_rows)/5);
                elseif strcmp(sovs{sov_i},'wake_night_mid2')
                    matching_rows = matching_rows(2*numel(matching_rows)/5:3*numel(matching_rows)/5);
                elseif strcmp(sovs{sov_i},'wake_night_mid3')
                    matching_rows = matching_rows(3*numel(matching_rows)/5:4*numel(matching_rows)/5);
                end

                % select events
                EEG_currSovEvent = pop_epoch(EEG_sub_file,{},epoch_range_rel_to_event,'eventindices',matching_rows);
                if numel(EEG_currSovEvent.epoch)<2 continue; end
                if ~(isscalar(bl_range) && bl_range == 0)
                    EEG_currSovEvent = pop_rmbase(EEG_currSovEvent,1000*bl_range);
                end
   
                % reject trials with +-XmicroVolt. I check that does what it suppose to do (maybe you should use also "EEG = pop_select(EEG, 'notrial', EEG.rejepoch);") 
                % and it seems unnecessety, as the output includes the substraction of the epochs from the data array
                if contains(sovs{sov_i}, 'wake')  thresh_amp = 150;
                else                              thresh_amp = 300;    end

                [~, Indexes] = pop_eegthresh(EEG_currSovEvent, 1, 1:size(EEG_currSovEvent.data,1), -thresh_amp, thresh_amp, epoch_range_rel_to_event(1), epoch_range_rel_to_event(2), 0, 0);
                if size(EEG_currSovEvent.data,3) ~= numel(Indexes)
                    [EEG_currSovEvent, ~] = pop_eegthresh(EEG_currSovEvent, 1, 1:size(EEG_currSovEvent.data,1), -thresh_amp, thresh_amp, epoch_range_rel_to_event(1), epoch_range_rel_to_event(2), 0, 1);
                else continue;  
                end
                if isempty(EEG_currSovEvent)   continue;  end
    
                EEG_currSovEvent = prepro_end(EEG_currSovEvent,EEG_ica,new_sample_rate);
    
                if ~isempty(EEG_currSovEvent) && ~EEG_currSovEvent.trials == 0 
                    interim_filename = char(sprintf("INTERIM_s-%s_sov-%s_%s_file-%d.set",subs{sub_i}, sovs{sov_i}, conds{events_type_i}, files_i));
                    pop_saveset(EEG_currSovEvent, 'filename', interim_filename, 'filepath', set_output_dir);
                end
            end
        end
    end

    for events_type_i = 1:numel(conds)
        for sov_i = 1:numel(sovs)
            % Find all interim files for this sub/sov/condition
            interim_pattern = sprintf("INTERIM_s-%s_sov-%s_%s_*.set",  subs{sub_i}, sovs{sov_i}, conds{events_type_i});
            interim_files = dir(fullfile(set_output_dir, interim_pattern));
            
            if isempty(interim_files)  continue; end
            
            % Load and merge all interim files
            merged_EEG = [];
            for f = 1:length(interim_files)
                curr_EEG = pop_loadset('filename', interim_files(f).name, 'filepath', set_output_dir);
                if isempty(merged_EEG)
                    merged_EEG = curr_EEG;
                elseif merged_EEG.trials > 1 || curr_EEG.trials >1  % otherwise (if both have 1 epcoh) EEGLAB cant merge
                    merged_EEG = pop_mergeset(merged_EEG, curr_EEG, 0);
                end
                delete(fullfile(set_output_dir, interim_files(f).name)); % Delete interim file
            end
            
            % Save final merged set file
            final_set_name = char(sprintf("s-%s_sov-%s_%s.set", subs{sub_i}, sovs{sov_i}, conds{events_type_i}));
            pop_saveset(merged_EEG, 'filename', final_set_name, 'filepath', set_output_dir);
            
            % Convert to fieldtrip and save
            cfg = []; 
            cfg.dataset = fullfile(set_output_dir, final_set_name);
            cfg.continuous = 'no';
            ft_data = ft_preprocessing(cfg);

            % sort channels by name (cuz order was changed becuase of interpolation differnetly for each subject)
            cfg = [];
            cfg.channel = sort(ft_data.label);
            ft_data= ft_selectdata(cfg, ft_data);

            ft_data = reorder_ft_elec(ft_data, sort(ft_data.label));
            ft_data = rmfield(ft_data, 'hdr'); % the header is no longer correct after reorder
            ft_data.cfg = rmfield(ft_data.cfg, 'channel');

            mat_output_file_name = char(sprintf("s_%s_%s_%s",  subs{sub_i}, sovs{sov_i}, conds{events_type_i}));
            parsave(fullfile(ft_output_dir, mat_output_file_name), 'ft_data', ft_data);

            delete(fullfile(set_output_dir, final_set_name)); % Delete set file
            
        end
    end
end

function standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,EventDependentrTrialOffset,num_workers)
    if num_workers>1
        if ~isempty(gcp('nocreate'))    delete(gcp('nocreate')); end % Close existing pool if any
        parpool(num_workers);
        parfor sub_i = 1:numel(subs)
            process_subject(subs,sub_i,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,EventDependentrTrialOffset);
        end
        delete(gcp('nocreate'));
    else
        for sub_i = 1:numel(subs)
            process_subject(subs,sub_i,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir,EventDependentrTrialOffset);
        end
    end

    
end

function curr_events_ids = eventHandler(cond,sub_events)
    if strcmp(cond,'AT1') || strcmp(cond,'NblAT1')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 1 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AT2') || strcmp(cond,'NblAT2')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 2 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AT3') || strcmp(cond,'NblAT3')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 3 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AT4') || strcmp(cond,'NblAT4')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 4 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'ATR10')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 10   & strcmp({sub_events.block_type}, 'random'));
        curr_events_rows = curr_events_rows - 1;
    elseif (length(cond{1}) == 6 || length(cond{1}) == 7) && ... % (A|T)((0-9)^3 |(0-9)^4)_(0-9)
           (cond{1}(1) == 'A' || cond{1}(1) == 'T') && ...
           isstrprop(cond{1}(end), 'digit') && ...
           cond{1}(end-1) == '_' && ...
           all(isstrprop(cond{1}(2:end-2), 'digit'))
        curr_events_rows = find(strcmp({sub_events.TOA}, cond{1}(1)) & strcmp({sub_events.tone}, cond{1}(2:end-2)) & [sub_events.tone_pos_in_trial] == str2num(cond{1}(end)));
    elseif (length(cond{1}) == 9 || length(cond{1}) == 10) && ... % Nbl(A|T)((0-9)^3 |(0-9)^4)_(0-9)
           (cond{1}(4) == 'A' || cond{1}(4) == 'T') && ...
           isstrprop(cond{1}(end), 'digit') && ...
           cond{1}(end-1) == '_' && ...
           all(isstrprop(cond{1}(5:end-2), 'digit'))
        curr_events_rows = find(strcmp({sub_events.TOA}, cond{1}(4)) & strcmp({sub_events.tone}, cond{1}(5:end-2)) & [sub_events.tone_pos_in_trial] == str2num(cond{1}(end)));
    elseif contains(cond{1}, 'T_prev')
        allTones = [500, 650, 845, 1098, 1428, 1856, 2413, 3137, 4079, 5302];
        curr_tone_pos_in_trial = cond{1}(end);
        curr_distance = extractBefore(extractAfter(cond{1}, 'T_prev'),'_' );
        prev_tone_event_interval = 2* str2num(curr_tone_pos_in_trial);
        curr_events_rows = [];
        for tone=allTones
            curr_tone_rows = find(strcmp({sub_events.TOA}, 'T') & strcmp({sub_events.tone}, string(tone)) & [sub_events.tone_pos_in_trial] == str2num(curr_tone_pos_in_trial));
            tone_trial_before = string({sub_events(curr_tone_rows-prev_tone_event_interval).tone});
            tones_in_diff = tonesByDiff(tone,string(curr_distance));
            if isempty(tones_in_diff) continue; end
            for tone_in_diff = tones_in_diff
                new_rows_exclude = curr_tone_rows(find(ismember(tone_trial_before, string(tone_in_diff))));
                curr_events_rows = [curr_events_rows, new_rows_exclude];
            end
        end
    elseif strcmp(cond,'A500ofT500_1') || strcmp(cond,'A500ofT500_2') || strcmp(cond,'A500ofT500_3')  || strcmp(cond,'A500ofT500_4') ...
        || strcmp(cond,'NblA500ofT500_1') || strcmp(cond,'NblA500ofT500_2') || strcmp(cond,'NblA500ofT500_3')  || strcmp(cond,'NblA500ofT500_4') 
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & strcmp({sub_events.tone}, '500') & [sub_events.tone_pos_in_trial] == str2num(cond{1}(end)));
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'1stA500_1') || strcmp(cond,'1stA500_2') || strcmp(cond,'1stA500_3') || strcmp(cond,'1stA500_4') 
        curr_events_rows = find(strcmp({sub_events.TOA}, cond{1}(4)) & strcmp({sub_events.tone}, cond{1}(5:end-2)) & [sub_events.tone_pos_in_trial] == str2num(cond{1}(end))& [sub_events.trial_pos_in_block] == 1);
    elseif strcmp(cond,'1stT1n500') || strcmp(cond,'1stT2n500') || strcmp(cond,'1stT3n500') || strcmp(cond,'1stT4n500') 
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == str2num(cond{1}(5))& [sub_events.trial_pos_in_block] == 1 & ~strcmp({sub_events.tone}, '500'));
    elseif strcmp(cond,'Nbl1stA500_1') || strcmp(cond,'Nbl1stA500_2') || strcmp(cond,'Nbl1stA500_3') || strcmp(cond,'Nbl1stA500_4')
        curr_events_rows = find(strcmp({sub_events.TOA}, cond{1}(7)) & strcmp({sub_events.tone}, cond{1}(8:end-2)) & [sub_events.tone_pos_in_trial] == str2num(cond{1}(end))& [sub_events.trial_pos_in_block] == 1);
    elseif strcmp(cond,'T1') || strcmp(cond,'NblT1') || strcmp(cond,'T2') || strcmp(cond,'NblT2') || strcmp(cond,'T3') || strcmp(cond,'NblT3') ||strcmp(cond,'T4') || strcmp(cond,'NblT4')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == str2double(cond(end)));
    elseif contains(cond, {'T1n500', 'T2n500', 'T3n500','T4n500'})
            pos = str2double(regexp(cond, 'T(\d)', 'tokens', 'once'));
            curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == pos & ~strcmp({sub_events.tone}, '500'));
    elseif strcmp(cond,'AT8')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 8 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AT500_9')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 9 & strcmp({sub_events.tone}, '500'));
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'ATn500_1') 
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 1 & ~strcmp({sub_events.tone}, '500'));
        curr_events_rows = curr_events_rows - 1;
   elseif strcmp(cond,'ATn500_9')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 9 & ~strcmp({sub_events.tone}, '500'));
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AT9')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 9 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AblT1')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 1 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AblT2')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 2 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AblT3')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 3 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AblT4')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 4 );
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AblO') ||  strcmp(cond,'AOtfr') ||  strcmp(cond,'AO') ||  strcmp(cond,'NblAO')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'O'));
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AblOF') ||  strcmp(cond,'AOFtfr') ||  strcmp(cond,'AOF')  ||  strcmp(cond,'NblAOF')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'fixed'));
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'AblOR') ||  strcmp(cond,'AORtfr') ||  strcmp(cond,'AOR')  ||  strcmp(cond,'NblAOR')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'random'));
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'BlockLastAOF')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'O')  & [sub_events.trial_pos_in_block] == 10   & strcmp({sub_events.block_type}, 'fixed'));
        curr_events_rows = curr_events_rows - 1;
    elseif strcmp(cond,'OF18')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'O')  & strcmp({sub_events.block_type}, 'fixed'));
    elseif strcmp(cond,'BlockLastAOR')
        curr_events_rows = find([sub_events.tone_pos_in_trial] == 10 & [sub_events.trial_pos_in_block] == 10 & strcmp({sub_events.TOA}, 'T') & strcmp({sub_events.block_type}, 'random'));
    elseif strcmp(cond,'OR618')
        curr_events_rows = find( [sub_events.trial_pos_in_block] == 6 & strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'random'));
    elseif strcmp(cond,'OR718')
        curr_events_rows = find( [sub_events.trial_pos_in_block] == 7 & strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'random'));
    elseif strcmp(cond,'OR818')
        curr_events_rows = find( [sub_events.trial_pos_in_block] == 8 & strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'random'));
    elseif strcmp(cond,'OR918')
        curr_events_rows = find( [sub_events.trial_pos_in_block] == 9 & strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'random'));
    elseif strcmp(cond, 'intblk') || strcmp(cond, 'NblIntbk') 
        curr_events_rows = find(strcmp({sub_events.type}, 'BGIN'));
    else
        error('no such event type %s',cond); % or should it be just warning?
    end
    curr_events_ids = {sub_events(curr_events_rows).event_id};
    curr_events_ids = cell2mat(curr_events_ids);
end

function extracted_events = extractEventDependentTrials(events_withN2events_dir,sov,sub,curr_events_ids,adjecent_range_to_exclude)
    n2events_table = load(sprintf("%s\\sub%s_referenced_sleepEvents.mat",events_withN2events_dir,sub));
    n2events_table = n2events_table.sleepEvents;

    matching_indices = false(size(n2events_table));
    for i = 1:length(curr_events_ids)
        is_curr_event = [n2events_table.event_id] == curr_events_ids(i);
        
        in_adjacent_range = ([n2events_table.event_id] >= curr_events_ids(i) - adjecent_range_to_exclude(1)) & ...
                            ([n2events_table.event_id] <= curr_events_ids(i) + adjecent_range_to_exclude(2));

        ss_exists = any([n2events_table(in_adjacent_range).is_ss] == 1);
        kc_exists = any([n2events_table(in_adjacent_range).is_kc] == 1);
        ss_elicited = any([n2events_table(in_adjacent_range).ss_start_t] > 0);
        kc_elicited = any([n2events_table(in_adjacent_range).kc_start_t] > 0);
        if strcmp(sov,"N2wo")
            add_indeces = ~(kc_exists || ss_exists);
        elseif strcmp(sov,"N2wJKc")
            add_indeces = kc_exists && ~ss_exists;
        elseif strcmp(sov,"N2wJSs")
            add_indeces = ~kc_exists && ss_exists;
        elseif strcmp(sov,"N2wSsKc")
            add_indeces = kc_exists && ss_exists;
        elseif strcmp(sov,"N2wSsOrKc")
            add_indeces = kc_exists || ss_exists;
        elseif strcmp(sov,"N2woSs")
            add_indeces = ~ss_exists;
        elseif strcmp(sov,"N2woKc")
            add_indeces = ~kc_exists;
        elseif strcmp(sov,"N2wSs")
            add_indeces = ss_exists;
        elseif strcmp(sov,"N2wKc")
            add_indeces = kc_exists;
        elseif strcmp(sov,"N2EliwJKc")
            add_indeces = kc_elicited && ~ss_elicited;
        elseif strcmp(sov,"N2EliwJSs")
            add_indeces = ~kc_elicited && ss_elicited;
        elseif strcmp(sov,"N2EliwSsKc")
            add_indeces = kc_elicited && ss_elicited;
        elseif strcmp(sov,"N2Eliwo")
            add_indeces = ~(kc_elicited || ss_elicited);
        else
            error("wrong N2 sov")
        end

        if add_indeces
            matching_indices = matching_indices | is_curr_event;
        end        
    end
    
    % Get the subset of the struct array that meets the conditions
    filtered_table = n2events_table(matching_indices);
    extracted_events = [filtered_table.('event_id')];
end

function files_set = getSubSetFilesOfSOVs(input_set_dir,sub_string,sovs)
    file_pattern = fullfile(input_set_dir, sprintf('*%s*.set',sub_string));
    if all(cellfun(@(x) ischar(x) && contains(x, 'wake'), sovs))
        file_pattern = fullfile(input_set_dir, sprintf('*%s*wake*.set',sub_string));
    elseif ~any(cellfun(@(x) ischar(x) && contains(x, 'wake'), sovs))
        file_pattern = fullfile(input_set_dir, sprintf('*%s*sleep*.set',sub_string));
    end
    files_set = dir(file_pattern);
end

function does_all_ft_output_exist = doesAllFtOutputExists(sovs, conds,sub_s,ft_output_dir)
    does_all_ft_output_exist = true;
    for sov_i=1:numel(sovs)
        for events_type_i=1:numel(conds)
            mat_output_file_name = char(sprintf("s_%s_%s_%s.mat",sub_s, sovs{sov_i},conds{events_type_i}));
            if ~isfile(fullfile(ft_output_dir, mat_output_file_name)) 
                does_all_ft_output_exist = false; 
            end
        end
    end
end

% load EEG struct with ica components and channels to reject from previous
% analysis files
function [EEG_sub_file_withICA,EEG_ica] = load_EEGfile_with_old_ICA(ica_input_dir,sub_s,file_sleepwake_name,EEG_sub_file)
    file_pattern = fullfile(ica_input_dir, sprintf('*%s*%s*ICA.set',sub_s,file_sleepwake_name));
    files_ica = dir(file_pattern);
    if length(files_ica) > 1
        warning('More than one file found. Please check the file pattern or directory.');
    end
    EEG_ica = pop_loadset('filepath',ica_input_dir,'filename',files_ica(1).name,'loadmode','info');

    EEG_sub_file.chaninfo.icachansind = EEG_ica.chaninfo.icachansind;
    EEG_sub_file.etc.icasphere_beforerms = EEG_ica.etc.icasphere_beforerms;
    EEG_sub_file.etc.icaweights_beforerms = EEG_ica.etc.icaweights_beforerms;             
    EEG_sub_file.icaact = EEG_ica.icaact;
    EEG_sub_file.icachansind = EEG_ica.icachansind;
    EEG_sub_file.icasphere = EEG_ica.icasphere;
    EEG_sub_file.icaweights = EEG_ica.icaweights;
    EEG_sub_file.icawinv = EEG_ica.icawinv;
    EEG_sub_file.reject.gcompreject = EEG_ica.reject.gcompreject;
    EEG_sub_file_withICA = eeg_checkset(EEG_sub_file); % it was critical in the continuos case. Not it's problematic. So I remove it.
end

function new_sov_curr_eventtype_ids = intersect_events_in_sov(sov,curr_file_name,curr_events_id,sub_events)
    if strcmp(sov,'wake') && (contains(curr_file_name, "wake_morning") || contains(curr_file_name, "wake_night"))
        new_sov_curr_eventtype_ids = curr_events_id;
        return
    elseif (contains(sov,'wake_morning') && contains(curr_file_name, "wake_morning")) || ...
        (contains(sov,'wake_night') &&  contains(curr_file_name, "wake_night"))
        new_sov_curr_eventtype_ids = curr_events_id;
        return
    elseif strcmp(sov,'REM')
        matching_indices = ismember([sub_events.event_id], curr_events_id) & ...
                            (strcmp({sub_events.sleep_stage}, 'tREM') | strcmp({sub_events.sleep_stage}, 'Rt') | strcmp({sub_events.sleep_stage}, 'pREM') | strcmp({sub_events.sleep_stage}, 'Rp'));
    elseif strcmp(sov,'tREM')
        matching_indices = ismember([sub_events.event_id], curr_events_id) & ...
                            (strcmp({sub_events.sleep_stage}, 'tREM') | strcmp({sub_events.sleep_stage}, 'Rt'));
    elseif strcmp(sov,'pREM')
        matching_indices = ismember([sub_events.event_id], curr_events_id) & ...
                            (strcmp({sub_events.sleep_stage}, 'pREM') | strcmp({sub_events.sleep_stage}, 'Rp'));
    elseif contains(sov,'N2w') || contains(sov,'N2Eli') 
        matching_indices = ismember([sub_events.event_id], curr_events_id) & strcmp({sub_events.sleep_stage}, 'N2');
    else
        matching_indices = ismember([sub_events.event_id], curr_events_id) & strcmp({sub_events.sleep_stage}, sov);
    end
    
    new_sov_curr_eventtype = sub_events(matching_indices);
    new_sov_curr_eventtype_ids = [new_sov_curr_eventtype.('event_id')];
end

function EEG_currSovEvent = prepro_end(EEG_currSovEvent,EEG_ica,new_sample_rate)
    % remove bad channels
    EEG_currSovEvent = pop_select(EEG_currSovEvent,'nochannel',EEG_ica.reject.rejchan); 

    % remove ICA components
    EEG_currSovEvent = pop_subcomp( EEG_currSovEvent,find(EEG_currSovEvent.reject.gcompreject), 0); 
    EEG_currSovEvent = eeg_checkset(EEG_currSovEvent); % critical

    % resampling
    EEG_currSovEvent =  pop_resample( EEG_currSovEvent, new_sample_rate); % NOT RECOMMENDED "Warning: Resampling of epoched data is not recommended (due to anti-aliasing filtering)! Note: For epoched datasets recomputing urevent latencies is not supported. The urevent structure will be cleared."

    % interpulate (make sure code correct. maybe "eeg_interp(EEG, EEG.rejchan);"?)
    EEG_currSovEvent = eeg_interp(EEG_currSovEvent,EEG_currSovEvent.chaninfo.removedchans);
    rowWithLabelCz = EEG_currSovEvent.chaninfo.ndchanlocs(strcmp({EEG_currSovEvent.chaninfo.ndchanlocs.labels}, 'Cz'));
    EEG_currSovEvent = eeg_interp(EEG_currSovEvent,rowWithLabelCz);

    % rereferencing
    EEG_currSovEvent = pop_reref( EEG_currSovEvent, []);
end

function parsave(filepath, varargin)
    for i = 1:2:length(varargin)
        varname = varargin{i};
        varvalue = varargin{i+1};
        eval([varname ' = varvalue;']);
    end
    save(filepath, varargin{1:2:end}, '-v7.3');
end


function tones = tonesByDiff(tone, tone_diff_categ)
    allTones = [500, 650, 845, 1098, 1428, 1856, 2413, 3137, 4079, 5302];
    if ~ismember(tone, allTones)
        error('Invalid row header. Must be one of the valid headers from the table.');
    end
    
    if ~ischar(tone_diff_categ) && ~isstring(tone_diff_categ)
        error('tone_diff_cateG must be a string.');
    end
    
    switch tone_diff_categ
        case 'low'
            ratioMin = 1.2;
            ratioMax = 1.8;
        case 'mid'
            ratioMin = 2;
            ratioMax = 3;
        case 'high'
            ratioMin = 3;
            ratioMax = inf;
        otherwise
            error('Invalid tone_diff_categ. Valid options are: XXXX');
    end

    ratios = tone ./ allTones;
    ratios_opo =  allTones ./ tone;
    matchingIndices = ((ratios >= ratioMin) & (ratios < ratioMax)) | ((ratios_opo >= ratioMin) & (ratios_opo < ratioMax));
    tones = allTones(matchingIndices);
    
    if isempty(tones)
        disp(['No columns found for row ' num2str(tone) ' with tone_diff_cateG ' tone_diff_categ]);
    end
end
function data_out = reorder_ft_elec(data_in, target_order)
% REORDER_FT_DATA - Reorder FieldTrip raw data structure to match target electrode order
%
% Usage: data_out = reorder_ft_data(data_in, target_order)
%
% Inputs:
%   data_in     - FieldTrip raw data structure with fields:
%                 hdr, label, time, trial, fsample, sampleinfo, elec, cfg
%   target_order - cell array of electrode labels in desired order
%
% Output:
%   data_out    - Reordered data structure

% Copy input structure
data_out = data_in;

% Find reordering indices
[~, reorder_idx] = ismember(target_order, data_in.label);

% Check if all target electrodes are present
missing_idx = find(reorder_idx == 0);
if ~isempty(missing_idx)
    missing_labels = target_order(missing_idx);
    warning('Missing electrodes: %s', strjoin(missing_labels, ', '));
    
    % Remove missing electrodes from target order
    target_order(missing_idx) = [];
    [~, reorder_idx] = ismember(target_order, data_in.label);
end

% Reorder channel labels
data_out.label = data_in.label(reorder_idx);

% Reorder trial data (each trial is channels x timepoints)
for trial = 1:length(data_in.trial)
    data_out.trial{trial} = data_in.trial{trial}(reorder_idx, :);
end

% Keep other fields unchanged (they don't depend on channel order)
% hdr, time, fsample, sampleinfo, cfg remain the same

% Reorder electrode structure
if isfield(data_in, 'elec') && ~isempty(data_in.elec)
    data_out.elec = data_in.elec;
    
    % The elec.label should match data.label, so use same reordering
    if isfield(data_in.elec, 'label') && length(data_in.elec.label) == length(data_in.label)
        % Same reordering as channels
        data_out.elec.label = data_in.elec.label(reorder_idx);
        
        if isfield(data_in.elec, 'chanpos')
            data_out.elec.chanpos = data_in.elec.chanpos(reorder_idx, :);
        end
        
        if isfield(data_in.elec, 'elecpos')
            data_out.elec.elecpos = data_in.elec.elecpos(reorder_idx, :);
        end
        
        if isfield(data_in.elec, 'chantype')
            data_out.elec.chantype = data_in.elec.chantype(reorder_idx);
        end
        
        if isfield(data_in.elec, 'chanunit')
            data_out.elec.chanunit = data_in.elec.chanunit(reorder_idx);
        end
    else
        error('⚠️  Electrode labels don''t match data labels - keeping original elec structure\n');
    end
else
    error(' ⚠️  No electrode structure found\n');
end
end