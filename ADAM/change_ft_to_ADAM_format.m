restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab nogui;

%%
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
ft_input_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\ft_per_cond';
output_adamformat_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\DATA';
preproc_stage = 'referenced';

%% Regular. No Leave-ove-out design

subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {'wake_morning','wake_night','N1','N2','N3','REM'};
conds_string = {'OF','OR','T','A','O'};

%%%%%%%%%%%%%%%%%%%%%%% my design %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "ses"
%                             wake_morning    wake_night        N1       N2      N3        REM
% 
% factor          OF              1               2             19       20      21         22             
% "trialtype"     OR              3               4             23       24      25         26               
%                 T               5               6             27       28      29         30                           
%                 A               7               8             31       32      33         34                            
%                 O               17              18            51       52      53         54   
data_table = [
    1, 2, 19, 20, 21, 22;
    3, 4, 23, 24, 25, 26;
    5, 6, 27, 28, 29, 30;
    7, 8, 31, 32, 33, 34;
%     9, 10, 35, 36, 37, 38;
%     11, 12, 39, 40, 41, 42;
%     13, 14, 43, 44, 45, 46;
%     15, 16, 47, 48, 49, 50;
    17, 18, 51, 52, 53, 54];
symbol_factorArray = array2table(data_table, 'RowNames',conds_string , 'VariableNames', sovs);

for sub_ind=1:size(subs,2)
    mat_file_output_name =   sprintf('s_%s_allSovs.mat',subs{sub_ind});
    if isOutputFile(mat_file_output_name, output_adamformat_dir)  continue; end 

    iter = 1;
    subs_conds_ft = cell(1,numel(conds_string)*numel(sovs));
    for sov_i=1:numel(sovs)
        if strcmp(sovs{sov_i}, 'wake_night') || strcmp(sovs{sov_i}, 'wake_morning')
            curr_file_ses = sovs{sov_i};
        else
            curr_file_ses = 'sleep';
        end

        if (strcmp(sovs{sov_i},'wake_night') && strcmp(subs{sub_ind},'37')) || ...
             (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'33') && strcmp(conds_string{cond_ind},"OFsenSmall6"))|| ...
             (strcmp(sovs{sov_i},'N1') && strcmp(subs{sub_ind},'36') && strcmp(conds_string{cond_ind},"OFsenSmall6"))
            continue;
        end
        [elabo_events] = get_events(subs{sub_ind},curr_file_ses,preproc_stage,referenced_elaboEvents_dir);           
        for cond_ind = 1:size(conds_string,2)
            if strcmp(sovs{sov_i},'REM')
                current_sleep_stage_times = (strcmp({elabo_events.('sleep_stage')},"Rt") | strcmp({elabo_events.('sleep_stage')},"Rp"));
            else
                current_sleep_stage_times =strcmp({elabo_events.('sleep_stage')},sovs{sov_i});
            end
                
            ft_mat_path = sprintf('%s\\s_%s_%s_%s.mat',ft_input_dir,subs{sub_ind},sovs{sov_i},conds_string{cond_ind});
            ft_mat = load(ft_mat_path);
            ft_mat = ft_mat.ft_data;
            ft_mat.trialinfo = ones(size(ft_mat.trial,2),1)*get_symbol_design(conds_string{cond_ind},sovs{sov_i},symbol_factorArray);

            subs_conds_ft{iter} = ft_mat;
            iter =iter+1;
        end
    end
    if all(cellfun(@isempty, subs_conds_ft))
        continue
    end
    merged_data = subs_conds_ft{1};
    for s =2:numel(subs_conds_ft)
        cfg = [];
        cfg.keepsampleinfo='no';
        merged_data = ft_appenddata(cfg, merged_data, subs_conds_ft{s});
    end
    merged_data.('fsample') = 250;
    parsave(sprintf("%s\\%s",output_adamformat_dir,mat_file_output_name),merged_data);
end

%% Leave-ove-out design
%%%%%%%%%%%%%%%%%%%%%%% my design (for each sov) %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "block_type"
%                                OF                OR 
% 
% factor          8              108              208               
% "subnum"        9              109              209               
%                 10             110              210                            
%                 11             111              211
%                 13             113              213    


subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','38'};
sovs = {'wake_morning','wake_night','N1','N2','N3','REM'};
preproc_stage = 'referenced';
conds_string = {'OF','OR'};
sub_nums = str2double(subs);
OF_vals = 50 + sub_nums;
OR_vals = sub_nums;
data_table_LOO = [OF_vals', OR_vals'];
disp('data_table:');
disp(data_table_LOO);
symbol_factorArray_LOO = array2table(data_table_LOO, 'RowNames',subs , 'VariableNames', conds_string);


for sov_i=1:size(sovs,2)
    curr_sov = sovs{sov_i};
    if strcmp(curr_sov,'wake_morning')
        curr_sov_filename = 'wmorning';
    elseif strcmp(curr_sov,'wake_night')
        curr_sov_filename = 'wnight';
    else
        curr_sov_filename = curr_sov;
    end
    mat_file_output_name =   sprintf('loo_blocktype_sov-%s.mat',curr_sov_filename);
    if isOutputFile(mat_file_output_name, output_adamformat_dir)  continue; end 

    iter = 1;
    subs_conds_ft = cell(1,numel(conds_string)*numel(sovs));
    for row = 1:size(symbol_factorArray_LOO, 1)
        for col = 1:size(symbol_factorArray_LOO, 2)
            curr_sub = symbol_factorArray_LOO.Properties.RowNames{row};
            curr_blocktype = symbol_factorArray_LOO.Properties.VariableNames{col};
            curr_symbol = symbol_factorArray_LOO{row, col};

            if (strcmp(curr_sov,'wake_night') && strcmp(curr_sub,'37'))
                continue;
            end


            ft_mat_path = sprintf('%s\\s_%s_%s_%s.mat',ft_input_dir,curr_sub,curr_sov,curr_blocktype);
            ft_mat = load(ft_mat_path);
            ft_mat = ft_mat.ft_data;
            ft_mat.trialinfo = ones(size(ft_mat.trial,2),1) * curr_symbol;

            subs_conds_ft{iter} = ft_mat;
            iter =iter+1;
        end
    end
    if all(cellfun(@isempty, subs_conds_ft))
        continue
    end

    % Merge all
    merged_data = subs_conds_ft{1};
    for s =2:numel(subs_conds_ft)
        cfg = [];
        cfg.keepsampleinfo='no';
        merged_data = ft_appenddata(cfg, merged_data, subs_conds_ft{s});
    end
    merged_data.('fsample') = 250;
    parsave(sprintf("%s\\%s",output_adamformat_dir,mat_file_output_name),merged_data);
end

%% util funcs
function parsave(fname, merged_data)
  save(fname, 'merged_data','-v7.3')
end

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

function symbol = get_symbol_design(condition,sov, symbol_design)
    try
        symbol = symbol_design.(sov)(condition);
    catch
        error('Combination of sleep_stage and condition not found in struct_array.');
    end
end