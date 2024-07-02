function   PowerInCluster(pathtofiles_temp, FileId_temp, cluster,OutputName, freq,t_start)

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

if ~exist('t_start','var')
    t_start = 1;
end

disp(['search for files of tipe: ',pathtofiles_temp,'/*',FileId_temp,'*.mat'])
F_temp = dir([pathtofiles_temp,'/*',FileId_temp,'*.mat']);   
cluster = cluster';
    % Cycles trough the files
    for sub_temp = 1 : length(F_temp) 
        % put in 'filename_temp' the iesim name of cell array F_temp
        filename_temp = getfield(F_temp,{sub_temp,1},'name',{;});
        
        % Loads the file given by 'filename_temp'
        disp(['loading file: ',pathtofiles_temp,'/',filename_temp])
        load([pathtofiles_temp,'/',filename_temp]) 
           
        
        tempMat = nanmean(squeeze(condition2(:,3,:,:)),3);
        tempMat = tempMat(freq,t_start:t_start+size(cluster,2)-1);
        
        tempCluster = cluster(freq,:);
        Power.sub(sub_temp) = nanmean(tempMat(tempCluster));        
    end
        
pathtofiles= [pathtofiles_temp '/results/'];

clear *_temp
clear condition
clear condition2
       
  save([pathtofiles ,OutputName '_' num2str(freq(1)/2) '_' num2str((freq(end)/2)+0.5) '.mat'],'Power','cluster')
end
    