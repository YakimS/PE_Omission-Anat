function EEGLAB_mat_for_event_sub_serverFunc()
    restoredefaultpath
    addpath /sci/labs/arzilab/ykmsharon/OmissionProject/Code/libs/fieldtrip-20230223
    ft_defaults
    addpath '/sci/labs/arzilab/ykmsharon/OmissionProject/Code/libs/eeglab2023.0'
    eeglab;
    
    %%
    referenced_elaboEvents_dir = '/sci/labs/arzilab/ykmsharon/OmissionProject/OmissionSleepData/rerefrenced/elaborated_events+outliers';
    ref_input_dir = '/sci/labs/arzilab/ykmsharon/OmissionProject/OmissionSleepData/rerefrenced';
    mat_per_cond_dir = '/sci/labs/arzilab/ykmsharon/OmissionProject/AnalysisData/ft_per_cond';
    subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
    preproc_stage = 'referenced';

    ses = {'sleep','wake_night','wake_morning'};
    %%
    
    for sub_i=1:size(subs,2)
        for ses_i=1:size(ses,2)
            mat_file_output_name =   sprintf('s_%s_%s_%s.mat',subs{sub_i}, ses{ses_i},'all');
            if isOutputFile(mat_file_output_name, mat_per_cond_dir)
                continue;
            end
    
            [elabo_events] = get_events(subs{sub_i},ses{ses_i},preproc_stage,referenced_elaboEvents_dir);
            cfg = []; 
            cfg.dataset = sprintf('%s\\s_%s_%s_%s.set',ref_input_dir,subs{sub_i},ses{ses_i},preproc_stage);
            cfg.continuous = 'no';
            fprintf('importing now %s\n',cfg.dataset);
            ft_subses_data = ft_preprocessing(cfg);

            indexes_value = 1:size(elabo_events,2);
            trials = false(1,size(elabo_events,2));
            trials(indexes_value) = true;
    
            cfg = []; 
            cfg.trials =trials;
            cfg.continuous = 'no';
            [ft_data] = ft_selectdata(cfg, ft_subses_data);
            parsave(sprintf("%s\\%s",mat_per_cond_dir,mat_file_output_name),ft_data);
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

function [elabo_events] = get_events(sub,ses,preproc_stage,elaboEvents_dir)
    event_mat_filename = sprintf('%s//s_%s_%s_%s_elaboEvents+outliers.mat',elaboEvents_dir,sub,ses,preproc_stage);
    elabo_events = load(event_mat_filename);
    elabo_events = elabo_events.events;
end

