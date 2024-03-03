restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;

%% convert .set to .mat with ft struct per condition using ft_preprocessing (the recommended method by ft toturial)

set_per_cond_dir = 'C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\TimeAnalysis\\referenced_per_cond';
ft_percond_dir = "C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\data_in_ft_cond_fomat";
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
conditions_string = {"O",'A','T'}; 
%{'A',"O",'T','ORsenBig5','ORsenSmall6','OFsenBig5','OFsenSmall6','ORfirst5','ORlast5','OFfirst5','OFlast5','OR','OF','OEf6','OEf2','OEf3','OEf4','OEf5','ORl6','ORl7'};
SOVS = {'wake_morning','wake_night'}; % 'N1','N2','REM','N3','wake_night','wake_morning'
for sov_i = 1:size(SOVS,2)
    for condition_ind = 1:size(conditions_string,2) 
        for sub_ind=1:size(subs,2)
        
            if (strcmp(SOVS{sov_i},'wake_night') && strcmp(subs{sub_ind},'37')) || ...
                 (strcmp(SOVS{sov_i},'N1') && strcmp(subs{sub_ind},'33') && strcmp(conditions_string{condition_ind},"OFsenSmall6"))|| ...
                 (strcmp(SOVS{sov_i},'N1') && strcmp(subs{sub_ind},'36') && strcmp(conditions_string{condition_ind},"OFsenSmall6"))
                continue;
            end
        
            ft_file_name =  sprintf('s_%s_%s_%s.mat',subs{sub_ind},SOVS{sov_i},conditions_string{condition_ind});
            ft_sub_full_filepath = sprintf("%s\\%s",ft_percond_dir,ft_file_name);
            if isOutputFile(ft_file_name, ft_percond_dir) continue; end
    
            set_file_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind},SOVS{sov_i},conditions_string{condition_ind});
            set_sub_full_filepath = strcat(set_per_cond_dir,'/',set_file_name);
            
    
            cfg = []; 
            cfg.dataset = set_sub_full_filepath;
            cfg.continuous = 'no';
            ft_data = ft_preprocessing(cfg);

            % was done in order to fix "pop_selectevent" issue. I
            % always add the first event. Ans now it needs to be deleted. see
            % "pop_selectevent excludes the first couple of events" mail
            % for more info
            cfg = []; 
            cfg.trials =[false true(1,numel(ft_data.trial)-1)];
            ft_data = ft_selectdata(cfg, ft_data);
            
            save(ft_sub_full_filepath,"ft_data");
        end
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
