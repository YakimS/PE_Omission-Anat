% https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/

restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
eeglab

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
ft_percond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft_per_cond\ftPreproImport_cont-no';
image_output_dir= 'C:\Users\User\OneDrive\Desktop\here';%'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\spatiotemp_clusterPerm';
preproc_stage = 'referenced';
sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);
choosenSuffix = wake_files_name_suffix;
condition_strings = {'OF','OR'};

%% Pre process 
% get the sub struct arrays for each condition
all_conds = cell(1, size(condition_strings,2));
for condition_ind = 1:size(condition_strings,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        ft_file_input_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',condition_strings{condition_ind},'.mat');
        ft_sub_full_filepath = strcat(ft_percond_dir,'/',ft_file_input_name);
        sub_data = load(ft_sub_full_filepath{1});

        subs_cond{sub_ind} = sub_data.ft_data;
    end
    all_conds{condition_ind} = subs_cond;
end

% gey all_conds, timelocked
cfg = [];
all_conds_timlocked = cell(1, size(condition_strings,2));
for condition_ind = 1:size(condition_strings,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        all_conds_timlocked{condition_ind}{sub_ind} = ft_timelockanalysis(cfg, all_conds{condition_ind}{sub_ind});
%         fields = {'var','dof'}; % Just tested if nessesary for baseline
%         comparison. It is unnessetsy for condition conmparison
%         all_conds_timlocked{condition_ind}{sub_ind} = rmfield(all_conds_timlocked{condition_ind}{sub_ind},fields);
    end
end

% get neighbours
cfg = [];
cfg.method = 'triangulation' ; 
cfg.feedback    = 'yes'; [~,ftpath] = ft_version;
elec       = ft_read_sens('GSN-HydroCel-128.sfp'); 
cfg.elec=elec;
neighbours = ft_prepare_neighbours(cfg);

% align "neighbours" struct with current existing labels (Cz is not in neighbours therefore excluded)
ind_existing_elect =[];
events_type_arr = all_conds_timlocked{1}{1}.label;
for elecd_ind = 1:size(neighbours,2)
    curr_event_i = find(ismember(events_type_arr,neighbours(elecd_ind).label));
    if ~isempty(curr_event_i)
        ind_existing_elect = [ind_existing_elect, elecd_ind];
    end
end
new_neighbours = neighbours(ind_existing_elect);

%% pre-stimulus-mean vs post-stimulus
% create baseline-per-electrode structs
allConds_baseline = all_conds_timlocked;
cfg = [];
for condition_ind = 1:size(condition_strings,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        curr_subCond_struct = all_conds_timlocked{condition_ind}{sub_ind};
        time0_ind = find(curr_subCond_struct.time == 0, 1);

        baseline = curr_subCond_struct.avg(:,1:time0_ind);
        baseline_mean = mean(baseline,2);
        new_baseline_avg = ones(size(curr_subCond_struct.avg)) .* baseline_mean;
        allConds_baseline{condition_ind}{sub_ind}.avg = new_baseline_avg; 
    end
end

for condition_ind = 1:size(condition_strings,2)
    output_filename = sprintf("%s/preVsPoststim_%s",image_output_dir,condition_strings{condition_ind});
    metadata = cluster_dependentT(allConds_baseline{condition_ind},  all_conds_timlocked{condition_ind},[-0.1,0.45],subs,new_neighbours,output_filename);
end
save(sprintf("%s/preVsPoststim_metadata.mat",image_output_dir), "metadata")

%% Cond1 VS Cond2

%%% subjects mean %%%%
contrasrs = {[1,2]};
for contrast_ind=1:size(contrasrs,2)
    cond1 = contrasrs{contrast_ind}(1);
    cond2 = contrasrs{contrast_ind}(2);
    
    output_filename = sprintf("%s/%sVs%s_avg",image_output_dir,condition_strings{cond1},condition_strings{cond2});
    try
        metadata = cluster_dependentT(all_conds_timlocked{cond1}, all_conds_timlocked{cond2},[-0.1,0.45],subs,new_neighbours,output_filename);
        save(sprintf("%s/SpatioTempSubAvg_metadata.mat",image_output_dir), "metadata")
    catch ME
        if strcmp(ME.message,"no clusters present with a p-value lower than the specified alpha, nothing to plot")
            sprintf("contrast: [%s, %s]: %s",condition_strings{cond1},condition_strings{cond2},ME.message)
        else
            ME.message
        end
    end
end

%%%%%%% Per subject %%%%%%%%%
contrasrs = {[1,2]};
for contrast_ind=1:size(contrasrs,2)
    for sub_ind=1:size(subs,2)
       cond1 = contrasrs{contrast_ind}(1);
       cond2 = contrasrs{contrast_ind}(2);
       timelock_cond1  = all_conds{cond1}{sub_ind};
       timelock_cond2 = all_conds{cond2}{sub_ind};
       stat_file_string = sprintf("%s/%sVs%s_sub-%s",image_output_dir,condition_strings{cond1},condition_strings{cond2}, subs{sub_ind});
       metadata = cluster_independetT(timelock_cond1,timelock_cond2,new_neighbours,[-0.1,0.45],stat_file_string);
    end
end
save(sprintf("%s/SpatioTempPerSub_metadata.mat",image_output_dir), "metadata")

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
    cfg.minnbchan        = 2;     
    cfg.tail             = 0;         
    cfg.clustertail      = 0;
    cfg.alpha            = 0.25;
    cfg.numrandomization = 1000;
    cfg.neighbours    = neighbours; 
    cfg.channel     = {'all', '-Cz'};
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
    cfg.channel     = {'all', '-Cz'};
    cfg.latency     = latency;
    Nsub = size(subs,2);
    cfg.numrandomization = 1000;
    
    cfg.neighbours  = neighbours; % defined as above
    cfg.avgovertime = 'no';
    cfg.parameter   = 'avg';
    cfg.method      = 'montecarlo';
    cfg.statistic   = 'ft_statfun_depsamplesT';
    cfg.correctm    = 'cluster';
    cfg.correcttail = 'prob';
    cfg.minnbchan        = 2;      % minimal number of neighbouring channels
    
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
    cfg.layout    = 'GSN-HydroCel-128.mat';
    cfg.zlim = [-5 5];
    cfg.alpha = 0.2; % This is the max alpha to be plotted. (0.3 is the hights value possible)
    cfg.saveaspng = png_filename;
    cfg.visible = 'no';
    cfg.toi =toi;
    cfg = ft_clusterplot(cfg, stat);
end