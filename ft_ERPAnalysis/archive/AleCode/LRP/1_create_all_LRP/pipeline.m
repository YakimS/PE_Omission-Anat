%% 2023_LRP pipeline 
clear;clc; 
list_participants={'002_CA_WR_awake_CLEAN';'004_CA_WR_awake_CLEAN';'005_CA_WR_awake_CLEAN';'009_CA_WR_awake_CLEAN';'010_CA_WR_awake_CLEAN';'013_CA_WR_awake_CLEAN';'016_CA_WR_awake_CLEAN';'018_CA_WR_awake_CLEAN';'019_CA_WR_awake_CLEAN';'020_CA_WR_awake_CLEAN';'021_CA_WR_awake_CLEAN';'022_CA_WR_awake_CLEAN';'023_CA_WR_awake_CLEAN';'024_CA_WR_awake_CLEAN';'025_CA_WR_awake_CLEAN';'026_CA_WR_awake_CLEAN';'027_CA_WR_awake_CLEAN';'028_CA_WR_awake_CLEAN';'030_CA_WR_awake_CLEAN';'031_CA_WR_awake_CLEAN';'032_CA_WR_awake_CLEAN';'036_CA_WR_awake_CLEAN';'039_CA_WR_awake_CLEAN';'040_CA_WR_awake_CLEAN';'041_CA_WR_awake_CLEAN';'047_CA_WR_awake_CLEAN';'048_CA_WR_awake_CLEAN';'049_CA_WR_awake_CLEAN';'050_CA_WR_awake_CLEAN';'051_CA_WR_awake_CLEAN';'052_CA_WR_awake_CLEAN';'053_CA_WR_awake_CLEAN'};
for a = 1:length(list_participants)
basename=list_participants{a}%
%% alert CR lrp
create_alert_LRP_all_pairs_congruent(basename)% here in line 25, I used eeglab2fieldtrip
%% create_alert_LRP_all_pairs_incongruent(basename)% 
end
