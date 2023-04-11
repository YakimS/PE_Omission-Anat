
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223

%     ft_data = eeglab2fieldtrip(eeglabsub_eeg,'comp','none'); % I editted "eeglab2fieldtrip". search "ShaYKM"

%% create .set per TOA condition

ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';
conditions_string = {'O','T','A'};

sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);
choosenSuffix = wake_files_name_suffix;

for condition_ind = 1:size(conditions_string,2)
    for sub_ind=1:size(subs,2)
        set_file_output_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',conditions_string{condition_ind},'.set');
        set_file_name =   strcat('s_',subs(sub_ind),choosenSuffix,'.set');
        if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
           
        eeglabsub_eeg =  pop_loadset(set_file_name, ref_input_dir);
        events_type_arr = {eeglabsub_eeg.event.type};
        events_cond_i = find(contains(events_type_arr,conditions_string{condition_ind},'IgnoreCase',true));
        
        if isempty(events_cond_i) continue;  end

        eeglabsub_eeg = pop_selectevent( eeglabsub_eeg, 'event',events_cond_i,'deleteevents','off','deleteepochs','on','invertepochs','off');
        eeglabsub_eeg = eeg_checkset( eeglabsub_eeg ); 

        pop_saveset(eeglabsub_eeg,'filepath',set_per_cond_dir,'filename',set_file_output_name{1},'version','7.3');
    end
end



%% create .set EO UO conditions

ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';
conditions_string = {'OF','OR'};

sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);
choosenSuffix = wake_files_name_suffix;

for sub_ind=1:size(subs,2)
    for condition_ind = 1:size(conditions_string,2)
        set_file_output_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',conditions_string{condition_ind},'.set');
        set_file_input_name =   strcat('s_',subs(sub_ind),choosenSuffix,'.set');
        if isOutputFile(set_file_output_name, set_per_cond_dir) continue; end
    
        eeglabsub_eeg =  pop_loadset(set_file_input_name, ref_input_dir);
        events_type_arr = {eeglabsub_eeg.event.type};
    
        if strcmp("OR",conditions_string{condition_ind})
            events_cond_i = find(contains(events_type_arr,'O') & ...
            (contains(events_type_arr,'_8')|contains(events_type_arr,'_7')|contains(events_type_arr,'_6')|contains(events_type_arr,'_5')|contains(events_type_arr,'_4'))...
            );
        elseif strcmp("OF",conditions_string{condition_ind}) 
            events_cond_i = find(contains(events_type_arr,'O') & contains(events_type_arr,'_9'));
        else  Exeption('wrong condition string');   
        end

        if isempty(events_cond_i)  continue; end
        
        eeglabsub_eeg_event = pop_selectevent( eeglabsub_eeg, 'event',events_cond_i,'deleteevents','off','deleteepochs','on','invertepochs','off');
        eeglabsub_eeg_event = eeg_checkset( eeglabsub_eeg_event ); 
        pop_saveset(eeglabsub_eeg_event,'filepath',set_per_cond_dir,'filename',set_file_output_name{1},'version','7.3');
    end
end

%% convert .set to .mat with ft struct per condition using ft_preprocessing (the recommended method by ft toturial)

set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';
ft_percond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft_per_cond\ftPreproImport_cont-no';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
conditions_string = {'OF','OR'};

for sub_ind=1:size(subs,2)
    for condition_ind = 1:size(conditions_string,2)   
        ft_file_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',conditions_string{condition_ind},'.mat');
        set_file_name =   strcat('s_',subs(sub_ind),choosenSuffix,'_',conditions_string{condition_ind},'.set');
        set_sub_full_filepath = strcat(set_per_cond_dir,'/',set_file_name);
        ft_sub_full_filepath = strcat(ft_percond_dir,'/',ft_file_name);
        if isOutputFile(ft_file_name, ft_percond_dir) continue; end

        cfg = []; 
        cfg.dataset = set_sub_full_filepath{1};
        cfg.continuous = 'no';
        ft_data = ft_preprocessing(cfg);

        save(ft_sub_full_filepath{1},"ft_data");
    end
end

%% util funcs
function isAlreadyExist = isOutputFile(output_file,output_dir)
    fullpath = strcat(output_dir,'\', output_file);
    fullpath = fullpath{1};
    if isfile(fullpath)
        string(strcat(output_file, ' already exists in path:',  fullpath))
        isAlreadyExist = true;
    else
        isAlreadyExist = false;
    end
end
