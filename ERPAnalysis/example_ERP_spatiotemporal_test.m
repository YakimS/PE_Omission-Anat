load C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\example\ERF_orig;    % averages for each individual subject, for each condition

%% calculate grand average for each condition
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'avg';
grandavgFIC  = ft_timelockgrandaverage(cfg, allsubjFIC{:});
grandavgFC   = ft_timelockgrandaverage(cfg, allsubjFC{:});
% "{:}" means to use data from all elements of the variable

%%

cfg = [];
cfg.method      = 'template';                         % try 'distance' as well
cfg.template    = 'ctf151_neighb.mat';                % specify type of template
cfg.layout      = 'CTF151_helmet.mat';                % specify layout of channels
% cfg.feedback    = 'yes';                              % show a neighbour plot
neighbours      = ft_prepare_neighbours(cfg, grandavgFIC); % define neighbouring channels
%%
% note that the layout and template fields have to be entered because at the earlier stage
% when ft_timelockgrandaverage is called the field 'grad' is removed. It is this field that
% holds information about the (layout of the) channels.

cfg = [];
cfg.channel     = 'MEG';
cfg.neighbours  = neighbours; % defined as above
cfg.latency     = [0.3 0.7];
cfg.avgovertime = 'yes';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 'all';  % there are 10 subjects, so 2^10=1024 possible permutations

Nsub = 10;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, allsubjFIC{:}, allsubjFC{:});

% make a plot
cfg = [];
cfg.style     = 'blank';
cfg.layout    = 'CTF151_helmet.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, grandavgFIC)
title('Nonparametric: significant with cluster-based multiple comparison correction')