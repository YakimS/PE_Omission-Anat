restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;
clear;
close;

%%
ref_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
ref_setfiles_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
ref_ftfiles_dir = 'C:\OExpOut\processed_data\ft_referenced';
subSovEvent_ftfiles_dir = 'C:\OExpOut\processed_data\ft_subSovCond';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
subs = {'35','36','37','38'};
preproc_stage = 'referenced';

sovs = {'wake_morning','wake_night','N1','N2','N3','REM'};
events_type = {'ORstrt','ORmid','ORend','OFstrt','OFmid','OFend','ORfirst5','ORlast5','OFfirst5','OFlast5','ORsenBig5','ORsenSmall6','OFsenBig5','OFsenSmall6','OF','OR','O','T','A'};
events_type = {'OF','OR','O','T','A'};
%%
% delete(gcp('nocreate'))
% tic
% ticBytes(gcp);
% parfor (sub_ind=1:size(subs,2),4)
for sub_i=1:size(subs,2)
    file_pattern = fullfile(ref_setfiles_dir, sprintf('*%s*.set',subs{sub_i}));
    if all(cellfun(@(x) ischar(x) && contains(x, 'wake'), sovs))
        file_pattern = fullfile(ref_setfiles_dir, sprintf('*%s*wake*.set',subs{sub_i}));
    elseif ~any(cellfun(@(x) ischar(x) && contains(x, 'wake'), sovs))
        file_pattern = fullfile(ref_setfiles_dir, sprintf('*%s*sleep*.set',subs{sub_i}));
    end
    files_set = dir(file_pattern);

    % skip sub if all it's files are done
    does_all_output_exist = true;
    for sov_i=1:numel(sovs)
        for events_type_i=1:numel(events_type)
            if strcmp(subs{sub_i},'37') && contains(files_set(files_i).name,'night')
                continue;
            end
            ft_output_file_name = char(sprintf("s_%s_%s_%s.mat",subs{sub_i}, sovs{sov_i},events_type{events_type_i}));
            if ~isfile(sprintf("%s\\%s",subSovEvent_ftfiles_dir,ft_output_file_name)) does_all_output_exist = false; end
        end
    end
    if does_all_output_exist continue; end
    
    for files_i = 1:length(files_set)
        if strcmp(subs{sub_i},'37') && contains(files_set(files_i).name,'night')
            continue;
        end
        
        if ~isempty(strfind(files_set(files_i).name, 'wake_morning'))
            curr_file_ses = 'wake_morning';
            file_sleepwake_name = 'morning';
        elseif ~isempty(strfind(files_set(files_i).name, 'wake_night'))
            curr_file_ses = 'wake_night';
            file_sleepwake_name = 'night';
        else
            curr_file_ses = 'sleep';
            file_sleepwake_name = 'sleep';
        end

        % get rereferenced .mat file. If doesnt exist, create it.
        curr_reref_ft_ses_path = sprintf("%s\\s_%s_%s_%s.mat",ref_ftfiles_dir,subs{sub_i},curr_file_ses,preproc_stage);
        if isfile(curr_reref_ft_ses_path)
            ft_data = load(curr_reref_ft_ses_path);
            
            if isfield(ft_data,"ft_data") % This if is becuase I mistakenly called the field in differnt names
                ft_subses_data = ft_data.ft_data;
            elseif isfield(ft_data,"merged_data")
                ft_subses_data = ft_data.merged_data;
            else
                error('No such field inside ft_subses_data')
            end
        else
            cfg = []; 
            cfg.dataset = sprintf('%s\\s_%s_%s_%s.set',ref_setfiles_dir,subs{sub_i},curr_file_ses,preproc_stage);
            cfg.continuous = 'no';
            fprintf('importing now %s\n',cfg.dataset);
            ft_subses_data = ft_preprocessing(cfg);
    
            % save all
            ft_data = ft_subses_data;
            parsave(curr_reref_ft_ses_path,ft_data);
        end

        % load events and set files
        file_pattern = fullfile(ref_elaboEvents_dir, sprintf('*%s*%s*',subs{sub_i},file_sleepwake_name));
        files_events = dir(file_pattern);
        if length(files_events) > 1
            error('More than one file found. Please check the file pattern or directory.');
        end
        sub_events_filepath = sprintf("%s\\%s",ref_elaboEvents_dir,files_events(1).name);
        elabo_events = load(sub_events_filepath);
        elabo_events = elabo_events.events;
        if length(elabo_events) ~= length(ft_subses_data.time)
            error('Different number of epoches of the ft and of the eventMat.');
        end
        
        for sov_i=1:numel(sovs)    
            for events_type_i = 1:size(events_type,2)
                mat_file_output_name =   sprintf('s_%s_%s_%s.mat',subs{sub_i}, sovs{sov_i},events_type{events_type_i});
                if   (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_i},'33') && strcmp(events_type{events_type_i},"OFsenSmall6"))|| ...
                     (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_i},'36') && strcmp(events_type{events_type_i},"OFsenSmall6")) ...
                     || ...
                    (contains(events_type{events_type_i},'strt') || contains(events_type{events_type_i},'mid') ||contains(events_type{events_type_i},'end')) ...
                    && ~strcmp(sovs{sov_i}, 'wake_night') && ~strcmp(sovs{sov_i}, 'wake_morning')...
                    ||...
                    (strcmp(curr_file_ses, 'wake_morning') && strcmp(subs{sub_i},'15') && contains(events_type{events_type_i},'end'))...
                    || ...
                    isOutputFile(mat_file_output_name, subSovEvent_ftfiles_dir)
                    continue;
                end
    
                if strcmp(sovs{sov_i},'REM')
                    current_sleep_stage_times = (strcmp({elabo_events.('sleep_stage')},"Rt") | strcmp({elabo_events.('sleep_stage')},"Rp"));
                else
                    current_sleep_stage_times = strcmp({elabo_events.('sleep_stage')},sovs{sov_i});
                end
                    
                if strcmp("O",events_type{events_type_i}) || strcmp("A",events_type{events_type_i}) ||strcmp("T",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},events_type{events_type_i});
                elseif strcmp("OR",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("ORstrt",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] <= 8 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFstrt",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] <= 8 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORmid",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 8 ...
                        & [elabo_events.('block_pos_in_file')] <= 16 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFmid",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 8 ...
                        & [elabo_events.('block_pos_in_file')] <= 16 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORend",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 16 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFend",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('block_pos_in_file')] > 16 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("OF",events_type{events_type_i}) 
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORsenBig5",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("ORsenSmall6",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFsenBig5",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("OFsenSmall6",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('omission_type_seniority')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("ORlast5",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("ORfirst5",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'random');
                elseif strcmp("OFlast5",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] > 5 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("OFfirst5",events_type{events_type_i})
                    specific_cond_index = strcmp({elabo_events.('TOA')},'O')...
                        & [elabo_events.('trial_pos_in_block')] < 6 ...
                        & strcmp({elabo_events.('block_type')},'fixed');
                elseif strcmp("all",events_type{events_type_i})
                    specific_cond_index = [];
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
                parsave(sprintf("%s\\%s",subSovEvent_ftfiles_dir,mat_file_output_name),ft_data);
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


