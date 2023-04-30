
restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
wake_files_name_suffix = 'wake_morning_referenced';  %wake_morning_referenced, wake_night_referenced
ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat\\%s',wake_files_name_suffix);
baseline_timerange = 100; % time from 
persub_output_dir = sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\per_sub_electrode",wake_files_name_suffix);
%% imports
imp = ft_importer_allsubjclass(subs,ft_cond_dir,baseline_timerange,wake_files_name_suffix);
[imp,neig] = imp.get_neighbours(imp);
[imp,timelock_OR] = imp.get_cond_timelocked(imp,'OR');
electrodes = timelock_OR{1}.label;
time = timelock_OR{1}.time;
time0_ind = find(time == 0, 1);
%% Plot ERP per electrodes
contrasrs = {{'OEf4','OR'},{'OF','OR'}};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for contrast_ind=1:size(contrasrs,2)
    cond1_name = contrasrs{contrast_ind}{1};
    cond2_name = contrasrs{contrast_ind}{2};
    [imp,raw_cond1] = imp.get_rawFt_cond(imp,cond1_name);
    [imp,raw_cond2] = imp.get_rawFt_cond(imp,cond2_name);
    for sub_i =1:size(subs,2)
        curr_sub_cond1 = raw_cond1{sub_i};
        curr_sub_cond2 = raw_cond2{sub_i};
        cfg = [];
        cfg.showlabels  = 'yes';
        cfg.layout    = electrodes;
        cfg.interactive  = 'no';
        cfg.figure = 'no';
        
        figure; 
        ft_multiplotER(cfg, curr_sub_cond1,curr_sub_cond2)
        savefig(sprintf("%s\\ERP_%s&%s_perElecd_sub-%s",persub_output_dir,cond1_name,cond2_name,subs{sub_i}))
    end
end
%% Time permutation analysis for each electrode X subj

contrasrs = {{'OEf4','OR'},{'OF','OR'}};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg                  = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'indepsamplesT';
cfg.correctm         = 'cluster';
cfg.clusterstatistic = 'maxsum';   
cfg.minnbchan        = 0;     
cfg.tail             = 0;         
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.clusteralpha     = 0.05;  
cfg.numrandomization = 1000;
cfg.neighbours    = neig;
cfg.latency     = [0,0.45];
cfg.ivar             = 1; % number or list with indices indicating the independent variable(s)

for contrast_ind=1:size(contrasrs,2)
    cond1_name = contrasrs{contrast_ind}{1};
    cond2_name = contrasrs{contrast_ind}{2};
    [imp,raw_cond1] = imp.get_rawFt_cond(imp,cond1_name);
    [imp,raw_cond2] = imp.get_rawFt_cond(imp,cond2_name);
    for sub_i =1:size(subs,2)
        curr_sub_cond1 = raw_cond1{sub_i};
        curr_sub_cond2 = raw_cond2{sub_i};
        n_fc  = size(curr_sub_cond1.trial, 2);
        n_fic = size(curr_sub_cond2.trial, 2);
        cfg.design           = [ones(1,n_fic), ones(1,n_fc)*2]; % design matrix
        for electd_i =1:size(electrodes,1)
            cfg.channel     = {electrodes{electd_i}};
            [stat] = ft_timelockstatistics(cfg, curr_sub_cond1, curr_sub_cond2);
            if all(stat.mask == 0)
                continue;
            else
                save(sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_name,cond2_name,subs{sub_i},electrodes{electd_i}), '-struct', 'stat');
            end
        end
    end
end

%% Create a erp for each sig. electrode X subj

contrasrs = {{'OEf4','OR'},{'OF','OR'}};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for contrast_ind=1:size(contrasrs,2)
    electds_amount_with_clust_per_sub = zeros(size(subs,2),1);
    cond1_name = contrasrs{contrast_ind}{1};
    cond2_name = contrasrs{contrast_ind}{2};
    [imp,raw_cond1] = imp.get_rawFt_cond(imp,cond1_name);
    [imp,raw_cond2] = imp.get_rawFt_cond(imp,cond2_name);
    for sub_i =1:size(subs,2)
        curr_sub_cond1 = raw_cond1{sub_i};
        curr_sub_cond2 = raw_cond2{sub_i};
        for electd_i =1:size(electrodes,1)
            file_path = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_name,cond2_name,subs{sub_i},electrodes{electd_i});
            if isfile(file_path)
                cond1_trials = zeros(size(curr_sub_cond1.trial,2),size(time,2));
                for trial_i=1:size(curr_sub_cond1.trial,2)
                    cond1_trials(trial_i,:) = curr_sub_cond1.trial{trial_i}(electd_i,:);
                end
    
                cond2_trials = zeros(size(curr_sub_cond2.trial,2),size(time,2));
                for trial_i=1:size(curr_sub_cond2.trial,2)
                    cond2_trials(trial_i,:) = curr_sub_cond2.trial{trial_i}(electd_i,:);
                end
    
                test_stat = load(file_path);
                mask_in_trial = zeros(size(time,2),1);
                mask_in_trial(time0_ind:size(time,2)) = test_stat.mask;
    
                cond1_trials_mean = mean(cond1_trials);
    
                plot(time,cond2_trials,'Color', [1 0 0 0.1],HandleVisibility='off' )
                hold on
                plot(time,cond1_trials,'Color', [0 0 1 0.1],HandleVisibility='off' )
                hold on
                plot(time,mean(cond1_trials),'Color', [0 0 1 1],LineWidth=2, DisplayName=cond1_name)
                hold on
                plot(time,mean(cond2_trials),'Color', [1 0 0 1],LineWidth=2, DisplayName=cond2_name)
                hold on
                plot(time(find(mask_in_trial)),cond1_trials_mean(find(mask_in_trial)),'O', 'DisplayName',sprintf('%s vs. %s',cond1_name,cond2_name),"Color","black","MarkerSize",4)
                hold off
    
                title(sprintf("%s vs %s - subject: %s, electrode: %s",cond1_name,cond2_name,subs{sub_i},electrodes{electd_i}));
                legend("Location","northeast","FontSize",6);
                axis([time(1) time(end) -20 20])
                output_im_file_path = sprintf("%s\\%svs%s_sub-%s_elctd-%s.png",persub_output_dir,cond1_name,cond2_name,subs{sub_i},electrodes{electd_i});
                saveas(gcf, output_im_file_path)
            end
        end
    end
end
%% Create a graph sums all sig. electrode X subj

contrasrs = {{'OEf4','OR'},{'OF','OR'}};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for contrast_ind=1:size(contrasrs,2)
    electds_amount_with_clust_per_sub = zeros(size(subs,2),1);
    cond1_name = contrasrs{contrast_ind}{1};
    cond2_name = contrasrs{contrast_ind}{2};
    num_of_subs_with_clust = 0;
    num_of_sig_electrodes = 0;
    plot_counter = 1;
    sub_plot_counter = 1;
    one_times = ones(size(time,2),1);
    for sub_i =1:size(subs,2)
        was_in_sub = false;
        curr_color = [rand,rand,rand];
        for electd_i =1:size(electrodes,1)      
            file_path = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_name,cond2_name,subs{sub_i},electrodes{electd_i});
            if isfile(file_path)
                num_of_sig_electrodes = num_of_sig_electrodes+1;
                was_in_sub = true;
                test_stat = load(file_path);
                mask_in_trial = zeros(size(time,2),1);
                mask_in_trial(time0_ind:size(time,2)) = test_stat.mask;
                plot(time(find(mask_in_trial)),plot_counter*one_times(find(mask_in_trial)),'.', 'DisplayName','Oe',"Color",curr_color,"MarkerSize",8)
                hold on;
                plot_counter = plot_counter+1;
            end
        end
        if was_in_sub
            num_of_subs_with_clust=num_of_subs_with_clust+1;
        end
    end
    title('Timeranges of significant clusters',sprintf("#subs= %d. Percent from allElectrodes = %.2f",num_of_subs_with_clust,num_of_sig_electrodes/((size(electrodes,1))*size(subs,2))))
    xlabel('Time (s)')
    hold off
    output_im_file_path = sprintf("%s\\%svs%s_summary-allSubElectd.png",persub_output_dir,cond1_name,cond2_name);
    saveas(gcf, output_im_file_path)
end