
function create_alert_LRP_all_pairs_congruent(basename)
loadpath_conflict_avg
EEG.setname = sprintf('%',basename);
EEG.filename = sprintf('%s.set',basename);
%%
eeglab nogui
EEG = pop_loadset('filename', [EEG.filename], 'filepath',[filepath_alert_sinAMA ]);
%% COUNT TOTAL  EPOCHS [72,73=congruents]
EEG = pop_selectevent( EEG, 'type',[72 73],'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = eeg_checkset( EEG ); 
if length(EEG.epoch)<45
   fprintf('%s%s%s%s\n', 'There is less than 45 trials. Epochs =  ',num2str(length(EEG.epoch)),' Subject:',[EEG.filename])
   return
end
%% LOAD again
EEG = pop_loadset('filename', [EEG.filename], 'filepath',[filepath_alert_sinAMA ]);
%% RIGHT RESPONSE 72
EEG = pop_selectevent( EEG, 'type',72,'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = eeg_checkset( EEG ); 
if length(EEG.epoch)<21
   fprintf('%s%s%s%s\n', 'There is less than 21 trials. Epochs =  ',num2str(length(EEG.epoch)),' Subject:',[EEG.filename])
   return
end
[data] = eeglab2fieldtrip(EEG,'raw') % convert to internally used FT_EEG format
chanlocs = EEG.chanlocs;clear EEG; 
% average across trials
cfg         = [];
cfg.latency = [-0.2 0.996]; % 
avgR = ft_timelockanalysis(cfg,data);    
%% LEFT RESPONSE 73
eeglab nogui
EEG.setname = sprintf('%',basename);
EEG.filename = sprintf('%s.set',basename);
%
EEG = pop_loadset('filename', [EEG.filename], 'filepath',[filepath_alert_sinAMA ]);

EEG = pop_selectevent( EEG, 'type',73,'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = eeg_checkset( EEG ); 
if length(EEG.epoch)<21
   fprintf('%s%s%s%s\n', 'There is less than 21 trials. Epochs =  ',num2str(length(EEG.epoch)),' Subject:',[EEG.filename])
   return
end
[data] = eeglab2fieldtrip(EEG,'raw'); 
chanlocs = EEG.chanlocs;   clear EEG; 
cfg         = [];
cfg.latency = [-0.2 0.996];%  
avgL = ft_timelockanalysis(cfg,data);
    
%% CALCULATE LRP
cfg             = [];
layout=load(['C:\proyectos_Cambridge\Conflict_project1\2022\SCRIPTS_USADOS_nov2022\layout_wena93ch_nov2022.mat']);
cfg.layout = layout.layout
cfg.channelcmb = {'E36' 'E104'%29 78
'E31' 'E80'%25 61
'E7' 'E106'%6 80
'E54' 'E79'%42 60
'E37' 'E87'%30 66
'E30' 'E105' %24 79
'E13' 'E112' %11 85
'E12' 'E5'   %10 4
'E61' 'E78'  %48 59
'E53' 'E86'  %41 65
'E42' 'E93'  %34 70
'E29' 'E111' %23 84
'E20' 'E118' %16 90
'E67' 'E77'  %52 58
'E60' 'E85'  %47 64
'E52' 'E92'  %40 69
'E47' 'E98'  %37 73
'E41' 'E103' %33 77
'E35' 'E110' %28 83
'E28' 'E117' %22 89
'E24' 'E124' %19 93
'E19' 'E4'   %15 3
'E71' 'E76'  %54 57
'E66' 'E84'  %51 63
'E59' 'E91'  %46 68
'E51' 'E97'  %39 72
'E46' 'E102' %36 76
'E40' 'E109' %32 82
'E34' 'E116' %27 88
'E27' 'E123'%21 92
'E23' 'E3' %18 2
'E18' 'E10' %14 8
'E70' 'E83' %53 62
'E65' 'E90'  %50 67
'E58' 'E96'   %45 71
'E50' 'E101'   %38 75
'E45' 'E108'   %35 81
'E39' 'E115'   %31 87
'E33' 'E122'   %26 91
'E26' 'E2'  %20 1
'E22' 'E9'  }%17 7
lrp=ft_lateralizedpotential(cfg,avgL,avgR);  
save([basename(1:15) '_lrp_alert_congruent.mat'], 'lrp');
end
%%
% % load single subject ERPs in a single cell array
% all_lrp = cell(1,length(list_participants));
% for i=1:length(list_participants)
%     load([list_participants{i}(1:15) '_lrp_alert_congruent.mat']);
%     all_lrp{i} = lrp;
% end
% 
% save(['all_lrp_alert_congruent.mat'], 'all_lrp');
