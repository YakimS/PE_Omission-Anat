
%https://www.fieldtriptoolbox.org/tutorial/eventrelatedstatistics/

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

%%

% calculate grand average for each condition
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'avg';
grandavg_cond1  = ft_timelockgrandaverage(cfg, all_conds_timlocked{1}{:});
grandavg_cond2   = ft_timelockgrandaverage(cfg, all_conds_timlocked{2}{:});
% "{:}" means to use data from all elements of the variable
%%
cfg = [];
cfg.showlabels  = 'yes';
cfg.layout    = 'GSN-HydroCel-128.mat';
figure; ft_multiplotER(cfg, grandavg_cond1, grandavg_cond2)

% cfg = [];
% cfg.channel = 'MLT12';
% figure; ft_singleplotER(cfg, grandavgFIC, grandavgFC)

%%
electrod_num = 1;

% Scaling of the vertical axis for the plots below
figure;
for isub = 1:size(subs,2)
    subplot(5,6,isub)
    % use the rectangle to indicate the time range used later
    %rectangle('Position',[time(1) 0 (time(2)-time(1)) ymax],'FaceColor',[0.7 0.7 0.7]);
    hold on;
    % plot the lines in front of the rectangle
    plot(all_conds_timlocked{1}{isub}.time,all_conds_timlocked{1}{isub}.avg(electrod_num,:), 'b');
    plot(all_conds_timlocked{2}{isub}.time,all_conds_timlocked{2}{isub}.avg(electrod_num,:), 'r');
    title(strcat('subject ',num2str(isub)))
%     ylim([0 1.9e-13])
%     xlim([-1 2])
end
subplot(5,6,size(subs,2)+1);
text(0.5,0.5,'FIC','color','b') ;text(0.5,0.3,'FC','color','r')
axis off

%% Look for a significan electrods between codition in specific timewindow

cfg.channel     = {'all', '-Cz'};
cfg.neighbours  = new_neighbours; % defined as above
cfg.latency     = [0.1 0.2];
cfg.avgovertime = 'yes';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 1000;  % there are 10 subjects, so 2^10=1024 possible permutations

Nsub = size(subs,2);
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, all_conds_timlocked{1}{:}, all_conds_timlocked{2}{:});

% make a plot
cfg = [];
cfg.style     = 'blank';
cfg.layout    = 'GSN-HydroCel-128.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, grandavg_cond1)
title('Nonparametric: significant with cluster-based multiple comparison correction')

%% Look for differnce clusters of electrods in all time points
alphaval = 0.05;

cfg = [];
cfg.channel     = {'all', '-Cz'};
cfg.neighbours  = new_neighbours; % defined as above
cfg.latency     = [-0.1 0.45];
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = alphaval;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 1000;  % there are 10 subjects, so 2^10=1024 possible permutations
cfg.minnbchan        = 2;      % minimal number of neighbouring channels

Nsub = size(subs,2);
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg,  all_conds_timlocked{1}{:}, all_conds_timlocked{2}{:});

% make a plot
cfg = [];
cfg.layout    = 'GSN-HydroCel-128.mat';
cfg.contournum = 0;
cfg.alpha = alphaval;
cfg.parameter='stat';
cfg.zlim = [-5 5];
ft_clusterplot(cfg, stat);
