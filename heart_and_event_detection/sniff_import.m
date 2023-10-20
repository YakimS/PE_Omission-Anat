restoredefaultpath
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab nogui;

%%
orig_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\orig\';
%% load for emg, HR, triggers
output_dir = strcat('C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\onlyTriggerAndEMG\');
electrodesNames =     { 'Temp','Press','EMG','ECG'}; 
electrodesEvenDetection_names = {'EMG1','EMG2','Trigger','ECG'};
labelMapping = containers.Map(electrodesNames, electrodesEvenDetection_names);
subs = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14',...
    '15','16','17','18','19','20','21','22','23','24','25','26','27','28','29'...
    '30','31','32','33','34','35','36','37','38'};

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
if ~isfolder(output_dir)
    mkdir(output_dir);
end

for sub_ind=1:size(subs,2)
    % run only if output file doesnt exists
    output_filename = strcat('BBS',subs(sub_ind),' SNIFF_orig_onlyTriggerAndEMG');
    output_filename = output_filename{1};
    if isfile([output_dir output_filename '.set'])
        string(strcat('Sub ',subs(sub_ind), ' already exists in path:',  output_filename))
        continue
    end
    
    % upload .set file
    set_filename =strcat('BBS',subs(sub_ind),'_orig.set');
    set_filename = set_filename{1};
    if ~isfile([orig_input_dir '\' set_filename])
        ['no input file ' orig_input_dir set_filename]
        continue
    end
    try
        EEG =  pop_loadset(set_filename, orig_input_dir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset(EEG);
    catch ME
        ['error uploading ' orig_input_dir set_filename]
        continue
    end 

    % get labels and change thire names 
    all_labels = {EEG.chanlocs.labels};
    electrodesNumber =[];
    for label_ind=1:size(all_labels,2)
        if any(ismember(electrodesNames, all_labels(label_ind)))
            electrodesNumber(end+1) = label_ind;
        end
    end
    if size(electrodesNames,2) > size(electrodesNumber,2) 
        'didnt find all electrodes labels' 
    end

    % exclude all the unlisted channles
    chanexcl = 1:size(all_labels,2);
    chanexcl(electrodesNumber) = [];
    EEG = pop_select(EEG,'nochannel',chanexcl);

    % Update the labels
    EEG.chanlocs = arrayfun(@(x) setfield(x, 'labels', labelMapping(x.labels)), EEG.chanlocs);
    chansNames = {EEG.chanlocs.labels};

    % savings
    % save .mat
    subEvents = EEG.event;
    subData = EEG.data;
    samplefreq = EEG.srate;

    save([output_dir, output_filename '.mat'],"subEvents","subData","samplefreq",'chansNames');
end

%% load all: EEG + emg, HR, triggers + events
subs = {'02','03','04','05','06','07','08','09','11','12','13','14',...
    '15','16','17','18','19','21','22','24','26','27','28','29'...
    '30','31','32','33','34','35','36','37','38'}; %'01','10', excluded. '20','23','25'
event_types = {'None', 'Pleasant', 'Unpleasant'};
output_dir = strcat('C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\prepro_withEvents\');
prepro_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\prepro\';
triggerEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\triggers_textfile_after_trial_exclusion\';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
if ~isfolder(output_dir)
    mkdir(output_dir);
end

for sub_ind=1:size(subs,2)
    % run only if output file doesnt exists
    output_filename_2 = strcat('BBS',subs(sub_ind),' SNIFF_PrePro_withEvents_zscored');
    output_filename_2 = output_filename_2{1};
    output_filename_3 = strcat('BBS',subs(sub_ind),' SNIFF_PrePro_withEvents_exclu');
    output_filename_3 = output_filename_3{1};
    if isfile([output_dir output_filename_2 '.set']) && isfile([output_dir output_filename_3 '.set'])
        string(strcat('Sub ',subs(sub_ind), ' already exists in path:', output_filename_2, 'or: ', output_filename_3))
        continue
    end
    
    % upload .set file
    set_filename =strcat('BBS',subs(sub_ind),'_preProcessed.set');
    set_filename = set_filename{1};
    if ~isfile([prepro_input_dir '\' set_filename])
        ['no input file ' prepro_input_dir set_filename]
        continue
    end
    try
        EEG =  pop_loadset(set_filename, prepro_input_dir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset(EEG);
    catch ME
        ['error uploading ' prepro_input_dir set_filename]
        continue
    end 

    EEG = pop_select(EEG, 'rmchannel', {'Temp' 'Press' 'ECG' 'ACCL' 'Chest' 'Abdomen' 'EMG'});

    %%%% save non z-scored set files
        events_filename = sprintf('%ssub-%s_triggerEvents.txt', triggerEvents_dir,subs{sub_ind});
        [EEG,x] = pop_importevent( EEG, 'event',events_filename,'fields', {'type', 'latency'},'timeunit', 1,'skipline',1);
        for event_i=1:numel(event_types)
            output_cond_filename = strcat('BBS',subs(sub_ind),' SNIFF_PrePro_epoched_cond-',event_types{event_i},"_exclu");
            output_cond_filename = output_cond_filename{1};
            [EEG_event,x] = pop_epoch( EEG,event_types{event_i} ,[-10 ,10]);
            pop_saveset(EEG_event,'filepath',output_dir,'filename',output_cond_filename,'version','7.3');
        end
        
        output_cond_filename = strcat('BBS',subs(sub_ind),' SNIFF_PrePro_epoched_cond-Smell_exclu');
        output_cond_filename = output_cond_filename{1};
        [EEG_event,x] = pop_epoch( EEG,{'Pleasant', 'Unpleasant'} ,[-10 ,10]);
        pop_saveset(EEG_event,'filepath',output_dir,'filename',output_cond_filename,'version','7.3');
        pop_saveset(EEG,'filepath',output_dir,'filename',output_filename_3,'version','7.3');

    %%%% save z-scored set files
        events_filename = sprintf('%ssub-%s_triggerEvents.txt', triggerEvents_dir,subs{sub_ind});
        mean_activity = mean(EEG.data, 2);  % Mean for each electrode
        std_activity = std(EEG.data, 0, 2);  % Standard deviation for each electrode
        EEG.data = (EEG.data - mean_activity) ./ std_activity;
        [EEG,x] = pop_importevent( EEG, 'event',events_filename,'fields', {'type', 'latency'},'timeunit', 1,'skipline',1);
        for event_i=1:numel(event_types)
            output_cond_filename = strcat('BBS',subs(sub_ind),' SNIFF_PrePro_epoched_cond-',event_types{event_i},"_zscored");
            output_cond_filename = output_cond_filename{1};
            [EEG_event,x] = pop_epoch( EEG,event_types{event_i} ,[-10 ,10]);
            pop_saveset(EEG_event,'filepath',output_dir,'filename',output_cond_filename,'version','7.3');
        end
        output_cond_filename = strcat('BBS',subs(sub_ind),' SNIFF_PrePro_epoched_cond-Smell_zscored');
        output_cond_filename = output_cond_filename{1};
        [EEG_event,x] = pop_epoch( EEG,{'Pleasant', 'Unpleasant'} ,[-10 ,10]);
        pop_saveset(EEG_event,'filepath',output_dir,'filename',output_cond_filename,'version','7.3');
        pop_saveset(EEG,'filepath',output_dir,'filename',output_filename_2,'version','7.3');
end
