args_path = "C:\Users\User\OneDrive\Documents\githubProjects\ft_ERPAnalysis\running_mats\spatioTempoAnaly_run_wake_night.mat";
args = load(args_path);
args = args.args;
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; %  args.subs;
sovs = {'wake_night','wake_morning','N1','N2','REM','N3'}; %args.wake_files_name_suffix; %  
bl = args.bl;
contrasts = {{'OF','OR'},{'A','T'},{'OFsenBig5','ORsenBig5'},{'OFsenSmall6','ORsenSmall6'},{'OFstrt','ORstrt'},{'OFmid','ORmid'},{'OFend','ORend'}}; %args.contrasts;
contrasts = {{'OFprep','ORprep'},{'OF','OR'}};
contrasts_strings = {{'Fixed Omission','Random Omission'},{'Fixed Omission','Random Omission'}}; % ,{'Omission', 'Tone'}
%{'A',"O",'T','ORsenBig5','ORsenSmall6','OFsenBig5','OFsenSmall6','OR','OF','OEf6','OEf2','OEf3','OEf4','OEf5','ORl6','ORl7'};
pre_vs_post_conds = {'O','Oprep','OFprep','ORprep'}; %args.pre_vs_post_conds_names;
pre_vs_post_conds_strings = {'Omission','Omission','Fixed Omission','Random Omission'};


output_main_dir = args.output_main_dir;
ft_cond_input_dir = "C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\import\ft_per_cond";
ft_cond_output_dir = "C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\data_in_ft_cond_fomat";

%%%%%%%%%%%%%%%%%%%%%%%%%%
% https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
restoredefaultpath
addpath(sprintf('%s\\fieldtrip-20230223', args.libs_dir))
ft_defaults
addpath(sprintf('%s\\eeglab2023.0', args.libs_dir))
addpath(args.libs_dir)
addpath(args.code_dir)
close;
%%
for sov_i = 1:numel(sovs)
    curr_subs = subs;
    if strcmp(sovs{sov_i}, 'wake_night')
        curr_subs(strcmp(curr_subs, '37')) = [];
    elseif strcmp(sovs{sov_i}, 'N1')
        curr_subs(strcmp(curr_subs, '37')) = [];
        curr_subs(strcmp(curr_subs, '36')) = [];
        curr_subs(strcmp(curr_subs, '33')) = [];
    elseif strcmp(sovs{sov_i}, 'wake_morning')
        curr_subs(strcmp(curr_subs, '15')) = [];
    elseif strcmp(sovs{sov_i}, 'N3')
        curr_subs(strcmp(curr_subs, '09')) = [];
    end
    
%     if contains(sovs{sov_i},'wake')
%         curr_contrasts = contrasts;
%     else
%         curr_contrasts = remove_strtMidEnd_contrasts(contrasts);
%     end
    curr_contrasts = contrasts;
    curr_contrast_strings = contrasts_strings;
    for contrast_i=1:numel(curr_contrasts)
        curr_contrast = curr_contrasts{contrast_i};
        curr_contrast_strings = contrasts_strings{contrast_i};
        between_subs_analysis(curr_subs,curr_contrast,output_main_dir,bl,ft_cond_input_dir,ft_cond_output_dir,sovs{sov_i},pre_vs_post_conds,curr_contrast_strings,pre_vs_post_conds_strings)
    end
end

%%
function between_subs_analysis(subs,contrast,output_main_dir,bl,ft_cond_input_dir,ft_cond_output_dir,sov,pre_vs_post_conds,contrast_strings,pre_vs_post_conds_strings)
    cond_rand_name ='Oprep';
    imp = ft_importer(subs,ft_cond_input_dir,ft_cond_output_dir,bl,sov); 
    timelock = imp.get_cond_timelocked(imp,cond_rand_name);
    electrodes = timelock{1}.label;
    time = timelock{1}.time;
    f = funcs_spatioTemporalAnalysis(imp, electrodes,time);
    
    cond1_Vs_cond2_dir = sprintf('%s\\%s\\cond1_Vs_cond2',output_main_dir,sov);
    pre_vs_poststim_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,sov);
    dir_baseline_erp = sprintf('%s\\%s\\baseline_erp',output_main_dir,sov);
    persub_output_dir = sprintf("%s\\%s\\per_sub_electrode",output_main_dir,sov);
    mkdir(cond1_Vs_cond2_dir);
    mkdir(pre_vs_poststim_dir);
    mkdir(dir_baseline_erp);
    mkdir(persub_output_dir);
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    Analysis                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
%     % baseline vs activity - subjects mean
    plot_topoplot = true;
%     f.spatiotempoClustPerm_BlPreStimVsActivity_subAvg(f,pre_vs_poststim_dir, pre_vs_post_conds_names,plot_topoplot)
    f.spatiotempoClustPerm_BlInterblockVsActivity_subAvg(f,pre_vs_poststim_dir, pre_vs_post_conds,sov,plot_topoplot)

    %f.plot_erp_per_contrast_and_sov(f,sov,contrast,contrast_strings,output_main_dir,sov,'interblock','Oprep')
    f.plot_erp_per_contrast_and_sov(f,sov,contrast,contrast_strings,output_main_dir,sov,'interblock','Oprep')

    for i=1:numel(pre_vs_post_conds)
        f.plot_erp_baseline_vs_cond_per_sov(f,sov,sov,pre_vs_post_conds{i},'interblock','Interblock Baseline',pre_vs_post_conds_strings{i},output_main_dir)
    end

%     for i=1:numel(pre_vs_post_conds)
%         f.plot_erp_baseline_vs_cond_per_sov(f,sov,'wake_morning',pre_vs_post_conds{i},'interblock','Interblock Baseline',pre_vs_post_conds_strings{i},output_main_dir)
%     end

% %     
%     % Cond1 VS Cond2 - subjects mean
%     plot_topoplot = true;
%     f.spatiotempoClustPerm_cond1VsCond2_subAvg(f,cond1_Vs_cond2_dir, {contrast},plot_topoplot)
% 
%     % Get time-electodes clusters of cond O vs. baseline. Look for difference in OF vs. OR in that time-electrode range
%     % with cluster permutatiton diff results
% 
%     conds = {contrast{1},contrast{2},'O'};  % makes sure it's size 4 (cond1, cond2, O, T), or 3 but then you need to check "false" on the is_with_T_lines
% % 
%     cond_preVsPoststim = load(sprintf("%s\\preVsPoststim_bl-%s_%s_avg",pre_vs_poststim_dir,'interblock', 'O'));
% 
%     f.plot_OClusters_contrasts(f,conds,cond_preVsPoststim,pre_vs_poststim_dir,true,false,'interblock')
%     f.plot_OClusters_contrasts(f,conds,cond_preVsPoststim,pre_vs_poststim_dir,false,false,'interblock')
end


function new_contrasts=remove_strtMidEnd_contrasts(contrasts)
    valid_pairs = true(size(contrasts));
    for i = 1:numel(contrasts)
        for j = 1:numel(contrasts{i})
            if contains(contrasts{i}{j}, 'end') || contains(contrasts{i}{j}, 'mid') || contains(contrasts{i}{j}, 'strt')
                valid_pairs(i) = false;
                break;
            end
        end
    end
    new_contrasts = contrasts(valid_pairs);
end




        