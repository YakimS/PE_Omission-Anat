
% sovs
N1 = defineExpStruct("N1", "N1", "N1", false);
N2 = defineExpStruct("N2", "N2", "N2", false);
N3 = defineExpStruct("N3", "N3", "N3", false);
REM = defineExpStruct("REM", "REM", "REM", false);
tREM = defineExpStruct("tREM", "tREM", "tREM", false);
pREM = defineExpStruct("pREM", "pREM", "pREM", false);
Wnig = defineExpStruct("wake_night", "wn", "Wake Pre", false);
Wmor = defineExpStruct("wake_morning", "wm", "Wake Post", false);

% [-0.1, 1.16]
AOmi = defineExpStruct("AO", "AO", "Omission", false);
AOmiR = defineExpStruct("AOR", "AOR", "Unpredictable Omission", false);
AOmiF = defineExpStruct("AOF", "AOF", "Predictable Omission", false);
intblksmpAO = defineExpStruct("intblksmpAO", "intblksmpAO", "Baseline", true);
intblksmpAOR = defineExpStruct("intblksmpAOR", "intblksmpAOR", "Baseline", true);
intblksmpAOF = defineExpStruct("intblksmpAOF", "intblksmpAOF", "Baseline", true);

noN2EventsAO = defineExpStruct("noN2EventsAO", "noN2EventsAO", "Omission w/o ss&kc", false);
noN2EventsAOF = defineExpStruct("noN2EventsAOF", "noN2EventsAOF", "Omission fixed w/o ss&kc", false);
noN2EventsAOR = defineExpStruct("noN2EventsAOR", "noN2EventsAOR", "Omission random w/o ss&kc", false);
noN2KcompAO = defineExpStruct("noN2KcompAO", "noN2KcompAO", "Omission w/o kc", false);
noN2KcompAOF = defineExpStruct("noN2KcompAOF", "noN2KcompAOF", "Predictable Omission w/o kc", false);
noN2KcompAOR = defineExpStruct("noN2KcompAOR", "noN2KcompAOR", "Unpredictable Omission w/o kc", false);
noN2SsAO = defineExpStruct("noN2SsAO", "noN2SsAO", "Omission w/o ss", false);

LastOmiF18 = defineExpStruct("LastOF18", "LastOF18", "Last Omission Fixed", false);
LastOmiR18 =  defineExpStruct("LastOR18", "LastOR18", "Last Omission Random", false);

% [-1.1, 2.16]
AOmiftr = defineExpStruct("AOtfr", "AOtfr", "Omission", false);
AOmiRtfr = defineExpStruct("AOFtfr", "AOFtfr", "Unpredictable Omission", false);
AOmiFtfr = defineExpStruct("AORtfr", "AORtfr", "Predictable Omission", false);
A1stTtfr = defineExpStruct("A1stT", "A1stT", "Trial 1st Adaptor-tone", false);
A5thTtfr = defineExpStruct("A5thT", "A5thT", "Trial 5th Adaptor-Tone", false);

% [1.5, 2.5]
T5thTfr = defineExpStruct("T5thTfr", "T5thTfr", "1st trial tone", false);
T1stTfr = defineExpStruct("T1stTfr", "T1stTfr", "5th trial tone", false);

%%%%%%%%
output_main_dir = "D:\OExpOut\spatioTemp";
ft_cond_input_dir = "D:\OExpOut\processed_data\ft_subSovCond";
ft_cond_output_dir = "D:\OExpOut\processed_data\ft_processed";
libs_dir = 'D:\matlab_libs';

%%%%%%

subs = {'08','09','10','11','13','15','16','17','19','20','21','24','25','26','28','30','31','33','34','35','36','38'}; 
subs = {'08','09','10'};
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
sovs = {Wnig};
examp_cond = T5thTfr;
time = -1.5:0.004:2.5;
test_latency = [-1.5, 2.5];

imp = ft_importer(subs,ft_cond_input_dir,ft_cond_output_dir,time); 
timelock = imp.get_cond_timelocked(imp,examp_cond,sovs{1});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);

wn_T5thTfr_raw = imp.get_rawFt_cond(imp,T5thTfr,Wnig);
wn_T1stTfr_raw = imp.get_rawFt_cond(imp,T1stTfr,Wnig);

%%

sovs = {Wnig};
examp_cond = AOmiRtfr;
time = -1.6:0.004:2.66;
test_latency = [0, 1.16];

imp = ft_importer(subs,ft_cond_input_dir,ft_cond_output_dir,time); 
timelock = imp.get_cond_timelocked(imp,examp_cond,sovs{1});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);

% wn_O_timelock = imp.timlocked.wn_O;
% wn_intb_timelock = imp.get_cond_timelocked(imp,intbkMid,sovs{1});

wn_AOmiRtfr_raw = imp.get_rawFt_cond(imp,AOmiRtfr,Wnig);
wn_AOmiFtfr_raw = imp.get_rawFt_cond(imp,AOmiFtfr,Wnig);
wn_A1stTtfr_raw = imp.get_rawFt_cond(imp,A1stTtfr,Wnig);
wn_A5thTtfr_raw = imp.get_rawFt_cond(imp,A5thTtfr,Wnig);

%%
sovs = {Wnig,N2,N3,REM};
examp_cond = AOmi;
time = -0.1:0.004:1.16;

imp = ft_importer(subs,ft_cond_input_dir,ft_cond_output_dir,time); 
timelock = imp.get_cond_timelocked(imp,examp_cond,sovs{1});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);

% wn_O_timelock = imp.timlocked.wn_O;
% wn_intb_timelock = imp.get_cond_timelocked(imp,intbkMid,sovs{1});

wn_O_raw = imp.get_rawFt_cond(imp,AOmi,Wnig);
wn_intb_raw = imp.get_rawFt_cond(imp,intblksmpAO,Wnig);
n3_intb_raw = imp.get_rawFt_cond(imp,intblksmpAO,N3);
%%
sovs = {Wnig,N2,N3,REM};
examp_cond = LastOmiR18;
time = -12:0.004:6;

imp = ft_importer(subs,ft_cond_input_dir,ft_cond_output_dir,time); 
timelock = imp.get_cond_timelocked(imp,examp_cond,sovs{1});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);

wn_lastOF18_raw = imp.get_rawFt_cond(imp,LastOmiF18,Wnig);
wn_lastOR18_raw = imp.get_rawFt_cond(imp,LastOmiR18,Wnig);

%% Multitaper
cycles_per_timewin = 3;
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 0.5:0.5:30;                         % analysis 0.5 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = cycles_per_timewin ./ cfg.foi;                      % Window length of 5 cycles per frequency
cfg.toi          = 'all';
cfg.polyremoval  = 0;

% [wn_lastOF18_TFRhann_allsubs_mean,wn_lastOF18_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_lastOF18_raw, cfg);
% [wn_lastOR18_TFRhann_allsubs_mean,wn_lastOR18_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_lastOR18_raw, cfg);

% [wn_AOmiRtfr_TFRhann_allsubs_mean,wn_AOmiRtfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_AOmiRtfr_raw, cfg);
% [wn_AOmiFtfr_TFRhann_allsubs_mean,wn_AOmiFtfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_AOmiFtfr_raw, cfg);

% [wn_A1stTtfr_TFRhann_allsubs_mean,wn_A1stTtfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_A1stTtfr_raw, cfg);
% [wn_A5thTtfr_TFRhann_allsubs_mean,wn_A5thTtfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_A5thTtfr_raw, cfg);

[wn_T1stTfr_TFRhann_allsubs_mean,wn_T1stTfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_T5thTfr_raw, cfg);
[wn_T5thTfr_TFRhann_allsubs_mean,wn_T5thTfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_T1stTfr_raw, cfg);


% [wn_O_TFRhann_allsubs_mean,wn_O_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_O_raw, cfg);
% [wn_intbk_TFRhann_allsubs_mean,wn_intbk_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_intb_raw, cfg);

%%  Hilbert   
cfg              = [];
cfg.method      = 'hilbert';
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.width       = 0.4;
% cfg.edgartnan        = 'yes'; % 'no' (default) or 'yes', replace filter edges with nans, works only for finite impulse response (FIR) filters, and requires a user specification of the filter order
cfg.foi          = 0.5:0.5:30;     
cfg.toi          = 'all';       
cfg.polyremoval  = 0;
% cfg.bpfiltord        = ones(numel(cfg.foi),1)*6;%(optional) scalar, or vector 1 x numfoi;
% cfg.pad='nextpow2';

cfg.bpfilttype = 'fir'; % otherwise, it uses IIR filter, which is suboptimal and create imbalance in the parameter space that cuases errors and warnings https://youtu.be/jy7IxIXUAJk?si=KVfHc-WAHa151SDx&t=1003
cfg.trials  = 1:10;

% [wn_A1stTtfr_TFRhann_allsubs_mean,wn_A1stTtfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_A1stTtfr_raw, cfg);
% [wn_A5thTtfr_TFRhann_allsubs_mean,wn_A5thTtfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_A5thTtfr_raw, cfg);

[wn_T1stTfr_TFRhann_allsubs_mean,wn_T1stTfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_T5thTfr_raw, cfg);
[wn_T5thTfr_TFRhann_allsubs_mean,wn_T5thTfr_TFRhann_allsubs] = get_TFRhann_allsubs(subs, wn_T1stTfr_raw, cfg);


%%
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:0.8:30;                         % analysis 2 to 30 Hz in steps of 1 Hz
cfg.toi          = 'all';
cfg.t_ftimwin    = 5 ./ cfg.foi;                      % Window length of 4 cycles per frequency
cfg.polyremoval  = 0;

wn_O_TFRhann_curr_sub = ft_freqanalysis(cfg, wn_O_raw{1});
wn_intb_TFRhann_curr_sub = ft_freqanalysis(cfg, wn_intb_raw{1});


%%
% cond1_allsubs = wn_lastOF18_TFRhann_allsubs;
% cond2_allsubs = wn_lastOR18_TFRhann_allsubs;

% cond1_allsubs = wn_O_TFRhann_allsubs;
% cond2_allsubs = wn_intbk_TFRhann_allsubs;
% 
% cond1_allsubs = wn_AOmiFtfr_TFRhann_allsubs;
% cond2_allsubs = wn_AOmiRtfr_TFRhann_allsubs;

% cond1_allsubs = wn_A1stTtfr_TFRhann_allsubs;
% cond2_allsubs = wn_A5thTtfr_TFRhann_allsubs;

cond1_allsubs = wn_T1stTfr_TFRhann_allsubs;
cond2_allsubs = wn_T5thTfr_TFRhann_allsubs;
test_latency = [-0.5,0.5];


channels_selection =  {'Cz','E31','E80','E55','E7','E106'};%mid-cent%{'E46','E47','E52','E53','E37'}; % left-posterior %{'Cz'};%{'E46','E47','52','53','37'}, 
[~, elec_ind] = ismember(channels_selection, cond1_allsubs{1}.('label'));
powspctrm_diff_avg = zeros([numel(elec_ind), size(cond1_allsubs{1}.powspctrm,[2,3])]);
powspctrm_cond1_avg = zeros([numel(elec_ind), size(cond1_allsubs{1}.powspctrm,[2,3])]);
powspctrm_cond2_avg = zeros([numel(elec_ind), size(cond1_allsubs{1}.powspctrm,[2,3])]);
for i=1:numel(cond1_allsubs)
    powspctrm_cond1_avg = powspctrm_cond1_avg + cond1_allsubs{i}.powspctrm(elec_ind,:,:);
    powspctrm_cond2_avg = powspctrm_cond2_avg + cond2_allsubs{i}.powspctrm(elec_ind,:,:);
    curr_diff = cond1_allsubs{i}.powspctrm(elec_ind,:,:) - cond2_allsubs{i}.powspctrm(elec_ind,:,:);
    powspctrm_diff_avg= powspctrm_diff_avg + (curr_diff);
end
powspctrm_diff_avg = powspctrm_diff_avg/ numel(cond1_allsubs);
powspctrm_cond1_avg = powspctrm_cond1_avg/ numel(cond1_allsubs);
powspctrm_cond2_avg = powspctrm_cond2_avg/ numel(cond1_allsubs);

cfg = [];
cfg.channel          = channels_selection;
cfg.latency          = test_latency;
cfg.frequency        = [0.5,30];
% cfg.avgoverchan      = 'yes' ;      
cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT'; % cfg.statistic = 'ft_statfun_depsamplesT';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.neighbours       = imp.get_neighbours(imp);
cfg.alpha            = 0.025;
% cfg.clusterthreshold = 'nonparametric_common';
cfg.correctm = 'cluster';
cfg.numrandomization = 200;
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

[stat] = ft_freqstatistics(cfg, cond1_allsubs{:}, cond2_allsubs{:});

%%
plot_struct = rmfield(cond1_allsubs{1}, {'powspctrm','cfg'});
plot_struct.('data_contrast') = powspctrm_diff_avg;
plot_struct.('label') = stat.label;
mask = zeros(size(powspctrm_diff_avg));
test_latency_index_1 = find(plot_struct.time == test_latency(1));
test_latency_index_2 = find(plot_struct.time == test_latency(2));
mask(:,:,test_latency_index_1:test_latency_index_2) = stat.mask;
plot_struct.('mask') = logical(mask);

cfg              = [];
cfg.parameter = 'data_contrast';
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.maskparameter = 'mask'; 
cfg.maskstyle    = 'outline'; %'opacity', 'saturation', or 'outline'
ft_singleplotTFR(cfg, plot_struct);
%%
stat_with_data = stat;
stat_with_data.('data_contrast') = powspctrm_diff_avg;
stat_with_data.('dimord') = 'chan_freq_time';


fig = figure;
%%% cfg data - diff, cond1, cond2
cfg              = [];
cfg.baseline     =  [cond1_allsubs{1}.('time')(1) cond1_allsubs{1}.('time')(end)];
cfg.baselinetype = 'absolute';
cfg.parameter = 'data_contrast';
cfg.maskparameter = 'mask'; 
cfg.maskstyle    = 'outline'; %'opacity', 'saturation', or 'outline'
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.title = sprintf('Amplitude difference in electode %s',strjoin(channels_selection, ' '));
cfg.figure         = fig;
subplot(2, 2, 2);
ft_singleplotTFR(cfg, stat_with_data);
%%
stat_with_data = stat;
stat_with_data.('data_contrast') = powspctrm_diff_avg;
stat_with_data.('dimord') = 'chan_freq_time';

fig = figure;
%%% cfg data - diff, cond1, cond2
cfg              = [];
cfg.baseline     =  [cond1_allsubs{1}.('time')(1) cond1_allsubs{1}.('time')(end)];
cfg.baselinetype = 'absolute';
cfg.parameter = 'data_contrast';
cfg.maskparameter = 'mask'; 
cfg.maskstyle    = 'outline'; %'opacity', 'saturation', or 'outline'
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.title = sprintf('Amplitude difference in electode %s',strjoin(channels_selection, ' '));
cfg.figure         = fig;
subplot(2, 2, 2);
ft_singleplotTFR(cfg, stat_with_data);
% 

% freqsss = 0.5:0.5:30;
% cfg.masknans       = 'yes';
% stat_with_data.freq = freqsss;
% % cond1
cfg.baseline     = [-0.1, 0];
cfg.baselinetype = 'zscore';
stat_with_data.('data_contrast') = powspctrm_cond1_avg;
cfg.title = sprintf('Amplitude cond1 in electode %s',strjoin(channels_selection, ' '));
subplot(2, 2, 1);
ft_singleplotTFR(cfg, stat_with_data);

% 
% % cond2
cfg.baseline     = [-0.1, 0];
cfg.baselinetype = 'zscore';
stat_with_data.('data_contrast') = powspctrm_cond2_avg;
cfg.title = sprintf('Amplitude cond2 in electode %s',strjoin(channels_selection, ' '));
subplot(2, 2, 3);
ft_singleplotTFR(cfg, stat_with_data);
% 
% %%% cfg stat
cfg              = [];
cfg.baseline     = 'no';
cfg.parameter = 'stat';
cfg.maskparameter = 'mask'; 
cfg.maskstyle    = 'outline';%'opacity', 'saturation', or 'outline'
cfg.zlim         = [-3 3];
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
cfg.title = sprintf('Statistic in electode %s',strjoin(channels_selection, ' '));
cfg.figure         = fig;
subplot(2, 2, 4);
ft_singleplotTFR(cfg, stat_with_data);

%%
cfg = [];
cfg.baseline     = [-0.1 1.16];
cfg.baselinetype = 'absolute';
cfg.masknans     = 'yes';
% cfg.zlim         = [-4 4];
cfg.showlabels   = 'yes';
cfg.parameter = 'powspctrm';
cfg.layout       = ft_read_sens('GSN-HydroCel-129.sfp');
figure
ft_multiplotTFR(cfg, TFRhann_curr_sub);

%%
function [TFRhann_allsubs_mean,TFRhann_allsubs]=get_TFRhann_allsubs(subs, ft_per_sub,cfg)
    TFRhann_allsubs = {};
    TFRhann_allsubs_meanpow = zeros([numel(ft_per_sub{1}.label),numel(cfg.foi),numel(ft_per_sub{1}.time{1})]);
    for sub_i=1:numel(subs)
        TFRhann_curr_sub = ft_freqanalysis(cfg, ft_per_sub{sub_i});
        TFRhann_allsubs{end+1} = TFRhann_curr_sub;
        TFRhann_allsubs_meanpow = TFRhann_allsubs_meanpow + ((TFRhann_curr_sub.powspctrm) / numel(subs));
    end
    TFRhann_allsubs_mean = TFRhann_curr_sub;
    TFRhann_allsubs_mean.powspctrm = TFRhann_allsubs_meanpow;
end

 function expStruct = defineExpStruct(import_s, short_s, long_s, isBaseline)
    expStruct = struct();
    expStruct.import_s = import_s;
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.isBaseline = isBaseline;
end
