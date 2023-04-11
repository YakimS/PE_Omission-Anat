
%%
restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0
eeglab

%% args set
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
ft_cond_dir= 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\data_in_ft_cond_fomat';
ft_testRes_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\ft_tests_results_mats';
image_output_dir= 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\spatiotemp_clusterPerm';
wake_files_name_suffix = 'wake_night_referenced';
conds_string = {'OF','OR','O','T'};
baseline_timerange = 52; % time from 

importer = ft_importer;
if ~exist("allConds_ftRaw","var")    allConds_ftRaw= importer.get_rawFt_conds(ft_cond_dir,conds_string,wake_files_name_suffix,subs);  end
if ~exist("allConds_timlocked","var")    allConds_timlocked=importer.get_allConds_timelocked(allConds_ftRaw,ft_cond_dir,conds_string,subs); end
if ~exist("allConds_timlocked_bl","var")   allConds_timlocked_bl=importer.get_allConds_timelocked_baseline([allConds_timlocked],ft_cond_dir,conds_string,subs,baseline_timerange);end
if ~exist("allConds_grandAvg","var")    allConds_grandAvg = importer.get_allConds_grandAvg(allConds_timlocked,ft_cond_dir,conds_string);end
if ~exist("neighbours","var")    neighbours = importer.get_neighbours(allConds_timlocked{1}{1}.label);end
time = allConds_grandAvg{1}.time;
electrods = allConds_grandAvg{1}.elec.label;

%% Find avg and std of baseline
number_of_electrodes = 93;
subs_avgBaseline_PerCondAndElectd = zeros(size(conds_string,2),size(subs,2),number_of_electrodes);
for cond_ind = 1:size(conds_string,2)
    for sub_i = 1:size(subs,2)
        subs_avgBaseline_PerCondAndElectd(cond_ind,sub_i,:) = allConds_timlocked_bl{cond_ind}{sub_i}.avg(:,1);
    end
end

avg_perCond = mean(subs_avgBaseline_PerCondAndElectd,[2,3]); 
stdperCond = std(subs_avgBaseline_PerCondAndElectd,0,[2,3]); 
for cond_ind = 1:size(conds_string,2)
    fprintf("Cond %s grand avg is: %d, std is:%d\n",conds_string{cond_ind},avg_perCond(cond_ind),stdperCond(cond_ind))
end

%% Is the baseline activity signigicantly different than 0

number_of_different_than_0_baseline = 0;
time = allConds_timlocked{1}{1}.time;
fig = figure;
for sub_i = 1:size(subs,2)   
    ax = subplot(ceil(size(subs,2)/5),5,sub_i);
    curr_sub_cond_struct =  allConds_timlocked{3}{sub_i}; %%%%% 3 is O?
    time0_ind = find(curr_sub_cond_struct.time == 0, 1);
    baseline = curr_sub_cond_struct.avg(:,1:time0_ind);
    for elecd_ind=1:size(neighbours,2)
        plot(ax, time(1:time0_ind), baseline(elecd_ind,:))
        hold on;
        [h,p,ci,stats] = ttest(baseline(elecd_ind,:));
        if p<0.6
            fprintf("sub:%s, elecd:%d",subs{sub_i},elecd_ind)
            number_of_different_than_0_baseline = number_of_different_than_0_baseline+1;
        end
    end
    hold off;
    axis([time(1) time(time0_ind) -2.5 2.5])
    title(sprintf("sub %s",subs{sub_i}));
    
    %legend("Location","northwest","FontSize",6)
end

set(gcf,'Position',[100 100 900 600]); %  [x y width height]
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'amplitude');
xlabel(han,'Time (s)');

title(han,'All electrodes, baseline activity per subject');
saveas(gcf, sprintf("%s/Cond-O_baseline_perSub_allelectd.png",image_output_dir))
fprintf("number_of_different_than_0_baseline: %d,   out of: %d\n",number_of_different_than_0_baseline,size(subs,2)*size(neighbours,2))


%% 
preVsPoststim_OF  = load(sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\ft_tests_results_mats\\preVsPoststim_bl-%d_OF.mat",baseline_timerange));
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

%% get all subs sig clusters prob
for sub_i =1:size(subs,2)
    file_path = sprintf("%s\\%s%s",ft_testRes_dir,'OFVsOR_sub-', subs{sub_i});
    currsub_stat  = load(file_path{1});
    currsub_stat_posclusters_prob = {currsub_stat.posclusters.prob};
    all_pos_clusters = [];
    for cluster_ind =  1:size(currsub_stat_posclusters_prob,2)
        if currsub_stat_posclusters_prob{cluster_ind} <0.2
            all_pos_clusters = [all_pos_clusters , currsub_stat_posclusters_prob{cluster_ind}];
        end
    end
    currsub_stat_negclusters_prob = {currsub_stat.negclusters.prob};
    all_neg_clusters = [];
    for cluster_ind =  1:size(currsub_stat_negclusters_prob,2)
        if currsub_stat_negclusters_prob{cluster_ind} <0.2
            all_neg_clusters = [all_neg_clusters , currsub_stat_negclusters_prob{cluster_ind}];
        end
    end
    if ~isempty(all_pos_clusters) || ~isempty(all_neg_clusters)
        fprintf("Sub %s clusters prob, positive: %s ; negative: %s\n",subs{sub_i}, join(string(all_pos_clusters),","),join(string(all_neg_clusters),","))
    end
end

%% Test the common electrodes in every subjects OF vs. OR cluster test

allSub_masksSum = zeros(size(electrods,2),size(time,2));
number_of_sub_with_sig_clusters = 0;
for sub_i=1:size(subs,2)
    curr_FOvsRO_stat = load(sprintf("%s\\OFVsOR_sub-%s",ft_testRes_dir,subs{sub_i}));
    if ~all(curr_FOvsRO_stat.mask(:)==0)
        allSub_masksSum = allSub_masksSum+curr_FOvsRO_stat.mask;
        number_of_sub_with_sig_clusters = number_of_sub_with_sig_clusters +1;
    end
end
c = pcolor(time, linspace(1,size(curr_FOvsRO_stat.label,1) , size(curr_FOvsRO_stat.label,1)), allSub_masksSum);
xlabel('Time');
ylabel('Electrode');
title(sprintf('Prevelence of each time-electrode in the %d subjects spatiotemporal clusters',size(subs,2)), ...
    sprintf('Number of subjects with sig electrodes is: %d',number_of_sub_with_sig_clusters))
colorbar
saveas(gcf, sprintf("%s/FOvsRO_prevelenceInSpatiotemporalCluster.png",image_output_dir))
%%

for i=1:5
    cfg=[];
    cfg.colorbar = 'yes'; 
    examp = allConds_grandAvg{1};
    examp = rmfield(examp,["dof","var"]);
    examp.label = examp.label(1:92);
    starttime_i = time0_ind+((i-1)*25);
    if i<5
        endtime_i = time0_ind+(i*25);
    else
        endtime_i = size(time,2);
    end
    cfg.zlim = [0 3.5];
    examp.avg = allSub_masksSum(:,starttime_i:endtime_i);
    examp.time = time(starttime_i:endtime_i);
    ft_topoplotER(cfg, examp)
    saveas(gcf, sprintf("%s/FOvsRO_ElecdAvgClustPervelance_bl-%d_time-[%.2f-%.2f].png",image_output_dir,baseline_timerange,time(starttime_i),time(endtime_i)))
end
%%
all_conds_preVsPoststim = {};
all_conds_preVsPoststim{1}  = load("C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\ft_tests_results_mats\preVsPoststim_bl-52_OF.mat");
all_conds_preVsPoststim{2}  = load("C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\ft_tests_results_mats\preVsPoststim_bl-52_OR.mat");
all_conds_preVsPoststim{3}  = load("C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\ft_tests_results_mats\preVsPoststim_bl-52_O.mat");

%% Get time-electodes clusters of cond O/OF/OR vs. baseline. Look for difference in OF vs. OR in that time-electrode range
% with cluster permutatiton diff results

curr_condition_strings = {'OF','OR','O'};
for cond_i=1:3
    for pos_neg_ind=1:2
        if pos_neg_ind ==1
            clusters = {all_conds_preVsPoststim{cond_i}.posclusters.prob};
            clust_mask = all_conds_preVsPoststim{cond_i}.posclusterslabelmat;
            title_text = sprintf("PreVsPoststim %s - positive clusters",curr_condition_strings{cond_i});
            pos_or_neg_text = 'pos';
        else
            clusters = {all_conds_preVsPoststim{cond_i}.negclusters.prob};
            clust_mask = all_conds_preVsPoststim{cond_i}.negclusterslabelmat;
            title_text = sprintf("PreVsPoststim %s - negative clusters",curr_condition_strings{cond_i});
            pos_or_neg_text = 'neg';
        end
        for clust_ind=1:size(clusters,2)
            if clusters{clust_ind} > 0.05
                continue;
            end
            
            % get time-electrode mask for current cluster
            curr_clust_mask = clust_mask;
            curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
            curr_clust_mask(curr_clust_mask ~= 0) = 1;
            temp = mean(curr_clust_mask,2);
            clust_electd = find(temp>0);
            temp = mean(curr_clust_mask,1);
            clust_times = find(temp>0);

            stat = cluster_permu_erp(subs,curr_condition_strings,allConds_timlocked,clust_electd,1,2,[time(clust_times(1)),time(clust_times(end))]);
            stat2 = cluster_permu_erp(subs,curr_condition_strings,allConds_timlocked,curr_clust_mask,1,2,[time(clust_times(1)),time(clust_times(end))]);

            % get mean activity per sub and cond
            % allSubs_conds_cluseAvgActivity average the activity only in cluster time-electrods.
            % allSubs_conds_AvgActivity average the activity over all electrods and time
            allSubs_conds_cluseAvgActivity = zeros(size(conds_string,2),size(subs,2),size(time,2));
            allSubs_conds_AvgActivity = zeros(size(conds_string,2),size(subs,2),size(time,2));
            for cond_j = 1:size(conds_string,2)
                for sub_i = 1:size(subs,2)
                    curr_sub_cond_struct =  allConds_timlocked{cond_j}{sub_i};
                    avg_withoutCz = curr_sub_cond_struct.avg(1:end-1,:);
                    avg_withoutCz_clusterMasked = avg_withoutCz .* curr_clust_mask;
                    sub_clust_activity_mean = sum(avg_withoutCz_clusterMasked,1) ./ sum(avg_withoutCz_clusterMasked~=0,1);
                    allSubs_conds_cluseAvgActivity(cond_j,sub_i,:) = sub_clust_activity_mean;
                    allSubs_conds_AvgActivity(cond_j,sub_i,:) = mean(avg_withoutCz(clust_electd,:),1);
                end
            end
            
            %%%%%%%   plot
            mean_activity_per_cond_clustTimeSpace = squeeze(mean(allSubs_conds_cluseAvgActivity,2));
            mean_activity_per_cond_clustSpace = squeeze(mean(allSubs_conds_AvgActivity,2));
            figure();
            for cond_j = 1:size(curr_condition_strings,2)
                plot(time, mean_activity_per_cond_clustTimeSpace(cond_j,:)','DisplayName',sprintf("%s-cluster time-electrode",curr_condition_strings{cond_j}))
                hold on;
                plot(time, mean_activity_per_cond_clustSpace(cond_j,:)','DisplayName',sprintf("%s-cluster electrode",curr_condition_strings{cond_j}))
                hold on;
            end
            % plot T cond for reference
             plot(time, mean_activity_per_cond_clustSpace(4,:)','DisplayName',sprintf("%s-cluster electrode",conds_string{4}),'Color','black')
            % plot sig points
            if ~all(stat.mask ==0)
                mask_in_trial = zeros(size(time,2),1);
                mask_in_trial(clust_times(1):clust_times(end)) = stat.mask;
                plot(time(find(mask_in_trial)),mean_activity_per_cond_clustSpace(3,find(mask_in_trial)),'*', 'DisplayName', 'OF vs. OR - electrode',"Color","red")
            end
            if ~all(stat2.mask ==0)
                mask_in_trial = zeros(size(time,2),1);
                mask_in_trial(clust_times(1):clust_times(end)) = stat2.mask;
                plot(time(find(mask_in_trial)),mean_activity_per_cond_clustTimeSpace(3,find(mask_in_trial)),'*', 'DisplayName','OF vs. OR - time-electrode',"Color","blue")
            end
            electrods_string = join({all_conds_preVsPoststim{cond_i}.label{clust_electd}},",");
            electrods_string = erase(electrods_string,"E");
            electrods_string = electrods_string{1};
            title(sprintf("%s, clust ind=%d, pval=%f, baseline=%dms",title_text,clust_ind,clusters{clust_ind},baseline_timerange), ...
                sprintf("%d Electrodes: %s\n%s",size(clust_electd,1),electrods_string(1:round(size(electrods_string,2)/2)),electrods_string(round(size(electrods_string,2)/2):end)),"FontSize",8);
            legend("Location","northeast","FontSize",5);
            axis([time(1) time(end) -1 1.5])
            saveas(gcf, sprintf("%s/cond-%s_%s_bl-%d_clustInd-%d.png",image_output_dir,curr_condition_strings{cond_i},pos_or_neg_text,baseline_timerange,clust_ind))
        end
    end
end

%%
function stat = cluster_permu_erp(subs,curr_condition_strings,allConds_timlocked,clust_mask,cond1,cond2,latency)
    all_conds_timelocked_currClustElecd = cell(1, size(curr_condition_strings,2));
    for cond_j = 1:size(curr_condition_strings,2)
        for sub_i = 1:size(subs,2)
            curr_subcond = allConds_timlocked{cond_j}{sub_i};
            curr_subcond = rmfield(curr_subcond,'dof');
            curr_subcond = rmfield(curr_subcond,'var');
            curr_subcond.label = {'eletd_avg'};
            if size(clust_mask,2) == 1 % there is only electrodes
                %curr_subcond.var = std(curr_subcond.avg(clust_mask,:),1,1);
                curr_subcond.avg = mean(curr_subcond.avg(clust_mask,:),1);
            else % theres time-electorde
                avg_withoutCz = curr_subcond.avg(1:end-1,:);
                avg_withoutCz_clusterMasked = avg_withoutCz .* clust_mask;
                sub_clust_activity_mean = sum(avg_withoutCz_clusterMasked,1) ./ sum(avg_withoutCz_clusterMasked~=0,1);
                curr_subcond.avg = sub_clust_activity_mean;
            end
            all_conds_timelocked_currClustElecd{cond_j}{sub_i} = curr_subcond;
        end
    end

    % cluster permutation anaslysis 
    % define the parameters for the statistical comparison
    cfg = [];
    cfg.channel     = {'eletd_avg'};
    cfg.latency     = latency;
    cfg.avgovertime = 'no';
    cfg.parameter   = 'avg';
    cfg.method      = 'analytic';
    cfg.statistic   = 'ft_statfun_depsamplesT';
    cfg.alpha       = 0.05;
    cfg.correctm    = 'no';            
    Nsub = size(subs,2);
    cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
    cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
    cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
    cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
    stat = ft_timelockstatistics(cfg, all_conds_timelocked_currClustElecd{cond1}{:}, all_conds_timelocked_currClustElecd{cond2}{:});   % don't forget the {:}!
end