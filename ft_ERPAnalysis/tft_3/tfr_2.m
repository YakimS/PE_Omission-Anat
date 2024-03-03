

% sovs
N1 = struct(); N1.import_s = "N1"; N1.short_s = "N1"; N1.long_s = "N1";
N2 = struct(); N2.import_s = "N2"; N2.short_s = "N2"; N2.long_s = "N2";
N3 = struct(); N3.import_s = "N3"; N3.short_s = "N3"; N3.long_s = "N3";
REM = struct(); REM.import_s = "REM"; REM.short_s = "REM"; REM.long_s = "REM";
tREM = struct(); tREM.import_s = "tREM"; tREM.short_s = "tREM"; tREM.long_s = "tREM";
pREM = struct(); pREM.import_s = "pREM"; pREM.short_s = "pREM"; pREM.long_s = "pREM";
Wnig = struct(); Wnig.import_s = "wake_night"; Wnig.short_s = "wn"; Wnig.long_s = "Wake Pre";
Wmor = struct(); Wmor.import_s = "wake_morning"; Wmor.short_s = "wm"; Wmor.long_s = "Wake Post";

% [-0.1, 0.448]
Omi = struct(); Omi.import_s = "O"; Omi.short_s = "O"; Omi.long_s = "Omission";
OmiR = struct(); OmiR.import_s = "OR"; OmiR.short_s = "OR"; OmiR.long_s = "Omission Random";
OmiF = struct(); OmiF.import_s = "OF"; OmiF.short_s = "OF"; OmiF.long_s = "Omission Fixed";
intbk = struct(); intbk.import_s = "intbk"; intbk.short_s = "intbk"; intbk.long_s = "Interblock (Avg)";
intbkMid = struct(); intbkMid.import_s = "intbkMid"; intbkMid.short_s = "intbkMid"; intbkMid.long_s = "Interblock middle (Avg)"; % 0.5s - 4.5s of the interblock cut to 0.5s

% [-12, 6]
OmiR618 = struct(); OmiR618.import_s = "OR618"; OmiR618.short_s = "OR618"; OmiR618.long_s = "Omission Random, 6th";
OmiR718 = struct(); OmiR718.import_s = "OR718"; OmiR718.short_s = "OR718"; OmiR718.long_s = "Omission Random, 7th";
OmiR818 = struct(); OmiR818.import_s = "OR818"; OmiR818.short_s = "OR818"; OmiR818.long_s = "Omission Random, 8th";
OmiR918 = struct(); OmiR918.import_s = "OR918"; OmiR918.short_s = "OR918"; OmiR918.long_s = "Omission Random, 9th";
OmiF18 = struct(); OmiF18.import_s = "OF18"; OmiF18.short_s = "OF18"; OmiF18.long_s = "Omission Fixed";
LastOmiF18 = struct(); LastOmiF18.import_s = "LastOF18"; LastOmiF18.short_s = "LastOF18"; LastOmiF18.long_s = "Last Omission Fixed";
LastOmiR18 = struct(); LastOmiR18.import_s = "LastOR18"; LastOmiR18.short_s = "LastOR18"; LastOmiR18.long_s = "Last Omission Random";

%[0,5]
intbk5 = struct(); intbk5.import_s = "intbk5"; intbk5.short_s = "intbk5"; intbk5.long_s = "Interblock";

%[-0.2,2]
intbk2 = struct(); intbk2.import_s = "intbk2"; intbk2.short_s = "intbk2"; intbk2.long_s = "Interblock";
intbkLast2 = struct(); intbkLast2.import_s = "interblockLast2sec"; intbkLast2.short_s = "intbkLast2"; intbkLast2.long_s = "Interblock end";
LastOR2 = struct(); LastOR2.import_s = "LastOR2sec"; LastOR2.short_s = "LastOR2"; LastOR2.long_s = "Last Omission Random";
LastOF2 = struct(); LastOF2.import_s = "LastOF2sec"; LastOF2.short_s = "LastOF2"; LastOF2.long_s = "Last Omission Fixed";

LastOmiR = struct(); LastOmiR.import_s = "LastOR"; LastOmiR.short_s = "LastOR"; LastOmiR.long_s = "Omission Random";
LastOmiF = struct(); LastOmiF.import_s = "LastOF"; LastOmiF.short_s = "LastOF"; LastOmiF.long_s = "Omission Fixed";


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
examp_cond = Omi;

curr_sov_subs = sub_exclu_per_sov(subs, sovs,examp_cond);
imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir); 
timelock = imp.get_cond_timelocked(imp,examp_cond,sovs{1});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);

wn_O_timelock = imp.timlocked.wn_O;
wn_intb_timelock = imp.get_cond_timelocked(imp,intbkMid,sovs{1});

wn_O_raw = imp.get_rawFt_cond(imp,Omi,Wnig);
wn_intb_raw = imp.get_rawFt_cond(imp,intbkMid,Wnig);
n3_intb_raw = imp.get_rawFt_cond(imp,intbkMid,N3);
%% time-freq decomposition

% cfg              = [];
% cfg.output       = 'pow';
% cfg.channel      = 'EEG';
% cfg.method       = 'mtmconvol';
% cfg.taper        = 'hanning';
% cfg.foi          = 2:2:50;                         % analysis 2 to 50 Hz in steps of 2 Hz
% cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.04;   % length of time window = 0.5 sec
% cfg.toi          = -0.1:0.04:0.448;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
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
% cfg.toi          = -0.1:0.04:0.448;  
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
% cfg.toi          = -0.1:0.04:0.448;  
% cfg.channel      = 'all';
% TFRmult = ft_freqanalysis(cfg, wn_O_raw{1});

%%% Morlet wavelets
% taper with a Gaussian shape.
% cfg.width determines the width of the wavelets in number of cycles. Making the value smaller will increase the temporal resolution at the expense of frequency resolution and vice versa.
cfg = [];
cfg.channel    = 'EEG';
cfg.keeptrials = 'yes';
cfg.channel      = 'all';
cfg.method     = 'wavelet';
cfg.width      = 0.5;
cfg.foi        = 1:2:40;
cfg.toi          = -0.1:0.04:0.448;  
cfg.pad     = 'nextpow2';

TFRwave_wn_intbk_sub1 = ft_freqanalysis(cfg, wn_intb_raw{1});
TFRwave_wn_O_sub1 = ft_freqanalysis(cfg, wn_O_raw{1});
TFRwave_n3_intbk_sub1 = ft_freqanalysis(cfg, n3_intb_raw{1});

TFRwave_wn_intbk_sub2 = ft_freqanalysis(cfg, wn_intb_raw{2});
TFRwave_wn_O_sub2 = ft_freqanalysis(cfg, wn_O_raw{2});
TFRwave_n3_intbk_sub2 = ft_freqanalysis(cfg, n3_intb_raw{2});

%% visu

%%% specto each elect
% cfg = [];
% cfg.baseline     = [-0.1 0];
% cfg.baselinetype = 'absolute';
% cfg.zlim         = [-50 50];
% cfg.showlabels   = 'yes';
% cfg.colorbar      = 'yes';
% cfg.layout       = ft_read_sens('GSN-HydroCel-129.sfp');
% figure
% ft_multiplotTFR(cfg, TFRwave_wn_intbk);

%%% 
cfg = [];
cfg.channel       = {'Cz'};
cfg.baselinetype  = 'relchange';
cfg.baseline      = [-0.1 0];
cfg.colorbar      = 'yes';
cfg.zlim          = [-10 10];     % use the same scaling for both figures
figure
ft_singleplotTFR(cfg, TFRwave_wn_intbk_sub1);
title('cue towards left');
figure
ft_singleplotTFR(cfg, TFRwave_n3_intbk_sub1);
title('cue towards right');

%%% topoplot
% cfg = [];
% cfg.baseline     = [-0.1 0];
% cfg.baselinetype = 'absolute';
% cfg.xlim         = [0 0.448];         % time
% cfg.zlim         = [-200 200];              % z
% cfg.ylim         = [10 15];             % freq
% cfg.marker       = 'on';
% cfg.layout       = ft_read_sens('GSN-HydroCel-129.sfp');
% cfg.colorbar     = 'yes';
% figure
% ft_topoplotTFR(cfg, TFRwave_wn_intbk);


%% https://natmeg.se/ft_statistics/statistics.html
channles = {'Cz'};

cond_1 = TFRwave_wn_intbk_sub1;
cond_2 = TFRwave_n3_intbk_sub1;

cfg = [];
cfg.method            = 'montecarlo';           % use the Monte Carlo Method to calculate the significance probability
cfg.statistic         = 'indepsamplesT';        % use the independent samples T-statistic as a measure to evaluate the effect at the sample level
cfg.correctm          = 'cluster';
cfg.clusteralpha      = 0.05;                   % alpha level of the sample-specific test statistic that will be used for thresholding
cfg.clustertail       = 0;
cfg.clusterstatistic  = 'maxsum';               % test statistic that will be evaluated under the permutation distribution.
cfg.tail              = 0;                      % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.correcttail       = 'prob';                 % the two-sided test implies that we do non-parametric two tests
cfg.alpha             = 0.05;                   % alpha level of the permutation test
cfg.numrandomization  = 1000;                   % number of draws from the permutation distribution
cfg.ivar              = 1;                      % the index of the independent variable in the design matrix
cfg.channel       = channles;
cfg.neighbours        = [];                     % there are no spatial neighbours, only in time and frequency
n_1 = size(cond_1.powspctrm,1);
n_2 = size(cond_2.powspctrm,1);
cfg.design           = [ones(1,n_1),ones(1,n_2)*2]; % design matrix

stat = ft_freqstatistics(cfg, cond_1,cond_2);

cfg = [];
cfg.channel       = channles;
cfg.baseline      = [-0.1 0];
% cfg.baselinetype  = 'relchange';
cfg.colorbar      = 'yes';
cfg.zlim          = [-5,5];
cfg.parameter     = 'stat'; % display the statistical value, i.e. the t-score
figure
ft_singleplotTFR(cfg, stat);
title('t-score (not corrected)')

%%

chansel  = find(strcmp(cond_1.label, channles)); % find the channel index
powspctrm_cond1  = mean(cond_1.powspctrm(:,chansel,:,:), 1);
powspctrm_cond2 = mean(cond_2.powspctrm(:,chansel,:,:), 1);

effect = powspctrm_cond1 - powspctrm_cond2;
siz    = size(effect);
effect = reshape(effect, siz(2:end)); % we need to "squeeze" out one of the dimensions, i.e. make it 3-D rather than 4-D

%%
stat.effect = effect;
cfg = [];
cfg.channel       = channles;
cfg.baseline      = [-0.1 0];
cfg.renderer      = 'openGL';     % painters does not support opacity, openGL does
cfg.colorbar      = 'yes';
cfg.parameter     = 'effect';     % display the power
cfg.maskparameter = 'mask';       % use significance to mask the power
cfg.maskalpha     = 0.3;          % make non-significant regions 30% visible
cfg.zlim          = 'maxabs';
figure
ft_singleplotTFR(cfg, stat);
title('significant power changes (p<0.05, corrected)')



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
