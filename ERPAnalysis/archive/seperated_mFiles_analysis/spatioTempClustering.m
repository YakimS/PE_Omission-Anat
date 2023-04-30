% https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
wake_files_name_suffix = 'wake_all_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat');
baseline_timerange = 100;

imp = ft_importer_allsubjclass(subs,ft_cond_dir,baseline_timerange,wake_files_name_suffix);
[imp,neig] = imp.get_neighbours(imp);
[imp,timelock_OR] = imp.get_cond_timelocked(imp,'OR');
electrodes = timelock_OR{1}.label;
%% baseline vs activity
output_dir = sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\preStim_Vs_postStim",wake_files_name_suffix);
conds_names = {'OR','OF','OEf4','O'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cond_i = 1:size(conds_names,2)
    output_filename = sprintf("%s/preVsPoststim_bl-%d_%s",output_dir,baseline_timerange,conds_names{cond_i});
    [imp,timelock_cond] = imp.get_cond_timelocked(imp,conds_names{cond_i});
    [imp,timelockBl_cond] = imp.get_cond_timelockedBl(imp,conds_names{cond_i});
    metadata = cluster_dependentT(timelockBl_cond, timelock_cond,[-0.1,0.45],subs,neig,output_filename);
end
save(sprintf("%s/preVsPoststim-bl-%d_metadata.mat",output_dir,baseline_timerange), "metadata")

%% Cond1 VS Cond2 - subjects mean
output_dir = sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\cond1_Vs_cond2",wake_files_name_suffix);
contrasrs = {{'OF','OR'},{'OEf4','OR'}};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for contrast_ind=1:size(contrasrs,2)
    cond1 = contrasrs{contrast_ind}{1};
    cond2 = contrasrs{contrast_ind}{2};    
    output_filename = sprintf("%s/%sVs%s_avg",output_dir,cond1,cond2);
    try
        [imp,rawft_cond1] = imp.get_cond_timelocked(imp,cond1);
        [imp,rawft_cond2] = imp.get_cond_timelocked(imp,cond2);
        
        metadata = cluster_dependentT(rawft_cond1, rawft_cond2,[-0.1,0.45],subs,neig,output_filename);
        %save(sprintf("%s/SpatioTempSubAvg_metadata.mat",image_output_dir), "metadata")
    catch ME
        if strcmp(ME.message,"no clusters present with a p-value lower than the specified alpha, nothing to plot")
            sprintf("contrast: [%s, %s]: %s",cond1,cond2,ME.message)
        else
            ME.message
        end
    end
end

%% Cond1 VS Cond2 - per subject
output_dir = sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\cond1_Vs_cond2",wake_files_name_suffix);
contrasrs = {{'OF','OR'},{'OEf4','OR'}};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for contrast_ind=1:size(contrasrs,2)
    cond1 = contrasrs{contrast_ind}{1};
    cond2 = contrasrs{contrast_ind}{2};
    [imp,rawft_cond1] = imp.get_rawFt_cond(imp,cond1);
    [imp,rawft_cond2] = imp.get_rawFt_cond(imp,cond2);
    for sub_ind=1:size(subs,2)
       stat_file_string = sprintf("%s/%sVs%s_sub-%s",output_dir,cond1,cond2, subs{sub_ind});
       try
            metadata = cluster_independetT(rawft_cond1{sub_ind},rawft_cond2{sub_ind},neig,[-0.1,0.45],stat_file_string);
       catch ME
            if strcmp(ME.message,"no clusters present with a p-value lower than the specified alpha, nothing to plot")
                sprintf("contrast: [%s, %s]: %s",cond1,cond2,ME.message)
            else
                ME.message
            end
        end
    end
end
%save(sprintf("%s/SpatioTempPerSub_metadata.mat",image_output_dir), "metadata")

%%%%%% one sub %%%%%%% 
% sub_ind = 19;
% cond1_ind = 1;
% cond2_ind = 3;
% timelockFC  = all_conds{cond1_ind}{sub_ind}; %or 19?
% timelockFIC = all_conds{cond2_ind}{sub_ind};
% stat_file_string = sprintf("%s/%sVs%s-_sub-%s",image_output_dir,conditions_string{cond1_ind},conditions_string{cond2_ind}, subs{sub_ind});
% metadata = get_all_timepoint_diff_electrodes_per_sub(timelockFC,timelockFIC,new_neighbours,stat_file_string);


%%
% Electrods Cluster between conditions. per timepoint for one subject
function metadata = cluster_independetT(cond1_struct, cond2_struct,neighbours,latency,stat_file_string)
    metadata = {};
    timelockFC  = cond1_struct;
    timelockFIC = cond2_struct;
    
    % ft_timelockstatistics
    cfg                  = [];
    cfg.method           = 'montecarlo';
    cfg.statistic        = 'indepsamplesT';
    cfg.correctm         = 'cluster';
    
    cfg.clusteralpha     = 0.2;  
    cfg.clusterstatistic = 'maxsum';   
    cfg.minnbchan        = 1;     
    cfg.tail             = 0;         
    cfg.clustertail      = 0;
    cfg.alpha            = 0.25;
    cfg.numrandomization = 1000;
    cfg.neighbours    = neighbours; 
    cfg.latency     = latency;
    n_fc  = size(timelockFC.trial, 2);
    n_fic = size(timelockFIC.trial, 2);
    cfg.design           = [ones(1,n_fic), ones(1,n_fc)*2]; % design matrix
    cfg.ivar             = 1; % number or list with indices indicating the independent variable(s)
    [stat] = ft_timelockstatistics(cfg, timelockFIC, timelockFC);
    save(sprintf("%s.mat",stat_file_string), '-struct', 'stat');
    
    if all(stat.mask == 0)
        return
    end

    %plot
    % cfg.toi makes sure to plot also the baseline timeperiod
    timediff = cond1_struct.time{1}(2) - cond1_struct.time{1}(1);
    toi = latency(1): timediff :latency(2);
    cfg = cluster_plot(stat,toi,stat_file_string);

    % return metadata
    metadata.cfg_ft_clusterplot =  cfg;
    metadata.ft_timelockstatistics =  stat.cfg;
end

% Electrods Cluster between conditions. per timepoint all subjects
function metadata = cluster_dependentT(cond1_struct, cond2_struct,latency,subs,neighbours,png_filename)
    metadata = {};
    cfg = [];
    cfg.latency     = latency;
    Nsub = size(subs,2);
    cfg.numrandomization = 10000;
    
    cfg.neighbours  = neighbours; % defined as above
    cfg.avgovertime = 'no';
    cfg.parameter   = 'avg';
    cfg.method      = 'montecarlo';
    cfg.statistic   = 'ft_statfun_depsamplesT';
    cfg.correctm    = 'cluster';
    cfg.correcttail = 'prob';
    cfg.minnbchan        = 1;      % minimal number of neighbouring channels
    
    cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
    cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
    cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
    cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
    
    stat = ft_timelockstatistics(cfg,cond1_struct{:}, cond2_struct{:});
    save(sprintf("%s.mat",png_filename), '-struct', 'stat');

    % plot
    timediff = cond1_struct{1}.time(2) - cond1_struct{1}.time(1);
    toi = latency(1): timediff :latency(2);
    cfg = cluster_plot(stat,toi,png_filename);

    % return metadata
    metadata.cfg_ft_clusterplot =  cfg;
    metadata.ft_timelockstatistics =  stat.cfg;
end

function cfg = cluster_plot(stat,toi,png_filename)
    % make a plot
    cfg = [];
    %cfg.highlightsymbolseries = ['*','.','.','.','.']; %%  (default ['*', 'x', '+', 'o', '.'] for p < [0.01 0.05 0.1 0.2 0.3]
    cfg.highlightsizeseries     = [5,4,4,4,4];  %1x5 vector, highlight marker size series   (default [6 6 6 6 6] for p < [0.01 0.05 0.1 0.2 0.3])
    cfg.zlim = [-5 5];
    cfg.alpha = 0.2; % This is the max alpha to be plotted. (0.3 is the hights value possible)
    cfg.saveaspng = png_filename;
    cfg.visible = 'no';
    cfg.toi =toi;
    cfg = ft_clusterplot(cfg, stat);
end