restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
eeglab


%% args set
ft_percond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft_per_cond\ftPreproImport_cont-no';
conditions_string = {'O','T','A'};
conditions_string = {'T','O'};






%% get the sub struct arrays for each condition
all_conds = cell(1, size(conditions_string,2));
for condition_ind = 1:size(conditions_string,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        ft_file_input_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',conditions_string{condition_ind},'.mat');
        ft_sub_full_filepath = strcat(ft_percond_dir,'/',ft_file_input_name);
        sub_data = load(ft_sub_full_filepath{1});

        subs_cond{sub_ind} = sub_data.ft_data;
    end
    all_conds{condition_ind} = subs_cond;
end


%% all_conds, timelocked
cfg = [];
all_conds_timlocked = cell(1, size(conditions_string,2));
for condition_ind = 1:size(conditions_string,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        all_conds_timlocked{condition_ind}{sub_ind} = ft_timelockanalysis(cfg, all_conds{condition_ind}{sub_ind});
%         fields = {'var','dof'}; % Just tested if nessesary for baseline
%         comparison. It is unnessetsy for condition conmparison
%         all_conds_timlocked{condition_ind}{sub_ind} = rmfield(all_conds_timlocked{condition_ind}{sub_ind},fields);
    end
end

%% neighbours
cfg = [];
cfg.method = 'triangulation' ;  %couldnt find template for this
cfg.feedback    = 'yes'; [~,ftpath] = ft_version;
elec       = ft_read_sens('GSN-HydroCel-128.sfp');   % or 129
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
%% Ale's between conditions
Nsub = size(subs,2);
cfg = [];
cfg.channel     = 'EEG';
cfg.neighbours  = new_neighbours; % defined as above
cfg.latency     = [0 0.448];
cfg.avgovertime = 'yes';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization=10000;
cfg.channel     = {'all', '-Cz'};

cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, all_conds_timlocked{1}{:}, all_conds_timlocked{2}{:});

cfg.zlim     = [-4 4];cfg.parameter='stat';cfg.interpolatenan='no';
ft_topoplotER(cfg,stat);% diff en t value
title(strcat(conditions_string{1},' vs. ', conditions_string{2}));c = colorbar;c.LineWidth = 1;c.FontSize = 14;
title(c,'t-val');
% so far it was the same as above, now change the colormap
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap

%%
a = all_conds_timlocked{1};
b = all_conds_timlocked{2};
get_timeAvg_diff_electrodes(a, b,[0 0.448],subs);


%% electrods Cluster between conditions. per timepoint
a = all_conds_timlocked{1};
b = all_conds_timlocked{2};
get_all_timepoints_diff_electrodes(a, b,[0 0.448],subs,neighbours);

%% prestimulus-mean vs activation

% create baseline-per-electrode structs
allConds_baseline = all_conds_timlocked;
cfg = [];
for condition_ind = 1:size(conditions_string,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        curr_subCond_struct = allConds_baseline{condition_ind}{sub_ind};
        time0_ind = find(curr_subCond_struct.time == 0, 1);

        baseline = curr_subCond_struct.avg(:,1:time0_ind);
        baseline_mean = mean(baseline,2);
        new_baseline_avg = ones(size(curr_subCond_struct.avg)) .* baseline_mean;
        allConds_baseline{condition_ind}{sub_ind}.avg = new_baseline_avg; 
    end
end

%
a = allConds_baseline{2};
b = all_conds_timlocked{2};
get_all_timepoints_diff_electrodes(a, b,subs,neighbours);


%%
function isAlreadyExist = isOutputFile(output_file,output_dir)
    fullpath = strcat(output_dir,'\', output_file);
    fullpath = fullpath{1};
    if isfile(fullpath)
        string(strcat(output_file, ' already exists in path:',  fullpath))
        isAlreadyExist = true;
    else
        isAlreadyExist = false;
    end
end

% electrods Cluster between conditions. per timepoint
function get_all_timepoints_diff_electrodes(cond1_struct, cond2_struct,latency,subs,neighbours)
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
    cfg.alpha       = 0.05;
    cfg.correctm    = 'cluster';
    cfg.correcttail = 'prob';
    cfg.minnbchan        = 2;      % minimal number of neighbouring channels
    
    cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
    cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
    cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
    cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
    
    
    stat = ft_timelockstatistics(cfg,cond1_struct{:}, cond2_struct{:});

    % make a plot
    cfg = [];
    cfg.highlightsymbolseries = ['*','*','.','.','.'];
    cfg.layout    = 'GSN-HydroCel-128.mat';
    cfg.contournum = 0;
    cfg.markersymbol = '.';
    cfg.alpha = 0.05;
    cfg.parameter='stat';
    cfg.zlim = [-5 5];
    ft_clusterplot(cfg, stat);
end

%Electrods Cluster between conditions. Grand-average over time
function get_timeAvg_diff_electrodes(cond1_struct, cond2_struct,latency,subs)
    cfg = [];
    cfg.channel     = {'all', '-Cz'};
    cfg.latency     = latency;
    Nsub = size(subs,2);
    cfg.numrandomization = 10000;
    
    cfg.avgovertime = 'yes';
    cfg.parameter   = 'avg';
    cfg.method      = 'montecarlo';
    cfg.statistic   = 'ft_statfun_depsamplesT';
    cfg.alpha       = 0.05;
    cfg.correctm    = 'no';
    cfg.correcttail = 'prob';
    
    cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
    cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
    cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
    cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
    
    
    stat = ft_timelockstatistics(cfg, cond1_struct{:}, cond2_struct{:});
    
    % make the plot
    cfg = [];
    cfg.style     = 'blank';
    cfg.layout    = 'GSN-HydroCel-128.mat';
    cfg.highlight = 'on';
    cfg.highlightchannel = find(stat.mask);
    cfg.comment   = 'no';
    grandavgFIC  = ft_timelockgrandaverage(cfg,cond1_struct{:});
    figure; ft_topoplotER(cfg, grandavgFIC)
    title('Nonparametric: significant without multiple comparison correction')
end



