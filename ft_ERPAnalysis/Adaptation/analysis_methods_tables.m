
[v, subs,dirs,time, events] = ADAPTATION_configuration();

%%

sovs = {v.wn,v.N1,v.N2,v.N3,v.REM,v.pREM,v.tREM,v.N2EliwJSs,v.N2EliwJKc,v.N2Eliwo}; 
conds = {v.Bl0T1,v.Bl0T2,v.Bl0T3,v.Bl0T4};

trial_stats = analyze_trial_counts(subs, sovs, conds, dirs.ft_cond_input, dirs.ft_cond_output, time);

