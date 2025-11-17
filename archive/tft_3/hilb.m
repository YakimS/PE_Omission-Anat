

% sovs
N1 = struct(); N1.import_s = "N1"; N1.short_s = "N1"; N1.long_s = "N1";
N2 = struct(); N2.import_s = "N2"; N2.short_s = "N2"; N2.long_s = "N2";
N3 = struct(); N3.import_s = "N3"; N3.short_s = "N3"; N3.long_s = "N3";
REM = struct(); REM.import_s = "REM"; REM.short_s = "REM"; REM.long_s = "REM";
tREM = struct(); tREM.import_s = "tREM"; tREM.short_s = "tREM"; tREM.long_s = "tREM";
pREM = struct(); pREM.import_s = "pREM"; pREM.short_s = "pREM"; pREM.long_s = "pREM";
Wnig = struct(); Wnig.import_s = "wake_night"; Wnig.short_s = "wn"; Wnig.long_s = "Wake Pre";
Wmor = struct(); Wmor.import_s = "wake_morning"; Wmor.short_s = "wm"; Wmor.long_s = "Wake Post";

% [-0.1, 0.58]
Omi = struct(); Omi.import_s = "O"; Omi.short_s = "O"; Omi.long_s = "Omission";
OmiR = struct(); OmiR.import_s = "OR"; OmiR.short_s = "OR"; OmiR.long_s = "Omission Random";
OmiF = struct(); OmiF.import_s = "OF"; OmiF.short_s = "OF"; OmiF.long_s = "Omission Fixed";
intbk = struct(); intbk.import_s = "intbk"; intbk.short_s = "intbk"; intbk.long_s = "Interblock (Avg)";
intbkMid = struct(); intbkMid.import_s = "intbkMid"; intbkMid.short_s = "intbkMid"; intbkMid.long_s = "Interblock middle (Avg)"; % 0.5s - 4.5s of the interblock cut to 0.5s

%%%%%%%%
output_main_dir = "D:\OExpOut\spatioTemp";
ft_cond_input_dir = "D:\OExpOut\processed_data\ft_subSovCond";
ft_cond_output_dir = "D:\OExpOut\processed_data\ft_processed";
libs_dir = 'D:\matlab_libs';

%%%%%%

subs = {'08','09','10','11','13','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; 
subs = {'08','09','10','11'};
%%%%%%%%%%%%%%%%%%%%%%%%%%
% https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
restoredefaultpath
addpath(sprintf('%s\\fieldtrip-20230223', libs_dir))
ft_defaults
addpath(sprintf('%s\\eeglab2023.0', libs_dir))

close;
addpath(libs_dir)
addpath(genpath('C:\Users\User\OneDrive\Documents\githubProjects'))

output_dir = sprintf("%s\\all",output_main_dir);
mkdir(output_dir);

%%
sovs = {Wnig,N2,N3,REM};
examp_cond = Omi;

curr_sov_subs = sub_exclu_per_sov(subs, sovs,examp_cond);
imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir,-0.1:0.004:0.58); 
timelock = imp.get_cond_timelocked(imp,examp_cond,sovs{1});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);

wn_O_timelock = imp.timlocked.wn_O;
wn_intb_timelock = imp.get_cond_timelocked(imp,intbkMid,sovs{1});

wn_O_raw = imp.get_rawFt_cond(imp,Omi,Wnig);
wn_intb_raw = imp.get_rawFt_cond(imp,intbkMid,Wnig);
n3_intb_raw = imp.get_rawFt_cond(imp,intbkMid,N3);

% https://fieldtriptoolbox.org/faq/why_does_my_output.freq_not_match_my_cfg.foi_when_using_mtmconvol_in_ft_freqanalyis/
% freq_given = [1.81159420289855	3.62318840579710	5.43478260869565	7.24637681159420	9.05797101449275	10.8695652173913	12.6811594202899	14.4927536231884	16.3043478260870	18.1159420289855	19.9275362318841	21.7391304347826	23.5507246376812	25.3623188405797	27.1739130434783	28.9855072463768	30.7971014492754];

freqbin = 0.5:2:30.5;% 1.5:0.5:30.5; % cant be 0.5:0.5:30
freqbin_plusone = freqbin;
freqbin_plusone(end+1) = (freqbin_plusone(2)  - freqbin_plusone(1)) + freqbin_plusone(end);
freqbin_minusone = freqbin;
freqbin_minusone(end) = [];
%%
elec = 1:93;
cond1_subs_hilb_zsc = hilbert_zscore(wn_intb_raw,freqbin,elec); 
% cond2_subs_hilb_zsc = hilbert_zscore(n3_intb_raw,freqbin,elec);
cond3_subs_hilb_zsc = hilbert_zscore(wn_O_raw,freqbin,elec);

cond1_subs_hilb_zsc_chanFreqTime={}; 
cond2_subs_hilb_zsc_chanFreqTime={};
cond3_subs_hilb_zsc_chanFreqTime={};
for sub_i=1:numel(subs)
  cond1_subs_hilb_zsc_chanFreqTime{end+1} =  permute(squeeze(mean(cond1_subs_hilb_zsc{sub_i},4)),[2,1,3]);
%   cond2_subs_hilb_zsc_chanFreqTime{end+1} =  permute(squeeze(mean(cond2_subs_hilb_zsc{sub_i},4)),[2,1,3]);
  cond3_subs_hilb_zsc_chanFreqTime{end+1} =  permute(squeeze(mean(cond3_subs_hilb_zsc{sub_i},4)),[2,1,3]);
end

% cond1_subs_hilb_zsc_cz={};
% cond2_subs_hilb_zsc_cz={};
% cond3_subs_hilb_zsc_cz={};
% 
% for sub_i=1:numel(cond1_subs_hilb_zsc)
%   cond1_subs_hilb_zsc_cz{end+1} =  squeeze(mean(cond1_subs_hilb_zsc{sub_i}(:,2,:,:),4)); 
%   cond2_subs_hilb_zsc_cz{end+1} =  squeeze(mean(cond2_subs_hilb_zsc{sub_i}(:,2,:,:),4));
%   cond3_subs_hilb_zsc_cz{end+1} =  squeeze(mean(cond3_subs_hilb_zsc{sub_i}s(:,2,:,:),4));
% end

% concatenatedArray_1 = zeros(numel(cond1_subs_hilb_zsc), numel(freqbin)-1,numel(time));
% concatenatedArray_2 = zeros(numel(cond2_subs_hilb_zsc), numel(freqbin)-1,numel(time));
% concatenatedArray_3 = zeros(numel(cond3_subs_hilb_zsc), numel(freqbin)-1,numel(time));
% for i = 1:numel(cond1_subs_hilb_zsc)
%     concatenatedArray_1(i, :, :) = cond1_subs_hilb_zsc_cz{i};
%     concatenatedArray_2(i, :, :) = cond2_subs_hilb_zsc_cz{i};
%     concatenatedArray_3(i, :, :) = cond3_subs_hilb_zsc_cz{i};
% end

% cond1_cat_subs_hilb_zsc_cz = squeeze(cat(4, cond1_subs_hilb_zsc_cz{:}));
% cond2_cat_subs_hilb_zsc_cz = squeeze(cat(4, cond2_subs_hilb_zsc_cz{:}));
% cond3_cat_subs_hilb_zsc_cz = squeeze(cat(4, cond3_subs_hilb_zsc_cz{:}));

%%  over specific set of electd, avg sub. Similar to clusterElla process
channels_selection = {'E46','E47','E52','E53','E37'};%; % left-posterior {'E46','E47','52','53','37'}, mid-cent {'Cz','31','80','55','7','106'}

cond1_subfreqtime_tfr_hilb= zeros([numel(subs),numel(freqbin_minusone),170]);
cond2_subfreqtime_tfr_hilb= zeros([numel(subs),numel(freqbin_minusone),170]);
cond3_subfreqtime_tfr_hilb= zeros([numel(subs),numel(freqbin_minusone),170]);

[~, elec_ind] = ismember(channels_selection, wn_O_raw{1}.('label'));
for i=1:numel(cond1_subs_hilb_zsc_chanFreqTime)
    cond1_subfreqtime_tfr_hilb(i,:,:) = squeeze(mean(cond1_subs_hilb_zsc_chanFreqTime{i}(elec_ind,:,:),1));
%     cond2_subfreqtime_tfr_hilb(i,:,:) = squeeze(mean(cond2_subs_hilb_zsc_chanFreqTime{i}(elec_ind,:,:),1));
    cond3_subfreqtime_tfr_hilb(i,:,:) = squeeze(mean(cond3_subs_hilb_zsc_chanFreqTime{i}(elec_ind,:,:),1));
end

old_elec = wn_O_raw{1}.elec;
new_elec = old_elec;
new_elec.chanpos = old_elec.chanpos(1,:);
new_elec.chantype = old_elec.chantype(1,:);
new_elec.chanunit = old_elec.chanunit(1,:);
new_elec.elecpos = old_elec.elecpos(1,:);
new_elec.label = old_elec.label(1,:);

data1 = struct();
data2 = struct();
data1.aaa = reshape(cond1_subfreqtime_tfr_hilb, [1,size(cond1_subfreqtime_tfr_hilb)]);
data2.aaa = reshape(cond3_subfreqtime_tfr_hilb, [1,size(cond3_subfreqtime_tfr_hilb)]);
data1.elec =new_elec;
data1.elec = new_elec;
data1.label = {'E2'};
data2.label = {'E2'};
data1.dimord = 'chan_rpt_freq_time';
data2.dimord = 'chan_rpt_freq_time';
data1.fsample = 250;
data2.fsample = 250;
data1.freq = freqbin_minusone;
data2.freq = freqbin_minusone;
data1.time =wn_O_raw{1}.time{1};
data2.time= wn_O_raw{1}.time{1};

cfg = [];
cfg.parameter = 'aaa';
cfg.method = 'montecarlo';
cfg.correctm = 'cluster';
cfg.clusterstatistc = 'maxsum';
cfg.numrandomization = 1000;
cfg.clusteralpha = 0.05;
cfg.tail = 0;
cfg.statistic = 'depsamplesT';
nsubj = numel(subs);
cfg.design = zeros(2,2*nsubj);
cfg.design(1,:)=[ones(1,nsubj) ones(1,nsubj)+1];
cfg.design(2,:)=[1:nsubj 1:nsubj];
cfg.ivar = 1;
cfg.uvar = 2;

stats = ft_freqstatistics(cfg,data1,data2);

% figure; pcolor(squeeze(stats.mask+0)'); shading flat
% pos = stats.posclusterslabelmat == 1; 
% figure; pcolor(squeeze(pos+0)'); shading flat
% figure; pcolor(wn_O_raw{1}.time{1},freqbin_minusone,squeeze(pos+0)); shading flat
% neg = stats.negclusterslabelmat == 1; 
% figure; pcolor(squeeze(neg+0)'); shading flat

%plot
% figure;scatter(Power_F_cued.sub,Power_F_uncued.sub,'MarkerFaceColor', [0 0.5 0.5]);hold on
% x = [-0.5:0.5:3]; y = x;
% plot(x,y,'k')
% title('C','FontSize',16);set(gcf,'Color',[1 1 1])
% box off;xlabel('C cued','FontSize',16); ylabel('C uncued ','FontSize',16); 
% xlim([-0.1 0.5]);ylim([-0.1 0.5]);
%     
% d = (PowerU.sub - PowerP.sub);
% ds = sort(d);
% figure;bar(ds,'FaceColor',[0.15 0.35 0.5])
% set(gcf,'Color',[1 1 1])
% box off;ylim([-1.2 1.2]);

currcond_chanFreqTime_cond1 = cond1_subs_hilb_zsc_chanFreqTime;
currcond_chanFreqTime_cond3 = cond3_subs_hilb_zsc_chanFreqTime;
timefreq_meanOverSubs_cond1 = zeros([numel(freqbin_minusone),numel(time)]);
timefreq_meanOverSubs_cond3 = zeros([numel(freqbin_minusone),numel(time)]);
for sub_i=1:numel(subs)
    timefreq_meanOverSubs_cond1 = timefreq_meanOverSubs_cond1 + squeeze(mean(currcond_chanFreqTime_cond1{sub_i}(elec_ind,:,:),1));
    timefreq_meanOverSubs_cond3 = timefreq_meanOverSubs_cond3 + squeeze(mean(currcond_chanFreqTime_cond3{sub_i}(elec_ind,:,:),1));
end
timefreq_meanOverSubs_cond1 = timefreq_meanOverSubs_cond1/numel(subs);
timefreq_meanOverSubs_cond3 = timefreq_meanOverSubs_cond3/numel(subs);

mat = timefreq_meanOverSubs_cond1;
f = figure;
pcolor(time, freqbin_minusone, mat);
shading interp; 
colorbar; %caxis([-1 1 ]);

title('F uncued','FontSize',16); set(gcf,'Color',[1 1 1])
xlabel('Time (s)','FontSize',16)
ylabel('Frequencies','FontSize',16)
c = colorbar;
ylabel(c,'Power (z-score)','Fontsize',16);
set(gca,'LineWidth',1,'FontSize',14)
% set(f,'position',[270 660 990 250]);
box on;


%% over specific electd
channels_selection = {'Cz'};%{'E46','E47','E52','E53','E37'}; % left-posterior {'E46','E47','52','53','37'}, mid-cent {'Cz','31','80','55','7','106'}
load('tfr_output_example.mat')
new_cond1_tfr_hilb = wn_O_tfr_hilb(1:numel(subs));
new_cond2_tfr_hilb = wn_O_tfr_hilb(1:numel(subs));

for i=1:numel(new_cond1_tfr_hilb)
    new_cond1_tfr_hilb{i}.powspctrm = cond1_subs_hilb_zsc_chanFreqTime{i};
    new_cond2_tfr_hilb{i}.powspctrm = cond3_subs_hilb_zsc_chanFreqTime{i};

    new_cond1_tfr_hilb{i}.time = wn_O_timelock{1}.time;
    new_cond2_tfr_hilb{i}.time = wn_O_timelock{1}.time;

    new_cond1_tfr_hilb{i}.freq = freqbin_minusone;
    new_cond2_tfr_hilb{i}.freq = freqbin_minusone;

     new_cond1_tfr_hilb{i} = rmfield(new_cond1_tfr_hilb{i},'cfg');
     new_cond2_tfr_hilb{i} = rmfield(new_cond2_tfr_hilb{i},'cfg');
end

[~, elec_ind] = ismember(channels_selection, new_cond1_tfr_hilb{1}.('label'));
powspctrm_diff_avg = zeros([numel(elec_ind), size(cond1_subs_hilb_zsc_chanFreqTime{1},[2,3])]);
powspctrm_cond1_avg = zeros([numel(elec_ind), size(cond1_subs_hilb_zsc_chanFreqTime{1},[2,3])]);
powspctrm_cond2_avg = zeros([numel(elec_ind), size(cond1_subs_hilb_zsc_chanFreqTime{1},[2,3])]);
for i=1:numel(new_cond1_tfr_hilb)
    powspctrm_cond1_avg = powspctrm_cond1_avg + new_cond1_tfr_hilb{i}.powspctrm(elec_ind,:,:);
    powspctrm_cond2_avg = powspctrm_cond2_avg + new_cond2_tfr_hilb{i}.powspctrm(elec_ind,:,:);
    curr_diff = new_cond1_tfr_hilb{i}.powspctrm(elec_ind,:,:) - new_cond2_tfr_hilb{i}.powspctrm(elec_ind,:,:);
    powspctrm_diff_avg= powspctrm_diff_avg+(curr_diff);
end
powspctrm_diff_avg = powspctrm_diff_avg/ numel(new_cond1_tfr_hilb);
powspctrm_cond1_avg = powspctrm_cond1_avg/ numel(new_cond1_tfr_hilb);
powspctrm_cond2_avg = powspctrm_cond2_avg/ numel(new_cond1_tfr_hilb);

cfg = [];
cfg.channel          = channels_selection;
cfg.latency          = [-0.1 0.58];
cfg.frequency        = [freqbin(1),freqbin(end)];
% cfg.avgoverchan      = 'yes' ;      
cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT'; % cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.clusterthreshold = 'nonparametric_common';
cfg.numrandomization = 10000;
subj_num = numel(subs);
design = zeros(2,2*subj_num);
for i = 1:subj_num
  design(1,i) = i;
end
for i = 1:subj_num
  design(1,subj_num+i) = i;
end
design(2,1:subj_num)        = 1;
design(2,subj_num+1:2*subj_num) = 2;
cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg, new_cond1_tfr_hilb{:}, new_cond2_tfr_hilb{:});

%%% Change data bins
% numBins = numel(freqbin);
% [~, origDim2, ~] = size(powspctrm_diff_avg);
% new_powspctrm_diff_avg = zeros(size(stat.stat));
% elementsPerBin = origDim2 / numBins;
% for bin = 1:numBins
%     % Calculate start and end indices for the elements in the original array that will be averaged into this bin
%     startIndex = round((bin - 1) * elementsPerBin) + 1;
%     endIndex = round(bin * elementsPerBin);
%     
%     % Handle potential index overflow
%     endIndex = min(endIndex, origDim2);
%     
%     % Average the elements for this bin
%     new_powspctrm_diff_avg(1, bin, :) = mean(powspctrm_diff_avg(1, startIndex:endIndex, :), 2);
% end
% new_powspctrm_diff_avg = mean(new_powspctrm_diff_avg,1);

stat_with_data = stat;
stat_with_data.('data_contrast') = powspctrm_diff_avg;
stat_with_data.('dimord') = 'chan_freq_time';

%%% cfg data - diff, cond1, cond2
cfg              = [];
cfg.baseline     = [-0.1 0];
cfg.parameter = 'data_contrast';
cfg.maskparameter = 'mask'; 
cfg.baselinetype = 'absolute';
cfg.maskstyle    = 'outline';%'opacity', 'saturation', or 'outline'
cfg.zlim         = [-0.1 0.1];
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.title = sprintf('Amplitude difference in electode %s',strjoin(channels_selection, ' '));
figure
ft_singleplotTFR(cfg, stat_with_data);

% cond1
stat_with_data.('data_contrast') = powspctrm_cond1_avg;
cfg.title = sprintf('Amplitude cond1 in electode %s',strjoin(channels_selection, ' '));
cfg.zlim         = [];
figure
ft_singleplotTFR(cfg, stat_with_data);

% cond2
stat_with_data.('data_contrast') = powspctrm_cond2_avg;
cfg.title = sprintf('Amplitude cond2 in electode %s',strjoin(channels_selection, ' '));
cfg.zlim         = [];
figure
ft_singleplotTFR(cfg, stat_with_data);

%%% cfg stat
cfg              = [];
cfg.baseline     = [-0.1 0];
cfg.parameter = 'stat';
cfg.maskparameter = 'mask'; 
cfg.baselinetype = 'absolute';
cfg.maskstyle    = 'outline';%'opacity', 'saturation', or 'outline'
cfg.zlim         = [-5 5];
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.title = sprintf('Statistic in electode %s',strjoin(channels_selection, ' '));
figure
ft_singleplotTFR(cfg, stat_with_data);

%% over specific freqband
load('tfr_output_example.mat')
new_cond1_tfr_hilb = wn_O_tfr_hilb;
new_cond2_tfr_hilb = wn_O_tfr_hilb;
for i=1:numel(new_cond1_tfr_hilb)
    new_cond1_tfr_hilb{i}.powspctrm = cond1_subs_hilb_zsc_chanFreqTime{i};
    new_cond2_tfr_hilb{i}.powspctrm = cond3_subs_hilb_zsc_chanFreqTime{i};

    new_cond1_tfr_hilb{i}.time = wn_O_timelock{1}.time;
    new_cond2_tfr_hilb{i}.time = wn_O_timelock{1}.time;

     new_cond1_tfr_hilb{i} = rmfield(new_cond1_tfr_hilb{i},'cfg');
     new_cond2_tfr_hilb{i} = rmfield(new_cond2_tfr_hilb{i},'cfg');
end

cfg = [];
% cfg.channel          = {'EEG'};
cfg.latency          = [0 0.58];
cfg.frequency        = [13 30];
cfg.avgoverfreq = 'yes' ;
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 300;
cfg.neighbours  = imp.get_neighbours(imp); % defined as above

subj_num = numel(subs);
design = zeros(2,2*subj_num);
for i = 1:subj_num
  design(1,i) = i;
end
for i = 1:subj_num
  design(1,subj_num+i) = i;
end
design(2,1:subj_num)        = 1;
design(2,subj_num+1:2*subj_num) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg, new_cond1_tfr_hilb{:}, new_cond2_tfr_hilb{:}); % procudes "out of memory" if too many freq bins
%%
% T-statistic of the difference 
cfg = [];
cfg.alpha  = 0.025;
cfg.parameter = 'stat';
cfg.zlim   = [-5 5];
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.toi = -0.1:0.04:0.58;
cfg.subplotsize = [4,4]; 
cfg.highlightsizeseries     = [4 4 4 4 4];
cfg.style              = 'straight';      %     colormap only. Defualt - colormap and conture lines
cfg.marker             = 'off';
ft_clusterplot(cfg, stat);

%%
cfg = [];
cfg.xlim  = -0.1:0.04:0.448;
% cfg.ylim = [25 30];
cfg.parameter = 'stat'; 
cfg.zlim = [-5 5];
cfg.comment  ='xlim';
cfg.commentpos = 'middletop';
cfg.colormap = 'parula';
cfg.highlightsizeseries     = [4 4 4 4 4];
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.style              = 'straight';      %     colormap only. Defualt - colormap and conture lines
cfg.marker             = 'off';
ft_topoplotTFR(cfg, stat);
%%
% wn_O_tfr_hilb, new_cond1_tfr_hilb
cfg                 = [];
cfg.interactive     = 'yes';
cfg.showoutline     = 'yes';
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.baseline        = [-0.1 0];
% cfg.baselinetype    = 'relchange';
% cfg.zlim            = 'maxabs';
ft_multiplotTFR(cfg, new_cond1_tfr_hilb{22});

%%

function subs_hilbert=hilbert_zscore(cond_raw_ft,freqbin,elec)
    subs_hilbert = {};
    nbin = length(freqbin)-1;
    time_dim_num = 3;
    for sub_i=1:numel(cond_raw_ft)
        fprintf("Running sub: %d out of %d\n", sub_i,numel(cond_raw_ft));
        subs_cond = cond_raw_ft{sub_i};
        hilbdata = zeros(nbin,numel(elec),numel(subs_cond.time{1}),numel(subs_cond.trial));
        for f = 1:nbin
            d = designfilt('bandpassiir', 'FilterOrder', 4, ...
               'HalfPowerFrequency1', freqbin(f), 'HalfPowerFrequency2', freqbin(f+1), ...
               'SampleRate', 250);
            for trial_i =1: numel(subs_cond.trial) 
%                 [filt, B, A] = ft_preproc_bandpassfilter(subs_cond.trial{trial_i}(elec,:), 250, [freqbin(f),freqbin(f+1)]) ; %filtEEG = pop_eegfiltnew(EEG,freqbin(f),freqbin(f+1));
                dat = subs_cond.trial{trial_i}(elec,:);
                filt = filtfilt(d, dat')';
                hilbdata(f,:,:,trial_i) =filt;
            end
            for trial_i =1: numel(subs_cond.trial) 
                hilbdata(f,:,:,trial_i) = hilbert(squeeze(hilbdata(f,:,:,trial_i))')';
            end
        end
        hilbdata = abs(hilbdata);
        zscorehil = zscore(hilbdata,0,time_dim_num);
        subs_hilbert{end+1} = zscorehil;
    end
end

 function curr_sov_subs = sub_exclu_per_sov(subs, sovs,cond)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        if strcmp(sovs{sov_i}.import_s, 'wake_night')
        elseif strcmp(sovs{sov_i}.import_s, 'N1')
        elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
            curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
        elseif strcmp(sovs{sov_i}.import_s, 'N2')
        elseif strcmp(sovs{sov_i}.import_s, 'N3')
        elseif contains(sovs{sov_i}.import_s, 'REM')
        elseif strcmp(sovs{sov_i}.import_s, 'tREM')
            curr_sov_subs(ismember(curr_sov_subs, {'36'})) = [];
        end
    end
end