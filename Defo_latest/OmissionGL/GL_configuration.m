function [v, subs, dirs, time, events,ft_read_sens_string] = GL_configuration(analysis_type)
    dirs = struct();
    dirs.ft_cond_input = "D:\GlobalLocal\ft_subSovCond_blPreO";
    dirs.ft_cond_output ="D:\GlobalLocal\ft_processed_blPreO";
    dirs.curr_project = addpath(genpath('C:\Users\User\Documents\GitHub\PE_Omission-Anat\Defo_latest'));
    dirs.libs = 'D:\matlab_libs';
    addpath(dirs.curr_project)
    addpath(dirs.libs)
    dirs.output_main = "D:\GlobalLocal\analysis_res";
    dirs.output_adamformat = 'C:\mvpa\GL\preprocessed2';
    dirs.output_adam_firstlvl = 'C:\mvpa\GL\FirstLevel2';
    dirs.output_adam_firstlvl_loo = 'C:\loo\GL2';
    dirs.output_adam_plots = 'C:\mvpa\GL\plots2';

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

    subs = {'1989RTKS','1991AGPE','1993AGRI','1993MRAB','1994LUAA','1994MREG','1994PTBV','1995ALKL','1995DNFR','1995GBKA','1995PTAF','1995RMBN','1995RTKL','1996RTHL','1996USRY','1997AIWG','1997ALKL','1997KRGT','1997MRBAE','1997RMDB','1998AADE','1998BRTI','1998IAKN','1999RTLY','1999VTSA','2000DLAL','2000UEAB'};

    time = -2:0.004:1.996;

    ft_read_sens_string = "";

    % sovs
    v.N1 = defineExpStruct("N1", "N1", "N1", false, [0.9, 0.1, 0.9]);
    v.N2 = defineExpStruct("N2", "N2", "N2", false,[1, 0.6, 0]);
    v.N3 = defineExpStruct("N3", "N3", "N3", false,[0.1, 0.9, 0.1]);
    v.REM = defineExpStruct("REM", "REM", "REM", false,[0.9, 0.1, 0.1]);
    v.wn = defineExpStruct("wake_night", "wn", "Wake Pre", false,[0, 0.7, 1]);
    
    
    % [-2, 1.996]
    v.ExOm = defineExpStruct("expomit", "ExOm", "Expected omission 4 tones", false, [0, 0, 0]);
    v.UnexOm = defineExpStruct("unexpomit", "UnexOm", "Deviant omission", false, [0, 0, 0]);
    v.ExCtrl = defineExpStruct("expomitctrl", "ExCtrl", "Expected omission 5 tones", false, [0, 0, 0]);


    events = struct();
    events.adaptor1 = struct();
    events.adaptor1.("event_time") = [-0.15,-0.05];
    events.adaptor1.("event_color") =[.85, .85 ,.85,  0.2];
    events.adaptor1.('event_text_color') =  [0,0,0];
    events.adaptor1.("event_text") =  'A';
    events.adaptor2 = events.adaptor1;
    events.adaptor2.("event_time") = [-0.3,-0.2];
    events.adaptor3 = events.adaptor1;
    events.adaptor3.("event_time") =  [-0.45,-0.35];
    events.adaptor4 = events.adaptor1;
    events.adaptor4.("event_time") = [-0.6,-0.5];
    events.omission = struct();
    events.omission.("event_time") = 0;
    events.omission.("event_color") = [0,0,0];
    events.omission.("event_text") = 'Omission';
    events.omission.('event_text_color') = [0,0,0];
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