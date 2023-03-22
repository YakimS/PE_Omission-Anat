
restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults

addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2022.1


%% get the sub struct arrays for each condition

input_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft\cont=unknown\';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
subs = {'08','09','10','11','13','14'};
preproc_stage = 'referenced';

sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);

conditions_string = {'O','A'};

all_conds = cell(1, size(conditions_string,2));
for condition_ind = 1:size(conditions_string,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        sud_data_path =   strcat(input_dir,'/s_',subs(sub_ind), wake_files_name_suffix,'.mat');
        sub_data = load(sud_data_path{1});
    
        events = sub_data.eeglabsub_events;
        ft_data = sub_data.ft_data.ft_data1;
        
        events_names = {events.type};
%         ft_data.trialinfo = events_names; %% TODO
%         ft_data.trialinfo = ones(size(ft_data.sampleinfo,1),1);
%         ft_data.trialinfo = ft_data.trialinfo * condition_ind;

        Index_currCond = find(contains(events_names,conditions_string{condition_ind}));

        cfg = [];
        cfg.trials = Index_currCond;
        data_currCond = ft_selectdata(cfg, ft_data);
        
        subs_cond{sub_ind} = data_currCond;
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
%%
elec       = ft_read_sens('GSN-HydroCel-128.sfp');
cfg               = [];
cfg.method        = 'distance';
cfg.neighbourdist = 3;
% cfg.feedback      = 'yes';
neighbours        = ft_prepare_neighbours(cfg,elec);

%% all_conds, grandavergae
cfg = [];
all_conds_timlockedgrandAvg = cell(1, size(conditions_string,2));
for condition_ind = 1:size(conditions_string,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        all_conds_timlockedgrandAvg{condition_ind}{sub_ind} = ft_timelockgrandaverage(cfg, all_conds_timlocked{condition_ind}{sub_ind});
    end
end

%%
%%%calculate grand average for each condition
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'avg'; 

grandavg_O  = ft_timelockgrandaverage(cfg, all_conds_timlocked{1}{:});
grandavg_A   = ft_timelockgrandaverage(cfg, all_conds_timlocked{2}{:});
% "{:}" means to use data from all elements of the variable

%%% Show all electrodes
% cfg = [];
% cfg.showlabels  = 'yes';
% figure; ft_multiplotER(cfg, grandavg_O, grandavg_A)

%%% Show one electrode
% cfg = [];
% cfg.channel = 'E22';
% figure; ft_singleplotER(cfg, grandavg_O, grandavg_A)


%%

allsubsO = all_conds_timlocked{1};
allsubsA = all_conds_timlocked{2};
%%
% note that the layout and template fields have to be entered because at the earlier stage
% when ft_timelockgrandaverage is called the field 'grad' is removed. It is this field that
% holds information about the (layout of the) channels.
Nsub = size(subs,2);
cfg = [];
cfg.channel     = 'EEG';
cfg.neighbours  = neighbours; % defined as above
%cfg.latency     = [0.3 0.7];
cfg.avgovertime = 'yes';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization='all';


cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, all_conds_timlockedgrandAvg{1}{:}, all_conds_timlockedgrandAvg{2}{:});

%%
% make a plot
cfg = [];
cfg.style     = 'blank';
cfg.layout    = 'GSN-HydroCel-128.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, grandavgFIC)
title('Nonparametric: significant with cluster-based multiple comparison correction')