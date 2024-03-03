restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab nogui;

%% convert .set to .mat with ft struct per condition using ft_preprocessing (the recommended method by ft toturial)

set_per_cond_dir = 'C:\\Users\\User\\OneDrive - huji.ac.il\\AnatArzData\\Data\\sniff\\prepro_withEvents';
ft_percond_dir = "C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\ft_per_cond_exclu";
subs = {'02','03','04','05','06','07','08','09','11','12','13','14',...
    '15','16','17','18','19','21','22','24','26','27','28','29'...
    '30','31','32','33','34','35','36','37','38'}; %'01','10', excluded. '20','23','25'
conditions_string = {'None', 'Pleasant', 'Unpleasant','Smell'};

for sub_ind=1:size(subs,2)
    for cond_i=1:numel(conditions_string)
        ft_file_name =  sprintf('s_%s_wake_%s.mat',subs{sub_ind},conditions_string{cond_i});
%         ft_sub_full_filepath = sprintf("%s\\%s",ft_percond_dir,ft_file_name);
%         if isOutputFile(ft_file_name, ft_percond_dir) continue; end
        ft_sub_full_filepath = sprintf("%s\\%s",ft_percond_dir,ft_file_name);
        if isOutputFile(ft_file_name, ft_percond_dir) continue; end
    
        %set_file_name =   sprintf('BBS%s SNIFF_prePro_epoched_cond-%s.set',subs{sub_ind},conditions_string{cond_i});
        set_file_name =   sprintf('BBS%s SNIFF_prePro_epoched_cond-%s_exclu.set',subs{sub_ind},conditions_string{cond_i});
        set_sub_full_filepath = strcat(set_per_cond_dir,'/',set_file_name);
        
        cfg = []; 
        cfg.dataset = set_sub_full_filepath;
        cfg.continuous = 'no';
        ft_data = ft_preprocessing(cfg);

        save(ft_sub_full_filepath,"ft_data");
    end
end


%% util funcs
function isAlreadyExist = isOutputFile(output_file,output_dir)
    fullpath = sprintf("%s\\%s",output_dir, output_file);
    if isfile(fullpath)
        string(strcat(output_file, ' already exists in path:',  fullpath))
        isAlreadyExist = true;
    else
        isAlreadyExist = false;
    end
end
