
%https://www.fieldtriptoolbox.org/tutorial/eventrelatedstatistics/

restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
wake_files_name_suffix = 'wake_morning_referenced'; %wake_morning_referenced, wake_night_referenced
ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat\\%s',wake_files_name_suffix);
conds_string = {'OEf4','OR','O','T'};
baseline_timerange = 100;

importer = ft_importer;
if ~exist("allConds_ftRaw","var")    allConds_ftRaw= importer.get_rawFt_conds(ft_cond_dir,conds_string,wake_files_name_suffix,subs);  end
if ~exist("allConds_timlocked","var")    allConds_timlocked=importer.get_allConds_timelocked(allConds_ftRaw,ft_cond_dir,conds_string,subs); end
if ~exist("allConds_timlocked_bl","var")   allConds_timlocked_bl=importer.get_allConds_timelocked_baseline([allConds_timlocked],ft_cond_dir,conds_string,subs,baseline_timerange);end
if ~exist("allConds_grandAvg","var")    allConds_grandAvg = importer.get_allConds_grandAvg(allConds_timlocked,ft_cond_dir,conds_string);end
if ~exist("neighbours","var")    neighbours = importer.get_neighbours(allConds_timlocked{1}{1}.label);end
clear importer

%% Plot ERP per electrodes
cfg = [];
cfg.showlabels  = 'yes';
cfg.layout    = 'GSN-HydroCel-128.mat';
cfg.interactive  = 'no';

figure; ft_multiplotER(cfg, allConds_grandAvg{1}, allConds_grandAvg{2}, allConds_grandAvg{4})
%blue - 1, red -2, green -3, purple - 4
text(0.5,0.35,'1','color','b') ;
text(0.5,0.3,'2','color','r');
text(0.5,0.25,'3','color','g');
text(0.5,0.2,'4','color','black');

% cfg = [];
% cfg.channel = 'MLT12';
% figure; ft_singleplotER(cfg, grandavgFIC, grandavgFC)

%% Plot erp all conditions per subject - for area
central_electrodes = [6,25,61,80];
frontal_electrodes = [8,9,13,14]; % E10, E11, E18, E16
parital_electrodes = [48,49,52,58,59]; % E61, E62, E67, E77, E78
temporalL_electrodes = [31,32,35] ;%E39, E40, E45
electrod_num = central_electrodes;
% Scaling of the vertical axis for the plots below
figure;
for isub = 1:size(subs,2)
    subplot(5,6,isub)
    % use the rectangle to indicate the time range used later
    %rectangle('Position',[time(1) 0 (time(2)-time(1)) ymax],'FaceColor',[0.7 0.7 0.7]);
    hold on;
    % plot the lines in front of the rectangle
    plot(allConds_timlocked{1}{isub}.time,allConds_timlocked{1}{isub}.avg(electrod_num,:), 'b');
    plot(allConds_timlocked{2}{isub}.time,allConds_timlocked{2}{isub}.avg(electrod_num,:), 'r');
    %plot(allConds_timlocked{3}{isub}.time,allConds_timlocked{3}{isub}.avg(electrod_num,:), 'black');
    plot(allConds_timlocked{4}{isub}.time,allConds_timlocked{4}{isub}.avg(electrod_num,:), 'g');
    title(strcat('subject ',subs{isub}))
%     ylim([0 1.9e-13])
     xlim([-0.1 0.45])
end
subplot(5,6,size(subs,2)+1);
axis off

%% Look for a significan electrods between codition in specific timewindow

cfg.channel     = {'all', '-Cz'};
cfg.neighbours  = neighbours; % defined as above
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
cfg.layout    = 'GSN-HydroCel-128.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, allConds_grandAvg{1})
title('Nonparametric: significant with cluster-based multiple comparison correction')

%% Look for differnce clusters of electrods in all time points
alphaval = 0.05;

cfg = [];
cfg.channel     = {'all', '-Cz'};
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
cfg.layout    = 'GSN-HydroCel-128.mat';
cfg.contournum = 0;
cfg.alpha = alphaval;
cfg.parameter='stat';
cfg.zlim = [-5 5];
ft_clusterplot(cfg, stat);
