%% creat a tone and add random ISI
function AX_block_full_night_sleep_omission_listen(task,RunNum,startRec,endRec)
% close all
% task = 0 - no task, task = 1 - attention to gaps and low tones, task = 2 - sleep

% RunNum = the number of times the 1/2 experiment will run. RunNum = 1 = 30min
db = 1;

% % let matlab ask for participant's ID number:
subject_data.ID = input('Participant: ', 's');
if isempty(subject_data.ID)
    error('put in participants ID!')
end

% t = datestr(now,30);
% cd('\Users\Room 12\Desktop\Anat\saved_data_test') %%% change folder path
% %diary([ subject_data.ID '_AX_block_' num2str(task) '_'  t '.txt'])
% disp(t);

% defining variables
sf = 48000;    % sample frequency (Hz)
fade_in = 10;  % ms
fade_out = 10; % ms
duration = 100;% ms
nrchannels = 2;% # of channels

silence_dur = [ 480 485 490 495 499 501 505 510 515 520]; % ms
freq_range = [500 650 845 1098 1428 1856 2413 3137 4079 5302 ]; % freq %6893 8961
omission = [6 7 8 9];
% order of fixed and random omission blocks
Fixed_random_order = [0 1 0 1 0 1 0 1 0 1 0 1];
block_order = randperm(length(Fixed_random_order));
Fixed_random_vec = [];
for block_num = 1:RunNum
    Fixed_random_vec = [Fixed_random_vec Fixed_random_order(block_order)];
end

% cd('C:\Users\Room 12\Desktop\Anat\Scripts') %%% change folder path
% load statements
% state_index = randperm(size(statements,2));

% Initialize and open PsychPortAudio
fprintf('Initialising audio.\n');
InitializePsychSound

if PsychPortAudio('GetOpenDeviceCount') == 1 % Return the number of currently open audio devices.
    PsychPortAudio('Close',0); %?
end

pamaster = PsychPortAudio('Open', [], 1+8, 1, sf, nrchannels, []);

% Start master immediately, wait for it to be started. We won't stop the master until the end of the session.
PsychPortAudio('Start', pamaster, 0, 0, 1);
PsychPortAudio('Volume', pamaster, db);
pahandle = PsychPortAudio('OpenSlave', pamaster, 1);

raw_Pnoise = pinknoise(sf*10);
Pnoise = GenerateEnvelope(sf, raw_Pnoise', fade_in, fade_out);
Pnoise = AttenuateSound(Pnoise, -30);
Pnoise = Pnoise';
Pnoise(2,:) = Pnoise;

% % % Connect to net station
% nshost = '172.29.27.159'; %net station host
% nsport = 55513;       %net station post
% NetStation('Connect', nshost,nsport);

% disp('Connected');

% if  exist('nshost','var') && ~isempty(nshost) && ...
%         exist('nsport','var') && nsport ~= 0
%     fprintf('Connecting to Net Station.\n');
%     [nsstatus, nserror] = NetStation('Connect',nshost,nsport);
%     if nsstatus ~= 0
%         error('Could not connect to NetStation host %s:%d.\n%s\n', ...
%             nshost, nsport, nserror);
%     end
% end

% NetStation('Synchronize');
%    start recording
% if startRec == 1
%     NetStation('StartRecording');
% end
pause(1);
% NetStation('Event','STRT', GetSecs, 0.001,'start',  1);
pause(5);

%  adaptor tone (x) + probe tone (a) * 10, 12 miniblocks of ~2 minutes, total 120 tone repetition for tone
tic

for block = 1:12*RunNum %length(probe) % run over all blocks all 102 rep
%     cd('C:\Users\Room 12\Desktop\Anat\Scripts') %%% change folder path
    
    %      % pink noise
    pasound2 = PsychPortAudio('OpenSlave', pamaster, 1);
    %     Into pasound2's standard buffer it goes...
    PsychPortAudio('FillBuffer', pasound2, Pnoise);
    PsychPortAudio('Start', pasound2, 0, 0, 1);
    
    fprintf('Block: %d\n', block);
    subject_data.stimuli_order{block} = [];
    
%     NetStation('Synchronize');
    pause(1);
    
    % %      send block begin marker
%     NetStation('Event', 'BGIN', GetSecs, 0.001, 'BNUM',block,'BTYP',Fixed_random_vec(block)); %
    pause(5);
    
     switch Fixed_random_vec(block)
        case 0 % fixed omission
            
            for miniblock = 1
                
                temp_vec_tone = randperm(length(freq_range)); % shuffle tone order
                
                for f = 1:length(freq_range)
%                     NetStation('Synchronize');
                    
                    for r =1:10  % 10 repetitions
                        
                        if r ~= 10
                            fprintf('Block %d blocktype %d miniblock %d  freq %d adaptor %d  probe %d\n',...
                                block, Fixed_random_vec(block), miniblock, f, freq_range(1), freq_range(temp_vec_tone(f)));
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(1)];
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(temp_vec_tone(f))];
                            
                            temp_vec_silence1 = randperm(length(silence_dur)); % shuffle first ISI order
                            temp_vec_silence2 = randperm(length(silence_dur)); % shuffle second ISI order
                            
                            adaptor_tone = GenerateTone(sf, duration, freq_range(1));
                            adaptor_tone = GenerateEnvelope(sf, adaptor_tone, fade_in, fade_out);
                            silence1 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence1(f)));
                            adaptor_tone_ISI = vertcat(adaptor_tone,silence1); % combine tone and silence
                            adaptor_tone_ISI = adaptor_tone_ISI';
                            adaptor_tone_ISI(2,:) = adaptor_tone_ISI;
                            PsychPortAudio('FillBuffer',pahandle,adaptor_tone_ISI);
%                             NetStation('Synchronize');
                            
                            % start stimulation
                            PsychPortAudio('Start',pahandle,1,0,1); %%% Blink
                            %  send tone start marker
%                             NetStation('Event', 'ADPT', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'FREQ',freq_range(1)); %
                            
                            probe_tone = GenerateTone(sf, duration, freq_range(temp_vec_tone(f)));
                            probe_tone = GenerateEnvelope(sf, probe_tone, fade_in, fade_out);
                            silence2 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence2(f)));
                            tone_silence = vertcat(probe_tone,silence2); % combine tone and silence
                            tone_silence = tone_silence';
                            tone_silence(2,:) = tone_silence;
                            PsychPortAudio('FillBuffer',pahandle,tone_silence);
                            
                            % start stimulation
                            PsychPortAudio('Start',pahandle,1,0,1);
%                             NetStation('Event', 'TONE', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'FREQ',freq_range(temp_vec_tone(f))); %
                        elseif r == 10
                            fprintf('Block %d blocktype %d miniblock %d  freq %d adaptor %d  omission %d\n',...
                                block, Fixed_random_vec(block), miniblock, f, freq_range(1), r);
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(1)];
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(temp_vec_tone(f))];
                            
                            temp_vec_silence1 = randperm(length(silence_dur)); % shuffle first ISI order
                            temp_vec_silence2 = randperm(length(silence_dur)); % shuffle second ISI order
                            
                            adaptor_tone = GenerateTone(sf, duration, freq_range(1));
                            adaptor_tone = GenerateEnvelope(sf, adaptor_tone, fade_in, fade_out);
                            silence1 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence1(f)));
                            adaptor_tone_ISI = vertcat(adaptor_tone,silence1); % combine tone and silence
                            adaptor_tone_ISI = adaptor_tone_ISI';
                            adaptor_tone_ISI(2,:) = adaptor_tone_ISI;
                            PsychPortAudio('FillBuffer',pahandle,adaptor_tone_ISI);
%                             NetStation('Synchronize');
                            
                            % start stimulation
                            PsychPortAudio('Start',pahandle,1,0,1); %%% Blink
                            %  send tone start marker
%                             NetStation('Event', 'ADPT', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'FREQ',freq_range(1)); %
                            pause((duration + silence_dur(temp_vec_silence1(f)))/1000) %wait for te duration of the tone

                            probe_tone = GenerateTone(sf, duration, freq_range(temp_vec_tone(f)));
                            probe_tone = GenerateEnvelope(sf, probe_tone, fade_in, fade_out);
                            silence2 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence2(f)));
                            tone_silence = vertcat(probe_tone,silence2); % combine tone and silence
                            tone_silence = tone_silence';
                            tone_silence(2,:) = tone_silence;
%                             PsychPortAudio('FillBuffer',pahandle,tone_silence);
%                             
%                             % start stimulation
%                             PsychPortAudio('Start',pahandle,1,0,1);
%                             NetStation('Event', 'OMIS', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'FREQ',freq_range(temp_vec_tone(f)),...
%                                 'location',r); %
                            
                            pause((duration + silence_dur(temp_vec_silence2(f)))/1000) %wait for te duration of the tone
                            
                        end % if r
                    end % r (run for 10 times)
                    
                end % f
                
            end % miniblock
            
        case 1 % random omission
            
            for miniblock = 1
                
                temp_vec_tone = randperm(length(freq_range)); % shuffle tone order
                
                for f = 1:length(freq_range)
%                     NetStation('Synchronize');
                    
                    if f == 1
                        temp_ind = randperm(length(omission(1:3)));
                        temp_omission = omission(temp_ind(1));
                    else
                        temp_ind = randperm(length(omission));
                        temp_omission = omission(temp_ind(1));
                    end
                    for r =1:10  % 10 repetitions
                        
                        if r ~= temp_omission
                            fprintf('Block %d blocktype %d miniblock %d  freq %d adaptor %d  probe %d\n',...
                                block, Fixed_random_vec(block), miniblock, f, freq_range(1), freq_range(temp_vec_tone(f)));
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(1)];
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(temp_vec_tone(f))];
                            
                            temp_vec_silence1 = randperm(length(silence_dur)); % shuffle first ISI order
                            temp_vec_silence2 = randperm(length(silence_dur)); % shuffle second ISI order
                            
                            adaptor_tone = GenerateTone(sf, duration, freq_range(1));
                            adaptor_tone = GenerateEnvelope(sf, adaptor_tone, fade_in, fade_out);
                            silence1 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence1(f)));
                            adaptor_tone_ISI = vertcat(adaptor_tone,silence1); % combine tone and silence
                            adaptor_tone_ISI = adaptor_tone_ISI';
                            adaptor_tone_ISI(2,:) = adaptor_tone_ISI;
                            PsychPortAudio('FillBuffer',pahandle,adaptor_tone_ISI);
%                             NetStation('Synchronize');
                                                        
                            % start stimulation
                            PsychPortAudio('Start',pahandle,1,0,1); %%% Blink
                            %  send tone start marker
%                             NetStation('Event', 'ADPT', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'FREQ',freq_range(1)); %
                                                        
                            probe_tone = GenerateTone(sf, duration, freq_range(temp_vec_tone(f)));
                            probe_tone = GenerateEnvelope(sf, probe_tone, fade_in, fade_out);
                            silence2 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence2(f)));
                            tone_silence = vertcat(probe_tone,silence2); % combine tone and silence
                            tone_silence = tone_silence';
                            tone_silence(2,:) = tone_silence;
                            PsychPortAudio('FillBuffer',pahandle,tone_silence);
                            
                            % start stimulation
                            PsychPortAudio('Start',pahandle,1,0,1);
%                             NetStation('Event', 'TONE', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'FREQ',freq_range(temp_vec_tone(f))); %
                        elseif r == temp_omission
                            fprintf('Block %d blocktype %d miniblock %d  freq %d adaptor %d  omission %d\n',...
                                block, Fixed_random_vec(block), miniblock, f, freq_range(1), r);
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(1)];
                            subject_data.stimuli_order{block} = [subject_data.stimuli_order{block}; freq_range(temp_vec_tone(f))];
                            
                            temp_vec_silence1 = randperm(length(silence_dur)); % shuffle first ISI order
                            temp_vec_silence2 = randperm(length(silence_dur)); % shuffle second ISI order
                            
                            adaptor_tone = GenerateTone(sf, duration, freq_range(1));
                            adaptor_tone = GenerateEnvelope(sf, adaptor_tone, fade_in, fade_out);
                            silence1 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence1(f)));
                            adaptor_tone_ISI = vertcat(adaptor_tone,silence1); % combine tone and silence
                            adaptor_tone_ISI = adaptor_tone_ISI';
                            adaptor_tone_ISI(2,:) = adaptor_tone_ISI;
                            PsychPortAudio('FillBuffer',pahandle,adaptor_tone_ISI);
%                             NetStation('Synchronize');
                            
                            % start stimulation
                            PsychPortAudio('Start',pahandle,1,0,1); %%% Blink
                            %  send tone start marker
%                             NetStation('Event', 'ADPT', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'FREQ',freq_range(1)); %
                            pause((duration + silence_dur(temp_vec_silence1(f)))/1000) %wait for te duration of the tone
                            
                            probe_tone = GenerateTone(sf, duration, freq_range(temp_vec_tone(f)));
                            probe_tone = GenerateEnvelope(sf, probe_tone, fade_in, fade_out);
                            silence2 = GenerateSilentInterval(sf, silence_dur(temp_vec_silence2(f)));
                            tone_silence = vertcat(probe_tone,silence2); % combine tone and silence
                            tone_silence = tone_silence';
                            tone_silence(2,:) = tone_silence;
%                             PsychPortAudio('FillBuffer',pahandle,tone_silence);
%                             
%                             % start stimulation
%                              PsychPortAudio('Start',pahandle,1,0,1);
%                             NetStation('Event', 'OMIS', GetSecs, 0.001,...
%                                 'block',  block, ...
%                                 'miniblock', miniblock, ...
%                                 'omission',freq_range(temp_vec_tone(f)),...
%                                 'location',r); %
                            
                            pause((duration + silence_dur(temp_vec_silence2(f)))/1000) %wait for te duration of the tone
                            
                        end % if r
                    end % r (run for 10 times)
                    
                end % f
                
            end % miniblock
    end % switch
    PsychPortAudio('Close',pasound2);
    
    
    if task == 1
        % Check if the subject awake/ enter answer of # of tones
        answer = input('How many gap were presented: ', 's');
        subject_data.answer{block} = answer;
        subject_data.gaps{block} = gap_location;
        %        subject_data.lowtone{block} = low_tone_location;
        
        % save subject data
%         t = datestr(now,30);
%         cd('\Users\Room 12\Desktop\Anat\saved_data_test')%%% change folder path
%         save([subject_data.ID '_attention_' t], 'subject_data')
        
    elseif task == 0
%         q = char(statements{state_index(block)});
%         answer = input(q);
%         subject_data.answer{block} = answer;
        % save subject data
%         t = datestr(now,30);
%         cd('\Users\Room 12\Desktop\Anat\saved_data_test')%%% change folder path
%         save([subject_data.ID '_noTask_' t], 'subject_data')
        
    elseif task == 2
%         t = datestr(now,30);
%         cd('\Users\Room 12\Desktop\Anat\saved_data_test')%%% change folder path
%         save([subject_data.ID '_sleep_' t], 'subject_data')
    end
    
end % ends z blocks
% cd('\Users\Room 12\Desktop\Anat\saved_data_test') %%% change folder path
% save([subject_data.ID '_' num2str(task) '_' t], 'subject_data')

toc
% cd('C:\Users\Room 12\Desktop\Anat\Scripts') %%% change folder path

%  End of Experiment
% wait for a bit
pause(5);
% NetStation('Event','SEND', GetSecs, 0.001,'end',  block);
fprintf('Exp end.\n'); %%% Blink

%exit nicely
% if endRec == 1
%     NetStation('StopRecording');
% end

