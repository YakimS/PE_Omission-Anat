%% turn a sleep .set file to a a ft file in 1000 trails batches

restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab nogui;
clear;

%%
ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
interim_res_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\reref_in_ft';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
batchSize = 1000;  
%%
% delete(gcp('nocreate'))
% tic
% ticBytes(gcp);
% parfor (sub_i=1:size(subs,2),3)
for sub_i=1:size(subs,2)
    set_file_name = sprintf('s_%s_sleep_referenced.set',subs{sub_i});
    mat_file_name = strrep(set_file_name, '.set', '.mat');
    if isOutputFile(mat_file_name,interim_res_dir)
        continue;
    end
    tic
    eeglabsub_reref =  pop_loadset(set_file_name, ref_input_dir);
    trialsNum = numel(eeglabsub_reref.event); 
    
    batchsIntervals = 1:batchSize:trialsNum+batchSize;
    batchsIntervals(batchsIntervals > trialsNum) = min(trialsNum, batchsIntervals(batchsIntervals > trialsNum));
    if numel(batchsIntervals) >= 2 && batchsIntervals(end) == batchsIntervals(end-1)
        batchsIntervals(end) = [];
    end
    batchsIntervals(end) = batchsIntervals(end)+1;
    
    subs_conds_ft = cell(1,numel(batchsIntervals)-1);
    for inter_i=1:(numel(batchsIntervals)-1)
        curr_inter = batchsIntervals(inter_i):(batchsIntervals(inter_i+1)-1);
        interim_filename = sprintf('interim-%d_%s',inter_i,set_file_name);
        new_eeglabsub= pop_select(eeglabsub_reref, 'trial', curr_inter );
    
        pop_saveset(new_eeglabsub,'filepath',interim_res_dir,'filename',interim_filename,'version','7.3');
    
        cfg = []; 
        cfg.dataset = sprintf('%s\\%s',interim_res_dir,interim_filename);
        cfg.continuous = 'no';
        ft_data = ft_preprocessing(cfg);
    
        subs_conds_ft{inter_i} = ft_data;
    
        delete(sprintf('%s\\%s',interim_res_dir,interim_filename));
    end
    
    merged_data = subs_conds_ft{1};
    for s =2:numel(subs_conds_ft)
        cfg = [];
        cfg.keepsampleinfo='no';
        merged_data = ft_appenddata(cfg, merged_data, subs_conds_ft{s});
    end
    merged_data.('fsample') = 250;
    parsave(sprintf('%s\\%s',interim_res_dir,mat_file_name),merged_data);
    
    toc
end
% tocBytes(gcp)
% toc
%% util funcs
function parsave(fname, merged_data)
  save(fname,'merged_data', '-v7.3');
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