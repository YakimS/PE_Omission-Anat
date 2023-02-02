%% SharonYakim use of "rereferenceFullNightSleep.m" code sended by Anat
% Example of how to use the code: EEG_ref = rereferenceFullNightSleep(EEG,1); % 1= common average.

function EEG = rereferenceFullNightSleep(basename,refmode,keepref)

%reference modes
%1 = common average
%2 = laplacian average
%3 = linked mastoid
%4 = none
%5 = current source density

%loadpathsFullNightSleep
filesuffix = '_ref';

if ischar(basename)
    %EEG = pop_loadset('filepath',[filepath '/analysis/interp'],'filename',[basename '_interp.set']);
    EEG = pop_loadset('filepath',[filepath '/analysis/rejected'],'filename',[basename '_rej.set']);

elseif isstruct(basename)
    EEG = basename;
end

% if isfield(EEG.chanlocs,'badchan')
%     badchannels = find(cell2mat({EEG.chanlocs.badchan}));
% else
%     badchannels = [];
% end

if isfield(EEG.reject,'rejchan')
    badchannels = EEG.reject.rejchan;
else
    badchannels = [];
end


if ~exist('refmode','var') || isempty(refmode)
    refmodes = {'Common','Laplacian','Linked Mastoid','None','Current Source Density'};
    [refmode,ok] = listdlg('ListString',refmodes,'SelectionMode','single','Name','Re-referencing',...
        'PromptString','Choose re-referencing type');
else
    ok = 1;
end

if refmode == 4
    fprintf('Data reference unchanged.\n');
    return;
end

if ok
if isfield(EEG.chaninfo,'ndchanlocs') && isstruct(EEG.chaninfo.ndchanlocs)
    EEG.chaninfo.nodatchans = EEG.chaninfo.ndchanlocs;
    czidx = find(strcmp('Cz',{EEG.chaninfo.ndchanlocs.labels}));
elseif isfield(EEG.chaninfo,'nodatchans') && isstruct(EEG.chaninfo.nodatchans)
    EEG.chaninfo.ndchanlocs = EEG.chaninfo.nodatchans;
    czidx = find(strcmp('Cz',{EEG.chaninfo.ndchanlocs.labels}));
else
    czidx = [];
end

refchan = {'E57' 'E100'};
for r = 1:length(refchan)
    refchan{r} = find(strcmp(refchan{r},{EEG.chanlocs.labels}));
end
refchan = cell2mat(refchan);

    switch refmode
        case 1
            fprintf('Referencing to common average.\n');
            if isempty(czidx)
                EEG = pop_reref( EEG, [], 'exclude', badchannels);
            else
                fieldloc = fieldnames(EEG.chanlocs);
                for ind = 1:length(fieldloc)
                    if ~isfield(EEG.chaninfo.ndchanlocs(czidx),fieldloc{ind})
                        EEG.chaninfo.ndchanlocs(czidx).(fieldloc{ind}) = [];
                    end
                end
                EEG = pop_reref( EEG, [], 'exclude', badchannels,'refloc',EEG.chaninfo.ndchanlocs(czidx));
                EEG.chaninfo.ndchanlocs(strcmp('Cz',{EEG.chaninfo.ndchanlocs.labels})) = [];
            end
            if ~exist('keepref','var') || keepref == 0
                EEG = pop_select(EEG,'nochannel',refchan);
            end
            EEG.ref = 'averef';
            
        case 2
            fprintf('Referencing to laplacian average.\n');
            EEG = pop_select(EEG,'nochannel',refchan);
            if ~isempty(czidx)
                EEG.chanlocs(end+1).labels = EEG.chaninfo.ndchanlocs(czidx).labels;
                fieldloc = fieldnames(EEG.chaninfo.ndchanlocs(czidx));
                for ind = 1:length(fieldloc)
                    EEG.chanlocs(end).(fieldloc{ind}) = EEG.chaninfo.ndchanlocs(czidx).(fieldloc{ind});
                end
                EEG.chanlocs(end).type = '';
                EEG.chaninfo.ndchanlocs(czidx) = [];
                EEG.data(end+1,:,:) = 0;
                EEG.nbchan = EEG.nbchan + 1;
            end
            % EEGLAB has nose direction as X-axis and right ear direction
            % as Y-axis, whereas cart2sph expects the reverse. Hence swap X
            % and Y below
            chanlocs = cat(2,cell2mat({EEG.chanlocs.Y})',cell2mat({EEG.chanlocs.X})',cell2mat({EEG.chanlocs.Z})');
            EEG.data = permute(lar(permute(EEG.data,[3 2 1]),chanlocs,badchannels),[3 2 1]);
            EEG.ref = 'laplacian';
            
        case 3
            refchan = setdiff(refchan,badchannels);
            fprintf('Referencing to %s.\n',cell2mat({EEG.chanlocs(refchan).labels}));
            EEG.ref = cell2mat({EEG.chanlocs(refchan).labels});
            
            if isempty(czidx)
                EEG = pop_reref( EEG, refchan, 'exclude', badchannels);
            else
                fieldloc = fieldnames(EEG.chanlocs);
                for ind = 1:length(fieldloc)
                    if ~isfield(EEG.chaninfo.ndchanlocs(czidx),fieldloc{ind})
                        EEG.chaninfo.ndchanlocs(czidx).(fieldloc{ind}) = [];
                    end
                end
                EEG = pop_reref( EEG, refchan, 'exclude', badchannels,'refloc',EEG.chaninfo.ndchanlocs(czidx));
                EEG.chaninfo.ndchanlocs(strcmp('Cz',{EEG.chaninfo.ndchanlocs.labels})) = [];
            end
            
        case 4
            fprintf('Data reference unchanged.\n');
            return;
            
        case 5
            fprintf('Computing current source density.\n');
            EEG = pop_select(EEG,'nochannel',refchan);
            if ~isempty(czidx)
                EEG.chanlocs(end+1).labels = EEG.chaninfo.ndchanlocs(czidx).labels;
                fieldloc = fieldnames(EEG.chaninfo.ndchanlocs(czidx));
                for ind = 1:length(fieldloc)
                    EEG.chanlocs(end).(fieldloc{ind}) = EEG.chaninfo.ndchanlocs(czidx).(fieldloc{ind});
                end
                EEG.chanlocs(end).type = '';
                EEG.chaninfo.ndchanlocs(czidx) = [];
                EEG.chaninfo.nodatchans(czidx) = [];
                EEG.data(end+1,:,:) = 0;
                EEG.nbchan = EEG.nbchan + 1;
            end
            % EEGLAB has nose direction as X-axis and right ear direction
            % as Y-axis, whereas cart2sph expects the reverse. Hence swap X
            % and Y below            
            chanlocs = cat(2,cell2mat({EEG.chanlocs.Y})',cell2mat({EEG.chanlocs.X})',cell2mat({EEG.chanlocs.Z})');
            [sph.theta, sph.phi] = cart2sph(chanlocs(:,1),chanlocs(:,2),chanlocs(:,3));
            sph.theta = (180/pi) * sph.theta;
            sph.phi = (180/pi) * sph.phi;
            sph.lab = {EEG.chanlocs.labels}';
            [G,H] = GetGH(sph);
            EEG.data = double(CSD(single(EEG.data),G,H));
            EEG.ref = 'csd';
    end
    
    if ischar(basename)
%         fprintf('Saving to %s.set.\n',basename);
%         pop_saveset(EEG,'filepath',[filepath '/analysis/referenced'],'filename',[basename filesuffix '.set'],'version','7.3');
    end
end