%% args set
args = {};
args.subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; % add 23 to night ones
args.ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat');
args.bl = 100;
args.contrasts = {{'OEf5','OR'},{'OEf6','OR'},{'OFFirst5','ORFirst5'},{'OEf6','ORf6'}};
args.pre_vs_post_conds_names = {'OEf5','OEf6','OR','ORf6','OFFirst5','ORFirst5','T','O'};
args.output_main_dir = sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm');

args.wake_files_name_suffix = 'wake_all_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save("spatioTempoAnaly_run_all.mat","args",'-mat')
args.wake_files_name_suffix = 'wake_morning_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save("spatioTempoAnaly_run_morning.mat","args",'-mat')
args.wake_files_name_suffix = 'wake_night_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save("spatioTempoAnaly_run_night.mat","args",'-mat')