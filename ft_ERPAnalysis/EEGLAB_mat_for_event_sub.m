restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;

%%
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
mat_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';
subs = {'38'}; %
preproc_stage = 'referenced';
sovs = {'wake_night','wake_morning'};%,'N1','N2','N3','REM'

%subs = {'15'};
%sleep_stages = {'N3'};

conds_string = {'all','ORstrt','ORmid','ORend','OFstrt','OFmid','OFend','ORfirst5','ORlast5','OFfirst5','OFlast5','ORsenBig5','ORsenSmall6','OFsenBig5','OFsenSmall6','OF','OR','O','T','A'};

%%
for sub_ind=1:size(subs,2)
    for sov_i=1:numel(sovs)
        if strcmp(sovs{sov_i}, 'wake_night') || strcmp(sovs{sov_i}, 'wake_morning')
            curr_file_ses = sovs{sov_i};
        else
            curr_file_ses = 'sleep';
        end
        
        % moves to the next subject if the output is all done
        all_output_done = true;
        for cond_ind = 1:size(conds_string,2)
            mat_file_output_name =   sprintf('s_%s_%s_%s.mat',subs{sub_ind}, sovs{sov_i},conds_string{cond_ind});
            if ~isOutputFile(mat_file_output_name, mat_per_cond_dir)  
                all_output_done = false;
            end
        end
        if all_output_done continue; end

        if (strcmp(sovs{sov_i},'wake_night') && strcmp(subs{sub_ind},'37')) || ...
             (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'33') && strcmp(conds_string{cond_ind},"OFsenSmall6"))|| ...
             (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'36') && strcmp(conds_string{cond_ind},"OFsenSmall6"))
            continue;
        end
        [elabo_events] = get_events(subs{sub_ind},curr_file_ses,preproc_stage,referenced_elaboEvents_dir);
            
        cfg = []; 
        cfg.dataset = sprintf('%s\\s_%s_%s_%s.set',ref_input_dir,subs{sub_ind},curr_file_ses,preproc_stage);
        cfg.continuous = 'no';
        ft_subses_data = ft_preprocessing(cfg);

        for cond_ind = 1:size(conds_string,2)
            if (contains(conds_string{cond_ind},'strt') || contains(conds_string{cond_ind},'mid') ||contains(conds_string{cond_ind},'end')) ...
                && ~strcmp(sovs{sov_i}, 'wake_night') && ~strcmp(sovs{sov_i}, 'wake_morning')
                continue;
            end

            mat_file_output_name =   sprintf('s_%s_%s_%s.mat',subs{sub_ind}, sovs{sov_i},conds_string{cond_ind});
            if isOutputFile(mat_file_output_name, mat_per_cond_dir)  continue; end

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
            elseif strcmp("all",conds_string{cond_ind})
                specific_cond_index = [];
            else  Exeption('wrong condition string');   
            end

            if strcmp("all",conds_string{cond_ind})
                indexes_value = 1:size(elabo_events,2);
            else
                indexes_value = find(specific_cond_index & ...
                            [elabo_events.('is_outlier_trial')] == 0 &...
                            current_sleep_stage_times);
            end
            

            if isempty(indexes_value) continue;  end

            trials = false(1,size(elabo_events,2));
            trials(indexes_value) = true;

            cfg = []; 
            cfg.trials =trials;
            cfg.continuous = 'no';
            [ft_data] = ft_selectdata(cfg, ft_subses_data);
            
            save(sprintf("%s\\%s",mat_per_cond_dir,mat_file_output_name),"ft_data");
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

