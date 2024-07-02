% analysis order/pipleline
%. 1 
% take the raw EEG mat (all trials x time (60s = 30 before and 30 after tone onset)
CreateEEGmat_ToneOdor 
% 2. Convert mat foles to set files
addpath('/work/imagingK/NCSL/matlab/eeglab13_5_4b');
addpath(genpath('/work/imagingK/NCSL/matlab/Neural correlates of sleep-learning'))
mat2setToneOdor2elec('NREM_all','tone','EEGL','EEGR')

% 3. Hilbert, Z-score, ERP
batchrunToneOdor('NREM_tone')

% 5. Average the two electrode per trial and save as elec = 3 (1 - EEGL, 2 - EEGR, 3 - avg EEGl+EEGR)
average2eletrial('NREM_tone_exc')

% 7. Combine all subjects 
%  time-freq 
submethod = 0; % 0 == subjects, 1 == supersubject
% experiment 1 and 2 NREM across all training trials
pathtofiles = '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec';
% CSp
catfiles(pathtofiles,'NREM_PleasantTone_s','condition2','NREM_PleasantTone_stim2',[4 4], submethod)
catfiles(pathtofiles,'NREM_PleasantTone_s','condition','NREM_PleasantTone_base2',[4 4], submethod)
% CSu
catfiles(pathtofiles,'NREM_UnpleasantTone_s','condition2','NREM_UnpleasantTone_stim2',[4 4], submethod)
catfiles(pathtofiles,'NREM_UnpleasantTone_s','condition','NREM_UnpleasantTone_base2',[4 4], submethod)
% CS
catfiles(pathtofiles,'NREM_tone_s','condition2','NREM_tone_stim2',[4 4], submethod)
catfiles(pathtofiles,'NREM_tone_s','condition','NREM_tone_base2',[4 4], submethod)

% Combine all subjects  ERP 
submethod = 0; % 0 == subjects, 1 == supersubject
pathtofiles = '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/ERP/2elec';

catfilesERP(pathtofiles,'NREM_PleasantTone_s','ERPdata','NREM_PleasantTone_stimERP',[3 3 ], submethod)
catfilesERP(pathtofiles,'NREM_UnpleasantTone_s','ERPdata','NREM_UnpleasantTone_stimERP',[3 3 ], submethod)
catfilesERP(pathtofiles,'NREM_tone_s','ERPdata','NREM_tone_stimERP',[3 3 ], submethod)

% 8. Cluster analysis
addpath('/work/imagingK/NCSL/matlab/fieldtrip-20121231')
srate = 1000;
f1 = 0.5; f2 = 80;
folder = 'subjects/';
loc = '/2elec/';
elec = 3;

% NREM  Tone vs. Baseline 
clusterToneOdor('NREM_tone_stim2','NREM_tone_base2','condition',[1 5],'intra',[f1 f2],4.501*srate:srate*9.5,1:5*srate,'base',folder,'nonparam',loc,elec)
% NREM  Pleasant Tone vs. Baseline 
clusterToneOdor('NREM_PleasantTone_stim2','NREM_PleasantTone_base2','condition',[1 5],'intra',[f1 f2],4.501*srate:srate*9.5,1:5*srate,'base',folder,'nonparam',loc,elec)
% NREM  Unleasant Tone vs. Baseline 
clusterToneOdor('NREM_UnpleasantTone_stim2','NREM_UnpleasantTone_base2','condition',[1 5],'intra',[f1 f2],4.501*srate:srate*9.5,1:5*srate,'base',folder,'nonparam',loc,elec)


%plot cluster
% CS
clusterploterToneOdor('NREM_tone_base2','NREM_tone_stim2','NREM_tone_stim2_vs_NREM_tone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat', 4501:9500,1:5000,'base',1,folder,loc)
% CSP
clusterploterToneOdor('NREM_PleasantTone_base2','NREM_PleasantTone_stim2','NREM_PleasantTone_stim2_vs_NREM_PleasantTone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat', 4501:9500,1:5000,'base',1,folder,loc)
%CSu
clusterploterToneOdor('NREM_UnpleasantTone_base2','NREM_UnpleasantTone_stim2','NREM_UnpleasantTone_stim2_vs_NREM_UnpleasantTone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat', 4501:9500,1:5000,'base',1,folder,loc)

% 9. Power in cluster 
% CSp/Pleasant
loc = '/2elec/';
saveClusters('NREM_PleasantTone_stim2_vs_NREM_PleasantTone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat',1, 0,loc)
cd '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/results/subjects'
load('cluster_NREM_PleasantTone_stim2_vs_NREM_PleasantTone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat')
% all
PowerInCluster('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/','NREM_PleasantTone_s' ,all_clusters,'NREM_PleasantTone_Power_cluster',1:80) % cluster 
% delta
PowerInCluster('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/','NREM_PleasantTone_s' ,all_clusters,'NREM_PleasantTone_Power_cluster',1:7) 
% theta
PowerInCluster('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/','NREM_PleasantTone_s' ,all_clusters,'NREM_PleasantTone_Power_cluster',8:15) 
% sigma
PowerInCluster('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/','NREM_PleasantTone_s' ,all_clusters,'NREM_PleasantTone_Power_cluster',22:31)  

%% 10. Power in delta (for bar plots)
% % all 4 sec
PowerInRectangular('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/','NREM_PleasantTone_s' ,1:4000,1:7,'NREM_PleasantTone',1000,elec) 
PowerInRectangular('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/','NREM_UnpleasantTone_s' ,1:4000,1:7,'NREM_UnpleasantTone',1000,elec)  
% 
%find time of peak activity in tone
% load('NREM_tone_envelope_in_freq_0.5_4.mat')
% tempERP = squeeze(nanmean(ERPdata(3,:,:),3));
% [~,ind] = max(tempERP);
% ind = ind -10000;
% t_win = ind-25:ind+25;

% learning phase
t_win = 77:2320;
PowerInRectangular('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/learning_part','NREM_tone_s' ,t_win,1:7,'NREM_tone_L',1000,elec)  

% zscore5sc
% CSp
PowerInRectangular('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/stabilization_part/zscore5sec','NREM_PleasantTone_s' ,t_win,1:7,'NREM_PleasantTone_Sb',1000,elec) 
% CSu
PowerInRectangular('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/stabilization_part/zscore5sec','NREM_UnpleasantTone_s' ,t_win,1:7,'NREM_UnpleasantTone_Sb',1000,elec)  
% 
%% 11. hilbert in delta 
PowerInTime('/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec' ,'NREM_tone_s',1:7,'NREM_tone',elec)
clusterToneOdorERP('NREM_tone_envelope_in_freq_0.5_4.mat','NREM_tone_envelope_in_freq_0.5_4.mat','ERPdata',[0 3],'intra',6.5*srate:9.5*srate,10*srate:13*srate,'twostimDep',folder,'nonparam',loc,elec) % 

%% %%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%
% plot base and stim together NREM
addpath '/work/imagingK/NCSL/matlab'
cd '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/results/subjects'
load('MatForFigures.mat')
%t = -1000:5000; 
t = -1:1/1000:5; 
time = 9000:15000; 
y = 0.5:0.5:40;
basetime = 1001;
baseline = zeros(length(y),basetime);
window = zeros(80,5000);

%%  plot spectrograms

%%%%%%%  tone %%%%%%%
mat = [NREM_tone_base  NREM_tone_stim];
load('NREM_tone_stim2_vs_NREM_tone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat')

%%%%%%% pleasant tone %%%%%%%
% all pleasant tone
mat = [NREM_PleasantTone_base  NREM_PleasantTone_stim];
filepath = '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/results/subjects/';
load([filepath 'NREM_PleasantTone_stim2_vs_NREM_PleasantTone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat'])

%%%%%%% unpleasant tone %%%%%%%
all unpleasant tone
mat = [NREM_UnpleasantTone_base  NREM_UnpleasantTone_stim];
filepath = '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/hilbert/zscore/2elec/results/subjects/';
load([filepath 'NREM_UnpleasantTone_stim2_vs_NREM_UnpleasantTone_base2_intra2_clustperm_nonparam_1  5_0.5           80_3.mat'])

% plot
fig = figure;
pcolor(t, y, mat(1:y(end)*2,time));shading interp; colorbar; 
set(gca,'LineWidth',1,'FontSize',14)
set(gcf,'Color',[1 1 1])
xlabel('Time (ms)','FontSize',16)
ylabel('Frequency (Hz)','FontSize',16)
c = colorbar; caxis([-0.5 0.5]); 
ylabel(c,'Power (z-score)','Fontsize',16);
set(c,'YTick', -0.5:0.5:0.5,'Fontsize',14);
colormap('redblue')
hold on
clear maskz
maskz(1:size(stats.mask,2),1:size(stats.mask,3)) = squeeze(stats.mask);maskz = maskz';
maskz = [baseline maskz];
contour(t, y, maskz(1:y(end)*2,:),1,'LineColor', [0.1, 0.1, 0.1],'LineWidth',2)
set(c,'YTick', -1:0.5:1);
onset = zeros(80,5000);
onset(1:80,1) = ones; % onset
onset = [baseline onset];contour(t, y, onset,1,'LineColor', [0.1, 0.1, 0.1],'LineStyle','--','LineWidth',2)
%fig.Units = 'centimeters';
set(fig, 'PaperPositionMode','auto')
set(fig,'position',[270 660 300 200]);box on;
saveas(fig, 'test1.png')

% window = zeros(80,5000);
% %window(1:7,1:4000) = ones; % delta 
% window(22:31,750:1450) = ones; % sigma
% window = [baseline window];contour(t, y, window,1,'LineColor', [0.5, 0.5, 0.5],'LineStyle','-')
% set(f,'position',[270 660 990 250]);box on;

%% learning phase plot delta hilbert
addpath '/work/imagingK/NCSL/matlab'
srate = 1000;
folder = 'subjects/';
loc = '/2elec/';
elec = 3;

cd '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/ERP/2elec/results/subjects'
load('NREM_PleasantTone_Lb_envelope_in_freq_0.5_4.mat')
PowerEnv_P = ERPdata;
PowerEnv_P = squeeze(PowerEnv_P(elec,:,:));
load('NREM_UnpleasantTone_Lb_envelope_in_freq_0.5_4.mat')
PowerEnv_U = ERPdata;
PowerEnv_U = squeeze(PowerEnv_U(elec,:,:));

lineProps.col{2} = [180/255 0/255 0/255]; % B40000
lineProps.col{1} = [255/255 102/255 102/255]; % FF6666
clear x;clear y;
t = 9000:15000;
time = -1000:5000;
x(1,:) = nanmean(PowerEnv_P(t,:),2);
x(2,:) = nanmean(PowerEnv_U(t,:),2);
y(1,:) = nanstd(PowerEnv_P(t,:)')./sqrt(sum(~isnan(PowerEnv_P(1,:))));
y(2,:) = nanstd(PowerEnv_U(t,:)')./sqrt(sum(~isnan(PowerEnv_U(1,:))));
figure;
H = mseb(time,x,y,lineProps);hold on
set(gcf,'Color',[1 1 1])
box off;xlabel('Time (s)','FontSize',16); ylabel('Delta power (z-score)','FontSize',16); 
ylim([-0.5 2.5]);legend('Tone paired w Pleasant','Tone paired w Unpleasant');
% plot sig difference betweeb P and U%load('NREM_PleasantTone_L_envelope_in_freq_0.5_4.mat_vs_NREM_UnpleasantTone_L_envelope_in_freq_0.5_4.mat_intra2_clustperm_nonparam0.012       2.353_e3.mat')
load('NREM_PleasantTone_Lb_envelope_in_freq_0.5_4.mat_vs_NREM_UnpleasantTone_Lb_envelope_in_freq_0.5_4.mat_intra2_clustperm_nonparam0.077        2.32_e3.mat')
start_point = 77;
neg = stats.negclusterslabelmat == 1; 
Line = find(squeeze(neg+0)')+start_point; 
time = (Line(1)):(Line(end));
plot(time, ones(length(Line))*-0.1,'k','Linewidth',3);
neg = stats.negclusterslabelmat == 2; 
Line = find(squeeze(neg+0)'); 
time = (Line(1)):(Line(end));
plot(time, ones(length(Line))*-0.1,'k','Linewidth',3);
% plot sig difference betweeb P and baseline
load('NREM_PleasantTone_L_envelope_in_freq_0.5_4.mat_vs_NREM_PleasantTone_L_envelope_in_freq_0.5_4.mat_intra2_clustperm_nonparam0  5_e3.mat')
mask = stats.mask == 1; 
LineP = find(squeeze(mask+0)'); 
time2 = (LineP(1)):(LineP(end));
plot(time2, ones(length(LineP))*-0.15,'k','Linewidth',3, 'color', [255/255 102/255 102/255]);
% plot sig difference betweeb P and baseline
load('NREM_UnpleasantTone_L_envelope_in_freq_0.5_4.mat_vs_NREM_UnpleasantTone_L_envelope_in_freq_0.5_4.mat_intra2_clustperm_nonparam0  5_e3.mat')
mask = stats.mask == 1; 
LineU = find(squeeze(mask+0)'); 
time2 = (LineU(1)):(LineU(end));
plot(time2, ones(length(LineU))*-0.2,'k','Linewidth',3, 'color', [180/255 0/255 0/255]);

set(gca,'XTick',[-1000 0 1000 2000 3000 4000 5000],'Fontsize',14)
set(gca,'XTickLabel',{'-1','0','1','2','3','4', '5'})

%% 
addpath '/work/imagingK/NCSL/matlab'
srate = 1000;
folder = 'subjects/';
loc = '/2elec/';
elec = 3;

cd '/work/imagingK/NCSL/Neural correlates of Sleep-Learning/analysis/tone odor conditioning/ERP/2elec/results/subjects'
load('NREM_tone_envelope_in_freq_4_7.mat')
PowerEnv = ERPdata;
PowerEnv = squeeze(PowerEnv(elec,:,:));

lineProps.col{2} = [1/255 102/255 94/255]; 
lineProps.col{1} = [90/255 180/255 172/255]; 
clear x;clear y;
t = 9000:15000;
time = -1000:5000;
x(1,:) = nanmean(PowerEnv(t,:),2);
y(1,:) = nanstd(PowerEnv(t,:)')./sqrt(sum(~isnan(PowerEnv(1,:))));
figure;
H = mseb(time,x,y,lineProps);hold on
set(gcf,'Color',[1 1 1])
box off;xlabel('Time (s)','FontSize',16); ylabel('Theta power (z-score)','FontSize',16); 
ylim([-0.5 1.5]);legend('Tone paired w Pleasant','Tone paired w Unpleasant');
% plot sig difference betweeb P and U
load('NREM_tone_envelope_in_freq_4_7.mat_vs_NREM_tone_envelope_in_freq_4_7.mat_intra2_clustperm_nonparam0  5_e3.mat')
start_point = 0;
mask = stats.mask == 1; 
Line = find(squeeze(mask+0)')+start_point; 
if ~isempty(Line)
time2 = (Line(1)):(Line(end));
plot(time2, ones(length(Line))*-0.05,'k','Linewidth',3);
end

set(gca,'XTick',[-1000 0 1000 2000 3000 4000 5000],'Fontsize',14)
set(gca,'XTickLabel',{'-1','0','1','2','3','4', '5'})