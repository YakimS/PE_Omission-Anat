
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223

%% ONE FILE
input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft\';
file_name = 's_03_wake_night_referenced.set';
full_file_path = strcat(input_dir,'\',file_name);

cfg = []; cfg.dataset = full_file_path; 
ft_data = ft_preprocessing(cfg);
save(output_dir, ft_data)


%% BATCH - all data.
input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft\ftPreproImport_cont-no';
subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
subs = {'08','09','10','11','13','14'};
preproc_stage = 'referenced';

sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);
choosenSuffix = wake_files_name_suffix;

for sub_ind=1:size(subs,2)
    ft_file_output_name =   strcat('s_',subs(sub_ind), choosenSuffix,'.mat');
    set_file_name =   strcat('s_',subs(sub_ind),choosenSuffix,'.set');
    set_sub_full_filepath = strcat(input_dir,'/',set_file_name);
    ft_sub_full_filepath = strcat(output_dir,'/',ft_file_output_name);
    if isfile(ft_sub_full_filepath)
        string(strcat(set_file_name, ' already exists in path:',  ft_sub_full_filepath))
        continue
    end

    eeglabsub_eeg =  pop_loadset(set_file_name, input_dir);
    eeglabsub_eeg = eeg_checkset( eeglabsub_eeg ); 
    eeglabsub_events = eeglabsub_eeg.event;
    

    %%%     "ft_preprocessing" import option
    cfg = []; 
    cfg.dataset = set_sub_full_filepath{1}; 
    cfg.continuous = 'no';
    ft_data = ft_preprocessing(cfg);

    %%%     "eeglab2fieldtrip" import option 
%     ft_data = eeglab2fieldtrip(eeglabsub_eeg,'comp','none'); % I editted "eeglab2fieldtrip". search "ShaYKM"

    save(ft_sub_full_filepath{1},"ft_data", "eeglabsub_events");
end



%% create .set per condition

ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
ref_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';

sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);
choosenSuffix = wake_files_name_suffix;

for condition_ind = 1:size(conditions_string,2)
    for sub_ind=1:size(subs,2)
        set_file_output_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',conditions_string{condition_ind},'.set');
        set_file_name =   strcat('s_',subs(sub_ind),choosenSuffix,'.set');
        if isOutputFile(set_file_output_name, ref_per_cond_dir) 
            continue
        end
           
        eeglabsub_eeg =  pop_loadset(set_file_name, ref_input_dir);
        events_type_arr = {eeglabsub_eeg.event.type};
        curr_event_i = find(contains(events_type_arr,conditions_string{condition_ind},'IgnoreCase',true));
        eeglabsub_eeg = pop_selectevent( eeglabsub_eeg, 'event',curr_event_i,'deleteevents','off','deleteepochs','on','invertepochs','off');
        eeglabsub_eeg = eeg_checkset( eeglabsub_eeg ); 

        pop_saveset(eeglabsub_eeg,'filepath',ref_per_cond_dir,'filename',set_file_output_name{1},'version','7.3');
    end
end

%% convert .set to .mat with ft struct per condition using ft_preprocessing (the recommended method by ft toturial)

ref_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';
ft_percond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft_per_cond\ftPreproImport_cont-no';
subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};

for condition_ind = 1:size(conditions_string,2)
    for sub_ind=1:size(subs,2)
        ft_file_input_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',conditions_string{condition_ind},'.mat');
        set_file_name =   strcat('s_',subs(sub_ind),choosenSuffix,'_',conditions_string{condition_ind},'.set');
        set_sub_full_filepath = strcat(ref_per_cond_dir,'/',set_file_name);
        ft_sub_full_filepath = strcat(ft_percond_dir,'/',ft_file_input_name);
        if isOutputFile(ft_file_input_name, ft_percond_dir) continue; end

        cfg = []; 
        cfg.dataset = set_sub_full_filepath{1};
        cfg.continuous = 'no';
        ft_data = ft_preprocessing(cfg);

        save(ft_sub_full_filepath{1},"ft_data");
    end
end