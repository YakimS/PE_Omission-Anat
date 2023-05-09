
% If file exists, announce and return true. Else, return false.
function isAlreadyExist = isOutputFile(output_file,output_dir,verbose)
    fullpath = sprintf("%s\\%s",output_dir,output_file );
    if isfile(fullpath)
        if verbose
            fprintf("\n%s  already exists in path: %s",output_file,output_dir );
        end
        isAlreadyExist = true;
    else
        isAlreadyExist = false;
    end
end