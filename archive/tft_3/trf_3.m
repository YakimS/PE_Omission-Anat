
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

%%%%%%%%
output_main_dir = "D:\OExpOut\spatioTemp";
ft_cond_input_dir = "D:\OExpOut\processed_data\ft_subSovCond";
ft_cond_output_dir = "D:\OExpOut\processed_data\ft_processed";
libs_dir = 'D:\matlab_libs';

%%%%%%

subs = {'08','09','10','11','13','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; 
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
examp_cond = AOmi;

curr_sov_subs = sub_exclu_per_sov(subs, sovs,examp_cond);
imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir); 
timelock = imp.get_cond_timelocked(imp,examp_cond,sovs{1});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);

% wn_O_timelock = imp.timlocked.wn_O;
% wn_intb_timelock = imp.get_cond_timelocked(imp,intbkMid,sovs{1});

wn_O_raw = imp.get_rawFt_cond(imp,AOmi,Wnig);
wn_intb_raw = imp.get_rawFt_cond(imp,intblksmpAO,Wnig);
n3_intb_raw = imp.get_rawFt_cond(imp,intblksmpAO,N3);


%% time-freq decomposition

%%% hanning
% cfg              = [];
% cfg.output       = 'pow';
% cfg.channel      = 'EEG';
% cfg.method       = 'mtmconvol';
% cfg.taper        = 'hanning';
% cfg.foi          = 2:2:50;                         % analysis 2 to 50 Hz in steps of 2 Hz
% cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.004;   % length of time window = 0.5 sec
% cfg.toi          = -0.1:0.004:0.448;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
% cfg.channel = 'all';
% TFR = ft_freqanalysis(cfg, wn_O_raw{1});

%%% Hanning taper, frequency dependent window length
% The main advantage of this approach is that the temporal smoothing decreases with higher frequencies, leading to increased sensitivity to short-lived effects. However, an increased temporal resolution is at the expense of frequency resolution 
% cfg              = [];
% cfg.output       = 'pow';
% cfg.method       = 'mtmconvol';
% cfg.taper        = 'hanning';
% cfg.foi          = 2:2:50;
% cfg.t_ftimwin    = 2./cfg.foi;  % 7 cycles per time window
% cfg.toi          = -0.1:0.004:0.448;  
% 
% cfg.channel      = 'all';
% hanning_taper_TFRhann = ft_freqanalysis(cfg, wn_O_raw{1});

%%% Multitapers
% Multitapers are typically used in order to achieve better control over the frequency smoothing. More tapers for a given time window will result in stronger smoothing. For frequencies above 30 Hz, smoothing has been shown to be advantageous, increasing sensitivity thanks to reduced variance in the estimates despite reduced effective spectral resolution.
% tl;dr: more sensitive to >30hz effects. For <30hz better to use hannigtaper
% cfg = [];
% cfg.output     = 'pow';
% cfg.channel    = 'EEG';
% cfg.method     = 'mtmconvol';
% cfg.foi        = 1:2:50;
% cfg.t_ftimwin  = 5./cfg.foi;
% cfg.tapsmofrq  = 0.4 *cfg.foi;
% cfg.toi          = -0.1:0.004:0.448;  
% cfg.channel      = 'all';
% TFRmult = ft_freqanalysis(cfg, wn_O_raw{1});

%%% Morlet wavelets
% taper with a Gaussian shape.
% cfg.width determines the width of the wavelets in number of cycles. Making the value smaller will increase the temporal resolution at the expense of frequency resolution and vice versa.
% cfg = [];
% cfg.channel    = 'all';
% cfg.keeptrials = 'yes';
% cfg.method     = 'wavelet';
% % cfg.width      = 0.5;
% cfg.foi        = 1.5:0.5:30;
% cfg.toi          = -0.1:0.004:0.448;  
% % cfg.pad     = 'nextpow2';
% 
% TFRwave_wn_intbk_sub1 = ft_freqanalysis(cfg, wn_intb_raw{1});
% TFRwave_wn_O_sub1 = ft_freqanalysis(cfg, wn_O_raw{1});
% TFRwave_n3_intbk_sub1 = ft_freqanalysis(cfg, n3_intb_raw{1});
% 
% TFRwave_wn_intbk_sub2 = ft_freqanalysis(cfg, wn_intb_raw{2});
% TFRwave_wn_O_sub2 = ft_freqanalysis(cfg, wn_O_raw{2});
% TFRwave_n3_intbk_sub2 = ft_freqanalysis(cfg, n3_intb_raw{2});
% 
% % grand avf yes keep trials
% wn_intb_tfr = {};
% wn_O_tfr = {};
% n3_intb_tfr = {};
% for i=1:numel(wn_intb_raw)
%     wn_intb_tfr{end+1} = ft_freqanalysis(cfg,  wn_intb_raw{i});
%     n3_intb_tfr{end+1} = ft_freqanalysis(cfg,  n3_intb_raw{i});
%     wn_O_tfr{end+1} = ft_freqanalysis(cfg,  wn_O_raw{i});
% end

% grand avf no keep trials
cfg = [];
cfg.channel    = 'all';
cfg.keeptrials = 'no';
cfg.method     = 'wavelet';
cfg.width      = 0.5;
cfg.foi        = 1.5:0.5:30;
cfg.toi          = -0.1:0.004:1.16;  
cfg.pad     = 'nextpow2';

wn_intb_tfr_nokeep = {};
wn_O_tfr_nokeep = {};
n3_intb_tfr_nokeep = {};
for i=1:numel(wn_intb_raw)
    wn_intb_tfr_nokeep{end+1} = ft_freqanalysis(cfg,  wn_intb_raw{i});
    n3_intb_tfr_nokeep{end+1} = ft_freqanalysis(cfg,  n3_intb_raw{i});
    wn_O_tfr_nokeep{end+1} = ft_freqanalysis(cfg,  wn_O_raw{i});
end
%%
cfg = [];
cfg.keeptrials='yes';
wn_intb_tfr_nokeep_grandAvg = ft_freqgrandaverage(cfg,wn_intb_tfr_nokeep{:});
wn_O_tfr_nokeep_grandAvg = ft_freqgrandaverage(cfg,wn_O_tfr_nokeep{:});
n3_intb_tfr_nokeep_grandAvg = ft_freqgrandaverage(cfg,n3_intb_tfr_nokeep{:});

%%

% Hilbert
% grand avf no keep trials
cfg = [];
cfg.keeptrials = 'no';
cfg.channel      = 'all';
cfg.method     = 'hilbert';
cfg.detrend = 'yes'; % https://www.fieldtriptoolbox.org/faq/why_does_my_tfr_look_strange_part_ii/   
cfg.width      = 0.5; %?
cfg.foi        = 1.5:0.5:30;
cfg.toi          = -0.1:0.004:1.16;  
cfg.edgartnan     = 'no'; %?
cfg.pad     = 'nextpow2';
% cfg.order = 4;


wn_intb_tfr_hilb = {};
wn_O_tfr_hilb = {};
n3_intb_tfr_hilb = {};
for i=1:numel(1)
    wn_intb_tfr_hilb{end+1} = ft_freqanalysis(cfg,  wn_intb_raw{i});
    n3_intb_tfr_hilb{end+1} = ft_freqanalysis(cfg,  n3_intb_raw{i});
    wn_O_tfr_hilb{end+1} = ft_freqanalysis(cfg,  wn_O_raw{i});
end
%%
cfg = [];
cfg.keeptrials='yes';
wn_intb_hilb_nokeep_grandAvg = ft_freqgrandaverage(cfg,wn_intb_tfr_hilb{:});
wn_O_hilb_nokeep_grandAvg = ft_freqgrandaverage(cfg,wn_O_tfr_hilb{:});
n3_intb_hilb_nokeep_grandAvg = ft_freqgrandaverage(cfg,n3_intb_tfr_hilb{:});

%% Hilbert
% grand avf keep trials
cfg = [];
cfg.keeptrials = 'yes';
cfg.channel      = 'all';
cfg.method     = 'hilbert';
% cfg.width      = 0.5; %?
cfg.foi        = 1.5:0.5:30;
cfg.toi          = -0.1:0.004:1.16;  
cfg.edgartnan     = 'yes'; %?
cfg.pad     = 'nextpow2';
% cfg.order = 4;

wn_intb_tfr_hilb_keep = {};
wn_O_tfr_hilb_keep = {};
n3_intb_tfr_hilb_keep = {};
for i=1:numel(wn_intb_raw)
    wn_intb_tfr_hilb_keep{end+1} = ft_freqanalysis(cfg,  wn_intb_raw{i});
    n3_intb_tfr_hilb_keep{end+1} = ft_freqanalysis(cfg,  n3_intb_raw{i});
    wn_O_tfr_hilb_keep{end+1} = ft_freqanalysis(cfg,  wn_O_raw{i});
end

cfg = [];
cfg.keeptrials='yes';
wn_intb_hilb_keep_grandAvg = ft_freqgrandaverage(cfg,wn_intb_tfr_hilb_keep{:});
wn_O_hilb_keep_grandAvg = ft_freqgrandaverage(cfg,wn_O_tfr_hilb_keep{:});
n3_intb_hilb_keep_grandAvg = ft_freqgrandaverage(cfg,n3_intb_tfr_hilb_keep{:});

%% visu

%%% specto each elect
cfg = [];
cfg.baseline     = [-0.1 0];
cfg.baselinetype = 'relative';
% cfg.zlim         = [-0.1,0.1];
cfg.showlabels   = 'yes';
cfg.colorbar      = 'yes';
cfg.layout       = ft_read_sens('GSN-HydroCel-129.sfp');
figure
ft_multiplotTFR(cfg, wn_O_tfr_nokeep{2});

%%% 
% cfg = [];
% cfg.channel       = {'Cz'};
% cfg.baselinetype  = 'relchange';
% cfg.baseline      = [-0.1 0];
% cfg.colorbar      = 'yes';
% % cfg.zlim          = [-10 10];     % use the same scaling for both figures
% figure
% ft_singleplotTFR(cfg, n3_intb_tfr_hilb{1});
% title('cue towards left');
% figure
% ft_singleplotTFR(cfg, wn_intb_tfr_hilb{1});
% title('cue towards right');

%%% topoplot
% cfg = [];
% cfg.baseline     = [-0.1 0];
% cfg.baselinetype = 'absolute';
% cfg.xlim         = [0 0.448];         % time
% % cfg.zlim         = [-200 200];              % z
% cfg.ylim         = [10 15];             % freq
% cfg.marker       = 'on';
% cfg.layout       = ft_read_sens('GSN-HydroCel-129.sfp');
% cfg.colorbar     = 'yes';
% figure
% ft_topoplotTFR(cfg, wn_intb_tfr_hilb{23});

%%
cfg = [];
% cfg.channel          = {'EEG'};
cfg.latency          = [0 1.16];
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
cfg.numrandomization = 1000;
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

[stat] = ft_freqstatistics(cfg, wn_intb_tfr_nokeep{:}, wn_O_tfr_nokeep{:});
%%
% T-statistic of the difference 
cfg = [];
cfg.alpha  = 0.025;
cfg.parameter = 'stat';
cfg.zlim   = [-5 5];
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
ft_clusterplot(cfg, stat);
%%
cfg = [];
cfg.xlim  = -0.1:0.04:1.16;
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

%% comparing 2 conds by normalizing

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)/(x1+x2)';
TFR_diff_MEG = ft_math(cfg, n3_intb_tfr_hilb{1}, wn_intb_tfr_hilb{1});

cfg = [];
cfg.baseline     = [-0.1 0];
cfg.baselinetype = 'absolute';
cfg.xlim         = [0 1.16];         % time
% cfg.zlim         = [-200 200];              % z
cfg.ylim         = [10 15];             % freq
cfg.marker       = 'on';
cfg.layout       = ft_read_sens('GSN-HydroCel-129.sfp');
cfg.colorbar     = 'yes';
figure
ft_topoplotTFR(cfg, wn_intb_tfr_hilb_keep{4});

cfg = [];
cfg.xlim         = [0.3 1.16]; % time
cfg.zlim         = [-0.4 0.4];  % 
cfg.ylim         = [15 25];     % frq
% cfg.marker       = 'on';
cfg.channel      = 'Cz';
cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');

% figure;
ft_topoplotTFR(cfg, TFR_diff_MEG);


%%

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

 function expStruct = defineExpStruct(import_s, short_s, long_s, isBaseline)
    expStruct = struct();
    expStruct.import_s = import_s;
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.isBaseline = isBaseline;
end
