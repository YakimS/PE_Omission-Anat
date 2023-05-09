function clusterElla(basename1,basename2,cond,window,freqs,per1,per2,compkind,statmode)% not using window for intra

% clusterolf('RandomStage2_AllTrials_stim2','RandomStage2_AllTrials_bas2','condition',[-1 1],'intra',[1 40],[2001:2251],[1:251])
% subjmethode = 0; % 0 == subjects, 1 == supersubject

loadpathsElla
loadsubjElla

if ~exist('compkind')
    compkind = 'base';
end

cond1 = load([filepath 'analysis/hilbert/zscore/results/'  basename1 ], [cond '2']);
times = [-10000:4:10000]./1000;
times = times(1:end-1);

TI = interp1(times, [1:length(times)],window, 'nearest');

data1 = cond1.condition2;

if strcmp(compkind,'base')
    cond2 = load([filepath 'analysis/hilbert/zscore/results/' basename2 ], cond);
    data2 = cond2.condition;
    
    data1.globspctrm = squeeze(nanmean(data1(freqs(1):freqs(2),1,per2,1:size(data1,4)),2));
    data2.globspctrm = squeeze(nanmean(data2(freqs(1):freqs(2),1,per1,1:size(data2,4)),2));
    data1.globspctrm = permute(data1.globspctrm,[3,2,1]);
    data2.globspctrm = permute(data2.globspctrm,[3,2,1]);
    
    [subj,~,freq] = size(data1.globspctrm);
    nsubj = subj;
    
    cfg.statistic = 'depsamplesT';
    cfg.design = zeros(2,2*nsubj);
    cfg.design(1,:)=[ones(1,nsubj) ones(1,nsubj)+1];
    cfg.design(2,:)=[1:nsubj 1:nsubj];
    cfg.ivar = 1;
    cfg.uvar = 2;
    
elseif strcmp(compkind,'twostimDep')
    cond2 = load([filepath 'analysis/hilbert/zscore/results/' basename2 ], [cond '2']);
    data2 = cond2.condition2;
    
    data1.globspctrm = squeeze(nanmean(data1(freqs(1):freqs(2),1,per2,1:size(data1,4)),2));
    data2.globspctrm = squeeze(nanmean(data2(freqs(1):freqs(2),1,per1,1:size(data2,4)),2));
    data1.globspctrm = permute(data1.globspctrm,[3,2,1]);
    data2.globspctrm = permute(data2.globspctrm,[3,2,1]);
    
    [subj,~,freq] = size(data1.globspctrm);
    nsubj = subj;
    
    cfg.statistic = 'depsamplesT';
    cfg.design = zeros(2,2*nsubj);
    cfg.design(1,:)=[ones(1,nsubj) ones(1,nsubj)+1];
    cfg.design(2,:)=[1:nsubj 1:nsubj];
    cfg.ivar = 1;
    cfg.uvar = 2;
    
elseif strcmp(compkind,'twostim')
    
    cond2 = load([filepath 'analysis/hilbert/zscore/results/' basename2 ], [cond '2']);
    data2 = cond2.condition2;
    
    data1.globspctrm = squeeze(nanmean(data1(freqs(1):freqs(2),1,per2,1:size(data1,4)),2));
    data2.globspctrm = squeeze(nanmean(data2(freqs(1):freqs(2),1,per1,1:size(data2,4)),2));
    data1.globspctrm = permute(data1.globspctrm,[3,2,1]);
    data2.globspctrm = permute(data2.globspctrm,[3,2,1]);
    
    [subj1,~,freq] = size(data1.globspctrm);
    nsubj1 = subj1;
    
    [subj2,~,freq] = size(data2.globspctrm);
    nsubj2 = subj2;
    
    cfg.statistic = 'indepsamplesT';
    cfg.design = zeros(1,nsubj1+nsubj2);
    cfg.design(1,:)=[ones(1,nsubj1) ones(1,nsubj2)+1];
    cfg.ivar = 1;
    
end

data1.label = {'Cz'};
data2.label = {'Cz'};
data1.dimord = 'rpt_freq_time';
data2.dimord = 'rpt_freq_time';
data1.fsample = 250;
data2.fsample = 250;
data1.freq = [1:freq];
data2.freq = [1:freq];
data1.time =[TI(1):TI(2)];
data2.time= [TI(1):TI(2)];

cfg.parameter = 'globspctrm';
cfg.method = 'montecarlo';
cfg.correctm = 'cluster';
cfg.clusterstatistc = 'maxsum';
cfg.numrandomization = 1000;
cfg.clusteralpha = 0.05;
cfg.tail = 0;

if exist('statmode','var')
    if strcmp(statmode,'nonparam')
        cfg.clusterthreshold = 'nonparametric_common';% default = 'parametric'
    end
end


stats = ft_freqstatistics(cfg,data1,data2)

data1 = data1.globspctrm;
data2 = data2.globspctrm;

if exist('statmode','var')
    if strcmp(statmode,'nonparam')
        fprintf('Saving %s.\n',[filepath 'analysis/hilbert/zscore/results/'  basename1 '_vs_' basename2 '_clustperm_nonparam_' num2str(window) '_' num2str(freqs) '.mat']);
        save([filepath 'analysis/hilbert/zscore/results/'  basename1 '_vs_' basename2 '_clustperm_nonparam_' num2str(window) '_' num2str(freqs) '.mat'],'per1', 'per2', 'TI','stats', 'data1', 'data2', 'times', 'window', '-v7.3'); %chanlocs
    end
else
    
    fprintf('Saving %s.\n',[filepath 'analysis/hilbert/zscore/results/'  basename1 '_vs_' basename2 '_intra2_clustperm_' num2str(window) '_' num2str(freqs) '.mat']);
    save([filepath 'analysis/hilbert/zscore/results/'  basename1 '_vs_' basename2 '_clustperm_' num2str(window) '_' num2str(freqs) '.mat'],'per1', 'per2', 'TI','stats', 'data1', 'data2', 'times', 'window', '-v7.3'); %chanlocs
end
