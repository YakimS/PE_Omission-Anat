restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;

%%
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';
sleep_stages = {'N1','N2','N3','REM'};
sleep_files_name_suffix = strcat('sleep');
wake_night_files_name_suffix = strcat('wake_night');
wake_morning_files_name_suffix = strcat('wake_morning');
ref_files = {sleep_files_name_suffix,wake_morning_files_name_suffix,wake_night_files_name_suffix};

%subs = {'25'};
ref_files = {wake_morning_files_name_suffix,wake_night_files_name_suffix};
%sleep_stages = {'N3'};

%% create .set per TOA condition

conditions_string = {'O','T','A'};

for ses_i=1:numel(ref_files)
    % wakefulness
    if strcmp(ref_files{ses_i}, wake_morning_files_name_suffix) || strcmp(ref_files{ses_i}, wake_night_files_name_suffix)
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                    all_output_done = false;
                end
            end
            if all_output_done continue; end

            if strcmp(subs{sub_ind}, '37') && strcmp(ref_files{ses_i}, 'wake_night') continue; end 
            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i},preproc_stage, ref_input_dir,referenced_elaboEvents_dir);
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
    
                indexes_value = find( strcmp({elabo_events.('TOA')},conditions_string{condition_ind})  & ...
                    [elabo_events.('is_outlier_trial')] == 0);
    
                if isempty(indexes_value) continue;  end

                % was done in order to fix "pop_selectevent" issue. I
                % always add the first event. Ans now it needs to be deleted. see
                % "pop_selectevent excludes the first couple of events" mail
                % for more info
                indexes_value= [1,indexes_value];
        
                new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
            end
        end
    else % sleep
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                        all_output_done = false;
                    end
                end
            end
            if all_output_done continue; end

            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i},preproc_stage,ref_input_dir,referenced_elaboEvents_dir);
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
    
                    if strcmp(sleep_stages{stage_i},'REM')
                        current_sleep_stage_times = (strcmp({elabo_events.('sleep_stage')},"Rt") | strcmp({elabo_events.('sleep_stage')},"Rp"));
                    else
                        current_sleep_stage_times =strcmp({elabo_events.('sleep_stage')},sleep_stages{stage_i});
                    end

                    indexes_value = find( strcmp({elabo_events.('TOA')},conditions_string{condition_ind})  & ...
                            [elabo_events.('is_outlier_trial')] == 0 &...
                            current_sleep_stage_times);

                    if isempty(indexes_value) continue;  end

                    % was done in order to fix "pop_selectevent" issue. I
                    % always add the first event. Ans now it needs to be deleted. see
                    % "pop_selectevent excludes the first couple of events" mail
                    % for more info
                    indexes_value= [1,indexes_value];
                
                    new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                    pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
                end
            end
        end
    end
end

%% create .set OF OR conditions 

conditions_string = {'OF','OR'};

for ses_i=1:numel(ref_files)
    % wakefulness
    if strcmp(ref_files{ses_i}, wake_morning_files_name_suffix) || strcmp(ref_files{ses_i}, wake_night_files_name_suffix)
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                    all_output_done = false;
                end
            end
            if all_output_done continue; end
            if strcmp(subs{sub_ind}, '37') && strcmp(ref_files{ses_i}, 'wake_night') continue; end 
            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i}, preproc_stage,ref_input_dir,referenced_elaboEvents_dir);
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
    
                if strcmp("OR",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & strcmp({elabo_events.('block_type')},'random'));
                elseif strcmp("OF",conditions_string{condition_ind}) 
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & strcmp({elabo_events.('block_type')},'fixed'));
                else  Exeption('wrong condition string');   
                end
    
                if isempty(indexes_value) continue;  end
        
                % was done in order to fix "pop_selectevent" issue. I
                % always add the first event. Ans now it needs to be deleted. see
                % "pop_selectevent excludes the first couple of events" mail
                % for more info
                indexes_value= [1,indexes_value];

                new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
            end
        end
    else % sleep
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                        all_output_done = false;
                    end
                end
            end
            if all_output_done continue; end
            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i},preproc_stage, ref_input_dir,referenced_elaboEvents_dir);
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end

                    if strcmp(sleep_stages{stage_i},'REM')
                        current_sleep_stage_times = (strcmp({elabo_events.('sleep_stage')},"Rt") | strcmp({elabo_events.('sleep_stage')},"Rp"));
                    else
                        current_sleep_stage_times =strcmp({elabo_events.('sleep_stage')},sleep_stages{stage_i});
                    end

    
                   if strcmp("OR",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'random'));
                    elseif strcmp("OF",conditions_string{condition_ind}) 
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'fixed'));
                    else  Exeption('wrong condition string');   
                    end

                    
                    if isempty(indexes_value) continue;  end

                    % was done in order to fix "pop_selectevent" issue. I
                    % always add the first event. Ans now it needs to be deleted. see
                    % "pop_selectevent excludes the first couple of events" mail
                    % for more info
                    indexes_value= [1,indexes_value];
            
                    new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                    pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
                end
            end
        end
    end
end

%% create .set OR/OF seniority less/more than.... conditions 

conditions_string = {'ORsenBig5','ORsenSmall6','OFsenBig5','OFsenSmall6'};

for ses_i=1:numel(ref_files)
    % wakefulness
    if strcmp(ref_files{ses_i}, wake_morning_files_name_suffix) || strcmp(ref_files{ses_i}, wake_night_files_name_suffix)
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                    all_output_done = false;
                end
            end
            if all_output_done continue; end
            
            if strcmp(subs{sub_ind}, '37') && strcmp(ref_files{ses_i}, 'wake_night') continue; end 
            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i},preproc_stage,ref_input_dir,referenced_elaboEvents_dir);
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
                
                if strcmp("ORsenBig5",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('omission_type_seniority')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'random'));
                elseif strcmp("ORsenSmall6",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('omission_type_seniority')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'random'));
                elseif strcmp("OFsenBig5",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('omission_type_seniority')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'fixed'));
                elseif strcmp("OFsenSmall6",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('omission_type_seniority')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'fixed'));
                else  Exeption('wrong condition string');   
                end
    
                if isempty(indexes_value) continue;  end

                % was done in order to fix "pop_selectevent" issue. I
                % always add the first event. Ans now it needs to be deleted. see
                % "pop_selectevent excludes the first couple of events" mail
                % for more info
                indexes_value= [1,indexes_value];
        
                new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
            end
        end
    else % sleep
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                        all_output_done = false;
                    end
                end
            end
            if all_output_done continue; end

            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i},preproc_stage, ref_input_dir,referenced_elaboEvents_dir);
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
                    
                    if strcmp(sleep_stages{stage_i},'REM')
                        current_sleep_stage_times = (strcmp({elabo_events.('sleep_stage')},"Rt") | strcmp({elabo_events.('sleep_stage')},"Rp"));
                    else
                        current_sleep_stage_times =strcmp({elabo_events.('sleep_stage')},sleep_stages{stage_i});
                    end

                    if strcmp("ORsenBig5",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('omission_type_seniority')] > 5 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'random'));
                    elseif strcmp("ORsenSmall6",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('omission_type_seniority')] < 6 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'random'));
                    elseif strcmp("OFsenBig5",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('omission_type_seniority')] > 5 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'fixed'));
                    elseif strcmp("OFsenSmall6",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('omission_type_seniority')] < 6 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'fixed'));
                    else  Exception('wrong condition string'); 
                        throw(MException('wrong condition string', 'Variable %s not found',conditions_string{condition_ind}));
                    end
   
                    if isempty(indexes_value) continue;  end

                    % was done in order to fix "pop_selectevent" issue. I
                    % always add the first event. Ans now it needs to be deleted. see
                    % "pop_selectevent excludes the first couple of events" mail
                    % for more info
                    indexes_value= [1,indexes_value];
            
                    new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                    pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
                end
            end
        end
    end
end

%% create .set ORfirst5 ORlast5 OFfirst5 OFlast5 conditions 

conditions_string = {'ORfirst5','ORlast5','OFfirst5','OFlast5'};

for ses_i=1:numel(ref_files)
    % wakefulness
    if strcmp(ref_files{ses_i}, wake_morning_files_name_suffix) || strcmp(ref_files{ses_i}, wake_night_files_name_suffix)
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                    all_output_done = false;
                end
            end
            if all_output_done continue; end
            
            if strcmp(subs{sub_ind}, '37') && strcmp(ref_files{ses_i}, 'wake_night') continue; end 
            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i},preproc_stage,ref_input_dir,referenced_elaboEvents_dir);
            for condition_ind = 1:size(conditions_string,2)
                set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, ref_files{ses_i},conditions_string{condition_ind});
                if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
                
                if strcmp("ORlast5",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('trial_pos_in_block')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'random'));
                elseif strcmp("ORfirst5",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('trial_pos_in_block')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'random'));
                elseif strcmp("OFlast5",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('trial_pos_in_block')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'fixed'));
                elseif strcmp("OFfirst5",conditions_string{condition_ind})
                    indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                        & [elabo_events.('is_outlier_trial')] == 0 ...
                        & [elabo_events.('trial_pos_in_block')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'fixed'));
                else  Exeption('wrong condition string');   
                end
    
                if isempty(indexes_value) continue;  end

                % was done in order to fix "pop_selectevent" issue. I
                % always add the first event. Ans now it needs to be deleted. see
                % "pop_selectevent excludes the first couple of events" mail
                % for more info
                indexes_value= [1,indexes_value];
        
                new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
            end
        end
    else % sleep
        for sub_ind=1:size(subs,2)
            % moves to the next subject if the output is all done
            all_output_done = true;
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if ~isOutputFile(set_file_output_name, set_per_cond_dir)  
                        all_output_done = false;
                    end
                end
            end
            if all_output_done continue; end

            [eeglabsub, elabo_events] = get_sub_data_and_events(subs{sub_ind},ref_files{ses_i},preproc_stage, ref_input_dir,referenced_elaboEvents_dir);
            for stage_i = 1:numel(sleep_stages)
                for condition_ind = 1:size(conditions_string,2)
                    set_file_output_name =   sprintf('s_%s_%s_%s.set',subs{sub_ind}, sleep_stages{stage_i},conditions_string{condition_ind});
                    if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
                    
                    if strcmp(sleep_stages{stage_i},'REM')
                        current_sleep_stage_times = (strcmp({elabo_events.('sleep_stage')},"Rt") | strcmp({elabo_events.('sleep_stage')},"Rp"));
                    else
                        current_sleep_stage_times =strcmp({elabo_events.('sleep_stage')},sleep_stages{stage_i});
                    end

                    if strcmp("ORlast5",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('trial_pos_in_block')] > 5 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'random'));
                    elseif strcmp("ORfirst5",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('trial_pos_in_block')] < 6 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'random'));
                    elseif strcmp("OFlast5",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('trial_pos_in_block')] > 5 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'fixed'));
                    elseif strcmp("OFfirst5",conditions_string{condition_ind})
                        indexes_value = find( strcmp({elabo_events.('TOA')},'O')  ...
                            & [elabo_events.('is_outlier_trial')] == 0 ...
                            & [elabo_events.('trial_pos_in_block')] < 6 ...
                            & current_sleep_stage_times...
                            & strcmp({elabo_events.('block_type')},'fixed'));
                    else  Exception('wrong condition string'); 
                        throw(MException('wrong condition string', 'Variable %s not found',conditions_string{condition_ind}));
                    end
   
                    if isempty(indexes_value) continue;  end

                    % was done in order to fix "pop_selectevent" issue. I
                    % always add the first event. Ans now it needs to be deleted. see
                    % "pop_selectevent excludes the first couple of events" mail
                    % for more info
                    indexes_value= [1,indexes_value];
                
                    new_eeglabsub = pop_selectevent( eeglabsub, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
                    pop_saveset(new_eeglabsub,'filepath',set_per_cond_dir,'filename',set_file_output_name,'version','7.3');
                end
            end
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

function [eeglabsub, elabo_events] = get_sub_data_and_events(sub,ses,preproc_stage,set_file_dir,elaboEvents_dir)
    set_file_name =   strcat('s_',sub,'_',ses,'_',preproc_stage,'.set');
    eeglabsub =  pop_loadset(set_file_name, set_file_dir);
    event_mat_filename = sprintf('%s\\s_%s_%s_%s_elaboEvents+outliers.mat',elaboEvents_dir,sub,ses,preproc_stage);
    elabo_events = load(event_mat_filename);
    elabo_events = elabo_events.events;
end

