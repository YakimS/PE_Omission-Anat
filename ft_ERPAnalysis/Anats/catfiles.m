function   catfiles(pathtofiles_temp, FileId_temp, Variable, OutputName_temp, dims_temp, supersubject)
% FUNCI�N DE CASO ESPECIAL S�LO PARA RESOLVER UN PROBLEMA PUNTUAL.NO USAR.

%example: catfiles('/imaging/ac04/Olfaction/hilbert/zscore/intracondition/','UnpleasantStage2_clean_AllTrials_s','condition2','UnpleasantStage2_AllTrials_sqrt_stim2',[4 4])

% LoadNCatFiles reads and concatenates variables of a group of files specified by the path
% 'pathtofiles_temp'.
% OPERATION:
%   Reads files in the path 'pathtofiles_temp', Concatenate and saves the specified 'Variables'.
%
%  pathtofiles_temp  :   Path and directory where the .mat files to be concatenated are.
%                   eg: 'D:\Eugenio\analisis\Resultados\RightvsWrong'
%
%  FileId_temp       :   Only files including the 'FileId_temp' string will be readen eg: 'false'
%
%  OutputName_temp   :   Name of the output file eg: 'MeanRESULTSHUF'
%
%  Variable    :   A cell array defined like in the following exemple.
%                   eg:   Variables ={'MATSYNCHRO', 'SHUFSYNCHRO','TIMEFREQ','ZTIMEFREQ'}
% 
%  dims_temp         :   vector of dimensions over which the variables must be concatenated,
%                   one value (dimension) by variable eg: [2 1] says: 'concatenate the first
%                   variable on the columns and the second variable, on the rows'.

%  supersubject :   == 0 concut all trial from all subjects together
%                   == 1 concut subjects
%
%
%   Variables ={'MATSYNCHRO', 'SHUFSYNCHRO','TIMEFREQ','ZTIMEFREQ'}
%
%   LoadNCatFiles4Andres('D:\Eugenio\analisis\Resultados\RightvsWrong', 'false', 'MeanRESULTSHUF', dims_temp, frange)
%   
%
%        E.Rodriguez 2004


Variables ={Variable};


% Constructs a Cell array 'F_temp' with the names of the files in 
% directory 'pathtofiles_temp'
disp(['search for files of tipe: ',pathtofiles_temp,'/*',FileId_temp,'*.mat'])
F_temp = dir([pathtofiles_temp,'/*',FileId_temp,'*.mat']);   

if supersubject == 1 
    % Cicles trough the files
    for i_temp = 1 : length(F_temp) 
        % put in 'filename_temp' the iesim name of cell array F_temp
        filename_temp = getfield(F_temp,{i_temp,1},'name',{;});
        
        % Loads the file given by 'filename_temp'
        disp(['loading file: ',pathtofiles_temp,'/',filename_temp])
        load([pathtofiles_temp,'/',filename_temp]) 
        
        % Cicles trough the variables
        for j_temp=1:length(Variables)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Define cumulating variables on the first run   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     %%%
            if i_temp==1                                                                                                    %%%     %%%
                eval(['Cum_',Variables{j_temp},'= nanmean(',Variables{j_temp},',5);']) % for supersubject change 4 to 5 (concatenate on nonexsit dimention)                                                     %%%     %%%
            else % this is for the following runs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     %%%
               eval(['Cum_',Variables{j_temp},'= cat(',num2str(dims_temp(j_temp)),', Cum_',Variables{j_temp},',nanmean(',Variables{j_temp},',5));']) % for supersubject change 4 to 5 (concatenate on nonexsit dimention)     %%%     %%%
            end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     %%%
        end             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
         % Cicles trough the variables to divide by Nfiles and kill useles variables
     for j_temp=1:length(Variables)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         eval([Variables{j_temp},'= ','Cum_',Variables{j_temp},';'])
         % eval([Variables{j_temp},'= ','Cum_',Variables{j_temp},';'])
         eval(['clear Cum_',Variables{j_temp},';'])
     end
pathtofiles= [pathtofiles_temp 'results/supersubject/']
OutputName=OutputName_temp
clear *_temp
    
elseif supersubject == 0
    % Cicles trough the files
    for i_temp = 1 : length(F_temp) 
        % put in 'filename_temp' the iesim name of cell array F_temp
        filename_temp = getfield(F_temp,{i_temp,1},'name',{;});
        
        % Loads the file given by 'filename_temp'
        disp(['loading file: ',pathtofiles_temp,'/',filename_temp])
        load([pathtofiles_temp,'/',filename_temp]) 
        
        % Cicles trough the variables
        for j_temp=1:length(Variables)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Define cumulating variables on the first run   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     %%%
            if i_temp==1                                                                                                    %%%     %%%
                eval(['Cum_',Variables{j_temp},'= nanmean(',Variables{j_temp},',4);']) % for supersubject change 4 to 5 (concatenate on nonexsit dimention)                                                     %%%     %%%
            else % this is for the following runs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     %%%
               eval(['Cum_',Variables{j_temp},'= cat(',num2str(dims_temp(j_temp)),', Cum_',Variables{j_temp},',nanmean(',Variables{j_temp},',4));']) % for supersubject change 4 to 5 (concatenate on nonexsit dimention)     %%%     %%%
            end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     %%%
        end             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
         % Cicles trough the variables to divide by Nfiles and kill useles variables
     for j_temp=1:length(Variables)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         eval([Variables{j_temp},'= ','Cum_',Variables{j_temp},';'])
         % eval([Variables{j_temp},'= ','Cum_',Variables{j_temp},';'])
         eval(['clear Cum_',Variables{j_temp},';'])
     end
pathtofiles= [pathtofiles_temp 'results/subjects/']
OutputName=OutputName_temp
clear *_temp

end
       
%    wsmiwin = squeeze(wsmiwin);
%   CumRho = squeeze(mean(CumRho,1));
%         
    
  save([pathtofiles ,OutputName], '-v7.3')%ojo que guarda todo!!!!!!!!!!!!!!!!!!
%  hdf5write('/imaging/ac04/Interoception/Hipnosis/Controls/Begins2/CumMatdif_All_HF2S.h5','/CumMatdif', 'CumMatdif')
end
    