restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;
%% Exteact inter-block baseline from basic-preprocessed set files
input_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\preProcessed';
set_output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\interblock_baseline_extraction\';
input_reref_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\';
ft_output_dir = set_output_dir;'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\ft_per_cond\';
events_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\imported\elaborated_events';
ica_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\ica';

length_of_bl_epoch_sec = 5;
new_sample_rate = 250;
samples_per_trial = 138;
trials_per_interblock_period = floor(length_of_bl_epoch_sec * new_sample_rate / samples_per_trial);

subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {"N1","N2","N3","REM",'wake','wake_morning','wake_night'};
% sovs = {'wake_morning','wake_night'};
% sovs = {'wake'};
events_type = {"Oprep","OFprep","ORprep",'interblock'};

%% 
for sub_i = 1:numel(subs)
    file_pattern = fullfile(input_set_dir, sprintf('*%s*.set',subs{sub_i}));
    if all(cellfun(@(x) ischar(x) && contains(x, 'wake'), sovs))
        file_pattern = fullfile(input_set_dir, sprintf('*%s*wake*.set',subs{sub_i}));
    elseif ~any(cellfun(@(x) ischar(x) && contains(x, 'wake'), sovs))
        file_pattern = fullfile(input_set_dir, sprintf('*%s*sleep*.set',subs{sub_i}));
    end
    files_set = dir(file_pattern);

    % skip sub if all it's files are done
    does_all_output_exist = true;
    for sov_i=1:numel(sovs)
        for events_type_i=1:numel(events_type)
            set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},events_type{events_type_i}));
            if ~isfile(sprintf("%s\\%s",set_output_dir,set_output_file_name)) does_all_output_exist = false; end
        end
    end
    if does_all_output_exist continue; end

    curr_sub_event_EEGs = struct();
    for files_i = 1:length(files_set)
        if strcmp(subs{sub_i},'37') && contains(files_set(files_i).name,'night')
            continue;
        end
        EEG_sub_file = pop_loadset('filename', files_set(files_i).name, 'filepath', input_set_dir);

        if ~isempty(strfind(files_set(files_i).name, 'wake_morning'))
            file_sleepwake_name = 'morning';
        elseif ~isempty(strfind(files_set(files_i).name, 'wake_night'))
            file_sleepwake_name = 'night';
        else
            file_sleepwake_name = 'sleep';
        end

        % load events and set files
        if contains(files_set(files_i).name,'sleep')
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*%d*',subs{sub_i},file_sleepwake_name,files_i));
        else
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*',subs{sub_i},file_sleepwake_name));
        end
        files_events = dir(file_pattern);
        if length(files_events) > 1
            error('More than one file found. Please check the file pattern or directory.');
        end
        sub_events_filepath = sprintf("%s\\%s",events_dir,files_events(1).name); % todo: make sure the right file is loadied by entering fileUM TO REGEX
        sub_events = load(sub_events_filepath);
        sub_events = sub_events.events;
        allevents = {EEG_sub_file.event.type};

        % get EEG struct for ica components and channels to reject
        file_pattern = fullfile(ica_input_dir, sprintf('*%s*%s*ICA.set',subs{sub_i},file_sleepwake_name));
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
        EEG_sub_file = eeg_checkset(EEG_sub_file); % it was critical in the continuos case. Not it's problematic. So I remove it.
    
        for events_type_i=1:numel(events_type)
            if strcmp(events_type{events_type_i},'Oprep')
                curr_events = find(strcmp({sub_events.TOA}, 'O'));
            elseif strcmp(events_type{events_type_i},'OFprep')
                curr_events = find(strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'fixed'));
            elseif strcmp(events_type{events_type_i},'ORprep')
                curr_events = find(strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'random'));
            elseif strcmp(events_type{events_type_i},'interblock')
                curr_events = find(strncmp('BGIN',allevents,length('BGIN')));
            else
                warning('no such event type');
            end

            for sov_i=1:numel(sovs)
                set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},events_type{events_type_i}));
                if isfile(sprintf("%s\\%s",set_output_dir,set_output_file_name)) continue; end
                                
                % find event in the curr sov  
                curr_sov_curr_eventtype_indexes =[];
                if strcmp(sovs{sov_i},'wake') && (contains(files_set(files_i).name, "wake_morning") || contains(files_set(files_i).name, "wake_night"))
                    curr_sov_curr_eventtype_indexes = curr_events;
                elseif (strcmp(sovs{sov_i},'wake_morning') && contains(files_set(files_i).name, "wake_morning")) || ...
                    (strcmp(sovs{sov_i},'wake_night') &&  contains(files_set(files_i).name, "wake_night"))
                    curr_sov_curr_eventtype_indexes = curr_events;
                else
                    curr_sov_curr_eventtype_indexes = intersect(find(strcmp({sub_events.sleep_stage}, sovs{sov_i})), curr_events);
                end
                if isempty(curr_sov_curr_eventtype_indexes) || numel(curr_sov_curr_eventtype_indexes)==1 continue;  end % if == 1, it creates issues with epochs.
                    
                % select events
                if strcmp(events_type{events_type_i},'interblock')
                    EEG_currSovEvent = pop_epoch(EEG_sub_file,{},[0 length_of_bl_epoch_sec],'eventindices',curr_sov_curr_eventtype_indexes);
                    EEG_currSovEvent = pop_rmbase(EEG_currSovEvent, []); % EEG_currSov = pop_rmbase(EEG_currSov, 'timerange',[0 200]);
                else
                    EEG_currSovEvent = pop_epoch(EEG_sub_file,{},[-0.1 0.45],'eventindices',curr_sov_curr_eventtype_indexes);
                    EEG_currSovEvent = pop_rmbase(EEG_currSovEvent, [-100   0]);
                end
   
                % reject trials with +-300microVolt. 
                % TODO: check that does what
                % it suppose to do. maybe you should use also "EEG =
                % pop_select(EEG, 'notrial', EEG.rejepoch);" Seems unnecessety,
                % as the output includes the substraction of the epochs from
                % the data array
                if contains(sovs{sov_i}, 'wake')
                    thresh_amp = 150;
                else
                    thresh_amp = 300;
                end
                if strcmp(events_type{events_type_i}, 'interblock')
                    [EEG_currSovEvent, Indexes] = pop_eegthresh(EEG_currSovEvent, 1, 1:size(EEG_currSovEvent.data,1), -thresh_amp, thresh_amp, 0, 5-0.001, 0, 1);
                else
                    [EEG_currSovEvent, Indexes] = pop_eegthresh(EEG_currSovEvent, 1, 1:size(EEG_currSovEvent.data,1), -thresh_amp, thresh_amp, -0.1, 0.448, 0, 1);
                end
                if isempty(EEG_currSovEvent)   continue;  end
    
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
    
                % merge sleep set files into one EEGLAB stuct
                curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},events_type{events_type_i});
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
    for events_type_i=1:numel(events_type)
        for sov_i=1:numel(sovs)
            curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},events_type{events_type_i});
            if ~isfield(curr_sub_event_EEGs, curr_sov_eventtype_name) continue; end
            EEG_currSovEvent = curr_sub_event_EEGs.(curr_sov_eventtype_name);
            EEG_currSovEvent = eeg_checkset(EEG_currSovEvent);
    
    %         % save .set of the sub's sov      
            set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},events_type{events_type_i}));
            pop_saveset(EEG_currSovEvent,'filename', set_output_file_name, 'filepath', set_output_dir);
    
            cfg = []; 
            cfg.dataset = sprintf('%s\\%s',set_output_dir,set_output_file_name);
            cfg.continuous = 'no';
            ft_data = ft_preprocessing(cfg);

            if strcmp(events_type{events_type_i}, 'interblock')
                new_number_of_trials = length(ft_data.trial) * trials_per_interblock_period;

                % devide ft_data to trials_per_interblock_period sections
                new_ftdata_trial = cell(1, new_number_of_trials);
                idx = 1;
                for i = 1:length(ft_data.trial)
                    data = ft_data.trial{i}; 
                    % Divide into sections of size samples_per_trial
                    for j = 1 : samples_per_trial : (samples_per_trial*trials_per_interblock_period)
                        section = data(:, j:j+(samples_per_trial-1)); % Extract samples_per_trial columns
                        new_ftdata_trial{idx} = section;
                        idx = idx+1;
                    end
                end
                ft_data.trial = new_ftdata_trial;
        
                % Creating the 1xsamples_per_trial double array
                new_timestamps = -0.1:(1/new_sample_rate):0.45;
                new_ftdata_time = cell(1, new_number_of_trials);
                for i = 1:new_number_of_trials
                    new_ftdata_time{i} = new_timestamps;
                end
                ft_data.time = new_ftdata_time;
        
                ft_data.hdr.nTrials = new_number_of_trials;
                
                % new ft_data.cfg.trl and ft_data.sampleinfo
                new_ftdata_cfg_trl = zeros(new_number_of_trials, 3);
                new_ftdata_cfg_trl(1,1) = 1;
                for i = 2:new_number_of_trials
                    new_ftdata_cfg_trl(i,1) = (new_ftdata_cfg_trl(i-1,1) + samples_per_trial);
                end
                new_ftdata_cfg_trl(:,2) = (new_ftdata_cfg_trl(:,1) + samples_per_trial -1);
                ft_data.cfg.trl = new_ftdata_cfg_trl;
                ft_data.sampleinfo = new_ftdata_cfg_trl(:, 1:end-1);
        
                % Baseline-correction options
                cfg = [];
                cfg.demean          = 'yes';
                cfg.baselinewindow  = [-0.1 0];
                ft_data = ft_preprocessing(cfg,ft_data);
            end
            mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},events_type{events_type_i}));
            ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
            save(ft_file_path,"ft_data");
        end
    end
end

%%
% Define the directory path
directoryPath = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\ica'; % Change this to your directory

% Define the prefix to be removed
prefixToRemove = 'Copy of ';

% Get a list of all files in the directory with the given prefix
files = dir(fullfile(directoryPath, [prefixToRemove '*']));

% Loop through each file
for k = 1:length(files)
    oldFileName = files(k).name;
    newFileName = strrep(oldFileName, prefixToRemove, '');

    % Create full file paths
    oldFilePath = fullfile(directoryPath, oldFileName);
    newFilePath = fullfile(directoryPath, newFileName);
    
    % Rename the file
    movefile(oldFilePath, newFilePath);
end
