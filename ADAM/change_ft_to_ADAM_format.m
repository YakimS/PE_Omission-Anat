restoredefaultpath
addpath D:\matlab_libs\fieldtrip-20230223
ft_defaults
addpath 'D:\matlab_libs\eeglab2023.0'
eeglab nogui;

%%
ft_input_dir = 'D:\OExpOut\processed_data\ft_subSovCond';
output_adamformat_dir = 'C:\mvpa\preprocessed\N2_noSleepEvents';

%% Regular. No Leave-ove-out design

subs = {'08','09','10','11','13','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {'wake_morning','wake_night','N1','N2','N3','REM'};
sovs = {'wake_night','N2','N3','REM'};
sovs = {'N2'};
conds_string = {'noN2EventsAOF','noN2EventsAOR','noN2EventsAO','intblksmpAOF','intblksmpAOR','intblksmpAO'};
latency = [0.480 1.160];


%%%%%%%%%%%%%%%%%%%%%%% my design %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "ses"
%                                    wake_morning    wake_night        N1       N2      N3        REM
% 
% factor          noN2KcompAOF             1               2             3        4       5          6             
% "trialtype"     noN2KcompAOR             7               8             9        10      11         12  
%                 noN2KcompAO              13              14            15       16      17         18
%                 intblksmpAOF              19              20            21       22      23         24
%                 intblksmpAOR              25              26            27       28      29         30
%                 intblksmpAO               31              32            33       34      35         36   
%                   
data_table = [
    1,  4, 5, 6;
    7,  10, 11, 12;
    13, 16, 17, 18;
    19, 22, 23, 24;
    25, 28, 29, 30;
    31, 34, 35, 36];

data_table = [4;10;16;22;28;34];

symbol_factorArray = array2table(data_table, 'RowNames',conds_string , 'VariableNames', sovs);

for sub_ind=1:size(subs,2)
    mat_file_output_name =   sprintf('s_%s_allSovs.mat',subs{sub_ind});
    if isOutputFile(mat_file_output_name, output_adamformat_dir)  continue; end 

    iter = 1;
    subs_conds_ft = cell(1,numel(conds_string)*numel(sovs));
    for sov_i=1:numel(sovs)
        for cond_ind = 1:size(conds_string,2)
            ft_mat_path = sprintf('%s\\s_%s_%s_%s.mat',ft_input_dir,subs{sub_ind},sovs{sov_i},conds_string{cond_ind});
            ft_mat = load(ft_mat_path);
            ft_mat = ft_mat.ft_data;
            ft_mat.trialinfo = ones(size(ft_mat.trial,2),1)*get_symbol_design(conds_string{cond_ind},sovs{sov_i},symbol_factorArray);

            % trim time by "latency" limits
            cfg  =[];
            cfg.toilim =latency;
            index = find(abs( ft_mat.time{1} - latency(1)) < 1e-6);
            ft_mat = ft_redefinetrial(cfg, ft_mat);
            cfg = [];
            cfg.offset = -(index-1);
            ft_mat = ft_redefinetrial(cfg, ft_mat);

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
    merged_data.('elec') = subs_conds_ft{1}.elec; %otherwise, elec gets discarded, which cause problems
    
    parsave(sprintf("%s\\%s",output_adamformat_dir,mat_file_output_name),merged_data);
end

%% Leave-ove-out design
%%%%%%%%%%%%%%%%%%%%%%% my design (for each sov) %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "block_type"
%                                OF                OR 
% 
% factor          8              58              8               
% "subnum"        9              59              9               
%                 10             60              10                            
%                 11             61              11
%                 13             63              13    


subs = {'08','09','10','11','13','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {'wake_night','N2','N3','REM'};
sovs = {'N2'};
conds_string = {'noN2EventsAOF','noN2EventsAOR'};
sub_nums = str2double(subs);
OF_vals = 50 + sub_nums;
OR_vals = sub_nums;
data_table_LOO = [OF_vals', OR_vals'];
disp('data_table:');
disp(data_table_LOO);
symbol_factorArray_LOO = array2table(data_table_LOO, 'RowNames',subs , 'VariableNames', conds_string);
latency = [0.480 1.160];


for sov_i=1:size(sovs,2)
    curr_sov = sovs{sov_i};
    if strcmp(curr_sov,'wake_morning')
        curr_sov_filename = 'wm';
    elseif strcmp(curr_sov,'wake_night')
        curr_sov_filename = 'wn';
    else
        curr_sov_filename = curr_sov;
    end
    mat_file_output_name =   sprintf('loo_%s.mat',curr_sov_filename);
    if isOutputFile(mat_file_output_name, output_adamformat_dir)  continue; end 

    iter = 1;
    subs_conds_ft = cell(1,numel(conds_string)*numel(sovs));
    for row = 1:size(symbol_factorArray_LOO, 1)
        for col = 1:size(symbol_factorArray_LOO, 2)
            curr_sub = symbol_factorArray_LOO.Properties.RowNames{row};
            curr_blocktype = symbol_factorArray_LOO.Properties.VariableNames{col};
            curr_symbol = symbol_factorArray_LOO{row, col};

            ft_mat_path = sprintf('%s\\s_%s_%s_%s.mat',ft_input_dir,curr_sub,curr_sov,curr_blocktype);
            ft_mat = load(ft_mat_path);
            ft_mat = ft_mat.ft_data;
            ft_mat.trialinfo = ones(size(ft_mat.trial,2),1) * curr_symbol;

            % trim time by "latency" limits
            cfg  =[];
            cfg.toilim =latency;
            index = find(abs( ft_mat.time{1} - latency(1)) < 1e-6);
            ft_mat = ft_redefinetrial(cfg, ft_mat);
            cfg = [];
            cfg.offset = -(index-1);
            ft_mat = ft_redefinetrial(cfg, ft_mat);

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
    merged_data.('elec') = subs_conds_ft{1}.elec; %otherwise, elec gets discarded, which cause problems
    parsave(sprintf("%s\\%s",output_adamformat_dir,mat_file_output_name),merged_data);
end

%% util funcs
function parsave(fname, merged_data)
  save(fname, 'merged_data','-v7.3')
end

function isAlreadyExist = isOutputFile(output_file,output_dir)
    fullpath = sprintf("%s\\%s",output_dir, output_file);
    if isfile(fullpath)
        fprintf("%s  already exists in path: %s\n", output_file,fullpath)
        isAlreadyExist = true;
    else
        isAlreadyExist = false;
    end
end

function symbol = get_symbol_design(condition,sov, symbol_design)
    try
        symbol = symbol_design.(sov)(condition);
    catch
        error('Combination of sleep_stage and condition not found in struct_array.');
    end
end