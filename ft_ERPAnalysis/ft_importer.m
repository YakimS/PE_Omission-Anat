classdef ft_importer < handle
    properties (SetAccess = private)
      subs
      input_dir
      output_dir
      epoch_time
      
      ftRaw
      timlocked
      grandAvg
      neighbours
      tfrHilbert
      tfrWavelets
      tfrMT
      tfrMT_zscored
    end
    methods(Static)
        % constructor
        function o = ft_importer(subs, input_dir,output_dir,epoch_time)
            o.subs = subs;
            o.input_dir = input_dir;
            o.output_dir = output_dir;
            o.epoch_time = epoch_time;

            o.ftRaw = {};
            o.timlocked = {};
            o.grandAvg = {};
            o.tfrHilbert = {};
            o.tfrWavelets = {};
            o.tfrMT = {};
            o.tfrMT_zscored = {};
        end

        % get/set

        function s = get_subs(o)
            s = o.subs;
        end
        function s = get_input_dir(o)
            s = o.input_dir;
        end
        function s = get_output_dir(o)
            s = o.output_dir;
        end
        function s = get_epoch_time(o)
            s = o.epoch_time;
        end
        function neighbours = get_neighbours(o)
            if isempty(o.neighbours)
                cfg = [];
                cfg.method = 'triangulation' ; 
                cfg.feedback    = 'no';
                elec       = ft_read_sens('GSN-HydroCel-129.sfp'); % if Cz is ref, use GSN-HydroCel-128.sfp. If not, use 'GSN-HydroCel-129.sfp'
                cfg.elec=elec;
                o.neighbours = ft_prepare_neighbours(cfg);
            end
            neighbours = o.neighbours;
        end

        function cond_ftRaw = get_rawFt_cond(o,cond,sov)
            if ~isfield(o.ftRaw,sprintf("%s_%s",sov.short_s,cond.short_s))
                ft_subs_cond = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    if contains(sov.short_s,'WAll') % import both wake night and morning
                        file_path_ngt = sprintf("%s\\s_%s_%s_%s.mat",o.input_dir,o.subs{sub_i},'wake_night',cond.import_s);
                        file_path_mng = sprintf("%s\\s_%s_%s_%s.mat",o.input_dir,o.subs{sub_i},'wake_morning',cond.import_s);
                        try
                            sub_data_ngt = load(file_path_ngt);
                            sub_data_mng = load(file_path_mng);

                            cfg = [];
                            ft_data =  ft_appenddata(cfg, sub_data_ngt.ft_data, sub_data_mng.ft_data);
                            ft_subs_cond{sub_i} = ft_data;
                        catch ME
                            sprintf('cant find: %s\n or: %s', file_path_ngt,file_path_mng)
                        end                            
                    else     % import only one cond 
                        file_path = sprintf("%s\\s_%s_%s_%s.mat",o.input_dir,o.subs{sub_i},sov.import_s,cond.import_s);
                        try
                            sub_data = load(file_path);
                            ft_subs_cond{sub_i} = sub_data.ft_data;
                        catch ME
                            sprintf('cant find: %s', file_path)
                        end
                    end
                end
                o.ftRaw.(sprintf("%s_%s",sov.short_s,cond.short_s)) = ft_subs_cond;
            end
            cond_ftRaw = o.ftRaw.(sprintf("%s_%s",sov.short_s,cond.short_s));
        end
        
        function cond_timlocked = get_cond_timelocked(o,cond,sov)
            if ~isfield(o.timlocked,sprintf("%s_%s",sov.short_s,cond.short_s))
                allsubs_cond_timlocked = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    file_path = sprintf("%s\\timelocked_sov-%s_cond-%s_sub-%s.mat",o.output_dir,sov.short_s,cond.short_s,o.subs{sub_i});
                    try
                        loaded = load(file_path);
                        allsubs_cond_timlocked{sub_i} = loaded.timelocked_subcond;
                        if allsubs_cond_timlocked{sub_i}.cfg.('trials_timelocked_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s\n',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                    catch ME
                        cfg = [];
                        cfg.feedback = 'no';
                        conds_ftraw = o.get_rawFt_cond(o,cond,sov);
                        allsubs_cond_timlocked{sub_i} = ft_timelockanalysis(cfg, conds_ftraw{sub_i});
                        allsubs_cond_timlocked{sub_i}.cfg.('trials_timelocked_avg') = numel(conds_ftraw{sub_i}.trial);
                        if allsubs_cond_timlocked{sub_i}.cfg.('trials_timelocked_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                        %save
                        timelocked_subcond = allsubs_cond_timlocked{sub_i};
                        save(file_path,"timelocked_subcond")
                    end
                end
                o.timlocked.(sprintf("%s_%s",sov.short_s,cond.short_s)) = allsubs_cond_timlocked;
            end
            cond_timlocked = o.timlocked.(sprintf("%s_%s",sov.short_s,cond.short_s));
        end
        
        % deprecated function cond_timlockedBl_preStim = get_cond_timelockedBl_preStim(o,cond,sov)
%             if ~isfield(o.timlocked_bl_pretrial,sprintf("%s_%s",sov,cond))
%                 allsubs_cond_timlockedBl = cell(1, size(o.subs,2));
%                 for sub_i=1:size(o.subs,2)
%                     file_path = sprintf("%s//bl%dms-timelocked_%s_cond-%s_sub-%s.mat",o.output_dir,o.baseline_length,sov,cond,o.subs{sub_i});
%                     try
%                         loaded = load(file_path);
%                         allsubs_cond_timlockedBl{sub_i} = loaded.baseline_subcond;
%                     catch ME
%                         timlocked = o.get_cond_timelocked(o,cond,sov);
%                         time0_ind = find(timlocked{sub_i}.time == 0, 1);
%                         time_baseline_ind = find(timlocked{sub_i}.time == -o.baseline_length*0.001, 1);
%                 
%                         baseline = timlocked{sub_i}.avg(:,time_baseline_ind:time0_ind);
%                         baseline_mean = mean(baseline,2);
%                         new_baseline_avg = ones(size(timlocked{sub_i}.avg)) .* baseline_mean;
%                         allsubs_cond_timlockedBl{sub_i} = rmfield(timlocked{sub_i},["dof","var"]);
%                         allsubs_cond_timlockedBl{sub_i}.avg = new_baseline_avg;
%                         
%                         %save
%                         baseline_subcond = allsubs_cond_timlockedBl{sub_i};
%                         save(file_path,"baseline_subcond")
%                     end
%                 end
%                 o.timlocked_bl.(sprintf("%s_%s",sov,cond)) = allsubs_cond_timlockedBl;
%             end
%             cond_timlockedBl_preStim = o.timlocked_bl_pretrial.(sprintf("%s_%s",sov,cond));
%         end

        % depecated function cond_rawBl = get_cond_rawBl(o,cond,sov)
%             if ~isfield(o.raw_bl,sprintf("%s_%s",sov,cond))
%                 allsubs_cond_rawBl = cell(1, size(o.subs,2));
%                 for sub_i=1:size(o.subs,2)
%                     file_path = sprintf("%s//bl%dms-raw_%s_cond-%s_sub-%s.mat",o.output_dir,o.baseline_length,sov,cond,o.subs{sub_i});
%                     try
%                         loaded = load(file_path);
%                         allsubs_cond_rawBl{sub_i} = loaded.baseline_subcond;
%                     catch ME
%                         rawFt = o.get_rawFt_cond(o,cond,sov);
%                         curr_sub_raw_ft = rawFt{sub_i};
%                         time0_ind = find(curr_sub_raw_ft.time{1} == 0, 1);
%                         time_baseline_ind = find(curr_sub_raw_ft.time{1} == -o.baseline_length*0.001, 1);
%                         allsubs_cond_rawBl{sub_i} = curr_sub_raw_ft;
%                         for trial_i=1:size(curr_sub_raw_ft.trial,2)
%                             baseline = curr_sub_raw_ft.trial{trial_i}(:,time_baseline_ind:time0_ind);
%                             baseline_mean = mean(baseline,2);
%                             new_baseline_avg = ones(size(curr_sub_raw_ft.trial{trial_i})) .* baseline_mean;
%                             allsubs_cond_rawBl{sub_i}.trial{trial_i} = new_baseline_avg;
%                         end
%                 
%                         %save
%                         baseline_subcond = allsubs_cond_rawBl{sub_i};
%                         save(file_path,"baseline_subcond")
%                     end
%                 end
%                 o.raw_bl.(sprintf("%s_%s",sov,cond)) = allsubs_cond_rawBl;
%             end
%             cond_rawBl = o.raw_bl.(sprintf("%s_%s",sov,cond));
%         end

        function cond_grandAvg = get_cond_grandAvg(o,cond,sov)
            if ~isfield(o.grandAvg,sprintf("%s_%s",sov.short_s,cond.short_s))
                cfg = [];
                file_path = sprintf("%s//timelock_grandAvg_%s_cond-%s.mat",o.output_dir,sov.short_s,cond.short_s);
                try
                    loaded = load(file_path);
                    cond_grandAvg = loaded.timelockGrandavg_cond;
                catch ME
                    timlocked = o.get_cond_timelocked(o,cond,sov);
                    cond_grandAvg  = ft_timelockgrandaverage(cfg, timlocked{:});
        
                    %save
                    timelockGrandavg_cond = cond_grandAvg;
                    save(sprintf("%s/timelocked_cond-%s_sub-avg.mat",o.output_dir,cond.short_s),"timelockGrandavg_cond")
                end
            else
                cond_grandAvg = o.grandAvg.(sprintf("%s_%s",sov.short_s,cond.short_s));
            end
        end
   
        function cond_TFR_hiblert=get_cond_TFR_hilbert(o,cond,sov)
            if ~isfield(o.tfrHilbert,sprintf("%s_%s",sov.short_s,cond.short_s))
                allsubs_cond_tfrHilbert = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    filename = sprintf("tfrHilbert_sov-%s_cond-%s_sub-%s.mat",sov.short_s,cond.short_s,o.subs{sub_i});
                    file_path = sprintf("%s\\tfr_hilbert\\%s",o.output_dir,filename);
                    try
                        loaded = load(file_path);
                        allsubs_cond_tfrHilbert{sub_i} = loaded.tfrHilbert_subcond;
                        if allsubs_cond_tfrHilbert{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s\n',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                    catch ME
                        fprintf("Running: %s\n",filename);
                        cfg = [];
                        cfg.feedback = 'no';
                        conds_ftraw = o.get_rawFt_cond(o,cond,sov);

% % %                         freq_bin = 1.5:0.5:40;
% % %                         sub_hilb_zsc = struct();
% % %                         sub_hilb_zsc.('label') = conds_ftraw{sub_i}.label;
% % %                         sub_hilb_zsc.('dimord') = 'chan_freq_time';
% % %                         sub_hilb_zsc.('freq') = freq_bin;
% % %                         sub_hilb_zsc.('time') = conds_ftraw{sub_i}.time{1};
% % %                         sub_hilb_zsc.('elec') = conds_ftraw{sub_i}.elec;
% % %                         freq_bin_for_hilb = freq_bin;
% % %                         freq_bin_for_hilb(end+1) = freq_bin_for_hilb(end) + (freq_bin_for_hilb(end) - freq_bin_for_hilb(end-1));
% % %                         hilb_zsc = o.hilbert_zscore(conds_ftraw{sub_i},freq_bin_for_hilb,1:numel(conds_ftraw{sub_i}.label));
% % %                         sub_hilb_zsc.('powspctrm') = permute(squeeze(mean(hilb_zsc,4)),[2,1,3]);
% % %                         allsubs_cond_tfrHilbert{sub_i} = sub_hilb_zsc;

%                         subs_hilb_trans = struct();
%                         subs_hilb_trans.('label') = conds_ftraw{sub_i}.label;
%                         subs_hilb_trans.('dimord') = 'chan_freq_time';
%                         subs_hilb_trans.('freq') = 1.5:0.5:30.5;
%                         subs_hilb_trans.('time') = conds_ftraw{sub_i}.time{1};
%                         subs_hilb_trans.('elec') = conds_ftraw{sub_i}.elec;
%                         freqBin_for_hilb =subs_hilb_trans.('freq');
%                         freqBin_for_hilb(end+1) = freqBin_for_hilb(end) + (freqBin_for_hilb(end) -freqBin_for_hilb(end-1));
%                         nbin = length(freqBin_for_hilb)-1;
%                         time_dim_num = 3;
%                         hilbdata = zeros(nbin,numel(subs_hilb_trans.('label')),numel(subs_hilb_trans.('time')),numel(conds_ftraw{sub_i}.trial));
%                         for i_bin = 1:nbin
%                             d = designfilt('bandpassiir', 'FilterOrder', 4, ...
%                                'HalfPowerFrequency1', freqBin_for_hilb(i_bin), 'HalfPowerFrequency2', freqBin_for_hilb(i_bin+1), ...
%                                'SampleRate', 250);
%                             for trial_i =1: numel(conds_ftraw{sub_i}) 
%                 %                 [filt, B, A] = ft_preproc_bandpassfilter(subs_cond.trial{trial_i}(elec,:), 250, [freqbin(f),freqbin(f+1)]) ; %filtEEG = pop_eegfiltnew(EEG,freqbin(f),freqbin(f+1));
%                                 dat = conds_ftraw{sub_i}.trial{trial_i}(1:numel(subs_hilb_trans.('label')),:);
%                                 filt = filtfilt(d, dat')';
%                                 hilbdata(i_bin,:,:,trial_i) =filt;
%                             end
%                             for trial_i =1: numel(conds_ftraw{sub_i}) 
%                                 hilbdata(i_bin,:,:,trial_i) = hilbert(squeeze(hilbdata(i_bin,:,:,trial_i))')';
%                             end
%                         end
%                         hilbdata = abs(hilbdata);
%                         zscorehil = zscore(hilbdata,0,time_dim_num);
%                         subs_hilb_trans.('powspctrm') = permute(squeeze(mean(zscorehil,4)),[2,1,3]);
%                         allsubs_cond_tfrHilbert{sub_i} =subs_hilb_trans;

%%%%                    Hilbert - ft func
                        cfg = [];
                        cfg.channel      = 'all';
                        cfg.method     = 'hilbert';
                        cfg.polyremoval  = 0;%cfg.detrend = 'yes'; % https://www.fieldtriptoolbox.org/faq/why_does_my_tfr_look_strange_part_ii/   
                        cfg.foi          = 0.5:0.5:30;   
                        cfg.toi          = 'all';    
                        cfg.width      = 0.4; 
                        cfg.bpfilttype = 'fir'; % otherwise, it uses IIR filter, which is suboptimal and create imbalance in the parameter space that cuases errors and warnings https://youtu.be/jy7IxIXUAJk?si=KVfHc-WAHa151SDx&t=1003
                        allsubs_cond_tfrHilbert{sub_i} = ft_freqanalysis(cfg, conds_ftraw{sub_i});
                        
                        
                        allsubs_cond_tfrHilbert{sub_i}.cfg.('trials_avg') = numel(conds_ftraw{sub_i}.trial);
                        if allsubs_cond_tfrHilbert{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                        %save
                        tfrHilbert_subcond = allsubs_cond_tfrHilbert{sub_i};
                        save(file_path,"tfrHilbert_subcond")
                    end
                end
                o.tfrHilbert.(sprintf("%s_%s",sov.short_s,cond.short_s)) = allsubs_cond_tfrHilbert;
            end
            cond_TFR_hiblert = o.tfrHilbert.(sprintf("%s_%s",sov.short_s,cond.short_s));
        end

        function cond_TFR_MT_zscored=get_cond_TFR_mt_zscored(o,cond,sov)
            if ~isfield(o.tfrMT_zscored,sprintf("%s_%s",sov.short_s,cond.short_s))
                allsubs_cond_tfrMT_zscored = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    filename = sprintf("tfrMTzscored_sov-%s_cond-%s_sub-%s.mat",sov.short_s,cond.short_s,o.subs{sub_i});
                    file_path = sprintf("%s\\tfr_mt\\zscored\\%s",o.output_dir,filename);
                    try
                        loaded = load(file_path);
                        allsubs_cond_tfrMT_zscored{sub_i} = loaded.tfrMTzscored_subcond;
                        if allsubs_cond_tfrMT_zscored{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s\n',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                    catch ME
                        fprintf("Running: %s\n",filename);
                        cfg = [];
                        cfg.feedback = 'no';
                        conds_ftraw = o.get_rawFt_cond(o,cond,sov);

                        cfg              = [];
                        cfg.output       = 'pow';
                        cfg.channel      = 'all';
                        cfg.method       = 'mtmconvol';
                        cfg.taper        = 'hanning';
                        cfg.foi          = 0.5:0.5:70; 
                        cfg.t_ftimwin    = 3 ./ cfg.foi;   
                        cfg.toi          = 'all';
                        cfg.polyremoval  = 0;
                        allsubs_cond_tfrMT_zscored{sub_i} = ft_freqanalysis(cfg, conds_ftraw{sub_i});
                        
                        foi = 0.5:0.5:70;
                        num_trials = length(conds_ftraw{sub_i}.trial);
                        batch_size = 50;
                        num_batches = ceil(num_trials / batch_size);
                        running_sum = [];
                        trial_count = 0;
                        for batch_i = 1:num_batches
                            trial_start = (batch_i - 1) * batch_size + 1;
                            trial_end = min(batch_i * batch_size, num_trials);
                            cfg = [];
                            cfg.output = 'pow';
                            cfg.channel = 'all';
                            cfg.method = 'mtmconvol';
                            cfg.taper = 'hanning';
                            cfg.foi = foi; 
                            cfg.t_ftimwin = 3 ./ cfg.foi;   
                            cfg.toi = 'all';
                            cfg.polyremoval = 0;
                            cfg.keeptrials = 'yes';
                            cfg.trials = trial_start:trial_end;
                            curr_sub_tfrMT = ft_freqanalysis(cfg, conds_ftraw{sub_i});
                        
                            temp_zscore_powspct = zeros(size(curr_sub_tfrMT.powspctrm)); % [trial, elec, freq, time]
                            for trial_i = 1:size(curr_sub_tfrMT.powspctrm,1)
                                curr_trial = squeeze(curr_sub_tfrMT.powspctrm(trial_i,:,:,:));
                                meanData = nanmean(curr_trial, 3);
                                stdData = nanstd(curr_trial, 0, 3);
                                for elec_i = 1:size(curr_trial, 1)
                                    for freq_i = 1:size(curr_trial, 2)
                                        temp_zscore_powspct(trial_i, elec_i, freq_i, :) = (curr_trial(elec_i, freq_i, :) - meanData(elec_i, freq_i)) / stdData(elec_i, freq_i);
                                    end
                                end
                            end
                            % Sum the current batch's z-scores
                            if isempty(running_sum)
                                running_sum = squeeze(nanmean(temp_zscore_powspct, 1));
                            else
                                running_sum = running_sum + squeeze(nanmean(temp_zscore_powspct, 1));
                            end
                            trial_count = trial_count + size(temp_zscore_powspct, 1);
                        end
                        % Compute the final  z-score across trials average
                        sub_zscore_powspct = running_sum / num_batches;

                        allsubs_cond_tfrMT_zscored{sub_i}.powspctrm_zscore = sub_zscore_powspct;

                        allsubs_cond_tfrMT_zscored{sub_i}.cfg.('trials_avg') = num_trials;
                        if allsubs_cond_tfrMT_zscored{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                        
                        %save
                        tfrMTzscored_subcond = allsubs_cond_tfrMT_zscored{sub_i};
                        save(file_path,"tfrMTzscored_subcond", '-v7.3')
                    end
                end
                o.tfrMT_zscored.(sprintf("%s_%s",sov.short_s,cond.short_s)) = allsubs_cond_tfrMT_zscored;
            end
            cond_TFR_MT_zscored = o.tfrMT_zscored.(sprintf("%s_%s",sov.short_s,cond.short_s));
        end

        function cond_TFR_MT=get_cond_TFR_mt(o,cond,sov)
            if ~isfield(o.tfrMT,sprintf("%s_%s",sov.short_s,cond.short_s))
                allsubs_cond_tfrMT = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    filename = sprintf("tfrMT_sov-%s_cond-%s_sub-%s.mat",sov.short_s,cond.short_s,o.subs{sub_i});
                    file_path = sprintf("%s\\tfr_mt\\%s",o.output_dir,filename);
                    try
                        loaded = load(file_path);
                        allsubs_cond_tfrMT{sub_i} = loaded.tfrMT_subcond;
                        if allsubs_cond_tfrMT{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s\n',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                    catch ME
                        fprintf("Running: %s\n",filename);
                        cfg = [];
                        cfg.feedback = 'no';
                        conds_ftraw = o.get_rawFt_cond(o,cond,sov);

%%%                    Multitaper - ft func
                        cfg              = [];
                        cfg.output       = 'pow';
                        cfg.channel      = 'all';
                        cfg.method       = 'mtmconvol';
                        cfg.taper        = 'hanning';
                        cfg.foi          = 0.5:0.5:70; 
                        cfg.t_ftimwin    = 3 ./ cfg.foi;   
                        cfg.toi          = 'all';
                        cfg.polyremoval  = 0;
                        allsubs_cond_tfrMT{sub_i} = ft_freqanalysis(cfg, conds_ftraw{sub_i});

                        allsubs_cond_tfrMT{sub_i}.cfg.('trials_avg') = numel(conds_ftraw{sub_i}.trial);
                        if allsubs_cond_tfrMT{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                        %save
                        tfrMT_subcond = allsubs_cond_tfrMT{sub_i};
                        save(file_path,"tfrMT_subcond")
                    end
                end
                o.tfrMT.(sprintf("%s_%s",sov.short_s,cond.short_s)) = allsubs_cond_tfrMT;
            end
            cond_TFR_MT = o.tfrMT.(sprintf("%s_%s",sov.short_s,cond.short_s));
        end

        function cond_TFR_wavelets=get_cond_TFR_wavelets(o,cond,sov)
            if ~isfield(o.tfrHilbert,sprintf("%s_%s",sov.short_s,cond.short_s))
                allsubs_cond_tfrWavelets = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    filename = sprintf("tfrWaveletes_sov-%s_cond-%s_sub-%s.mat",sov.short_s,cond.short_s,o.subs{sub_i});
                    file_path = sprintf("%s\\%s",o.output_dir,filename);
                    try
                        loaded = load(file_path);
                        allsubs_cond_tfrWavelets{sub_i} = loaded.tfrWaveletes_subcond;
                        if allsubs_cond_tfrWavelets{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s\n',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                    catch ME
                        fprintf("Running: %s\n",filename);
                        cfg = [];
                        cfg.feedback = 'no';
                        conds_ftraw = o.get_rawFt_cond(o,cond,sov);

%%%                    wavelet - ft func
                        cfg = [];
                        cfg.keeptrials = 'no';
                        cfg.channel      = 'all';
                        cfg.method     = 'wavelet';  
                        cfg.foilim = [1.5, 40]; % cfg.foi        =  1.5:0.5:40;
                        cfg.toi          = -0.1:0.004:0.448;  
                        cfg.pad     = 'nextpow2';
                        % cfg.order = 4;
%                          cfg.width      = 0.2; %?
                        allsubs_cond_tfrWavelets{sub_i} = ft_freqanalysis(cfg, conds_ftraw{sub_i});

                        allsubs_cond_tfrWavelets{sub_i}.cfg.('trials_avg') = numel(conds_ftraw{sub_i}.trial);
                        if allsubs_cond_tfrWavelets{sub_i}.cfg.('trials_avg') == 1
                            fprintf('sub: %s, cond: %s, sov: %s',o.subs{sub_i}, cond.long_s, sov.long_s)
                            error('one trail in this cond for this sub. Highly unrecommended')
                        end
                        %save
                        tfrWaveletes_subcond = allsubs_cond_tfrWavelets{sub_i};
                        save(file_path,"tfrWaveletes_subcond")
                    end
                end
                o.tfrHilbert.(sprintf("%s_%s",sov.short_s,cond.short_s)) = allsubs_cond_tfrWavelets;
            end
            cond_TFR_wavelets = o.tfrHilbert.(sprintf("%s_%s",sov.short_s,cond.short_s));
        end


        function zscorehil=hilbert_zscore(subs_cond_raw_ft,freqbin,elec)
            nbin = length(freqbin)-1;
            time_dim_num = 3;
            hilbdata = zeros(nbin,numel(elec),numel(subs_cond_raw_ft.time{1}),numel(subs_cond_raw_ft.trial));
            for f = 1:nbin
                d = designfilt('bandpassiir', 'FilterOrder', 4, ...
                   'HalfPowerFrequency1', freqbin(f), 'HalfPowerFrequency2', freqbin(f+1), ...
                   'SampleRate', 250);
                for trial_i =1: numel(subs_cond_raw_ft.trial) 
    %                 [filt, B, A] = ft_preproc_bandpassfilter(subs_cond.trial{trial_i}(elec,:), 250, [freqbin(f),freqbin(f+1)]) ; %filtEEG = pop_eegfiltnew(EEG,freqbin(f),freqbin(f+1));
                    dat = subs_cond_raw_ft.trial{trial_i}(elec,:);
                    filt = filtfilt(d, dat')';
                    hilbdata(f,:,:,trial_i) =filt;
                end
                for trial_i =1: numel(subs_cond_raw_ft.trial) 
                    hilbdata(f,:,:,trial_i) = hilbert(squeeze(hilbdata(f,:,:,trial_i))')';
                end
            end
            hilbdata = abs(hilbdata);
            zscorehil = zscore(hilbdata,0,time_dim_num);
        end
    end
end