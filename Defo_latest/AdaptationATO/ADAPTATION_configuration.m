function [v, subs, dirs, time, events] = ADAPTATION_configuration()
    % '05','06','07','12'
    subs = {'01','02','03','04','08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
   
    time = -0.1:0.004:0.576;

    dirs = struct();
    dirs.output_main = "D:\OExpOut\adapt_res";
    dirs.ft_cond_input = "D:\OExpOut\processed_data\ft_subSovCond";
    dirs.ft_cond_output = "D:\OExpOut\processed_data\ft_processed";
    dirs.libs = 'D:\matlab_libs';
    dirs.curr_project = genpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest');
    
    ft_read_sens_string = 'GSN-HydroCel-129.sfp';

    % https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
    restoredefaultpath 
    addpath(sprintf('%s\\fieldtrip-20241219', dirs.libs)) % fieldtrip-20230223
    ft_defaults;
    addpath(sprintf('%s\\eeglab2024.2', dirs.libs)) %%eeglab2023.0'
    close;
    addpath(dirs.libs)
    addpath(sprintf('%s\\klabhub-bayesFactor-04b80fd', dirs.libs))
    addpath(dirs.curr_project)


    % Create main structure
    v = struct();
    v.N1 = defineExpStruct('N1', 'N1', 'N1 sleep', false, [0.9, 0.1, 0.9]);
    v.N2 = defineExpStruct('N2', 'N2', 'N2 sleep', false, [1, 0.7, 0]);
    v.N3 = defineExpStruct('N3', 'N3', 'N3 sleep', false, [0.1, 0.9, 0.1]);
    v.REM = defineExpStruct('REM', 'REM', 'REM sleep', false, [0.9, 0.1, 0.1]);
    v.wn = defineExpStruct('wake_night', 'wn', 'Wake pre-sleep', false, [0, 0.7, 1]);

    v.N2wo = defineExpStruct('N2wo', 'N2wo', 'N2 w/o events', false, v.N2.color);
    v.N2woSs = defineExpStruct('N2woSs', 'N2woSs', 'N2 w/o spindles', false, v.N2.color);
    v.N2woKc = defineExpStruct('N2woKc', 'N2woKc', 'N2 w/o k-complexes', false, v.N2.color);
    v.N2wSs = defineExpStruct('N2wSs', 'N2wSs', 'N2 w/ spindles', false, v.N2.color);
    v.N2wKc = defineExpStruct('N2wKc', 'N2wKc', 'N2 w/ k-complexes', false, v.N2.color);
    v.N2wJSs = defineExpStruct('N2wJSs', 'N2wJSs', 'N2 w/ spindles', false, v.N2.color);
    v.N2wJKc = defineExpStruct('N2wJKc', 'N2wJKc', 'N2 w/ k-complexes', false, v.N2.color);
    v.N2wSsKc = defineExpStruct('N2wSsKc', 'N2wSsKc', 'N2 w/ k-complexes & spindles', false, v.N2.color);
    v.N2EliwJSs = defineExpStruct('N2EliwJSs', 'N2EliwJSs', 'N2 w/ spindles', false, [0.6, 0.8, 0.0]);
    v.N2EliwJKc = defineExpStruct('N2EliwJKc', 'N2EliwJKc', 'N2 w/ k-complexes', false, [0.8, 0.47, 0.13]);
    v.N2EliwSsKc = defineExpStruct('N2EliwSsKc', 'N2EliwSsKc', 'N2 w/ k-complexes & spindles', false, v.N2.color);
    v.N2Eliwo = defineExpStruct('N2Eliwo', 'N2Eliwo', 'N2 w/o events', false, [0.91, 0.64, 0.09]);

    v.tREM = defineExpStruct('tREM', 'tREM', 'tonic REM sleep', false, v.REM.color);
    v.pREM = defineExpStruct('pREM', 'pREM', 'phasic REM sleep', false, v.REM.color);
    v.wake_morning = defineExpStruct('wake_morning', 'wm', 'Wake post-sleep', false, [0.5, 0.8, 1]);
    v.wake_morning_beg = defineExpStruct('wake_morning_beg', 'wmbeg', 'Beggining Wake Post', false,  [0.8, 0.3, 1]);
    v.wake_morning_end = defineExpStruct('wake_morning_end', 'wmend', 'End Wake Post', false, [0.4, 0.1, 0.8]);
    v.wake_night_beg = defineExpStruct('wake_night_beg', 'wnbeg', 'Beggining Wake Pre', false, [0.3, 0.9, 0.7]);
    v.wake_night_mid1 = defineExpStruct('wake_night_mid1', 'wnmid1', 'Mid1 Wake Pre', false, [0.15, 0.75, 0.7]);
    v.wake_night_mid2 = defineExpStruct('wake_night_mid2', 'wnmid2', 'Mid2 Wake Pre', false, [0.1, 0.45, 0.8]);
    v.wake_night_mid3 = defineExpStruct('wake_night_mid3', 'wnmid3', 'Mid3 Wake Pre', false, [0.1, 0.2, 0.9]);
    v.wake_night_end = defineExpStruct('wake_night_end', 'wnend', 'End Wake Pre', false,  [0, 0.1, 1]);
    v.wake = defineExpStruct('wake', 'WAll', 'Wake Pre+Post', false, [0.6, 0.9, 1]);
    
    % Define components
    v.N100 = defineExpComponent('N100', 'N100', [0.05, 0.15], false);
    v.P2 = defineExpComponent('P2', 'P2', [0.15, 0.25], true);
    v.N350 = defineExpComponent('N350', 'N350', [0.3, 0.5], false);
    
    
    % Basic tones
    tone_prefixes = {'Bl0', 'Nbl'};
    for prefix = tone_prefixes
        for i = 1:4
            if strcmp('Bl0',prefix)
                name = sprintf('T%dn500', i);
            else
                name = sprintf('%sT%dn500', prefix{1}, i);
            end
            
            short_name = sprintf('%sT%d', prefix{1}, i);
            color = [mod(56+59*i, 256)/256, mod(166+9*i, 256)/256, mod(165-40*i, 256)/256];
            v.(short_name) = defineExpStruct(name, short_name, sprintf('T%d', i), false, color);
        end
    end
    
    % Generate frequency-based tones
    tone_hz = [650,845,1098,1428,1856,2413,3137,4079,5302];
    for hz = tone_hz
        for pos = 1:4
            for prefix = tone_prefixes
                if strcmp('Bl0',prefix)
                    import_name = sprintf('T%d_%d', hz, pos);
                else
                    import_name = sprintf('%sT%d_%d', prefix{1}, hz, pos);
                end
                code_name =  sprintf('%sT%d_%d', prefix{1}, hz, pos);
                v.(code_name) = defineExpStruct(import_name, import_name, sprintf('%dth %d', pos,hz), false, [0, 0, 0]);
            end
        end
    end
    
    
    tones_diffs={"low", "mid", "high"};
    for tones_i =1:numel(tones_diffs)
        for pos = 1:4
            import_name = sprintf("T_prev%s_%d",tones_diffs{tones_i},pos);
            v.(import_name) = defineExpStruct(import_name, import_name, import_name, false, [0, 0, 0]);
        end
    end
    
    % Add A500 and T500 variants
    variants = {'T500', 'A500', 'A500ofT500'};
    for prefix = tone_prefixes
        for variant = variants
            for i = 1:4
                base_name = sprintf('%s%s_%d', prefix{1}, variant{1}, i);
                first_name = sprintf('%s1st%s_%d', prefix{1}, variant{1}, i);
                
                v.(base_name) = defineExpStruct(base_name, base_name, base_name, false, [mod(56+40*i, 256)/256, mod(166+7*i, 256)/256, mod(165-20*i, 256)/256]);
                v.(first_name) = defineExpStruct(first_name, first_name, first_name, false, [mod(56+40*i, 256)/256, mod(166+7*i, 256)/256, mod(165-20*i, 256)/256]);
            end
        end
    end
    
    % [-0.1, 1.16]
    % AblT1 = defineExpStruct("AblT1", "AblT1", "1st tone", false);
    % AblT2 = defineExpStruct("AblT2", "AblT2", "2nd tone", false);
    % AblT3 = defineExpStruct("AblT3", "AblT3", "3rd tone", false);
    % AblT4 = defineExpStruct("AblT4", "AblT4", "4th tone", false);
    % 
    % AT1 = defineExpStruct("AT1", "AT1", "1st tone", false, [56/256, 166/256, 165/256]);
    % AT2 = defineExpStruct("AT2", "AT2", "2nd tone", false,  [115/256, 175/256, 72/256]);
    % AT3 = defineExpStruct("AT3", "AT3", "3rd tone", false, [237/256, 173/256, 8/256]);
    % AT4 = defineExpStruct("AT4", "AT4", "4th tone", false,  [255/256, 124/256, 5/256]);
    
    % NblAT1 = defineExpStruct("NblAT1", "NblAT1", "1st tone", false);
    % NblAT2 = defineExpStruct("NblAT2", "NblAT2", "2nd tone", false);
    % NblAT3 = defineExpStruct("NblAT3", "NblAT3", "3rd tone", false);
    % NblAT4 = defineExpStruct("NblAT4", "NblAT4", "4th tone", false);


    events = struct();
    events.tone = struct();
    events.tone.("event_time") = [0,0.1];
    events.tone.("event_color") = [.2, .2 ,.2,  0.05];
    events.tone.('event_text_color') = [0,0,0];
    events.tone.("event_text") = "Tone";
    events.n1 = struct();
    events.n1.("event_time") = v.N100.latency;
    events.n1.("event_color") = [.2, .2 ,.2, 0.05];
    events.n1.("event_text") = v.N100.long_s;
    events.p2 = struct();
    events.p2.("event_time") = v.P2.latency;
    events.p2.("event_color") = [.2, .2 ,.2,  0.05];
    events.p2.('event_text_color') = [0,0,0];
    events.p2.("event_text") = v.P2.long_s;
    events.n350 = struct();
    events.n350.("event_time") = v.N350.latency;
    events.n350.("event_color") = [.2, .2 ,.2,  0.05];
    events.n350.("event_text") = v.N350.long_s;
    events.n350.('event_text_color') = [0,0,0];
    events.adaptor = struct();
    events.adaptor.("event_time") = 0;
    events.adaptor.("event_color") = [.2, .2 ,.2];
    events.adaptor.("event_text") = 'Adaptor';
    events.adaptor.('event_text_color') = [0,0,0];
end


function expStruct = defineExpStruct(import_s, short_s, long_s, isBaseline,color)
    expStruct = struct();
    expStruct.import_s = import_s;
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.isBaseline = isBaseline;
    expStruct.color = color;
end

% isPositive is 1 or -1
function expStruct = defineExpComponent(short_s, long_s, latency,isPositive)
    expStruct = struct();
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.latency = latency;
    expStruct.isPositive = isPositive;
end
