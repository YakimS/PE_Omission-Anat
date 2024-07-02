function clusterToneOdor(basename1,basename2,cond,window,type,freqs,per1,per2)% not using window for intra
% clusterToneOdor('NREM_tone_stim2','NREM_tone_base2','condition',[1 5],'intra',[f1 f2],4.501*srate:srate*9.5,1:5*srate,'base',folder,'nonparam',loc,elec)
% clusterolf('RandomStage2_AllTrials_stim2','RandomStage2_AllTrials_bas2','condition',[-1 1],'intra',[1 40],[2001:2251],[1:251])
loadpathsToneOdor
loadsubjToneOdor

switch type
    case 'inter'
        cond1 = load([filepath 'tone odor conditioning/hilbert/zscore/' basename1 ], cond);
        cond2 = load([filepath 'tone odor conditioning/hilbert/zscore/' basename2 ], cond);
        times = [-20000:4:20000]./1000;
        times = times(1:end-1);
        
        TI = interp1(times, [1:length(times)],window, 'nearest');
        
        data1 = cond1.condition;
        data2 = cond2.condition;
        
        data1.globspctrm = squeeze(nanmean(data1(freqs(1):freqs(2),1,TI(1):TI(2),1:12),2));
        data2.globspctrm = squeeze(nanmean(data2(freqs(1):freqs(2),1,TI(1):TI(2),1:12),2));
        data1.globspctrm = permute(data1.globspctrm,[3,2,1]);
        data2.globspctrm = permute(data2.globspctrm,[3,2,1]);
        
        [subj,~,freq] = size(data1.globspctrm);
        
        nsubj = subj;
        
        data1.label = {'Cz'};
        data2.label = {'Cz'};
        data1.dimord = 'rpt_freq_time';
        data2.dimord = 'rpt_freq_time';
        data1.fsample = 500;
        data2.fsample = 500;
        data1.freq = [1:freq];
        data2.freq = [1:freq];
        data1.time =[TI(1):TI(2)];
        data2.time= [TI(1):TI(2)];
        
        
        cfg.parameter = 'globspctrm';
        cfg.method = 'montecarlo';
        cfg.correctm = 'cluster';
        cfg.clusterstatistc = 'maxsum'; % maximum of the cluster-level statistics.
        cfg.statistic = 'depsamplesT';
        cfg.numrandomization = 1000;
        cfg.clusteralpha = 0.05;
        %cfg.tail = 1;
        
        cfg.design = zeros(2,2*nsubj);
        cfg.design(1,:)=[ones(1,nsubj) ones(1,nsubj)+1];
        cfg.design(2,:)=[1:nsubj 1:nsubj];
        cfg.ivar = 1;
        cfg.uvar = 2;
        
        stats = ft_freqstatistics(cfg,data1,data2)
        
        data1 = data1.globspctrm;
        data2 = data2.globspctrm;
        
        fprintf('Saving %s.\n',[filepath 'tone odor conditioning/hilbert/zscore/results/' basename1 '_vs_' basename2  '_clean_beta_clustperm.mat']);
        save([filepath 'tone odor conditioning/hilbert/zscore/results/' basename1 '_vs_' basename2 '_clean_beta_clustperm.mat'], 'stats', 'data1', 'data2', 'times', 'window', 'TI', '-v7.3'); %chanlocs
        
        
    case 'intra'
        
        cond1 = load([filepath 'tone odor conditioning/hilbert/zscore/results/' basename1 ], [cond '2']);
        times = [-10000:4:10000]./1000;
        times = times(1:end-1);
        
        TI = interp1(times, [1:length(times)],window, 'nearest');
        
        data1 = cond1.condition2;

%         
        cond2 = load([filepath 'tone odor conditioning/hilbert/zscore/results/' basename2 ], cond);  %if comparing two stim and not stim baseline add 2 like line 68      
%       data2 = cond2.stage2bl;
        data2 = cond2.condition; %if comparing two stim and not stim baseline add 2 "data2 = cond2.condition2"
         
        data1.globspctrm = squeeze(nanmean(data1(freqs(1):freqs(2),1,per2,1:size(data1,4)),2)); % 751:1251 is -2 to 0 sec
        data2.globspctrm = squeeze(nanmean(data2(freqs(1):freqs(2),1,per1,1:size(data2,4)),2)); % 1:501 is 0 to 2 sec
        data1.globspctrm = permute(data1.globspctrm,[3,2,1]);
        data2.globspctrm = permute(data2.globspctrm,[3,2,1]);
        
        [subj,~,freq] = size(data1.globspctrm);
        
        nsubj = subj;
        
        data1.label = {'Cz'};
        data2.label = {'Cz'};
        data1.dimord = 'rpt_freq_time';
        data2.dimord = 'rpt_freq_time';
        data1.fsample = 500;
        data2.fsample = 500;
        data1.freq = [1:freq];
        data2.freq = [1:freq];
        data1.time =[TI(1):TI(2)];
        data2.time= [TI(1):TI(2)];
        
        
        cfg.parameter = 'globspctrm';
        cfg.method = 'montecarlo';
        cfg.correctm = 'cluster';
        cfg.clusterstatistc = 'maxsum';
        cfg.statistic = 'depsamplesT';
        cfg.numrandomization = 1000;
        cfg.clusteralpha = 0.05;
        %cfg.tail = 1;
        
        cfg.design = zeros(2,2*nsubj);
        cfg.design(1,:)=[ones(1,nsubj) ones(1,nsubj)+1];
        cfg.design(2,:)=[1:nsubj 1:nsubj];
        cfg.ivar = 1;
        cfg.uvar = 2;
        
        stats = ft_freqstatistics(cfg,data1,data2)
       
        data1 = data1.globspctrm;
        data2 = data2.globspctrm;
        
        fprintf('Saving %s.\n',[filepath 'tone odor conditioning/hilbert/zscore/results/' basename1 '_vs_' basename2 '_intra2_clustperm_' num2str(window) '_' num2str(freqs) '.mat']);
        save([filepath 'tone odor conditioning/hilbert/zscore/results/' basename1 '_vs_' basename2 '_intra2_clustperm_' num2str(window) '_' num2str(freqs) '.mat'],'per1', 'per2', 'TI','stats', 'data1', 'data2', 'times', 'window', '-v7.3'); %chanlocs
        
        
        
end


end