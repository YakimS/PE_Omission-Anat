function   PowerInRectangular(pathtofiles_temp, FileId_temp, cluster,freq,OutputName_temp,srate,elec,baseline,for_hilbert)

% OPERATION:
%   Reads files in the path 'pathtofiles_temp', find min and mas peaks and saves the specified 'Variables'.
%
%  pathtofiles_temp  :   Path and directory where the .mat files to be concatenated are.
%                   eg: 'D:\Eugenio\analisis\Resultados\RightvsWrong'
%
%  FileId_temp       :   Only files including the 'FileId_temp' string will be readen eg: 'false'
%
%  OutputName_temp   :   Name of the output file eg: 'MeanRESULTSHUF'
%

% Constructs a Cell array 'F_temp' with the names of the files in
% directory 'pathtofiles_temp'
disp(['search for files of tipe: ',pathtofiles_temp,'/*',FileId_temp,'*.mat'])
F_temp = dir([pathtofiles_temp,'/*',FileId_temp,'*.mat']);

% Cicles trough the files
for sub_temp = 1 : length(F_temp)
    % put in 'filename_temp' the iesim name of cell array F_temp
    filename_temp = getfield(F_temp,{sub_temp,1},'name',{;});
    
    % Loads the file given by 'filename_temp'
    disp(['loading file: ',pathtofiles_temp,'/',filename_temp])
    load([pathtofiles_temp,'/',filename_temp])
    
    %Power.Trial{sub_temp} = nanmean(squeeze(nanmean(squeeze(condition2(freq,:,cluster,:)),1)));
    if exist('for_hilbert')
     Power.sub(sub_temp) = nanmean(nanmean(nanmean(squeeze(hilbdata(freq,elec,cluster,:)))));
    elseif ~exist('baseline')
        Power.sub(sub_temp) = nanmean(nanmean(nanmean(squeeze(condition2(freq,elec,cluster,:)))));
    else
        Power.sub(sub_temp) = nanmean(nanmean(nanmean(squeeze(condition(freq,elec,cluster,:)))));
    end
end

pathtofiles= [pathtofiles_temp '/results/'];
%OutputName= [OutputName_temp '_freq_' num2str(freq(1)/2) '_' num2str(freq(end)/2) '_time_' num2str(round(cluster(1)/srate)) '_' num2str(round(cluster(end)/srate)) '.mat'];
OutputName= [OutputName_temp '_freq_' num2str(freq(1)/2) '_' num2str((freq(end)/2)+0.5) '_time_' num2str((cluster(1)/srate)) '_' num2str((cluster(end)/srate)) '.mat'];

clear *_temp
clear condition
clear condition2

save([pathtofiles ,OutputName]) % save power
end
