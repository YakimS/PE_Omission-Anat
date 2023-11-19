restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;
%% Exteact inter-block baseline from basic-preprocessed set files
input_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\preProcessed';
set_output_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\interblock_baseline_extraction\';
input_reref_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\';
ft_output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\ft_per_cond\';
events_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\imported\elaborated_events';
ica_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\ica_interpolated';

length_of_bl_epoch_sec = 5;
sample_rate = 250;
top_freq = 40;
samples_per_trial = 138;
trials_per_interblock_period = floor(length_of_bl_epoch_sec * sample_rate / samples_per_trial);

subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
%subs = {'08','09','10','11','13','14','15'};
sovs = {"N1","N2","N3","REM",'wake'};
%sovs = {'wake'};

%% create interblock baseline
for sub_i = 1:numel(subs)
    file_pattern = fullfile(input_set_dir, sprintf('*%s*.set',subs{sub_i}));
    if all(strcmp(sovs, 'wake'))
        file_pattern = fullfile(input_set_dir, sprintf('*%s*wake*.set',subs{sub_i}));
    elseif ~any(strcmp(sovs, 'wake'))
        file_pattern = fullfile(input_set_dir, sprintf('*%s*sleep*.set',subs{sub_i}));
    end
    files_set = dir(file_pattern);

    % skip sub if all it's files are done
    does_all_output_exist = true;
    for sov_i=1:numel(sovs)
        set_output_file_name = char(sprintf("s-%s_interblockBaseline_sov-%s.set",subs{sub_i}, sovs{sov_i}));
        if ~isfile(sprintf("%s\\%s",set_output_dir,set_output_file_name)) does_all_output_exist = false; end
    end
    if does_all_output_exist continue; end

    curr_sub_EEGs = struct();
    for files_i = 1:length(files_set)
        if strcmp(subs{sub_i},'37') && contains(files_set(files_i).name,'night')
            continue;
        end
        EEG_sub_file = pop_loadset('filename', files_set(files_i).name, 'filepath', input_set_dir);
    
        % downsample
        EEG_sub_file =  pop_resample( EEG_sub_file, 250);
     
        if ~isempty(strfind(files_set(files_i).name, 'wake_morning'))
            file_sleepwake_name = 'morning';
        elseif ~isempty(strfind(files_set(files_i).name, 'wake_night'))
            file_sleepwake_name = 'night';
        else
            file_sleepwake_name = 'sleep';
        end

        
        file_pattern = fullfile(ica_input_dir, sprintf('*%s*%s*.set',subs{sub_i},file_sleepwake_name));
        files_ica = dir(file_pattern);
        if length(files_ica) > 1
            warning('More than one file found. Please check the file pattern or directory.');
        end
        icaEEG = pop_loadset('filepath',ica_input_dir,'filename',files_ica(1).name,'loadmode','info');
        % ICA rejection
        if isfield(icaEEG,'icaweights') && ~isempty(icaEEG.icaweights)
            fprintf('Loading existing ICA info from %s%s.\n',EEG_sub_file.filepath,EEG_sub_file.filename);
            EEG_sub_file.icaact = icaEEG.icaact;
            EEG_sub_file.icawinv = icaEEG.icawinv;
            EEG_sub_file.icasphere = icaEEG.icasphere;
            EEG_sub_file.icaweights = icaEEG.icaweights;
            EEG_sub_file.icachansind = icaEEG.icachansind;
            EEG_sub_file.reject.gcompreject = icaEEG.reject.gcompreject;
            
            pattern = 'pop_subcomp\( EEG, \[(.*?)\],';
            matches = regexp( icaEEG.history, pattern, 'tokens');
            numberArray = str2num(matches{1}{1}); %#ok<ST2NM> This function is appropriate here for converting string arrays
            EEG_sub_file = pop_subcomp(EEG_sub_file,numberArray,0); % turn the last variable to 1 to see the ICA results
        end


        %%% remove noisy electrodes
        chandata = reshape(EEG_sub_file.data,EEG_sub_file.nbchan,EEG_sub_file.pnts*EEG_sub_file.trials); %Get chan x tpts..
        zerochan = find(var(chandata,0,2) < 0.5); %Remove zero channels from spec..
        electrodes = setdiff(1:EEG_sub_file.nbchan,zerochan);
        [EEG_sub_file, indelec, ~, com] = pop_rejchan(EEG_sub_file,'elec',electrodes ,'threshold',[-3.5 3.5],'norm','on','measure','spec' ,'freqrange',[1 top_freq]);
         %file_pattern = fullfile(input_reref_set_dir, sprintf('*%s*%s*.set',subs{sub_i},file_sleepwake_name)); % File pattern to match
%         files_reref = dir(file_pattern);
%         rerefEEG = pop_loadset('filepath',input_reref_set_dir,'filename',files_reref(1).name,'loadmode','info');
% %         if ~isempty(rerefEEG.reject.rejchan)  
% %             EEG_sub_file = pop_select(EEG_sub_file,'nochannel',rerefEEG.reject.rejchan);  
% %         end   
        % reject electrodes according to prev pre-processing
    %         file_pattern = fullfile(ica_input_dir, sprintf('*%s*.set',subs{sub_i})); % File pattern to match
    %         files_ica = dir(file_pattern);
    %         icaEEG = pop_loadset('filepath',ica_input_dir,'filename',files_ica(1).name,'loadmode','info');
    %         if isfield(icaEEG,'rejchan') && ~isempty(icaEEG.rejchan)
    %             EEG.rejchan = icaEEG.rejchan;
    %             for c = 1:length(EEG.chanlocs)
    %                 EEG.chanlocs(c).badchan = 0;
    %             end
    %             fprintf('Found %d bad channels and %d bad trials in existing file.\n', length(EEG.rejchan), length(EEG.rejepoch));
    %             if ~isempty(EEG.rejchan)  
    %                 EEG = pop_select(EEG,'nochannel',{EEG.rejchan.labels});  
    %             end
    %         end
        if ~isempty(indelec)  
            EEG_sub_file = pop_select(EEG_sub_file,'nochannel',{EEG_sub_file.chaninfo.removedchans.labels});  
            EEG_sub_file = eeg_interp(EEG_sub_file, EEG_sub_file.chaninfo.removedchans);
        end
    
        % load events and set files
        if contains(files_set(files_i).name,'sleep')
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*%d*',subs{sub_i},file_sleepwake_name,files_i));
        else
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*',subs{sub_i},file_sleepwake_name));
        end
        files_events = dir(file_pattern);
        if length(files_events) > 1
            warning('More than one file found. Please check the file pattern or directory.');
        end
        sub_events_filepath = sprintf("%s\\%s",events_dir,files_events(1).name); % todo: make sure the right file is loadied by entering fileUM TO REGEX
        sub_events = load(sub_events_filepath);
        sub_events = sub_events.events;
        allevents = {EEG_sub_file.event.type};
        bgin_events = find(strncmp('BGIN',allevents,length('BGIN')));

        for sov_i=1:numel(sovs)
            set_output_file_name = char(sprintf("s-%s_interblockBaseline_sov-%s.set",subs{sub_i}, sovs{sov_i}));
%             if isfile(sprintf("%s\\%s",set_output_dir,set_output_file_name)) continue; end
                            
            % find BGIN in the curr sov    
            curr_sov_BGIN_indexes =[];
            if strcmp(sovs{sov_i},'wake') && (contains(files_set(files_i).name, "wake_morning") || contains(files_set(files_i).name, "wake_night"))
                curr_sov_BGIN_indexes = bgin_events;
            else
                for bgin_events_i =1:numel(bgin_events)
                    if strcmp(sub_events(bgin_events(bgin_events_i)).('sleep_stage'), sovs{sov_i})
                        curr_sov_BGIN_indexes = [curr_sov_BGIN_indexes, bgin_events(bgin_events_i)];
                    end
                end
            end
            if isempty(curr_sov_BGIN_indexes) continue;  end
                
            % select events
            EEG_currSov = pop_epoch(EEG_sub_file,{},[0 length_of_bl_epoch_sec],'eventindices',curr_sov_BGIN_indexes);
            EEG_currSov = pop_rmbase(EEG_currSov, 'timerange',[0 200]);

            % reject trials with +-300microVolt. 
            [EEG_currSov, Indexes] = pop_eegthresh(EEG_currSov, 1, 1:size(EEG_currSov.data,1), -300, 300, 0, 5-0.001, 0, 1);
            if isempty(EEG_currSov)   continue;  end

            % rereferencing
            EEG_currSov = pop_reref( EEG_currSov, []);
            rowWithLabelCz = EEG_currSov.chaninfo.ndchanlocs(strcmp({EEG_currSov.chaninfo.ndchanlocs.labels}, 'Cz'));
            EEG_currSov = eeg_interp(EEG_currSov,rowWithLabelCz);

            % merge sleep set files into one EEGLAB stuct
            if ~isempty(EEG_currSov) && ~EEG_currSov.trials == 0 
                if ~isfield(curr_sub_EEGs, sovs{sov_i})
                    curr_sub_EEGs.(sovs{sov_i}) = EEG_currSov;
                else
                    curr_sub_EEGs.(sovs{sov_i}) = pop_mergeset( curr_sub_EEGs.(sovs{sov_i}), EEG_currSov, 0);
                end
            end
        end
    end

    for sov_i=1:numel(sovs)
        if ~isfield(curr_sub_EEGs, sovs{sov_i}) continue; end
        EEG_currSov = curr_sub_EEGs.(sovs{sov_i});
        EEG_currSov = eeg_checkset(EEG_currSov);

% %         % save .set of the sub's sov
        set_output_file_name = char(sprintf("s-%s_interblockBaseline_sov-%s.set",subs{sub_i}, sovs{sov_i}));
%         pop_saveset(EEG_currSov,'filename', set_output_file_name, 'filepath', set_output_dir);

        cfg = []; 
        cfg.dataset = sprintf('%s\\%s',set_output_dir,set_output_file_name);
        cfg.continuous = 'no';
        ft_data = ft_preprocessing(cfg);

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
        new_timestamps = -0.1:(1/sample_rate):0.45;
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
        cfg.demean          = 'yes';
        cfg.baselinewindow  = [-0.1 0];
        ft_data = ft_preprocessing(cfg,ft_data);

        ft_output_file_name = strrep(set_output_file_name, 'set', 'mat');
        ft_file_path = sprintf('%s\\%s',ft_output_dir,ft_output_file_name);
        save(ft_file_path,"ft_data");
    end
end
%%
% Define the directory path
directoryPath = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sub15_all_files'; % Change this to your directory

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

%% create omission
sovs = {"N1","N2","N3","REM",'wake'};
events_type = {"Oprep","OFprep","ORprep"};

for sub_i = 1:numel(subs)
    file_pattern = fullfile(input_set_dir, sprintf('*%s*.set',subs{sub_i}));
    if all(strcmp(sovs, 'wake'))
        file_pattern = fullfile(input_set_dir, sprintf('*%s*wake*.set',subs{sub_i}));
    elseif ~any(strcmp(sovs, 'wake'))
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
    
        % downsample
        EEG_sub_file =  pop_resample( EEG_sub_file, 250);
     
        if ~isempty(strfind(files_set(files_i).name, 'wake_morning'))
            file_sleepwake_name = 'morning';
        elseif ~isempty(strfind(files_set(files_i).name, 'wake_night'))
            file_sleepwake_name = 'night';
        else
            file_sleepwake_name = 'sleep';
        end

        file_pattern = fullfile(ica_input_dir, sprintf('*%s*%s*.set',subs{sub_i},file_sleepwake_name));
        files_ica = dir(file_pattern);
        if length(files_ica) > 1
            warning('More than one file found. Please check the file pattern or directory.');
        end
        icaEEG = pop_loadset('filepath',ica_input_dir,'filename',files_ica(1).name,'loadmode','info');
        % ICA rejection
        if isfield(icaEEG,'icaweights') && ~isempty(icaEEG.icaweights)
            fprintf('Loading existing ICA info from %s%s.\n',EEG_sub_file.filepath,EEG_sub_file.filename);
            EEG_sub_file.icaact = icaEEG.icaact;
            EEG_sub_file.icawinv = icaEEG.icawinv;
            EEG_sub_file.icasphere = icaEEG.icasphere;
            EEG_sub_file.icaweights = icaEEG.icaweights;
            EEG_sub_file.icachansind = icaEEG.icachansind;
            EEG_sub_file.reject.gcompreject = icaEEG.reject.gcompreject;
            
            pattern = 'pop_subcomp\( EEG, \[(.*?)\],';
            matches = regexp( icaEEG.history, pattern, 'tokens');
            numberArray = str2num(matches{1}{1}); %#ok<ST2NM> This function is appropriate here for converting string arrays
            EEG_sub_file = pop_subcomp(EEG_sub_file,numberArray,0); % turn the last variable to 1 to see the ICA results
        end


        %%% remove noisy electrodes
        chandata = reshape(EEG_sub_file.data,EEG_sub_file.nbchan,EEG_sub_file.pnts*EEG_sub_file.trials); %Get chan x tpts..
        zerochan = find(var(chandata,0,2) < 0.5); %Remove zero channels from spec..
        electrodes = setdiff(1:EEG_sub_file.nbchan,zerochan);
        [EEG_sub_file, indelec, ~, com] = pop_rejchan(EEG_sub_file,'elec',electrodes ,'threshold',[-3.5 3.5],'norm','on','measure','spec' ,'freqrange',[1 top_freq]);
         %file_pattern = fullfile(input_reref_set_dir, sprintf('*%s*%s*.set',subs{sub_i},file_sleepwake_name)); % File pattern to match
%         files_reref = dir(file_pattern);
%         rerefEEG = pop_loadset('filepath',input_reref_set_dir,'filename',files_reref(1).name,'loadmode','info');
% %         if ~isempty(rerefEEG.reject.rejchan)  
% %             EEG_sub_file = pop_select(EEG_sub_file,'nochannel',rerefEEG.reject.rejchan);  
% %         end   
        % reject electrodes according to prev pre-processing
    %         file_pattern = fullfile(ica_input_dir, sprintf('*%s*.set',subs{sub_i})); % File pattern to match
    %         files_ica = dir(file_pattern);
    %         icaEEG = pop_loadset('filepath',ica_input_dir,'filename',files_ica(1).name,'loadmode','info');
    %         if isfield(icaEEG,'rejchan') && ~isempty(icaEEG.rejchan)
    %             EEG.rejchan = icaEEG.rejchan;
    %             for c = 1:length(EEG.chanlocs)
    %                 EEG.chanlocs(c).badchan = 0;
    %             end
    %             fprintf('Found %d bad channels and %d bad trials in existing file.\n', length(EEG.rejchan), length(EEG.rejepoch));
    %             if ~isempty(EEG.rejchan)  
    %                 EEG = pop_select(EEG,'nochannel',{EEG.rejchan.labels});  
    %             end
    %         end
        if ~isempty(indelec)  
            EEG_sub_file = pop_select(EEG_sub_file,'nochannel',{EEG_sub_file.chaninfo.removedchans.labels});  
            EEG_sub_file = eeg_interp(EEG_sub_file, EEG_sub_file.chaninfo.removedchans);
        end
    
        % load events and set files
        if contains(files_set(files_i).name,'sleep')
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*%d*',subs{sub_i},file_sleepwake_name,files_i));
        else
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*',subs{sub_i},file_sleepwake_name));
        end
        files_events = dir(file_pattern);
        if length(files_events) > 1
            warning('More than one file found. Please check the file pattern or directory.');
        end
        sub_events_filepath = sprintf("%s\\%s",events_dir,files_events(1).name); % todo: make sure the right file is loadied by entering fileUM TO REGEX
        sub_events = load(sub_events_filepath);
        sub_events = sub_events.events;
        allevents = {EEG_sub_file.event.type};
        for events_type_i=1:numel(events_type)
            if strcmp(events_type{events_type_i},'Oprep')
                curr_events = find(strcmp({sub_events.TOA}, 'O'));
            elseif strcmp(events_type{events_type_i},'OFprep')
                curr_events = find(strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'fixed'));
            elseif strcmp(events_type{events_type_i},'ORprep')
                curr_events = find(strcmp({sub_events.TOA}, 'O') & strcmp({sub_events.block_type}, 'random'));
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
                else
                    curr_sov_curr_eventtype_indexes = intersect(find(strcmp({sub_events.sleep_stage}, sovs{sov_i})), curr_events);
                end
                if isempty(curr_sov_curr_eventtype_indexes) || numel(curr_sov_curr_eventtype_indexes)==1 continue;  end % if == 1, it creates issues with epochs.
                    
                % select events
                EEG_currSovEventtype = pop_epoch(EEG_sub_file,{},[-0.1 0.45],'eventindices',curr_sov_curr_eventtype_indexes);
                EEG_currSovEventtype = pop_rmbase(EEG_currSovEventtype, [-100   0]);
    
                % reject trials with +-300microVolt. 
                [EEG_currSovEventtype, Indexes] = pop_eegthresh(EEG_currSovEventtype, 1, 1:size(EEG_currSovEventtype.data,1), -300, 300, -0.1, 0.448, 0, 1);
                if isempty(EEG_currSovEventtype)   continue;  end
    
                % rereferencing
                EEG_currSovEventtype = pop_reref( EEG_currSovEventtype, []);
                rowWithLabelCz = EEG_currSovEventtype.chaninfo.ndchanlocs(strcmp({EEG_currSovEventtype.chaninfo.ndchanlocs.labels}, 'Cz'));
                EEG_currSovEventtype = eeg_interp(EEG_currSovEventtype,rowWithLabelCz);
    
                % merge sleep set files into one EEGLAB stuct
                curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},events_type{events_type_i});
                if ~isempty(EEG_currSovEventtype) && ~EEG_currSovEventtype.trials == 0 
                    if ~isfield(curr_sub_event_EEGs, curr_sov_eventtype_name)
                        curr_sub_event_EEGs.(curr_sov_eventtype_name) = EEG_currSovEventtype;
                    else
                        curr_sub_event_EEGs.(curr_sov_eventtype_name) = pop_mergeset( curr_sub_event_EEGs.(curr_sov_eventtype_name), EEG_currSovEventtype, 0);
                    end
                end
            end
        end
    end

    for events_type_i=1:numel(events_type)
        for sov_i=1:numel(sovs)
            curr_sov_eventtype_name = sprintf("%s_%s",sovs{sov_i},events_type{events_type_i});
            if ~isfield(curr_sub_event_EEGs, curr_sov_eventtype_name) continue; end
            EEG_currSovEventtype = curr_sub_event_EEGs.(curr_sov_eventtype_name);
            EEG_currSovEventtype = eeg_checkset(EEG_currSovEventtype);
    
    %         % save .set of the sub's sov      
            set_output_file_name = char(sprintf("s-%s_sov-%s_%s.set",subs{sub_i}, sovs{sov_i},events_type{events_type_i}));
            pop_saveset(EEG_currSovEventtype,'filename', set_output_file_name, 'filepath', set_output_dir);
    
            cfg = []; 
            cfg.dataset = sprintf('%s\\%s',set_output_dir,set_output_file_name);
            cfg.continuous = 'no';
            ft_data = ft_preprocessing(cfg);
    
            mat_output_file_name = char(sprintf("s_%s_%s_%s",subs{sub_i}, sovs{sov_i},events_type{events_type_i}));
            ft_file_path = sprintf('%s\\%s',ft_output_dir,mat_output_file_name);
            save(ft_file_path,"ft_data");
        end
    end
end