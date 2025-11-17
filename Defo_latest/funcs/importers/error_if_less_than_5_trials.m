function error_if_less_than_5_trials(sub, cond, sov, numOfTrials)
    % Check if number of trials meets minimum requirement
    %
    % Inputs:
    %   sub - subject ID string
    %   cond - condition struct with long_s field
    %   sov - SOV struct with long_s field  
    %   numOfTrials - number of trials (integer)
    %
    % Throws exception if less than 5 trials
    
    if numOfTrials < 5
        fprintf('sub: %s, cond: %s, sov: %s', sub, cond.import_s, sov.import_s)
        ME = MException('MyComponent:LessThanFiveTrials', ...
            sprintf('less than 5 trials in this cond for this sub. Highly unrecommended. Trials: %d', numOfTrials));
        throw(ME);
    end
end 