clear
close all
pack
%%
restoredefaultpath
addpath D:\matlab_libs\fieldtrip-20230223
ft_defaults
addpath 'D:\matlab_libs\eeglab2023.0'
eeglab nogui;
%% Exteact inter-block baseline from basic-preprocessed set files
input_set_dir = 'D:\\AnatArzData\Data\preProcessed';
set_output_dir = 'D:\OExpOut\processed_data\set_subSovCond';
ft_output_dir = 'D:\OExpOut\processed_data\ft_subSovCond';
events_dir = 'D:\AnatArzData\Data\imported\elaborated_events';
ica_input_dir = 'D:\AnatArzData\Data\ica';
event_statistics_dir = 'D:\OExpOut\event_statistics';
events_withN2events_dir = "D:\OExpOut\old\eventDetection\try2\imported_eventDetectionChan\no_filters\events_with_sleepevents";

new_sample_rate = 250;

subs = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {'wake_morning','wake_night',"N2","N3","REM","tREM","pREM",'wake','N1'};
sovs = {'wake_night','N1',"N2","N3","REM","N2wo"}; % ,'wake_morning' % ,"N2wo","N2woSs"
%%
conds = {"NblT1","NblT2","NblT3","NblT4"}; %,


epoch_range_rel_to_event = [-0.1,0.58];
bl_range = 0; % s

standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)

% conds = {"NblAO","NblAOR","NblAOF"};
% % blO means that the bl amplitude offset of the epochs are just before the O, and not the first event. 
% 
% epoch_range_rel_to_event = [-0.1,1.16];
% bl_range = 0; % ms
% 
% standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
%                         set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir)
%%
conds = {"T1","T2","T3","T4"};
% blO means that the bl amplitude offset of the epochs are just before the O, and not the first event. 

epoch_range_rel_to_event = [-0.1,0.58];
bl_range = [-0.1,0]; % s

standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir)
%%
conds = {"AblT1","AblT2","AblT3","AblT4","AblOF","AblOR","AblO"};
% blO means that the bl amplitude offset of the epochs are just before the O, and not the first event. 

epoch_range_rel_to_event = [-0.1,1.16];
bl_range = [0.5,0.6]; % s

standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir)

%%

conds = {"NblAOF","NblAOR","NblAO"};
epoch_range_rel_to_event = [-0.1,1.16];
bl_range = 0; % s

standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)


%%
conds = {"intblk"};
epoch_range_rel_to_event = [0,5];
bl_range = 0; % ms
standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)

%%
conds = {"NblAO","NblAOR","NblAOF"};
conds = {"AO"};
conds = {"NblAO"};

sovs = {'wake_night','N1',"N2","N3","REM"}; 
epoch_range_rel_to_event = [-0.1,1.16];
bl_range = 0; % ms

create_subcond_epoched_smpIntblk(subs,sovs,conds, "intblk",epoch_range_rel_to_event,bl_range,new_sample_rate,set_output_dir,ft_output_dir)

%% create "LastAO","LastAOF","LastAOR"
% Notice: differnt +-XmicroVolt threshold than others!

conds = {"LastAOF","LastAT"};%,"LastAOFNoN2Events","LastATNoN2Events"};
post_onset_epoch_length = 6;
pre_onset_epoch_length = 0.1;

for sub_i = 1:numel(subs)
    % get files
    files_set = getSubSetFilesOfSOVs(input_set_dir,subs{sub_i},sovs);

    % skip sub if all it's output files exists
    if doesAllSetOutputExists(sovs, conds,subs{sub_i},set_output_dir) continue; end

    curr_sub_event_EEGs = struct();
    for files_i = 1:length(files_set)
        EEG_sub_file = pop_loadset('filename', files_set(files_i).name, 'filepath', input_set_dir);

        if ~isempty(strfind(files_set(files_i).name, 'wake_morning'))   file_sleepwake_name = 'morning';
        elseif ~isempty(strfind(files_set(files_i).name, 'wake_night')) file_sleepwake_name = 'night';
        elseif   ~isempty(strfind(files_set(files_i).name, 'sleep'))      file_sleepwake_name = 'sleep';
        else    error('no sleep / wake_morning / wake_night string in the files name');   
        end

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
        if length(files_events) > 1
            error('More than one file found. Please check the file pattern or directory.');
        end
        sub_events_filepath = sprintf("%s\\%s",events_dir,files_events(1).name);
        sub_events = load(sub_events_filepath);
        sub_events = sub_events.events;
        allevents = {EEG_sub_file.event.type};

        [EEG_sub_file,EEG_ica] = load_EEGfile_with_old_ICA(ica_input_dir,subs{sub_i},file_sleepwake_name,EEG_sub_file);

        for events_type_i=1:numel(conds)
            if strcmp(conds{events_type_i},'LastAOF')  ||  strcmp(conds{events_type_i},"LastAOFNoN2Events") 
                curr_events = find(strcmp({sub_events.TOA}, 'O') & ...
                    strcmp({sub_events.block_type}, 'fixed') & ...
                    [sub_events.trial_pos_in_block] == 10);
            elseif strcmp(conds{events_type_i},'LastAT') ||  strcmp(conds{events_type_i},"LastATNoN2Events") 
                curr_events = find(strcmp({sub_events.TOA}, 'T') &  ...
                                strcmp({sub_events.block_type}, 'random')  & ...
                                [sub_events.tone_pos_in_trial] ==10 & ...
                                [sub_events.trial_pos_in_block] == 10);
            else
                error('no such event type'); % or should it be just warning?
            end
            curr_events = curr_events - 1;

            if strcmp(conds{events_type_i},"LastATNoN2Events") || strcmp(conds{events_type_i},"LastAOFNoN2Events")
                % extract only events in N2 without ss and kc
                n2_sleepevents_reref_table = load(sprintf("%s\\sub%s_referenced_sleepEvents.mat",events_withN2events_dir,subs{sub_i}));
                n2_sleepevents_reref_table = n2_sleepevents_reref_table.sleepEvents;
                matchingRows = [];
                for i = 1:length(curr_events)
                    adaptorEventID = sub_events(curr_events(i)).event_id;
                    for j = 1:length(n2_sleepevents_reref_table)
                        if n2_sleepevents_reref_table(j).event_id == adaptorEventID ...
                            && n2_sleepevents_reref_table(j).is_ss == 0 ...
                            &&  n2_sleepevents_reref_table(j).is_kc == 0 ...
                            && j ~= numel(n2_sleepevents_reref_table) ... 
                            && j+1 ~= numel(n2_sleepevents_reref_table) ... 
                            && j+1+1 ~= numel(n2_sleepevents_reref_table) ... 
                            && j+1+1+1 ~= numel(n2_sleepevents_reref_table) ...
                            && n2_sleepevents_reref_table(j+1).is_ss == 0 ... % check if it happen in the omission after the adaptor
                            &&  n2_sleepevents_reref_table(j+1).is_kc == 0  ...% check if it happen in the omission after the adaptor
                            && n2_sleepevents_reref_table(j+1+1).is_ss == 0 ... % check if it happen in the omission afterafter the adaptor
                            &&  n2_sleepevents_reref_table(j+1+1).is_kc == 0  % check if it happen in the omission afterafter the adaptor
                            matchingRows = [matchingRows, curr_events(i)];
                            break; 
                        end
                    end
                end
                curr_events = matchingRows;
                if isempty(curr_events)
                    continue;
                end
            end

            for sov_i=1:numel(sovs)
                set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},conds{events_type_i}));
                if isfile(sprintf("%s\\%s",set_output_dir,set_output_file_name)) continue; end
                                
                % find event in the curr sov  
                curr_sov_curr_eventtype_indexes = intersect_events_in_sov(sovs{sov_i},files_set(files_i).name,curr_events,sub_events);
                if isempty(curr_sov_curr_eventtype_indexes) || numel(curr_sov_curr_eventtype_indexes)==1 continue;  end % if == 1, it creates issues with epochs.

                % select events
                EEG_currSovEvent = pop_epoch(EEG_sub_file,{},[-pre_onset_epoch_length post_onset_epoch_length],'eventindices',curr_sov_curr_eventtype_indexes);
                EEG_currSovEvent = pop_rmbase(EEG_currSovEvent, [-(1000*pre_onset_epoch_length)   0]);
   
                % reject trials with +-XmicroVolt. I check that does what it suppose to do (maybe you should use also "EEG = pop_select(EEG, 'notrial', EEG.rejepoch);") 
                % and it seems unnecessety, as the output includes the substraction of the epochs from the data array
                if contains(sovs{sov_i}, 'wake')  thresh_amp = 250;
                else                              thresh_amp = 400;    end
                if strcmp(conds{events_type_i}, 'intbk')
                    [EEG_currSovEvent, Indexes] = pop_eegthresh(EEG_currSovEvent, 1, 1:size(EEG_currSovEvent.data,1), -thresh_amp, thresh_amp, 0, 5-0.001, 0, 1);
                else
                    [EEG_currSovEvent, Indexes] = pop_eegthresh(EEG_currSovEvent, 1, 1:size(EEG_currSovEvent.data,1), -thresh_amp, thresh_amp, -0.1, post_onset_epoch_length, 0, 1);
                end
                if isempty(EEG_currSovEvent) || EEG_currSovEvent.trials == 1 continue;  end
    
                EEG_currSovEvent = prepro_end(EEG_currSovEvent,EEG_ica,new_sample_rate);
    
                % merge sleep set files into one EEGLAB stuct
                curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},conds{events_type_i});
                if ~isempty(EEG_currSovEvent) && ~EEG_currSovEvent.trials == 0 
                    if ~isfield(curr_sub_event_EEGs, curr_sov_eventtype_name)
                        curr_sub_event_EEGs.(curr_sov_eventtype_name) = EEG_currSovEvent;
                    else
                        curr_sub_event_EEGs.(curr_sov_eventtype_name) = pop_mergeset(curr_sub_event_EEGs.(curr_sov_eventtype_name), EEG_currSovEvent, 0);
                    end
                end
            end
        end
    end

    % events - set to ft
    for events_type_i=1:numel(conds)
        for sov_i=1:numel(sovs)
            curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},conds{events_type_i});
            if ~isfield(curr_sub_event_EEGs, curr_sov_eventtype_name) continue; end
            EEG_currSovEvent = curr_sub_event_EEGs.(curr_sov_eventtype_name);
            EEG_currSovEvent = eeg_checkset(EEG_currSovEvent);
    
    %         % save .set of the sub's sov      
            set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},conds{events_type_i}));
            pop_saveset(EEG_currSovEvent,'filename', set_output_file_name, 'filepath', set_output_dir);
    
            cfg = []; 
            cfg.dataset = sprintf('%s\\%s',set_output_dir,set_output_file_name);
            cfg.continuous = 'no';
            ft_data = ft_preprocessing(cfg);

            mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},conds{events_type_i}));
            ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
            save(ft_file_path,"ft_data");
        end
    end
end



%% create 'intbkMid' conds (<5s mean)
length_of_bl_epoch_sec = 5;
samples_per_trial = 170;
post_onset_epoch_length = 0.58;

trials_per_interblock_period = floor(length_of_bl_epoch_sec * new_sample_rate / samples_per_trial);
cut_start_timepoint = floor(((length_of_bl_epoch_sec * new_sample_rate) - (trials_per_interblock_period * samples_per_trial)) / 2);

conds = {'intbkMid'};
for sub_i = 1:numel(subs)
    for sov_i=1:numel(sovs)
        if strcmp(sovs{sov_i},'wake_morning') && strcmp(subs{sub_i},'14') ||  ...
             strcmp(sovs{sov_i},'tREM') && strcmp(subs{sub_i},'36')|| ...
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

%% 'intbk5'
for sub_i = 1:numel(subs)
    % events - set to ft
    for sov_i=1:numel(sovs)
        if (strcmp(sovs{sov_i},'wake_morning') && strcmp(subs{sub_i},'14')) || ...
            (strcmp(sovs{sov_i},'wake_morning') && strcmp(subs{sub_i},'23')) 
            continue;
        end

        % save .set of the sub's sov      
        set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},'intbk'));

        cfg = [];
        cfg.dataset = sprintf('%s\\%s',set_output_dir,set_output_file_name);
        cfg.continuous = 'no';
        ft_data = ft_preprocessing(cfg);

        mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},'intbk5'));
        ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
        save(ft_file_path,"ft_data");
    end
end

%% Functions

substring = 'A5thT'; % Specify the substring to look for in file names
folderPaths = {'D:\OExpOut\processed_data\ft_subSovCond', ...
                'D:\OExpOut\processed_data\ft_processed', ...
                'D:\OExpOut\processed_data\set_subSovCond', ...
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


replaceStringInFilenames("C:\OExpOut\processed_data\set_subSovCond", "interblock", "intbk");

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
function create_subcond_epoched_smpIntblk(subs,sovs,conds, intblk_string,epoch_range_rel_to_event,bl_range,sample_rate,set_output_dir,ft_output_dir)
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
            set_intblk_file_name = char(sprintf("s-%" + "s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},intblk_string));

            % turn to ft
            cfg = []; 
            cfg.dataset = sprintf('%s\\%s',set_output_dir,set_intblk_file_name);
            cfg.continuous = 'no';
            ft_data_all = ft_preprocessing(cfg);
    
            for cond_i=1:numel(conds)
                intlb_name = sprintf('intblksmp%s', conds{cond_i});
                mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},intlb_name));
                ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
                if isfile(sprintf("%s.mat",ft_file_path)) continue; end
    
                %%% get sov-cond num of trials
                set_sovcond_file_name = char(sprintf("s-%" + "s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},conds{cond_i}));
                EEG_currSovCond = pop_loadset('filename', set_sovcond_file_name, 'filepath', set_output_dir);
                subSovCond_number_of_trials = numel(EEG_currSovCond.epoch);
    
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
                    cfg.baselinewindow  = bl_range*1000;
                end
                cfg.trials = 1:size(ft_data_all.trial,2);
                ft_data = ft_preprocessing(cfg,ft_data_all);
        
                save(ft_file_path,"ft_data");
            end
        end
    end
end

function standardPreprocessing(subs,sovs,conds,epoch_range_rel_to_event,new_sample_rate,bl_range, ...
                        set_output_dir,input_set_dir,events_dir,ica_input_dir,ft_output_dir,events_withN2events_dir)

    for sub_i = 1:numel(subs)
        % get files
        files_set = getSubSetFilesOfSOVs(input_set_dir,subs{sub_i},sovs);
        if numel(files_set) ==0
            error("No files for sub %s, in folder %s",subs{sub_i},input_set_dir);
        end
    
        % skip sub if all it's output files exists
        if doesAllSetOutputExists(sovs, conds,subs{sub_i},set_output_dir) continue; end
    
        curr_sub_event_EEGs = struct();
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
            if length(files_events) > 1
                error('More than one file found. Please check the file pattern or directory.');
            end
            sub_ses_events_filepath = sprintf("%s\\%s",events_dir,files_events(1).name);
            sub_ses_orijFile_events = load(sub_ses_events_filepath);
            sub_ses_orijFile_events = sub_ses_orijFile_events.events;
            if numel(sub_ses_orijFile_events) ~= numel(EEG_sub_file.event)
                error('events array dont match')
            end
            
            for events_type_i=1:numel(conds)
                for sov_i=1:numel(sovs)
                    currSes_currCond_eventsIDs = eventHandler(conds{events_type_i},sub_ses_orijFile_events);
                    if isempty(currSes_currCond_eventsIDs) continue; end

                    set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},conds{events_type_i}));
                    if isfile(sprintf("%s\\%s",set_output_dir,set_output_file_name)) continue; end

                    currSes_currCond_eventsIDs = intersect_events_in_sov(sovs{sov_i},files_set(files_i).name,currSes_currCond_eventsIDs,sub_ses_orijFile_events);
                                    
                    % find event in the curr sov  
                    if strcmp(sovs{sov_i},"N2woSs") || strcmp(sovs{sov_i},"N2wo")
                        currSes_currCond_eventsIDs = extractOnlyN2WithoutSS(events_withN2events_dir,subs{sub_i},currSes_currCond_eventsIDs,2);
                    end
                    if strcmp(sovs{sov_i},"N2woKc") || strcmp(sovs{sov_i},"N2wo")
                        currSes_currCond_eventsIDs = extractOnlyN2WithoutKc(events_withN2events_dir,subs{sub_i},currSes_currCond_eventsIDs,2);
                    end
                    
                    if isempty(currSes_currCond_eventsIDs) || numel(currSes_currCond_eventsIDs)==1 continue;  end % if == 1, it creates issues with epochs.
                    
                    matching_indices = ismember([sub_ses_orijFile_events.event_id], currSes_currCond_eventsIDs);
                    filtered_events = sub_ses_orijFile_events(matching_indices);
                    matching_rows = find(matching_indices);
    
                    % select events
                    EEG_currSovEvent = pop_epoch(EEG_sub_file,{},epoch_range_rel_to_event,'eventindices',matching_rows);
                    if ~(isscalar(bl_range) && bl_range == 0)
                        EEG_currSovEvent = pop_rmbase(EEG_currSovEvent,1000*bl_range);
                    end
       
                    % reject trials with +-XmicroVolt. I check that does what it suppose to do (maybe you should use also "EEG = pop_select(EEG, 'notrial', EEG.rejepoch);") 
                    % and it seems unnecessety, as the output includes the substraction of the epochs from the data array
                    if contains(sovs{sov_i}, 'wake')  thresh_amp = 150;
                    else                              thresh_amp = 300;    end
                    [EEG_currSovEvent, ~] = pop_eegthresh(EEG_currSovEvent, 1, 1:size(EEG_currSovEvent.data,1), -thresh_amp, thresh_amp, epoch_range_rel_to_event(1), epoch_range_rel_to_event(2), 0, 1);
                    if isempty(EEG_currSovEvent)   continue;  end
        
                    EEG_currSovEvent = prepro_end(EEG_currSovEvent,EEG_ica,new_sample_rate);
        
                    % merge sleep set files into one EEGLAB stuct
                    curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},conds{events_type_i});
                    if ~isempty(EEG_currSovEvent) && ~EEG_currSovEvent.trials == 0 
                        if ~isfield(curr_sub_event_EEGs, curr_sov_eventtype_name)
                            curr_sub_event_EEGs.(curr_sov_eventtype_name) = EEG_currSovEvent;
                        else
                            curr_sub_event_EEGs.(curr_sov_eventtype_name) = pop_mergeset(curr_sub_event_EEGs.(curr_sov_eventtype_name), EEG_currSovEvent, 0);
                        end
                    end
                end
            end
        end
    
    
        % events - set to ft
        for events_type_i=1:numel(conds)
            for sov_i=1:numel(sovs)
                curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},conds{events_type_i});
                if ~isfield(curr_sub_event_EEGs, curr_sov_eventtype_name) continue; end
                EEG_currSovEvent = curr_sub_event_EEGs.(curr_sov_eventtype_name);
                EEG_currSovEvent = eeg_checkset(EEG_currSovEvent);
        
        %         % save .set of the sub's sov      
                set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},conds{events_type_i}));
                pop_saveset(EEG_currSovEvent,'filename', set_output_file_name, 'filepath', set_output_dir);
        
                cfg = []; 
                cfg.dataset = sprintf('%s\\%s',set_output_dir,set_output_file_name);
                cfg.continuous = 'no';
                ft_data = ft_preprocessing(cfg);
    
                mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},conds{events_type_i}));
                ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
                save(ft_file_path,"ft_data");
            end
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
    elseif strcmp(cond,'T1') || strcmp(cond,'NblT1')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 1 );
    elseif strcmp(cond,'T2') || strcmp(cond,'NblT2')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 2 );
    elseif strcmp(cond,'T3') || strcmp(cond,'NblT3')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 3 );
    elseif strcmp(cond,'T4') || strcmp(cond,'NblT4')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 4 );
    elseif strcmp(cond,'AT8')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'T') & [sub_events.tone_pos_in_trial] == 8 );
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
    elseif strcmp(cond,'LastOF18')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'O')  & [sub_events.trial_pos_in_block] == 10   & strcmp({sub_events.block_type}, 'fixed'));
    elseif strcmp(cond,'OF18')
        curr_events_rows = find(strcmp({sub_events.TOA}, 'O')  & strcmp({sub_events.block_type}, 'fixed'));
    elseif strcmp(cond,'LastOR18')
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

% extract only events in N2 without kc
function extracted_events = extractOnlyN2WithoutKc(events_withN2events_dir,sub,curr_events_ids,adjecent_range_to_exclude)
    n2_sleepevents_reref_table = load(sprintf("%s\\sub%s_referenced_sleepEvents.mat",events_withN2events_dir,sub));
    n2_sleepevents_reref_table = n2_sleepevents_reref_table.sleepEvents;

    matching_indices = false(size(n2_sleepevents_reref_table));
    for i = 1:length(curr_events_ids)
        is_curr_event = [n2_sleepevents_reref_table.event_id] == curr_events_ids(i);
        
        in_adjacent_range = ([n2_sleepevents_reref_table.event_id] >= curr_events_ids(i) - adjecent_range_to_exclude) & ...
                            ([n2_sleepevents_reref_table.event_id] <= curr_events_ids(i) + adjecent_range_to_exclude) & ...
                            ~is_curr_event;  % Exclude the current event from the adjacent range

        if any([n2_sleepevents_reref_table(in_adjacent_range).is_kc] ~= 0)
            continue;
        end
        
        % If no adjacent events with is_ss ~= 0, mark the current event as matching
        matching_indices = matching_indices | is_curr_event;
    end
    
    % Get the subset of the struct array that meets the conditions
    filtered_table = n2_sleepevents_reref_table(matching_indices);
    extracted_events = [filtered_table.('event_id')];
end

% extract only events in N2 without ss
function extracted_events = extractOnlyN2WithoutSS(events_withN2events_dir,sub,curr_events_ids,adjecent_range_to_exclude)
    n2_sleepevents_reref_table = load(sprintf("%s\\sub%s_referenced_sleepEvents.mat",events_withN2events_dir,sub));
    n2_sleepevents_reref_table = n2_sleepevents_reref_table.sleepEvents;

    matching_indices = false(size(n2_sleepevents_reref_table));
    for i = 1:length(curr_events_ids)
        is_curr_event = [n2_sleepevents_reref_table.event_id] == curr_events_ids(i);
        
        in_adjacent_range = ([n2_sleepevents_reref_table.event_id] >= curr_events_ids(i) - adjecent_range_to_exclude) & ...
                            ([n2_sleepevents_reref_table.event_id] <= curr_events_ids(i) + adjecent_range_to_exclude) & ...
                            ~is_curr_event;  % Exclude the current event from the adjacent range

        if any([n2_sleepevents_reref_table(in_adjacent_range).is_ss] ~= 0)
            continue;
        end
        
        % If no adjacent events with is_ss ~= 0, mark the current event as matching
        matching_indices = matching_indices | is_curr_event;
    end
    
    % Get the subset of the struct array that meets the conditions
    filtered_table = n2_sleepevents_reref_table(matching_indices);
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

function does_all_set_output_exist = doesAllSetOutputExists(sovs, conds,sub_s,set_output_dir)
    does_all_set_output_exist = true;
    for sov_i=1:numel(sovs)
        for events_type_i=1:numel(conds)
            set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",sub_s, sovs{sov_i},conds{events_type_i}));
            if ~isfile(sprintf("%s\\%s",set_output_dir,set_output_file_name)) 
                does_all_set_output_exist = false; 
            end
        end
    end
end

function does_all_ft_output_exist = doesAllFtOutputExists(sovs, conds,sub_s,ft_output_dir)
    does_all_ft_output_exist = true;
    for sov_i=1:numel(sovs)
        for events_type_i=1:numel(conds)
            set_output_file_name = char(sprintf("s_%s_%s_%s.set",sub_s, sovs{sov_i},conds{events_type_i}));
            if ~isfile(sprintf("%s\\%s",ft_output_dir,set_output_file_name)) 
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
    new_sov_curr_eventtype_ids =[];
    if strcmp(sov,'wake') && (contains(curr_file_name, "wake_morning") || contains(curr_file_name, "wake_night"))
        new_sov_curr_eventtype_ids = curr_events_id;
        return
    elseif (strcmp(sov,'wake_morning') && contains(curr_file_name, "wake_morning")) || ...
        (strcmp(sov,'wake_night') &&  contains(curr_file_name, "wake_night"))
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
    elseif strcmp(sov,'N2wo') || strcmp(sov,'N2woSs') || strcmp(sov,'N2woKc')
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

    
