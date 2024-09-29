restoredefaultpath
addpath D:\matlab_libs\fieldtrip-20230223
ft_defaults
addpath 'D:\matlab_libs\eeglab2023.0'
eeglab nogui;

%%
ft_input_dir = 'D:\GlobalLocal\ft_subSovCond';
output_adamformat_dir = 'C:\mvpa\GL\preprocessed';

%% Regular. No Leave-ove-out design

subs = {'1989RTKS','1991AGPE','1993AGRI','1993MRAB','1994LUAA','1994MREG','1994PTBV','1995ALKL','1995DNFR','1995GBKA','1995PTAF','1995RMBN','1995RTKL','1996RTHL','1996USRY','1997AIWG','1997ALKL','1997KRGT','1997MRBAE','1997RMDB','1998AADE','1998BRTI','1998IAKN','1999RTLY','1999VTSA','2000DLAL','2000UEAB'};
sovs = {'wake_night','N1','N2','N3','REM'};
conds_string = {'expomit','unexpomit'};
latency = [-1 1];


%%%%%%%%%%%%%%%%%%%%%%% my design %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "ses"
%                                    wake_night        N1               N2       N3     REM
% 
% factor          expomit               1               2             3        4       5                 
% "trialtype"     unexpomit             6               7             8        9      10         

%                   
data_table = [
    1,  2, 3, 4, 5;
    6,  7, 8, 9, 10];


symbol_factorArray = array2table(data_table, 'RowNames',conds_string , 'VariableNames', sovs);

for sub_ind=1:size(subs,2)
    mat_file_output_name =   sprintf('s-%d_allSovs.mat',sub_ind);
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

%%%%%%%% save subject indexes
outputFile = sprintf("%s\\subjects_indexes.txt",output_adamformat_dir); 
fid = fopen(outputFile, 'w');
if fid == -1   error('Cannot open file for writing: %s', outputFile); end
fprintf(fid, 'Index\tString\n');
for i = 1:length(subs)
    fprintf(fid, '%d\t%s\n', i, subs{i});
end
fclose(fid);
fprintf('File saved successfully: %s\n', outputFile);

%% Leave-ove-out design
%%%%%%%%%%%%%%%%%%%%%%% my design (for each sov) %%%%%%%%%%%%%%%%%%%%%%
%                               
%                   factor "block_type"
%                  OF                OR 
% 
% factor          1              51                  
% "subnum"        2              52                 
%                 3              53                                  
%                 4              54       
%                 5              55   


subs = {'1989RTKS','1991AGPE','1993AGRI','1993MRAB','1994LUAA','1994MREG','1994PTBV','1995ALKL','1995DNFR','1995GBKA','1995PTAF','1995RMBN','1995RTKL','1996RTHL','1996USRY','1997AIWG','1997ALKL','1997KRGT','1997MRBAE','1997RMDB','1998AADE','1998BRTI','1998IAKN','1999RTLY','1999VTSA','2000DLAL','2000UEAB'};
sovs = {'wake_night','N1','N2','N3','REM'}; 
conds_string = {'expomit','unexpomit'};
latency = [-1 1];


OF_vals = 50 + (1:numel(subs));
OR_vals = (1:numel(subs));
data_table_LOO = [OF_vals', OR_vals'];
disp('data_table:');
disp(data_table_LOO);
symbol_factorArray_LOO = array2table(data_table_LOO, 'RowNames',subs , 'VariableNames', conds_string);


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