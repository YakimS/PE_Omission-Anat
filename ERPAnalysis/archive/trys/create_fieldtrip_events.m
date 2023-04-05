
%% from .set
% pok = eeglab2fieldtrip(EEG,'raw','none');

test_mode = 1;

input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\O_vs_T\';
preproc_stage = 'referenced';
sleep_files_name_suffix = strcat('_sleep_',preproc_stage,'.set');
wake_files_name_suffix = strcat('_wake_night_',preproc_stage,'.set');

if test_mode == 1
    subs = {'08','09','10','12','11'};
else
    subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
end
conditions_string = {'O','T'};


for condition_ind = 1:size(conditions_string,2)
    cond_filepath = strcat(output_dir, 'cond_',conditions_string(condition_ind), '.mat');
    if isfile(cond_filepath)
        string(strcat('Cond_',conditions_string(condition_ind), ' already exists in path:',  cond_filepath))
        continue
    end

    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        eeglabsub_wake =  pop_loadset( strcat('s_',subs(sub_ind),wake_files_name_suffix), input_dir);
    
        
        events_type_arr = {eeglabsub_wake.event.type};
        curr_event_i = find(contains(events_type_arr,conditions_string{condition_ind},'IgnoreCase',true));
        [event_EEG,event_indices] = pop_selectevent(eeglabsub_wake, 'event', curr_event_i);

        %%% Ale also had:
        % flags in pop_selectevent - 'deleteevents','off','deleteepochs','on','invertepochs','off'
        % EEG = eeg_checkset( EEG ); 

        %%%     "eeglab2fieldtrip" import option
%         event_fieldtrip = eeglab2fieldtrip(event_EEG,'comp','none');  % I editted "eeglab2fieldtrip". search "ShaYKM"
        
%%%     "ft_preprocessing" import option
        cfg = []; 
        cfg.dataset = set_sub_full_filepath{1}; 
        cfg.continuous = 'yes';
        event_fieldtrip = ft_preprocessing(cfg);

        subs_cond{sub_ind} = event_fieldtrip;
    end

    save(cond_filepath{1},"subs_cond", '-v7.3');
end


%%
filush = strcat(input_dir,'\s_',subs(sub_ind),wake_files_name_suffix);
cfg = []; cfg.dataset = filush; 
ft_data1 = ft_preprocessing(cfg);