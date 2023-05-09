%% space time cluster permutation
clear;clc; 
%% CONGRUENT
[Congruent]=load(['all_Congruent_alert_allchan.mat']);
Congruent=Congruent.all_Congruent_alert_allchan
cfg=[]; cfg.channel          = {'all','-E57','-E100','-E114'};
cfg.latency   = 'all';cfg.parameter = 'avg';
[grandavg_Congruent_alert_allchan] = ft_timelockgrandaverage(cfg, Congruent{:})
% save(['grandavg_Congruent_alert_allchan.mat'], 'grandavg_Congruent_alert_allchan');
%% INCONGRUENT
[Incongruent]=load(['all_Incongruent_alert_allchan.mat']);
Incongruent=Incongruent.all_Incongruent_alert_allchan
cfg=[]; cfg.channel          = {'all','-E57','-E100','-E114'}
cfg.latency   = 'all';cfg.parameter = 'avg';
[grandavg_Incongruent_alert_allchan] = ft_timelockgrandaverage(cfg, Incongruent{:})
% save(['grandavg_Incongruent_alert_allchan.mat'], 'grandavg_Incongruent_alert_allchan');
%% NON PARAMETRIC statistics
%% neighbours
cfg = [];
cfg.method = 'triangulation' ;  %couldnt find template for this
cfg.feedback    = 'yes'; [~,ftpath] = ft_version;
elec = ft_read_sens(strcat(ftpath, '/template/electrode/GSN-HydroCel-128.sfp' ));   % or 129
cfg.elec=elec
neighbours = ft_prepare_neighbours(cfg)%, grandavg_Congruent_alert_allchan);
%% Monte carlo
cfg = [];
cfg.neighbours  = neighbours; % % cfg.neighbours  = []
%% cfg.channel          = {'all','-E57','-E100','-E114'}%% if all channels
%% hypothesis driven,P3comp--> centroparietal channels 18chann; {'E30', 'E7', 'E106', 'E37', 'E31', 'E80', 'E87','E53', 'E54','E55','E79','E86','E60','E61', 'E62','E78','E85','E105'}%
cfg.channel    = {'E30', 'E7', 'E106', 'E37', 'E31', 'E80', 'E87','E53', 'E54','E55','E79','E86','E60','E61', 'E62','E78','E85','E105'}%
cfg.latency     = [0 0.996];%all time points
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 1000;  % there are 10 subjects, so 2^10=1024 possible permutations
cfg.minnbchan        = 2;      % minimal number of neighbouring channels

Nsub = 33;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, Congruent{:}, Incongruent{:});
% save(['stat_cong_incong_alert_P3_0to996.mat'], 'stat');


%% LAYOUT--> genera layout 
% % % % % [~,ftpath] = ft_version;
% % % % % elec = ft_read_sens(strcat(ftpath, '/template/electrode/GSN-HydroCel-128.sfp' ));   % or 129
% % % % % cfg = []
% % % % % cfg.rotate=90
% % % % % cfg.center='yes'
% % % % % layout = ft_prepare_layout(cfg,Congruent{1, 1});
% % % % % ft_plot_layout(layout)%

%% make a plot%% ft_clusterplot can be used to plot the effect.
%% first adapt
%% adapt stat [0 996]
[i1,i2] = match_str(stat.label,Congruent{1,1}.label)
stat.adapt2=zeros(93,250)%250=[0 996]ms
stat.adapt2(i2',:)=stat.stat
stat.stat=stat.adapt2
%adapt label
stat.label2={'E2';'E3';'E4';'E5';'E6';'E7';'E9';'E10';'E11';'E12';'E13';'E15';'E16';'E18';'E19';'E20';'E22';'E23';'E24';'E26';'E27';'E28';'E29';'E30';'E31';'E33';'E34';'E35';'E36';'E37';'E39';'E40';'E41';'E42';'E45';'E46';'E47';'E50';'E51';'E52';'E53';'E54';'E55';'E57';'E58';'E59';'E60';'E61';'E62';'E65';'E66';'E67';'E70';'E71';'E72';'E75';'E76';'E77';'E78';'E79';'E80';'E83';'E84';'E85';'E86';'E87';'E90';'E91';'E92';'E93';'E96';'E97';'E98';'E100';'E101';'E102';'E103';'E104';'E105';'E106';'E108';'E109';'E110';'E111';'E112';'E114';'E115';'E116';'E117';'E118';'E122';'E123';'E124'}
stat.label=stat.label2
%adapt mask
stat.mask2=zeros(93,250)%64
stat.mask2(i2',:)=stat.mask
stat.mask=stat.mask2
%adapt post
stat.posclusterslabelmat2=zeros(93,250)%64
stat.posclusterslabelmat2(i2',:)=stat.posclusterslabelmat
stat.posclusterslabelmat=stat.posclusterslabelmat2
%adapt neg
stat.negclusterslabelmat2=zeros(93,250)%64
stat.negclusterslabelmat2(i2',:)=stat.negclusterslabelmat
stat.negclusterslabelmat=stat.negclusterslabelmat2
%% plot cluster window [topo*each timepoints]%% to do a video
% cfg = [];
% cfg.highlightsymbolseries = ['*','*','.','.','.'];
% layout=load(['layout_93chann.mat']);
% cfg.layout = layout.layout
% cfg.highlightcolorpos       = [1 0 0]%color of highlight marker for positive clusters (default = [0 0 0])
% cfg.highlightcolorneg       = [0 0 1]%color of highlight marker for negative clusters (default = [0 0 0])
% cfg.contournum = 0;
% cfg.alpha = 0.025;
% cfg.parameter='stat';
% cfg.zlim = [-4 4];%cfg.interpolatenan, 'yes'
% cfg.saveaspng='clusters_pos_neg_allchann_time'
% ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
% cfg.colormap=colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
% cfgtopo.interpolatenan ='no'
% cfg.interpolatenan ='no'
% ft_clusterplot(cfg, stat);%% if you put a breakpoint on line 301(ft_clusterplot). It will show the time window of the cluster.



%% plot topography of  Congruent,Incongruent, Incongruent-Congruent
cfg          = [];
layout=load(['layout_93chann.mat']);
cfg.layout = layout.layout
%% plot cluster window||t = 0.464 to 0.792 
cfg.xlim=[0.464 0.792]
cfg.zlim     = [-4 4];
cfg.colormap = parula;cfg.marker   = 'off';cfg.style    = 'fill';cfg.colorbar = 'yes';
%% 
figure;
subplot(1,3,1);ft_topoplotER(cfg,grandavg_Congruent_alert_allchan);
title('Congruent');c = colorbar;c.LineWidth = 1;c.FontSize = 18;
title(c,'\muV');% cfg.xlim = [0.25 0.3];
%%
subplot(1,3,2);ft_topoplotER(cfg,grandavg_Incongruent_alert_allchan);
title('Incongruent');c = colorbar;c.LineWidth = 1;c.FontSize = 18;
title(c,'\muV');

%% plot stat
cfg.zlim     = [-4 4];cfg.parameter='stat';cfg.interpolatenan='no'%%subplot(1,3,3);ft_topoplotER(cfg,diferencia);
subplot(1,3,3);ft_topoplotER(cfg,stat);% diff en t value
title('Congruent-Incongruent');c = colorbar;c.LineWidth = 1;c.FontSize = 14;
title(c,'t-val');
% so far it was the same as above, now change the colormap
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap

%%
saveas(gcf,['topo_alert_cong_incong_0to996.fig']) 
saveas(gcf,['topo_alert_cong_incong_0to996.png']) 
save2pdf('topo_alert_cong_incong_0to996',gcf,600);
