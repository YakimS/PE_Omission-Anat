function allsubs_cond_tfr=get_cond_TFR(subs,cond,sov,tfr_algo, dirs)
    if strcmp(tfr_algo,'multitaper')
        allsubs_cond_tfr = get_cond_TFR_mt(subs,cond,sov, dirs.ft_cond_input, dirs.ft_cond_output);
    elseif strcmp(tfr_algo,'multitaper_zscored')
        allsubs_cond_tfr = get_cond_TFR_mt_zscored(subs,cond,sov, dirs.ft_cond_input, dirs.ft_cond_output);
    elseif strcmp(tfr_algo,'hilbert')
        allsubs_cond_tfr = get_cond_TFR_hilbert(subs,cond,sov, dirs.ft_cond_input, dirs.ft_cond_output);
    elseif strcmp(tfr_algo,'hilbert_zscored')
        allsubs_cond_tfr = get_cond_TFR_hilbert_zscored(subs,cond,sov, dirs.ft_cond_input, dirs.ft_cond_output);
    else
        error('no such tfr algo implemented')
    end
end


function allsubs_cond_tfrHilbert_zscored=get_cond_TFR_hilbert_zscored(subs,cond,sov, input_dir, output_dir)
    allsubs_cond_tfrHilbert_zscored = cell(1, size(subs,2));
    for sub_i=1:size(subs,2)
        filename = sprintf("tfrHilbertzscored_sov-%s_cond-%s_sub-%s.mat",sov.short_s,cond.short_s,subs{sub_i});
        file_path = sprintf("%s\\tfr_hilbert\\zscored\\%s",output_dir,filename);
        try
            loaded = load(file_path);
            allsubs_cond_tfrHilbert_zscored{sub_i} = loaded.tfrHilbertzscored_subcond;
            error_if_less_than_5_trials(subs{sub_i},cond, sov, allsubs_cond_tfrHilbert_zscored{sub_i}.cfg.('trials_avg'))
            
        catch ME
            fprintf("Running: %s\n",filename);
            cfg = [];
            cfg.feedback = 'no';
            conds_ftraw = get_rawFt_cond(subs,cond,sov, input_dir);

            %%%%    Hilbert - ft func
            % cfg = [];
            % cfg.channel      = 'all';
            % cfg.method     = 'hilbert';
            % cfg.polyremoval  = 0;%cfg.detrend = 'yes'; % https://www.fieldtriptoolbox.org/faq/why_does_my_tfr_look_strange_part_ii/   
            % cfg.foi          = 0.5:0.5:70;   
            % cfg.toi          = 'all';    
            % cfg.width      = 0.4; 
            % cfg.bpfilttype = 'fir'; % otherwise, it uses IIR filter, which is suboptimal and create imbalance in the parameter space that cuases errors and warnings https://youtu.be/jy7IxIXUAJk?si=KVfHc-WAHa151SDx&t=1003
            
            cfg = [];
            cfg.channel = 'all';
            cfg.method = 'hilbert';
            cfg.toi = 'all';
            cfg.bpfilttype = 'fir';% otherwise, it uses IIR filter, which is suboptimal and create imbalance in the parameter space that cuases errors and warnings https://youtu.be/jy7IxIXUAJk?si=KVfHc-WAHa151SDx&t=1003
            cfg.polyremoval = 0;
            cfg.foi          = 0.5:0.5:70; 
            cycles = 3 + 1.5*log10(cfg.foi);
            cycles = min(cycles, 5); 
            cfg.t_ftimwin = cycles ./ cfg.foi;
            cfg.width = min(cfg.foi ./ cycles, cfg.foi * 0.4); % explicitly control bandwidth:
            %optional:
            cfg.pad = max(cfg.t_ftimwin);% Longest window (at lowest frequency)

            allsubs_cond_tfrHilbert_zscored{sub_i} = ft_freqanalysis(cfg, conds_ftraw{sub_i});
            
            num_trials = length(conds_ftraw{sub_i}.trial);
            batch_size = 50;
            num_batches = ceil(num_trials / batch_size);
            running_sum = [];
            trial_count = 0;
            for batch_i = 1:num_batches
                trial_start = (batch_i - 1) * batch_size + 1;
                trial_end = min(batch_i * batch_size, num_trials);
                cfg.keeptrials = 'yes';
                cfg.trials = trial_start:trial_end;
                curr_sub_tfrHil = ft_freqanalysis(cfg, conds_ftraw{sub_i});

                temp_zscore_powspct = zeros(size(curr_sub_tfrHil.powspctrm)); % [trial, elec, freq, time]
                for trial_i = 1:size(curr_sub_tfrHil.powspctrm,1)
                    curr_trial = squeeze(curr_sub_tfrHil.powspctrm(trial_i,:,:,:));
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
            allsubs_cond_tfrHilbert_zscored{sub_i}.powspctrm_zscore = sub_zscore_powspct;
            allsubs_cond_tfrHilbert_zscored{sub_i}.cfg.('trials_avg') = num_trials;
            error_if_less_than_5_trials(subs{sub_i},cond, sov, allsubs_cond_tfrHilbert_zscored{sub_i}.cfg.('trials_avg'))
            
            %save
            tfrHilbertzscored_subcond = allsubs_cond_tfrHilbert_zscored{sub_i};
            save(file_path,"tfrHilbertzscored_subcond", '-v7.3')
        end
    end
end