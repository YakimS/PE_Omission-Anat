restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
eeglab


%% args set
ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
ref_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';
ft_percond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft_per_cond\ftPreproImport_cont-no';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';

sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);
choosenSuffix = wake_files_name_suffix;

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

%% all_conds, baseline and activation

cond1_active = cell(1, size(subs,2));
cond1_baseline = cell(1, size(subs,2));
for sub_ind=1:size(subs,2)

    cfg = [];
    cfg.toilim = [0.1 0.2];
    cond1_active{sub_ind} = ft_redefinetrial(cfg, all_conds{1}{sub_ind});
    
    cfg = [];
    cfg.toilim = [-0.1 0];
    cond1_baseline{sub_ind} =  ft_redefinetrial(cfg, all_conds{1}{sub_ind}); % TODO: solve issues of inconsistency
    
    cond1_baseline{sub_ind}.time = cond1_active{sub_ind}.time;
end
%% baseline and activation - Timelock
cond1_active_timelocked = cell(1, size(subs,2));
cond1_baseline_timelocked = cell(1, size(subs,2));
cfg = [];
for condition_ind = 1:size(conditions_string,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        cond1_active_timelocked{sub_ind} = ft_timelockanalysis(cfg, cond1_active{sub_ind});
        cond1_baseline_timelocked{sub_ind} = ft_timelockanalysis(cfg, cond1_baseline{sub_ind});
    end
end

%% all_conds, timelocked
cfg = [];
all_conds_timlocked = cell(1, size(conditions_string,2));
for condition_ind = 1:size(conditions_string,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        all_conds_timlocked{condition_ind}{sub_ind} = ft_timelockanalysis(cfg, all_conds{condition_ind}{sub_ind});
    end
end

%%
cfg = [];
cfg.channel     = {'all', '-Cz'};
Nsub = size(subs,2);
cfg.numrandomization = 500;

cfg.method           = 'analytic'; % 'analytic' , montecarlo;
cfg.statistic        = 'ft_statfun_actvsblT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.neighbours       = new_neighbours;

ntrials = 26;
design  = zeros(2,2*ntrials);
design(1,1:ntrials) = 1;
design(1,ntrials+1:2*ntrials) = 2;
design(2,1:ntrials) = [1:ntrials];
design(2,ntrials+1:2*ntrials) = [1:ntrials];

cfg.design   = design;
cfg.ivar     = 1;
cfg.uvar     = 2;

[stat] = ft_timelockstatistics(cfg, cond1_active_timelocked{:}, cond1_baseline_timelocked{:});

%%
cfg = [];
cfg.channel     = {'all', '-Cz'};
Nsub = size(subs,2);
cfg.numrandomization = 500;
cfg.neighbours       = new_neighbours;

cfg.method           = 'analytic'; % 'analytic' , montecarlo;
cfg.statistic        = 'ft_statfun_actvsblT'; % MAKE SURE TIMES ARE INDEPENEDBT
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;

design = zeros(2, Nsubj*2);
design(1,:) = [1:Nsubj 1:Nsubj];
design(2,:) = [ones(1,Nsubj) ones(1,Nsubj)*2];

cfg.design = design;
cfg.uvar   = 1;
cfg.ivar   = 2;

[stat] = ft_timelockstatistics(cfg, cond1_active_timelocked{:}, cond1_baseline_timelocked{:});