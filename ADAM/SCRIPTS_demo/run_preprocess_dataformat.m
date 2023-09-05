%% FIELDTRIP PREPROCESSING OF NEUROMAG DATA
%  Joram van Driel, VU, Amsterdam, September-October-December 2017

clear, close all
restoredefaultpath
addpath('PATH/TO/FIELDTRIP') % only necessary if FT is not already on the Matlab search path
ft_defaults;

readdir = 'PATH/TO/FIF_INPUT/FILES';
writdir = 'PATH/TO/MAT_OUTPUT/FILES';
cd(readdir)
subs = dir('S*'); subs([subs.isdir]==0)=[];

%% IMPORT DATA
tic
elec = ft_read_sens('standard_1005.elc'); % default 10-05 label positions, see below why we need this

% EEG
for subno=1:length(subs);
    
    cd([readdir subs(subno).name filesep 'MEG' filesep]);
    filz = dir('*sss.fif');
    datall = cell(1,length(filz));
    outfilename1 = [writdir filesep subs(subno).name '_ds000117_EEG.mat'];
    
    if exist(outfilename1,'file'), continue; end
    
    fprintf('Preprocessing subject %i of %i...',subno,length(subs))
    
    %%
    for fi = 1:length(filz)
        
        datafilename = (filz(fi).name);
        
        % Fieldtrip functions to get trial info and epoched data
        % - 5 6 7: familiar faces
        % - 13 14 15: unfamiliar faces
        % - 17 18 19: scrambled faces
        
        cfg = [];
        cfg.dataset = datafilename;
        cfg.trialdef.eventtype = 'STI101';
        cfg.trialdef.eventvalue = [5 6 7 13 14 15 17 18 19];
        cfg.trialdef.prestim  = 0.5;
        cfg.trialdef.poststim = 1.5;
        cfg.trialfun = 'ft_trialfun_general';
        cfg = ft_definetrial(cfg);
        
        if isempty(cfg.trl), continue; end
        
        % Preprocessing:
        % - no low/high-pass filtering
        % - no baseline correction (done in ADAM toolbox)
        % - epoching -1.5 to 2.5 seconds
        % - downsampling to 100 Hz
        
        header = ft_read_header(datafilename);
        
        % Note on channels:
        % - MEG sensors are in dat.grad
        % - EEG electrodes are in dat.elec
        % - MEG magnetometers end with 1
        % - MEG gradiometers end with 2 and 3
        
        cfg.channel = {'EEG','-EEG061','-EEG062','-EEG063','-EEG064'}; % channel 61-64 are HEOG,VEOG,ECG and a free-floating unused channel; removing these gives 70 channels as described in Wakeman & Henson (2105) paper
       
        data = ft_preprocessing(cfg);
        
        data.elec.chanpos(61:64,:)=[];
        data.elec.elecpos(61:64,:)=[];
        data.elec.label(61:64)=[];
        
        %% CHANGE ELECTRODE MONTAGE
        
        % The electrodes in the .fif Neuromag data have the labels
        % EEG001-EEG074, which is a bit unhandy for plotting topomaps
        % according to a 10-05 labeling system; moreover, we noticed when
        % importing the channel locations and plotting the layout, that
        % channel 6-16 were misplaced and located on position 5-15. So here
        % is a piece of correction code to deal with this.
        
        % Note that Po9 and Po10 have channel number 1 and 3; see http://imaging.mrc-cbu.cam.ac.uk/meg/EEGChannelNames
        
        chanlabs = {'PO9','Fpz','PO10','AF7','AF3','AFz','AF4','AF8','F7','F5','F3','F1','Fz','F2','F4','F6','F8','FT9','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6',...
            'FT8','FT10','T9','T7','C5','C3','C1','Cz','C2','C4','C6','T8','T10','TP9','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','TP10',...
            'P9','P7','P5','P3','P1','Pz','P2','P4','P6','P8','P10','PO7','PO3','POz','PO4','PO8','O1','Oz','O2','Iz'};
        
        for ch=1:length(chanlabs)
            chanidx=find(strcmpi(elec.label,chanlabs(ch)));
            data.label(ch)  = chanlabs(ch);
            data.elec.label(ch) = chanlabs(ch);
            data.elec.chanpos(ch,:) = elec.chanpos(chanidx,:)./10; % default elec is in mm; data elec is in cm
            data.elec.elecpos(ch,:) = elec.elecpos(chanidx,:)./10; % default elec is in mm; data elec is in cm
        end
        
        % check if this went OK
%         cfg=[];
%         cfg.elec = data.elec;
%         layout = ft_prepare_layout(cfg, data);
% 
%         cfg.layout = layout;
%         ft_layoutplot(cfg);

        
        %%
        cfg = [];
        cfg.resample = 'yes';
        cfg.fsample = header.Fs;
        cfg.resamplefs = header.Fs/4;
        cfg.detrend = 'no';
        dat = ft_resampledata(cfg,data);
        
        datall{fi} = dat;

    end
    
    cfg=[];
    merge_string = 'merged_data = ft_appenddata(cfg';
    for fi=1:length(filz)
        merge_string = [merge_string ',datall{' num2str(fi) '}'];
    end
    merge_string = [merge_string ');'];
    eval(merge_string);
    
    %%
    save(outfilename1,'merged_data')

end
t1=toc;

%-%
% MEG
for subno=1:length(subs);
    
    cd([readdir subs(subno).name filesep 'MEG' filesep]);
    filz = dir('*sss.fif');
    datall = cell(1,length(filz));
    outfilename1 = [writdir filesep subs(subno).name '_ds000117_MEG_gradmag.mat'];
    outfilename2 = [writdir filesep subs(subno).name '_ds000117_MEG_grad.mat'];
    
    if exist(outfilename1,'file'), continue; end
    
    fprintf('Preprocessing subject %i of %i...',subno,length(subs))
    
    %%
    for fi = 1:length(filz)
        
        datafilename = (filz(fi).name);
        
        % Fieldtrip functions to get trial info and epoched data
        % - 5 6 7: familiar faces
        % - 13 14 15: unfamiliar faces
        % - 17 18 19: scrambled faces
        
        cfg = [];
        cfg.dataset = datafilename;
        cfg.trialdef.eventtype = 'STI101';
        cfg.trialdef.eventvalue = [5 6 7 13 14 15 17 18 19];
        cfg.trialdef.prestim  = 0.5;
        cfg.trialdef.poststim = 1.5;
        cfg.trialfun = 'ft_trialfun_general'; % this is a custom-written trial function that also evaluates accuracy
        cfg = ft_definetrial(cfg);
        
        if isempty(cfg.trl), continue; end
        
        % Preprocessing:
        % - no low/high-pass filtering
        % - no baseline correction (done in ADAM toolbox)
        % - epoching -1.5 to 2.5 seconds
        % - downsampling to 100 Hz
        
        header = ft_read_header(datafilename);
        
        % Note on channels:
        % - MEG sensors are in dat.grad
        % - EEG electrodes are in dat.elec
        % - MEG magnetometers end with 1
        % - MEG gradiometers end with 2 and 3
        
        cfg.channel = {'MEG*'}; % note: we use only the two gradiometers for decoding, the magnetometers were discarded to save space and time
        
        data = ft_preprocessing(cfg);
                
        %%
        cfg = [];
        cfg.resample = 'yes';
        cfg.fsample = header.Fs;
        cfg.resamplefs = header.Fs/4;
        cfg.detrend = 'no';
        dat = ft_resampledata(cfg,data);
        
        datall{fi} = dat;
        % save(outfilename,'dat');
    end
    
    cfg=[];
    merge_string = 'merged_data = ft_appenddata(cfg';
    for fi=1:length(filz)
        merge_string = [merge_string ',datall{' num2str(fi) '}'];
    end
    merge_string = [merge_string ');'];
    eval(merge_string);
    
    %%
    % save(outfilename1,'merged_data') % no need to do this, we are only doing gradiometers
    
    cfg=[];
    cfg.channel = {'MEG*','-MEG*1'};
    merged_data = ft_selectdata(cfg,merged_data);
    save(outfilename2,'merged_data')

end
t2=toc;

%%
fprintf('Preprocessing %i EEG subjects took %i minutes\n',length(subs),round(t1/60))
fprintf('Preprocessing %i MEG subjects took %i minutes\n',length(subs),round(t2/60))
