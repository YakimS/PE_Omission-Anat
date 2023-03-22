
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2022.1
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223

%% ONE FILE
input_dir = 'C:\Users\User\Cloud-Drive\BigFiles\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft';
file_name = 's_03_wake_night_referenced.set';
full_file_path = strcat(input_dir,'\',file_name);

cfg = []; cfg.dataset = full_file_path; 
ft_data = ft_preprocessing(cfg);
save(output_dir, ft_data)


%% BATCH
input_dir = 'C:\Users\User\Cloud-Drive\BigFiles\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft';
subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
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

    eeglabsub_eeg =  pop_loadset( set_file_name, input_dir);
    eeglabsub_events = eeglabsub_eeg.event;

    cfg = []; 
    cfg.dataset = set_sub_full_filepath{1}; 
    cfg.continuous = 'no';
    ft_data = ft_preprocessing(cfg);

    save(ft_sub_full_filepath{1},"ft_data", "eeglabsub_events");
end
