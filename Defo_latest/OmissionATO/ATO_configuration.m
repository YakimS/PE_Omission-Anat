function [v, subs, dirs, time, events,ft_read_sens_string] = ATO_configuration(analysis_type)
    dirs = struct();
    dirs.output_main = "D:\OExpOut\spatioTemp";
    dirs.ft_cond_input = "D:\OExpOut\processed_data\ft_subSovCond";
    dirs.ft_cond_output = "D:\OExpOut\processed_data\ft_processed";
    dirs.libs = 'D:\matlab_libs';
    dirs.curr_project = genpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest');
    dirs.output_adamformat = 'C:\mvpa\ATO\preprocessed';
    dirs.output_adam_firstlvl = 'C:\mvpa\ATO\firstlevel';
    dirs.output_adam_firstlvl_loo = 'C:\loo\ATO';
    dirs.output_adam_plots = 'C:\mvpa\ATO\plots';

    if strcmp(analysis_type,'cp')
        get_cp_dependencies(dirs.libs)
    elseif strcmp(analysis_type,'mvpa')
        get_mvpa_dependencies(dirs.libs)
    else
        error('grande problemo')
    end
    addpath(dirs.curr_project)
    addpath(dirs.libs)

    v = struct();

    % '05','06','07','12'
    subs = {'08','09','10','11','13','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; 

    time = -1.6:0.004:2.656;
  
    ft_read_sens_string = 'GSN-HydroCel-129.sfp';

    % Create add all conds
    v.N1 = defineExpStruct("N1", "N1", "N1", false, [0.9, 0.1, 0.9]);
    v.N2 = defineExpStruct("N2", "N2", "N2", false,[1, 0.6, 0]);
    v.N3 = defineExpStruct("N3", "N3", "N3", false,[0.1, 0.9, 0.1]);
    v.REM = defineExpStruct("REM", "REM", "REM", false,[0.9, 0.1, 0.1]);
    v.wn = defineExpStruct("wake_night", "wn", "Wake Pre", false,[0, 0.7, 1]);

    % v.N2wo = defineExpStruct('N2wo', 'N2wo', 'N2 w/o events', false, v.N2.color);
    % v.N2woSs = defineExpStruct('N2woSs', 'N2woSs', 'N2 w/o spindles', false, v.N2.color);
    % v.N2woKc = defineExpStruct('N2woKc', 'N2woKc', 'N2 w/o k-complexes', false, v.N2.color);
    % v.N2wSs = defineExpStruct('N2wSs', 'N2wSs', 'N2 w/ spindles', false, v.N2.color);
    % v.N2wKc = defineExpStruct('N2wKc', 'N2wKc', 'N2 w/ k-complexes', false, v.N2.color);
    % v.N2wJSs = defineExpStruct('N2wJSs', 'N2wJSs', 'N2 w/ spindles', false, v.N2.color);
    % v.N2wJKc = defineExpStruct('N2wJKc', 'N2wJKc', 'N2 w/ k-complexes', false, v.N2.color);
    % v.N2wSsKc = defineExpStruct('N2wSsKc', 'N2wSsKc', 'N2 w/ k-complexes & spindles', false, v.N2.color);
    v.N2EliwJSs = defineExpStruct('N2EliwJSs', 'N2EliwJSs', 'N2 w/ spindles', false, [0.6, 0.8, 0.0]);
    v.N2EliwJKc = defineExpStruct('N2EliwJKc', 'N2EliwJKc', 'N2 w/ k-complexes', false, [0.8, 0.47, 0.13]);
    v.N2EliwSsKc = defineExpStruct('N2EliwSsKc', 'N2EliwSsKc', 'N2 w/ k-complexes & spindles', false, v.N2.color);
    v.N2Eliwo = defineExpStruct('N2Eliwo', 'N2Eliwo', 'N2 w/o events', false, [0.91, 0.64, 0.09]);


    % [-1.6, 2.66]
    v.AOmi = defineExpStruct("AO", "AO", "Omission", false, [0, 0, 0]);
    v.AOmiF  = defineExpStruct("AOF", "AOF", "Predictable Omission", false, [0, 0, 0]);
    v.AOmiR = defineExpStruct("AOR", "AOR", "Unpredictable Omission", false, [0, 0, 0]);
    v.intblksmpAO = defineExpStruct("intblksmpAO", "intblksmpAO", "Baseline", true, [0, 0, 0]);

    % % [-0.1, 1.16]
    % % No ampl Baseline
    % NblAT1 = defineExpStruct("NblAT1", "NblAT1", "1st tone", false);
    % NblAT2 = defineExpStruct("NblAT2", "NblAT2", "2nd tone", false);
    % NblAT3 = defineExpStruct("NblAT3", "NblAT3", "3rd tone", false);
    % NblAT4 = defineExpStruct("NblAT4", "NblAT4", "4th tone", false);
    % NblAOmi = defineExpStruct("NblAO", "NblAO", "Omission", false, [0, 0, 0]);
    % NblAOmiR = defineExpStruct("NblAOR", "NblAOR", "Unpredictable Omission", false, [0, 0, 0]);
    % NblAOmiF = defineExpStruct("NblAOF", "NblAOF", "Predictable Omission", false, [0, 0, 0]);
    % intblksmpNblAO = defineExpStruct("intblksmpNblAO", "intblksmpNblAO", "Baseline", true, [0, 0, 0]);
    % intblksmpNblAOR = defineExpStruct("intblksmpNblAOR", "intblksmpNblAOR", "Baseline", true, [0, 0, 0]);
    % intblksmpNblAOF = defineExpStruct("intblksmpNblAOF", "intblksmpNblAOF", "Baseline", true, [0, 0, 0]);
    % 
    % % Ampl baseline pre-O / T
    % AblOmi = defineExpStruct("AblO", "AblO", "Omission", false, [0, 0, 0]);
    % intblksmpAblO = defineExpStruct("intblksmpAblO", "intblksmpAblO", "Baseline", true, [0, 0, 0]);
    % AblT1 = defineExpStruct("AblT1", "AblT1", "1st tone", false);
    % AblT2 = defineExpStruct("AblT2", "AblT2", "2nd tone", false);
    % AblT3 = defineExpStruct("AblT3", "AblT3", "3rd tone", false);
    % AblT4 = defineExpStruct("AblT4", "AblT4", "4th tone", false);
    % 
    % % Ampl baseline pre-A
    % AT1 = defineExpStruct("AT1", "AT1", "1st tone", false, [56/256, 166/256, 165/256]);
    % AT2 = defineExpStruct("AT2", "AT2", "2nd tone", false,  [115/256, 175/256, 72/256]);
    % AT3 = defineExpStruct("AT3", "AT3", "3rd tone", false, [237/256, 173/256, 8/256]);
    % AT4 = defineExpStruct("AT4", "AT4", "4th tone", false,  [255/256, 124/256, 5/256]);
    % AT1 = defineExpStruct("AT1", "AT1", "1st tone", false, [0, 0, 0]);
    % AT5 = defineExpStruct("AT5", "AT5", "5th tone", false, [0, 0, 0]);
    % AT8 = defineExpStruct("AT8", "AT8", "8th tone", false, [0, 0, 0]);
    % ATR10 = defineExpStruct("ATR10", "ATR10", "10th tone, random block", false, [0, 0, 0]);
    % intblksmpAOR = defineExpStruct("intblksmpAOR", "intblksmpAOR", "Baseline", true, [0, 0, 0]);
    % intblksmpAOF = defineExpStruct("intblksmpAOF", "intblksmpAOF", "Baseline", true, [0, 0, 0]);
    
    % % [-1.5, 2.5] (note! They are opposite - T5thTfr is T1stTfr and vice versa)
    % T5thTfr = defineExpStruct("T5thTfr", "T5thTfr", "1st trial tone", false, [0, 0, 0]);
    % T1stTfr = defineExpStruct("T1stTfr", "T1stTfr", "5th trial tone", false, [0, 0, 0]);
    % 
    % % [-0.1, 6]
    % lastAOF = defineExpStruct("lastAOF", "lastAOF", "Last A OF", false, [0, 0, 0]);
    % lastAT = defineExpStruct("lastAT", "lastAT", "Last A T", false, [0, 0, 0]);
    % lastAOFnoN2Events  = defineExpStruct("LastAOFNoN2Events", "LastAOFNoN2Events", "Last A OF w/o ss&kc", false, [0, 0, 0]);
    % lastATnoN2Events = defineExpStruct("LastATNoN2Events", "LastATNoN2Events", "Last A T w/o ss&kc", false, [0, 0, 0]);
    
    % % [-12, 6]
    % OmiR618 = struct(); OmiR618.import_s = "OR618"; OmiR618.short_s = "OR618"; OmiR618.long_s = "Omission Random, 6th";
    % OmiR718 = struct(); OmiR718.import_s = "OR718"; OmiR718.short_s = "OR718"; OmiR718.long_s = "Omission Random, 7th";
    % OmiR818 = struct(); OmiR818.import_s = "OR818"; OmiR818.short_s = "OR818"; OmiR818.lo ng_s = "Omission Random, 8th";
    % OmiR918 = struct(); OmiR918.import_s = "OR918"; OmiR918.short_s = "OR918"; OmiR918.long_s = "Omission Random, 9th";
    % OmiF18 = struct(); OmiF18.import_s = "OF18"; OmiF18.short_s = "OF18"; OmiF18.long_s = "Omission Fixed";
    % LastOmiF18 = struct(); LastOmiF18.import_s = "LastOF18"; LastOmiF18.short_s = "LastOF18"; LastOmiF18.long_s = "Last Omission Fixed";
    % LastOmiR18 = struct(); LastOmiR18.import_s = "LastOR18"; LastOmiR18.short_s = "LastOR18"; LastOmiR18.long_s = "Last Omission Random";
    % 
    % %[0,5]
    % intbk5 = struct(); intbk5.import_s = "intbk5"; intbk5.short_s = "intbk5"; intbk5.long_s = "Interblock";
    % 
    % %[-0.2,2]
    % intbk2 = struct(); intbk2.import_s = "intbk2"; intbk2.short_s = "intbk2"; intbk2.long_s = "Interblock";
    % intbkLast2 = struct(); intbkLast2.import_s = "interblockLast2sec"; intbkLast2.short_s = "intbkLast2"; intbkLast2.long_s = "Interblock end";
    % LastOR2 = struct(); LastOR2.import_s = "LastOR2sec"; LastOR2.short_s = "LastOR2"; LastOR2.long_s = "Last Omission Random";
    % LastOF2 = struct(); LastOF2.import_s = "LastOF2sec"; LastOF2.short_s = "LastOF2"; LastOF2.long_s = "Last Omission Fixed";
    % 
    % LastOmiR = struct(); LastOmiR.import_s = "LastOR"; LastOmiR.short_s = "LastOR"; LastOmiR.long_s = "Omission Random";
    % LastOmiF = struct(); LastOmiF.import_s = "LastOF"; LastOmiF.short_s = "LastOF"; LastOmiF.long_s = "Omission Fixed";
    % 

    events = struct();
    events.adaptor = struct();
    events.adaptor.("event_time") = [0,0.1];
    events.adaptor.("event_color") = [.2, .2 ,.2,  0.05];
    events.adaptor.("event_text_color") = [0,0,0];
    events.adaptor.("event_text") = "Adaptor";
    events.omission = struct();
    events.omission.("event_time") = [0.58,0.62];
    events.omission.("event_color") = [.2, .2 ,.2,  0.05];
    events.omission.("event_text") = 'Omission';
    events.omission.("event_text_color") = [0,0,0];
end


function expStruct = defineExpStruct(import_s, short_s, long_s, isBaseline,color)
    expStruct = struct();
    expStruct.import_s = import_s;
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.isBaseline = isBaseline;
    expStruct.color = color;
end


function get_cp_dependencies(mainlibdir)
    % https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
    restoredefaultpath 
    addpath(sprintf('%s\\fieldtrip-20241219', mainlibdir)) % fieldtrip-20230223
    ft_defaults;
    addpath(sprintf('%s\\eeglab2024.2',mainlibdir)) %%eeglab2023.0'
    close;
    addpath(sprintf('%s\\klabhub-bayesFactor-04b80fd', mainlibdir))
end


function get_mvpa_dependencies(mainlibdir)
    ft_path = sprintf('%s\\fieldtrip-20170704',mainlibdir); %fieldtrip-20230223, fieldtrip-lite-20230316 wont work
    eeglab_path = sprintf('%s\\eeglab2024.2',mainlibdir);
    adam_path = sprintf('%s\\ADAM-1.14-beta',mainlibdir);
    
    % FT
    if (exist(ft_path,'dir') == 7) && (~isdeployed)
        restoredefaultpath
        addpath(ft_path,'-begin');
        ft_defaults; % find default options and files
        disp('FIELDTRIP IS ALIVE');
    elseif ~isdeployed
        disp(['WARNING, CANNOT FIND FIELDTRIP TOOLBOX AT ' ft_path ', CHECK PATHS IN startup.m']);
    end
    
    % EEGLAB
    if (exist(eeglab_path,'dir') == 7) && (~isdeployed)
        curdir = pwd;
        cd(eeglab_path);
        eeglab;
        cd(curdir);
        disp('EEGLAB IS ALIVE');
    elseif ~isdeployed
        disp(['WARNING, CANNOT FIND EEGLAB TOOLBOX AT ' eeglab_path ', CHECK PATHS IN startup.m']);
    end
    if ~isdeployed
        % remove conflicting paths
        rmpath(genpath(fullfile(eeglab_path,'external','fieldtrip-partial')));
        % create eeglabexefolder function to replace eeglab's internal
        % function and put options files in eeglab root
        tmpf = which('eeglabexefolder.m');
        if ~isempty(tmpf)
            if isempty(which('eeglabexefolder_original.m'))
                movefile(tmpf,[ tmpf(1:end-2) '_original.m']);
            end
            fid = fopen(tmpf,'w');
            fprintf(fid, 'function eeglabdir = eeglabexefolder\n');
            fprintf(fid, '%% This is to replace eeglabs native function, so it knows where to find the option files after compiling.\n');
            fprintf(fid, 'eeglabdir = ''%s'';\n', eeglab_path);
            fclose(fid);
            tmpf = which('eeg_optionsbackup.m');
            copyfile(tmpf, fullfile(eeglabexefolder, 'eeg_optionsbackup.txt'));
            tmpf = which('eeg_options.m');
            copyfile(tmpf, fullfile(eeglabexefolder, 'eeg_options.txt')); 
            disp(['EEGLAB: exefolder is here ' eeglabexefolder]);
        end
    end
    
    % ADAM decoding toolbox
    if (exist(adam_path,'dir') == 7) && (~isdeployed)
        addpath(genpath(adam_path),'-begin');
        % create findcapfile function to return location of capfile
        tmpf = which('standard-10-5-cap385.elp');
        if ~isempty(tmpf)
            fid = fopen(fullfile(fileparts(tmpf),'findcapfile.m'),'w');
            fprintf(fid, 'function capfile = findcapfile\n');
            fprintf(fid, '%% This is to be able to find the capfile for elecrode lookup after compiling.\n');
            fprintf(fid, 'capfile = ''%s'';\n', tmpf);
            fclose(fid);
        end
        disp('ADAM IS ALIVE');
        disp(['ADAM:   capfile is here ' findcapfile]);
    elseif ~isdeployed
        disp(['WARNING, CANNOT FIND ADAM TOOLBOX AT ' adam_path ', CHECK PATHS IN startup.m']);
    end
    
    disp('The latest and greatest of the ADAM toolbox can be downloaded from <a href = "http://www.fahrenfort.com/ADAM.htm">http://www.fahrenfort.com/ADAM.htm</a>');

    close;

end