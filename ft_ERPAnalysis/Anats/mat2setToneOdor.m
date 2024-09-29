function mat2setToneOdor(basename,condition,side1)

loadpathsToneOdor

load([filepath 'matlab_data/tone odor conditioning/' basename]);
cond1 = eval([basename '.' condition '.' side1]);
%cond2 = eval([basename '.' condition '.' side2]);

for s = 1:size(cond1,2)

    elec1 = cond1{1,s};
    %elec2 = cond2{1,s};
    %cond = cat(3,elec1,elec2);    
    %cond = permute(cond([3 2 1]));
    cond = [];
    if ~isempty(elec1)
    %cond(1,:,:) = elec1'; % for all 60 sec
    cond(1,:,:) = elec1(:,20001:40000)'; % for 10 sec before and 10 sec after tone onset
    end
    save([filepath 'tone odor conditioning/data/'  basename '_' condition '_s' num2str(s) '.mat'],'cond', '-v7.3'); %chanlocs

    % Importing to EEG lab
    EEG = pop_importdata('dataformat','matlab','nbchan',0,'data', [filepath 'tone odor conditioning/data/' basename '_' condition '_s' num2str(s) '.mat'],'setname',[basename '_' condition '_' num2str(s)],'srate',1000,'pnts',0,'xmin',0);
    %EEG = pop_resample( EEG, 500);

    EEG = pop_saveset(EEG, 'filename', [ basename '_' condition '_s' num2str(s) '.set'], 'filepath', [filepath 'tone odor conditioning/set/']);

end

end