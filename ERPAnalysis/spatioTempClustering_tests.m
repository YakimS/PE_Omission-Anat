
%%
restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
eeglab

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
ft_percond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\condsFolder\all_ft_per_cond\ftPreproImport_cont-no';
image_output_dir= 'C:\Users\User\OneDrive\Desktop\here';%'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\spatiotemp_clusterPerm';
preproc_stage = 'referenced';
sleep_files_name_suffix = strcat('_sleep_',preproc_stage);
wake_files_name_suffix = strcat('_wake_night_',preproc_stage);
choosenSuffix = wake_files_name_suffix;
condition_strings = {'OF','OR','O'};

%% Pre process 
% get the sub struct arrays for each condition
all_conds = cell(1, size(condition_strings,2));
for cond_ind = 1:size(condition_strings,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        ft_file_input_name =   strcat('s_',subs(sub_ind), choosenSuffix,'_',condition_strings{cond_ind},'.mat');
        ft_sub_full_filepath = strcat(ft_percond_dir,'/',ft_file_input_name);
        sub_data = load(ft_sub_full_filepath{1});

        subs_cond{sub_ind} = sub_data.ft_data;
    end
    all_conds{cond_ind} = subs_cond;
end

% gey all_conds, timelocked
cfg = [];
all_conds_timlocked = cell(1, size(condition_strings,2));
for cond_ind = 1:size(condition_strings,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        all_conds_timlocked{cond_ind}{sub_ind} = ft_timelockanalysis(cfg, all_conds{cond_ind}{sub_ind});
%         fields = {'var','dof'}; % Just tested if nessesary for baseline
%         comparison. It is unnessetsy for condition conmparison
%         all_conds_timlocked{condition_ind}{sub_ind} = rmfield(all_conds_timlocked{condition_ind}{sub_ind},fields);
    end
end

% get neighbours
cfg = [];
cfg.method = 'triangulation' ; 
cfg.feedback    = 'yes'; [~,ftpath] = ft_version;
elec       = ft_read_sens('GSN-HydroCel-128.sfp'); 
cfg.elec=elec;
neighbours = ft_prepare_neighbours(cfg);

% align "neighbours" struct with current existing labels (Cz is not in neighbours therefore excluded)
ind_existing_elect =[];
events_type_arr = all_conds_timlocked{1}{1}.label;
for elecd_ind = 1:size(neighbours,2)
    curr_event_i = find(ismember(events_type_arr,neighbours(elecd_ind).label));
    if ~isempty(curr_event_i)
        ind_existing_elect = [ind_existing_elect, elecd_ind];
    end
end
new_neighbours = neighbours(ind_existing_elect);

% create baseline-per-electrode structs
allConds_baseline = all_conds_timlocked;
cfg = [];
for cond_ind = 1:size(condition_strings,2)
    subs_cond = cell(1, size(subs,2));
    for sub_ind=1:size(subs,2)
        curr_sub_cond_struct = all_conds_timlocked{cond_ind}{sub_ind};
        time0_ind = find(curr_sub_cond_struct.time == 0, 1);

        baseline = curr_sub_cond_struct.avg(:,1:time0_ind);
        baseline_mean = mean(baseline,2);
        new_baseline_avg = ones(size(curr_sub_cond_struct.avg)) .* baseline_mean;
        allConds_baseline{cond_ind}{sub_ind}.avg = new_baseline_avg; 
    end
end

%% Find avg and std of baseline
number_of_electrodes = 93;
subs_avgBaseline_PerCondAndElectd = zeros(size(condition_strings,2),size(subs,2),number_of_electrodes);
for cond_ind = 1:size(condition_strings,2)
    for sub_ind = 1:size(subs,2)
        subs_avgBaseline_PerCondAndElectd(cond_ind,sub_ind,:) = allConds_baseline{cond_ind}{sub_ind}.avg(:,1);
    end
end

avg_perCond = mean(subs_avgBaseline_PerCondAndElectd,[2,3]); 
stdperCond = std(subs_avgBaseline_PerCondAndElectd,0,[2,3]); 
for cond_ind = 1:size(condition_strings,2)
    fprintf("Cond %s grand avg is: %d, std is:%d\n",condition_strings{cond_ind},avg_perCond(cond_ind),stdperCond(cond_ind))
end


%% Is the baseline activity signigicantly different than 0

number_of_different_than_0_baseline = 0;
for sub_ind = 1:size(subs,2)
    curr_sub_cond_struct =  all_conds_timlocked{3}{sub_ind};
    time0_ind = find(curr_sub_cond_struct.time == 0, 1);

    baseline = curr_sub_cond_struct.avg(:,1:time0_ind);
    for elecd_ind=1:size(new_neighbours,2)
        [h,p,ci,stats] = ttest(baseline(elecd_ind,:));
        if p<0.05
            fprintf("sub:%s, elecd:%d",subs{sub_ind},elecd_ind)
            number_of_different_than_0_baseline = number_of_different_than_0_baseline+1;
        end
    end
end
fprintf("number_of_different_than_0_baseline: %d,   out of: %d\n",number_of_different_than_0_baseline,size(subs,2)*size(new_neighbours,2))


%% 
preVsPoststim_OF  = load("C:\Users\User\OneDrive\Desktop\here\preVsPoststim_OF.mat");
stat = preVsPoststim_OF;
figure
subplot(4,1,1); plot(stat.time, stat.stat); ylabel('t-value');
subplot(4,1,3); semilogy(stat.time, stat.prob); ylabel('prob'); axis([0 0.5 0.001 2])
subplot(4,1,4); plot(stat.time, stat.mask); ylabel('significant'); axis([0 0.5  -0.1 1.1])
%% Explore clusters deviancy 
figure 
subplot(2,1,1); hist(stat.negdistribution, 200);% axis([-10 10 0 100])
for i=1:numel(stat.negclusters)
  X = [stat.negclusters(i).clusterstat stat.negclusters(i).clusterstat];
  Y = [0 100];
  line(X, Y, 'color', 'r')
end

subplot(2,1,2); hist(stat.posdistribution, 200); %axis([-10 10 0 100])

for i=1:numel(stat.posclusters)
  X = [stat.posclusters(i).clusterstat stat.posclusters(i).clusterstat];
  Y = [0 100];
  line(X, Y, 'color', 'r')
end

%%
preVsPoststim_OF  = load("C:\Users\User\OneDrive\Desktop\here\preVsPoststim_OF.mat");
preVsPoststim_OR  = load("C:\Users\User\OneDrive\Desktop\here\preVsPoststim_OR.mat");
preVsPoststim_O  = load("C:\Users\User\OneDrive\Desktop\here\preVsPoststim_O.mat");

%% Get time-electodes clusters of cond O vs. baseline. Look for difference in OF vs. OR in that time-electrode range
for pos_neg_ind=1:2
    if pos_neg_ind ==1
        clusters = {preVsPoststim_O.posclusters.prob};
        clust_mask = preVsPoststim_O.posclusterslabelmat;
        title_text ="preVsPoststim_O.posclusters";
    else
        clusters = {preVsPoststim_O.negclusters.prob};
        clust_mask = preVsPoststim_O.negclusterslabelmat;
        title_text ="preVsPoststim_O.negclusters";
    end
    for clust_ind=1:size(clusters,2)
        if clusters{clust_ind} > 0.05
            continue;
        end
        
        % get time-electrode mask for current cluster
        curr_clust_mask = clust_mask;
        curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
        curr_clust_mask(curr_clust_mask ~= 0) = 1;
        clust_mask_mean = mean(curr_clust_mask,2);
        clust_electd = find(clust_mask_mean>0);
    
        % get mean activity per sub and cond
        % allSubs_conds_cluseAvgActivity average the activity only in cluster time-electrods.
        % allSubs_conds_AvgActivity average the activity over all electrods and time
        allSubs_conds_cluseAvgActivity = zeros(size(condition_strings,2),size(subs,2),size(preVsPoststim_O.time,2));
        allSubs_conds_AvgActivity = zeros(size(condition_strings,2),size(subs,2),size(preVsPoststim_O.time,2));
        for cond_ind = 1:size(condition_strings,2)
            for sub_ind = 1:size(subs,2)
                curr_sub_cond_struct =  all_conds_timlocked{cond_ind}{sub_ind};
                avg_withoutCz = curr_sub_cond_struct.avg(1:end-1,:);
                avg_withoutCz_clusterMasked = avg_withoutCz .* curr_clust_mask;
                sub_clust_activity_mean = sum(avg_withoutCz_clusterMasked,1) ./ sum(avg_withoutCz_clusterMasked~=0,1);
                allSubs_conds_cluseAvgActivity(cond_ind,sub_ind,:) = sub_clust_activity_mean;
                allSubs_conds_AvgActivity(cond_ind,sub_ind,:) = mean(avg_withoutCz(clust_electd,:),1);
            end
        end
        
        %plot
        mean_activity_per_cond_clustTimeSpace = mean(allSubs_conds_cluseAvgActivity,2);
        mean_activity_per_cond_clustSpace = mean(allSubs_conds_AvgActivity,2);
        figure();
        for cond_ind = 1:size(condition_strings,2)
            plot(preVsPoststim_O.time, squeeze(mean_activity_per_cond_clustTimeSpace(cond_ind,:))','DisplayName',sprintf("%s-cluster time-electrode",condition_strings{cond_ind}))
            hold on;
            plot(preVsPoststim_O.time, squeeze(mean_activity_per_cond_clustSpace(cond_ind,:))','DisplayName',sprintf("%s-cluster electrode",condition_strings{cond_ind}))
            hold on;
        end
        title(sprintf("%s, clust ind=%d, pval=%f",title_text,clust_ind,clusters{clust_ind}));
        legend("Location","northwest","FontSize",6)
    end
end

%% Get time-electodes clusters of cond (OF/OR) vs. baseline. Look for difference in OF vs. OR in that time-electrode range

for pos_neg_ind=1:4
    if pos_neg_ind ==1
        clusters = {preVsPoststim_OR.posclusters.prob};
        clust_mask = preVsPoststim_OR.posclusterslabelmat;
        title_text ="preVsPoststim_OR.posclusters";
    elseif pos_neg_ind ==2
        clusters = {preVsPoststim_OR.negclusters.prob};
        clust_mask = preVsPoststim_OR.negclusterslabelmat;
        title_text ="preVsPoststim_OR.negclusters";
    elseif pos_neg_ind ==3
        clusters = {preVsPoststim_OF.posclusters.prob};
        clust_mask = preVsPoststim_OF.posclusterslabelmat;
        title_text ="preVsPoststim_OF.posclusters";
    else
        clusters = {preVsPoststim_OF.negclusters.prob};
        clust_mask = preVsPoststim_OF.negclusterslabelmat;
        title_text ="preVsPoststim_OF.negclusters";
    end
    for clust_ind=1:size(clusters,2)
        if clusters{clust_ind} > 0.05
            continue;
        end
        
        % get time-electrode mask for current cluster
        curr_clust_mask = clust_mask;
        curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
        curr_clust_mask(curr_clust_mask ~= 0) = 1;
        clust_mask_mean = mean(curr_clust_mask,2);
        clust_electd = find(clust_mask_mean>0);
    
        % get mean activity per sub and cond
        % allSubs_conds_cluseAvgActivity average the activity only in cluster time-electrods.
        % allSubs_conds_AvgActivity average the activity over all electrods and time
        allSubs_conds_cluseAvgActivity = zeros(size(condition_strings,2),size(subs,2),size(preVsPoststim_O.time,2));
        allSubs_conds_AvgActivity = zeros(size(condition_strings,2),size(subs,2),size(preVsPoststim_O.time,2));
        for cond_ind = 1:size(condition_strings,2)
            for sub_ind = 1:size(subs,2)
                curr_sub_cond_struct =  all_conds_timlocked{cond_ind}{sub_ind};
                avg_withoutCz = curr_sub_cond_struct.avg(1:end-1,:);
                avg_withoutCz_clusterMasked = avg_withoutCz .* curr_clust_mask;
                sub_clust_activity_mean = sum(avg_withoutCz_clusterMasked,1) ./ sum(avg_withoutCz_clusterMasked~=0,1);
                allSubs_conds_cluseAvgActivity(cond_ind,sub_ind,:) = sub_clust_activity_mean;
                allSubs_conds_AvgActivity(cond_ind,sub_ind,:) = mean(avg_withoutCz(clust_electd,:),1);
            end
        end
        
        %plot
        mean_activity_per_cond_clustTimeSpace = mean(allSubs_conds_cluseAvgActivity,2);
        mean_activity_per_cond_clustSpace = mean(allSubs_conds_AvgActivity,2);
        figure();
        for cond_ind = 1:size(condition_strings,2)
            plot(preVsPoststim_O.time, squeeze(mean_activity_per_cond_clustTimeSpace(cond_ind,:))','DisplayName',sprintf("%s-cluster time-electrode",condition_strings{cond_ind}))
            hold on;
            plot(preVsPoststim_O.time, squeeze(mean_activity_per_cond_clustSpace(cond_ind,:))','DisplayName',sprintf("%s-cluster electrode",condition_strings{cond_ind}))
            hold on;
        end
        title(sprintf("%s, clust ind=%d, pval=%f",title_text,clust_ind,clusters{clust_ind}));
        legend("Location","northwest","FontSize",6)
    end
end

for pos_neg_ind=1:4
    if pos_neg_ind ==1
        clusters = {preVsPoststim_OR.posclusters.prob};
        title_text ="preVsPoststim_OR.posclusters";
    elseif pos_neg_ind ==2
        clusters = {preVsPoststim_OR.negclusters.prob};
        title_text ="preVsPoststim_OR.negclusters";
    elseif pos_neg_ind ==3
        clusters = {preVsPoststim_OF.posclusters.prob};
        title_text ="preVsPoststim_OF.posclusters";
    else
        clusters = {preVsPoststim_OF.negclusters.prob};
        title_text ="preVsPoststim_OF.negclusters";
    end
    for clust_ind=1:size(clusters,2)
        if clusters{clust_ind} > 0.05
            continue;
        end
        
        % get time-electrode mask for current cluster
        curr_clust_mask = clust_mask;
        curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
        curr_clust_mask(curr_clust_mask ~= 0) = 1;
        clust_mask_mean = mean(curr_clust_mask,2);
        clust_electd = find(clust_mask_mean>0);
    
        % get mean activity per sub and cond
        % allSubs_conds_cluseAvgActivity average the activity only in cluster time-electrods.
        % allSubs_conds_AvgActivity average the activity over all electrods and time
        allSubs_conds_cluseAvgActivity = zeros(size(condition_strings,2),size(subs,2),size(preVsPoststim_O.time,2));
        allSubs_conds_AvgActivity = zeros(size(condition_strings,2),size(subs,2),size(preVsPoststim_O.time,2));
        for cond_ind = 1:size(condition_strings,2)
            for sub_ind = 1:size(subs,2)
                curr_sub_cond_struct =  all_conds_timlocked{cond_ind}{sub_ind};
                avg_withoutCz = curr_sub_cond_struct.avg(1:end-1,:);
                avg_withoutCz_clusterMasked = avg_withoutCz .* curr_clust_mask;
                sub_clust_activity_mean = sum(avg_withoutCz_clusterMasked,1) ./ sum(avg_withoutCz_clusterMasked~=0,1);
                allSubs_conds_cluseAvgActivity(cond_ind,sub_ind,:) = sub_clust_activity_mean;

                allSubs_conds_AvgActivity(cond_ind,sub_ind,:) = mean(avg_withoutCz(clust_electd,:),1);
            end
        end
        
        %plot
        mean_activity_per_cond_clustTimeSpace = mean(allSubs_conds_cluseAvgActivity,2);
        mean_activity_per_cond_clustSpace = mean(allSubs_conds_AvgActivity,2);
        fig = figure();
        for cond_ind = 1:size(condition_strings,2)
            plot(preVsPoststim_O.time, squeeze(mean_activity_per_cond_clustTimeSpace(cond_ind,:))','DisplayName',sprintf("%s-cluster time-electrode",condition_strings{cond_ind}))
            hold on;
            plot(preVsPoststim_O.time, squeeze(mean_activity_per_cond_clustSpace(cond_ind,:))','DisplayName',sprintf("%s-cluster electrode",condition_strings{cond_ind}))
            hold on;
        end
        title(sprintf("%s, clust ind=%d, pval=%f",title_text,clust_ind,clusters{clust_ind}));
        legend("Location","northwest","FontSize",6)
    end
end