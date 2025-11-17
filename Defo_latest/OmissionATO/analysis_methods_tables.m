
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionATO')
[v, subs,dirs,epoch_time, events,ft_read_sens_string] = ATO_configuration();
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionATO')


%%

sovs = {v.wn,v.N2,v.N3,v.REM}; 
conds = {v.AOmiF,v.AOmiR};

trial_stats = analyze_trial_counts(subs, sovs, conds, dirs.ft_cond_input, dirs.ft_cond_output);

