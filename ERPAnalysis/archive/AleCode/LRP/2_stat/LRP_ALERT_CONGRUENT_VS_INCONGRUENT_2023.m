%% stat LRP_ALERT_CONGRUENT_VS_INCONGRUENT
clear;clc; Title= 'LRP during alert trials'
%% aqui usé la matrices all_Incongruent_alert_allchan.mat como molde,
% porque no me funcionaba directamente fieldtrip.
%lines 9:39)load and prepare template to do the estadistica.
% reemplazo por zeros(93,100) y luego posiciono los respectivos
%pares de electrodos (LRPs)en sus posiciones a izquierda.(Right_Hemiscalp=zeros)
%% prepare template 
allerp_cond1 = load(['all_Incongruent_alert_allchan.mat']);
allerp_cond2 = load(['all_Incongruent_alert_allchan.mat']);
%cond 1
allerp_cond1 = allerp_cond1.all_Incongruent_alert_allchan;
%cond 2
allerp_cond2 = allerp_cond2.all_Incongruent_alert_allchan;
%% cleaning || replace with zeros
for t =1:32%% 32 participants have LRP in the alert condition
allerp_cond1{1,t}.avg=zeros(93,300);allerp_cond1{1,t}.var=zeros(93,300);
allerp_cond2{1,t}.avg=zeros(93,300);allerp_cond2{1,t}.var=zeros(93,300);
cond3{1,t}=allerp_cond1{1,t}%template1
cond4{1,t}=allerp_cond2{1,t}%template2
end
%% def chann
%% vector of indices(according to label list) of the left_hemiscalp
a=[29,25,6,42,30,24,11,10,48,41,34,23,16,52,47,40,37,33,28,22,19,15,54,51,46,39,36,32,27,21,18,14,53,50,45,38,35,31,26,20,17];
%% conditions to be compared %%
%% cond 1 //all_lrp_alert_congruent
load(['all_lrp_alert_congruent.mat']);
for w= 1:length(all_lrp)%32
cond3{1,w}.avg(a,:)=all_lrp{1,w}.avg% load C3 hemiscalp
end
%% cond2 all_lrp_alert_incongruent
load(['all_lrp_alert_incongruent.mat']);
for w= 1:length(all_lrp)%32
    cond4{1,w}.avg(a,:)=all_lrp{1,w}.avg%paste todo el hemiscalp(41electrodos)
end
for w=1:32
all_lrp_alert_congruent{1,w}=cond3{1,w};%
all_lrp_alert_incongruent{1,w}=cond4{1,w};%
end

%% neighbours
cfg = [];
cfg.method = 'triangulation' ; cfg.feedback    = 'yes'; [~,ftpath] = ft_version;
elec = ft_read_sens(strcat(ftpath, '/template/electrode/GSN-HydroCel-128.sfp' ));   % In the paper, it is described as 128.
cfg.elec=elec;
neighbours = ft_prepare_neighbours(cfg);%, grandavg_Congruent_alert_allchan);
%% avg
cfg=[]; cfg.keepindividual = 'yes';
[avg_lrp_congruent_alert] = ft_timelockgrandaverage(cfg, all_lrp_alert_congruent{:})
cfg=[]; cfg.keepindividual = 'yes';
[avg_lrp_incongruent_alert] = ft_timelockgrandaverage(cfg, all_lrp_alert_incongruent{:})
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

%% space-time cluster permutation; Monte carlo
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];
cfg.neighbours  =neighbours;%
%% all hemiscalp 41 chann:
cfg.channel    = {'E36','E31','E7','E54','E37','E30','E13','E12','E61','E53','E42','E29','E20','E67','E60','E52','E47','E41','E35','E28','E24','E19','E71','E66','E59','E51','E46','E40','E34','E27','E23','E18','E70','E65','E58','E50','E45','E39','E33','E26','E22'}
cfg.latency     = [0.120  0.260];%window of interest
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.clusteralpha     = 0.1% [cluster threshold for LRP:0.1(Koudier 2014),(Andrillon 2019)]; does not change error type 1 || with the ERPs use 0.05
cfg.clusterstatistic = 'maxsum';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 1000%
cfg.minnbchan        = 2;%
Nsub = 32;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
stat = ft_timelockstatistics(cfg, all_lrp_alert_congruent{:}, all_lrp_alert_incongruent{:});
%%
display('Om')
display('Om')
%%  [120 260]stat 
save(['stat_alert_cong_incong_LRP_120to260_hemiscalp_C3.mat'], 'stat');
%% adapt to plot[120 hasta 260]
load('stat_alert_cong_incong_LRP_120to260_hemiscalp_C3.mat');
%% adapt stat [120 260]
label_93={'E2';'E3';'E4';'E5';'E6';'E7';'E9';'E10';'E11';'E12';'E13';'E15';'E16';'E18';'E19';'E20';'E22';'E23';'E24';'E26';'E27';'E28';'E29';'E30';'E31';'E33';'E34';'E35';'E36';'E37';'E39';'E40';'E41';'E42';'E45';'E46';'E47';'E50';'E51';'E52';'E53';'E54';'E55';'E57';'E58';'E59';'E60';'E61';'E62';'E65';'E66';'E67';'E70';'E71';'E72';'E75';'E76';'E77';'E78';'E79';'E80';'E83';'E84';'E85';'E86';'E87';'E90';'E91';'E92';'E93';'E96';'E97';'E98';'E100';'E101';'E102';'E103';'E104';'E105';'E106';'E108';'E109';'E110';'E111';'E112';'E114';'E115';'E116';'E117';'E118';'E122';'E123';'E124'}
[i1,i2] = match_str(stat.label,label_93)
stat.adapt2=zeros(93,66)%
stat.adapt2(i2',31:66)=stat.stat
stat.stat=stat.adapt2
%adapt label
stat.time=[0:0.004:0.26]
%adapt label
stat.label2={'E2';'E3';'E4';'E5';'E6';'E7';'E9';'E10';'E11';'E12';'E13';'E15';'E16';'E18';'E19';'E20';'E22';'E23';'E24';'E26';'E27';'E28';'E29';'E30';'E31';'E33';'E34';'E35';'E36';'E37';'E39';'E40';'E41';'E42';'E45';'E46';'E47';'E50';'E51';'E52';'E53';'E54';'E55';'E57';'E58';'E59';'E60';'E61';'E62';'E65';'E66';'E67';'E70';'E71';'E72';'E75';'E76';'E77';'E78';'E79';'E80';'E83';'E84';'E85';'E86';'E87';'E90';'E91';'E92';'E93';'E96';'E97';'E98';'E100';'E101';'E102';'E103';'E104';'E105';'E106';'E108';'E109';'E110';'E111';'E112';'E114';'E115';'E116';'E117';'E118';'E122';'E123';'E124'}
stat.label=stat.label2
%adapt mask
stat.mask2=zeros(93,66)%64
stat.mask2(i2',31:66)=stat.mask
stat.mask=stat.mask2
%adapt post
stat.posclusterslabelmat2=zeros(93,66)%64
stat.posclusterslabelmat2(i2',31:66)=stat.posclusterslabelmat
stat.posclusterslabelmat=stat.posclusterslabelmat2
%adapt neg
stat.negclusterslabelmat2=zeros(93,66)%64
stat.negclusterslabelmat2(i2',31:66)=stat.negclusterslabelmat
stat.negclusterslabelmat=stat.negclusterslabelmat2
%%
%%
%% plot topography of  Congruent,Incongruent, Incongruent-Congruent
cfg          = [];
layout=load(['layout_93chann.mat']);
cfg.layout = layout.layout
%% plot cluster window||t = 0.464 to 0.792 
cfg.xlim=[0.120 0.260]
cfg.zlim     = [-4 4];
cfg.colormap = parula;cfg.marker   = 'off';cfg.style    = 'fill';cfg.colorbar = 'yes';
figure;
cfg.zlim     = [-4 4];cfg.parameter='stat';cfg.interpolatenan='no'%%subplot(1,3,3);ft_topoplotER(cfg,diferencia);
ft_topoplotER(cfg,stat);% diff en t value
title('Congruent-Incongruent');c = colorbar;c.LineWidth = 1;c.FontSize = 14;
title(c,'t-val');
% so far it was the same as above, now change the colormap
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap

%%
saveas(gcf,['topo_alert_cong_incong_120to260.fig']) 
saveas(gcf,['topo_alert_cong_incong_120to260.png']) 
save2pdf('topo_alert_cong_incong_120to260',gcf,600);

%% plot clusters %% all time points with the sign electrodes|| to do a video
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cfg = [];
% cfg.channel = stat.label(any(stat.mask,2));% plot elec of the cluster
% layout=load(['C:\proyectos_Cambridge\Conflict_project1\2022\SCRIPTS_USADOS_nov2022\layout_wena93ch_nov2022.mat']);
% cfg.layout = layout.layout
% cfg.highlightcolorpos       = [1 0 0]%color of highlight marker for positive clusters (default = [0 0 0])
% cfg.highlightcolorneg       = [0 0 1]%color of highlight marker for negative clusters (default = [0 0 0])
% cfg.contournum = 0;
% cfg.alpha = 0.025;
% cfg.parameter='stat';%cfg.colormap=brewermap
% cfg.zlim = [-4 4];
% cfg.saveaspng='clusters_pos_neg';
% ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
% cfg.colormap=colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
% cfgtopo.interpolatenan ='no'
% cfg.interpolatenan ='no'
% ft_clusterplot(cfg, stat);%% comenta linea 301 y saca inicio y termino de clusters
%%
%% cohensd
cfg = [];
cfg.channel = stat.label(any(stat.mask,2));%{'E36'}
cfg.latency = [min(stat.time(any(stat.mask,1))) max(stat.time(any(stat.mask,1)))]
cfg.avgoverchan = 'yes';
cfg.avgovertime = 'yes';
cfg.method = 'analytic';
cfg.statistic = 'ft_statfun_cohensd'; % see FT_STATFUN_COHENSD
Nsub = 32;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

effect_rectangle = ft_timelockstatistics(cfg,avg_lrp_congruent_alert, avg_lrp_incongruent_alert);
%save(['cohensd_LRP_120to260.mat'], 'effect_rectangle');
%% Computing the maximum effect size
cfg = [];
cfg.parameter = 'individual';
cfg.channel = stat.label(any(stat.mask,2));
cfg.latency = [min(stat.time(any(stat.mask,1))) max(stat.time(any(stat.mask,1)))]
cfg.method = 'analytic';
cfg.statistic = 'ft_statfun_cohensd'; % see FT_STATFUN_COHENSD
Nsub = 32;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
effect_all = ft_timelockstatistics(cfg,avg_lrp_congruent_alert, avg_lrp_incongruent_alert);
save(['cohensd_LRP_ALL_time_chann.mat'], 'effect_all');
% This results in a single effect size estimate for every  channel and 
%for every timepoint. We can plot a distribution of the effect over all channels:
cfg = [];
layout=load(['C:\proyectos_Cambridge\Conflict_project1\2022\SCRIPTS_USADOS_nov2022\layout_wena93ch_nov2022.mat']);
cfg.layout = layout.layout
cfg.parameter = 'cohensd';
ft_multiplotER(cfg, effect_all);
%% We can determine the channel and latency with the maximum effect like this:
[m, ind] = max(effect_all.cohensd(:));
[i, j]   = ind2sub(size(effect_all.cohensd), ind);
fprintf('maximum effect of %g on channel %s at latency %g\n', effect_all.cohensd(i,j), effect_all.label{i}, effect_all.time(j));

%% bayes factor
cfg = [];
cfg.channel = stat.label(any(stat.mask,2));
cfg.latency = [min(stat.time(any(stat.mask,1))) max(stat.time(any(stat.mask,1)))]
cfg.avgoverchan = 'yes';
cfg.avgovertime = 'yes';
cfg.method = 'analytic';
cfg.statistic = 'ft_statfun_bayesfactor' % see FT_STATFUN_COHENSD
Nsub = 32;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

effect_bayes_rectangle = ft_timelockstatistics(cfg,avg_lrp_congruent_alert, avg_lrp_incongruent_alert);
% save(['effect_bayes_rectangle_LRP_120to260_cluster_C3.mat'], 'effect_bayes_rectangle');
