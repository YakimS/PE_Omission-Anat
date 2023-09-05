restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab nogui;
clear;

%%
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
ft_all_input_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\reref_in_ft';
mat_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\ft_per_cond';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';

%%% Only run wake together or sleep together
% sovs = {'wake_night','wake_morning'};
% sessions = {'wake_night','wake_morning'};
% % 
sovs = {'N1','N2','N3','REM'};
sessions = {'sleep'};

conds_string = {'ORstrt','ORmid','ORend','OFstrt','OFmid','OFend','ORfirst5','ORlast5','OFfirst5','OFlast5','ORsenBig5','ORsenSmall6','OFsenBig5','OFsenSmall6','OF','OR','O','T','A'};

%%
% delete(gcp('nocreate'))
% tic
% ticBytes(gcp);
% parfor (sub_ind=1:size(subs,2),4)
for sub_ind=1:size(subs,2)
    for ses_i=1:numel(sessions)
        if strcmp(sessions{ses_i}, 'wake_night') || strcmp(sessions{ses_i}, 'wake_morning')
            curr_file_ses = sessions{ses_i};
        else
            curr_file_ses = 'sleep';
        end
        if (strcmp(sessions{ses_i}, 'wake_night') && strcmp(subs{sub_ind},'37'))
            continue;
        end

        % moves to the next subject if the output is all done
        all_output_done = true;
        for cond_ind = 1:size(conds_string,2)
            if strcmp(curr_file_ses,'sleep')
                for sov_i=1:numel(sovs) 
                    mat_file_output_name =   sprintf('s_%s_%s_%s.mat',subs{sub_ind}, sovs{sov_i},conds_string{cond_ind});
                    if   (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'33') && strcmp(conds_string{cond_ind},"OFsenSmall6"))|| ...
                         (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'36') && strcmp(conds_string{cond_ind},"OFsenSmall6"))
                        continue;
                    end
                    if ~isOutputFile(mat_file_output_name, mat_per_cond_dir)  
                        all_output_done = false;
                    end
                end
            else % wake session
                mat_file_output_name =   sprintf('s_%s_%s_%s.mat',subs{sub_ind}, sessions{ses_i},conds_string{cond_ind});
                if  (contains(conds_string{cond_ind},'strt') || contains(conds_string{cond_ind},'mid') ||contains(conds_string{cond_ind},'end')) ...
                    && ~strcmp(sessions{ses_i}, 'wake_night') && ~strcmp(sessions{ses_i}, 'wake_morning') ...
                    ||...
                    (strcmp(sessions{ses_i}, 'wake_morning') && strcmp(subs{sub_ind},'15') && contains(conds_string{cond_ind},'end'))
                    continue;
                end
                if ~isOutputFile(mat_file_output_name, mat_per_cond_dir)  
                    all_output_done = false;
                end
            end    
        end
        if all_output_done continue; end

        [elabo_events] = get_events(subs{sub_ind},curr_file_ses,preproc_stage,referenced_elaboEvents_dir);
        ft_all_ses_file = load(sprintf('%s\\s_%s_%s_%s.mat',ft_all_input_dir,subs{sub_ind},curr_file_ses,preproc_stage));
        ft_subses_data = ft_all_ses_file.merged_data;

        for sov_i=1:numel(sovs)    
            for cond_ind = 1:size(conds_string,2)
                mat_file_output_name =   sprintf('s_%s_%s_%s.mat',subs{sub_ind}, sovs{sov_i},conds_string{cond_ind});
                if   (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'33') && strcmp(conds_string{cond_ind},"OFsenSmall6"))|| ...
                     (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'36') && strcmp(conds_string{cond_ind},"OFsenSmall6")) ...
                     || ...
                    (contains(conds_string{cond_ind},'strt') || contains(conds_string{cond_ind},'mid') ||contains(conds_string{cond_ind},'end')) ...
                    && ~strcmp(sovs{sov_i}, 'wake_night') && ~strcmp(sovs{sov_i}, 'wake_morning')...
                    ||...
                    (strcmp(sessions{ses_i}, 'wake_morning') && strcmp(subs{sub_ind},'15') && contains(conds_string{cond_ind},'end'))...
                    || ...
                    isOutputFile(mat_file_output_name, mat_per_cond_dir)
                    continue;
                end
    
                if strcmp(sovs{sov_i},'REM')
                    current_sleep_stage_times = (strcmp({elabo_events.('sleep_stage')},"Rt") | strcmp({elabo_events.('sleep_stage')},"Rp"));
                else
                    current_sleep_stage_times =strcmp({elabo_events.('sleep_stage')},sovs{sov_i});
                end
                    
                if strcmp("O",conds_string{cond_ind}) || strcmp("A",conds_string{cond_ind}) ||strcmp("T",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},conds_string{cond_ind});
                elseif strcmp("OR",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("ORstrt",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] <= 8 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFstrt",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] <= 8 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORmid",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 8 ...
                        & [elabo_events.('block_pos_in_file')] <= 16 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFmid",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 8 ...
                        & [elabo_events.('block_pos_in_file')] <= 16 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORend",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 16 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFend",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 16 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("OF",conds_string{cond_ind}) 
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORsenBig5",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("ORsenSmall6",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFsenBig5",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("OFsenSmall6",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORlast5",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("ORfirst5",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFlast5",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("OFfirst5",conds_string{cond_ind})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                else  Exeption('wrong condition string');   
                end
    
                indexes_value = find(specific_cond_index & ...
                                [elabo_events.('is_outlier_trial')] == 0 &...
                                current_sleep_stage_times);
    
                if isempty(indexes_value) continue;  end
    
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
end
% tocBytes(gcp)
% toc

%% util funcs
function parsave(fname, ft_data)
  save(fname, 'ft_data')
end

function isAlreadyExist = isOutputFile(output_file,output_dir)
    fullpath = sprintf("%s\\%s",output_dir, output_file);
    if isfile(fullpath)
        %string(strcat(output_file, ' already exists in path:',  fullpath))
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

