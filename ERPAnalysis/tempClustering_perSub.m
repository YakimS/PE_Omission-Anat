
restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
eeglab

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
wake_files_name_suffix = 'wake_morning_referenced';  %wake_morning_referenced, wake_night_referenced
ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat\\%s',wake_files_name_suffix);

conds_string = {'OEf4','OR','O','T'};
persub_output_dir = sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\per_sub_electrode\\alpha%s",wake_files_name_suffix,alpha_string);

baseline_timerange = 100; % time from 
alpha = 0.025;

%% imports

importer = ft_importer;
if ~exist("allConds_ftRaw","var")    allConds_ftRaw= importer.get_rawFt_conds(ft_cond_dir,conds_string,wake_files_name_suffix,subs);  end
if ~exist("allConds_timlocked","var")    allConds_timlocked=importer.get_allConds_timelocked(allConds_ftRaw,ft_cond_dir,conds_string,subs); end
if ~exist("neighbours","var")    neighbours = importer.get_neighbours(allConds_timlocked{1}{1}.label);end
time = allConds_timlocked{1}{1}.time;
electrods = allConds_timlocked{1}{1}.elec.label;
time0_ind = find(time == 0, 1);

alpha_string = num2str(alpha);


%% Plot ERP per electrodes
persub_output_dir = sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\per_sub_electrode\\%s",wake_files_name_suffix,alpha_string);

for sub_i =1:size(subs,2)
    curr_sub_cond1 = allConds_ftRaw{1}{sub_i};
    curr_sub_cond2 = allConds_ftRaw{2}{sub_i};
    cfg = [];
    cfg.showlabels  = 'yes';
    cfg.layout    = 'GSN-HydroCel-128.mat';
    cfg.interactive  = 'no';
    cfg.figure = 'no';
    
    figure; 
    ft_multiplotER(cfg, curr_sub_cond1,curr_sub_cond2)
    savefig(sprintf("%s\\ERP_%s&%s_perElecd_sub-%s",persub_output_dir,conds_string{1},conds_string{2},subs{sub_i}))
end
%% Time permutation analysis for each electrode X subj


cond1_text = conds_string{1};
cond2_text = conds_string{2};
 
cfg                  = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'indepsamplesT';
cfg.correctm         = 'cluster';
cfg.clusterstatistic = 'maxsum';   
cfg.minnbchan        = 0;     
cfg.tail             = 0;         
cfg.clustertail      = 0;
cfg.alpha            = alpha;
cfg.clusteralpha     = 0.05;  
cfg.numrandomization = 1000;
cfg.neighbours    = neighbours;
cfg.latency     = [0,0.45];
cfg.ivar             = 1; % number or list with indices indicating the independent variable(s)

for sub_i =1:size(subs,2)
    curr_sub_cond1 = allConds_ftRaw{1}{sub_i};
    curr_sub_cond2 = allConds_ftRaw{2}{sub_i};
    n_fc  = size(curr_sub_cond1.trial, 2);
    n_fic = size(curr_sub_cond2.trial, 2);
    cfg.design           = [ones(1,n_fic), ones(1,n_fc)*2]; % design matrix
    for electd_i =1:size(electrods,1)-1
        cfg.channel     = {electrods{electd_i}};
        [stat] = ft_timelockstatistics(cfg, curr_sub_cond1, curr_sub_cond2);
        if all(stat.mask == 0)
            continue;
        else
            save(sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_text,cond2_text,subs{sub_i},electrods{electd_i}), '-struct', 'stat');
        end
    end
end

%% Create a erp for each sig. electrode X subj

cond1_text = conds_string{1};
cond2_text = conds_string{2};
electds_amount_with_clust_per_sub = zeros(size(subs,2),1);
for sub_i =1:size(subs,2)
    curr_sub_cond1 = allConds_ftRaw{1}{sub_i};
    curr_sub_cond2 = allConds_ftRaw{2}{sub_i};
    for electd_i =1:size(electrods,1)-1
        file_path = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_text,cond2_text,subs{sub_i},electrods{electd_i});
        if isfile(file_path)
            electds_amount_with_clust_per_sub(sub_i) = electds_amount_with_clust_per_sub(sub_i) + 1;
            FO_trials = zeros(size(curr_sub_cond1.trial,2),size(time,2));
            for trial_i=1:size(curr_sub_cond1.trial,2)
                FO_trials(trial_i,:) = curr_sub_cond1.trial{trial_i}(electd_i,:);
            end

            RO_trials = zeros(size(curr_sub_cond2.trial,2),size(time,2));
            for trial_i=1:size(curr_sub_cond2.trial,2)
                RO_trials(trial_i,:) = curr_sub_cond2.trial{trial_i}(electd_i,:);
            end

            test_stat = load(file_path);
            mask_in_trial = zeros(size(time,2),1);
            mask_in_trial(time0_ind:size(time,2)) = test_stat.mask;

            FO_trials_mean = mean(FO_trials);

            plot(time,RO_trials,'Color', [1 0 0 0.1],HandleVisibility='off' )
            hold on
            plot(time,FO_trials,'Color', [0 0 1 0.1],HandleVisibility='off' )
            hold on
            plot(time,mean(FO_trials),'Color', [0 0 1 1],LineWidth=2, DisplayName=cond1_text)
            hold on
            plot(time,mean(RO_trials),'Color', [1 0 0 1],LineWidth=2, DisplayName=cond2_text)
            hold on
            plot(time(find(mask_in_trial)),FO_trials_mean(find(mask_in_trial)),'O', 'DisplayName',sprintf('%s vs. %s',cond1_text,cond2_text),"Color","black","MarkerSize",4)
            hold off

            title(sprintf("%s vs %s - subject: %s, electrode: %s",cond1_text,cond2_text,subs{sub_i},electrods{electd_i}));
            legend("Location","northeast","FontSize",6);
            axis([time(1) time(end) -20 20])
            output_im_file_path = sprintf("%s\\%svs%s_sub-%s_elctd-%s.png",persub_output_dir,cond1_text,cond2_text,subs{sub_i},electrods{electd_i});
            saveas(gcf, output_im_file_path)
        end
    end
end
%% Create a graph sums all sig. electrode X subj

cond1_text = conds_string{1};
cond2_text = conds_string{2};
num_of_subs_with_clust = 0;
num_of_sig_electrodes = 0;
plot_counter = 1;
sub_plot_counter = 1;
one_times = ones(size(time,2),1);
for sub_i =1:size(subs,2)
    was_in_sub = false;
    curr_color = [rand,rand,rand];
    for electd_i =1:size(electrods,1)-1        
        file_path = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_text,cond2_text,subs{sub_i},electrods{electd_i});
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
title('Timeranges of significant clusters',sprintf("alpha=%s, #subs= %d. Percent from allElectrodes = %.2f",alpha_string,num_of_subs_with_clust,num_of_sig_electrodes/((size(electrods,1)-1)*size(subs,2))))
xlabel('Time (s)')
hold off
output_im_file_path = sprintf("%s\\%svs%s_summary-allSubElectd.png",persub_output_dir,cond1_text,cond2_text);
saveas(gcf, output_im_file_path)