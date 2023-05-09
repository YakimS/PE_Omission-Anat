
%https://www.fieldtriptoolbox.org/tutorial/eventrelatedstatistics/

restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
wake_files_name_suffix = 'wake_morning_referenced'; %wake_morning_referenced, wake_night_referenced
ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat');
baseline_timerange = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%
imp = ft_importer(subs,ft_cond_dir,baseline_timerange,wake_files_name_suffix);
[imp,neig] = imp.get_neighbours(imp);

%% Plot ERP per electrodes

[imp,grandavg_cond1] = imp.get_cond_grandAvg(imp,'OR');
[imp,grandavg_cond2] = imp.get_cond_grandAvg(imp,'OF');
[imp,grandavg_cond3] = imp.get_cond_grandAvg(imp,'T');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];
cfg.showlabels  = 'yes';
cfg.interactive  = 'no';

figure; ft_multiplotER(cfg,grandavg_cond1,grandavg_cond2,grandavg_cond3)
%blue - 1, red -2, green -3, purple - 4
text(0.5,0.35,'1','color','b') ;
text(0.5,0.3,'2','color','r');
text(0.5,0.25,'3','color','g');
text(0.5,0.2,'4','color','black');

% cfg = [];
% cfg.channel = 'MLT12';
% figure; ft_singleplotER(cfg, grandavgFIC, grandavgFC)

%% Plot erp all conditions per subject - for area
central_electrodes = [6,25,61,80,93];
frontal_electrodes = [8,9,13,14]; % E10, E11, E18, E16
parital_electrodes = [48,49,52,58,59]; % E61, E62, E67, E77, E78
temporalL_electrodes = [31,32,35] ;%E39, E40, E45
electrod_num = frontal_electrodes;

cond1 = 'OEf5';
cond2 = 'OR';
cond3 = 'T';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Scaling of the vertical axis for the plots below
[imp,grandavg_cond1] = imp.get_cond_timelocked(imp,cond1);
[imp,grandavg_cond2] = imp.get_cond_timelocked(imp,cond2);
[imp,grandavg_cond3] = imp.get_cond_timelocked(imp,cond3);
figure;
for isub = 1:size(subs,2)
    subplot(5,6,isub)
    % use the rectangle to indicate the time range used later
    %rectangle('Position',[time(1) 0 (time(2)-time(1)) ymax],'FaceColor',[0.7 0.7 0.7]);
    hold on;
    % plot the lines in front of the rectangle
    plot(grandavg_cond1{isub}.time,grandavg_cond1{isub}.avg(electrod_num,:), 'b');
    plot(grandavg_cond2{isub}.time,grandavg_cond2{isub}.avg(electrod_num,:), 'r');
    plot(grandavg_cond3{isub}.time,grandavg_cond3{isub}.avg(electrod_num,:), 'g');
    title(strcat('subject ',subs{isub}))
%     ylim([0 1.9e-13])
     xlim([-0.1 0.45])
end
subplot(5,6,size(subs,2)+1);
axis off

%% Plot erp of difference conditions per subject - for area
central_electrodes = [6,25,61,80,93];
frontal_electrodes = [8,9,13,14]; % E10, E11, E18, E16
parital_electrodes = [48,49,52,58,59]; % E61, E62, E67, E77, E78
temporalL_electrodes = [31,32,35] ;%E39, E40, E45
electrod_num = central_electrodes;

cond1 = 'OEf5';
cond2 = 'OR';
cond3 = 'T';
cond4 = 'A';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Scaling of the vertical axis for the plots below
[imp,grandavg_cond1] = imp.get_cond_timelocked(imp,cond1);
[imp,grandavg_cond2] = imp.get_cond_timelocked(imp,cond2);
[imp,grandavg_cond3] = imp.get_cond_timelocked(imp,cond3);
[imp,grandavg_cond4] = imp.get_cond_timelocked(imp,cond4);
figure;
for isub = 1:size(subs,2)
    subplot(5,6,isub)
    % use the rectangle to indicate the time range used later
    %rectangle('Position',[time(1) 0 (time(2)-time(1)) ymax],'FaceColor',[0.7 0.7 0.7]);
    hold on;
    % plot the lines in front of the rectangle
    plot(grandavg_cond1{isub}.time,grandavg_cond1{isub}.avg(electrod_num,:) - grandavg_cond2{isub}.avg(electrod_num,:), 'b');
    plot(grandavg_cond1{isub}.time,grandavg_cond3{isub}.avg(electrod_num,:) - grandavg_cond4{isub}.avg(electrod_num,:), 'r');
    title(strcat('subject ',subs{isub}))
%     ylim([0 1.9e-13])
     xlim([-0.1 0.45])
end
subplot(5,6,size(subs,2)+1);
axis off

%% Look for a significan electrods between codition in specific timewindow

cfg.neighbours  = neig; % defined as above
cfg.latency     = [0.05 0.2];
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

stat = ft_timelockstatistics(cfg, allConds_timlocked{1}{:}, allConds_timlocked{2}{:});

% make a plot
cfg = [];
cfg.style     = 'blank';
% delete. cfg.layout    = 'GSN-HydroCel-128.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, allConds_grandAvg{1})
title('Nonparametric: significant with cluster-based multiple comparison correction')

%% Look for differnce clusters of electrods in all time points
alphaval = 0.05;

cfg = [];
cfg.neighbours  = neighbours; % defined as above
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

stat = ft_timelockstatistics(cfg,  allConds_timlocked{1}{:}, allConds_timlocked{2}{:});

% make a plot
cfg = [];
cfg.contournum = 0;
cfg.alpha = alphaval;
cfg.parameter='stat';
cfg.zlim = [-5 5];
ft_clusterplot(cfg, stat);
