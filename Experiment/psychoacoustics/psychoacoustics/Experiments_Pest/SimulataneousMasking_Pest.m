function [pos_ans, q] = SimulataneousMasking_Pest(std_level, var_level, nAFC)

% A 20-ms, 1-kHz sine tone (the signal) is presented within a band of
% bandpass noise of 300-ms (400-1600 Hz). All sounds are onset and offset
% gated by means of two raised cosine onset and offset gates of 10-ms. The
% subject has to detect the tone (in yes/no task) or to tell which interval
% has the tone.
% - PARAMETER VARIED ADAPTIVELY: the level of the signal;
% - STANDARD LEVEL: in the current experiment it has no use.
% !!!PLEASE NOTE THAT THE EXACT SOUND PRESSURE LEVEL AT LISTENER'S EAR MUST
% BE DETERMINED APART BY MEANS OF AN ADEQUATE HARDWARE!!!

%%% BEGINNING EXPERIMENT'S PARAMETER %%%
sf = 44100; % sample frequency in Hz
signaldur = 20; % signal duration
freq = 1000; % signal frequency
noisedur = 300; % noise duration
lf = 400; % noise lowest frequency
hf = 1600; % noise highest frequency

% [1] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE SOUNDS
signal = GenerateTone(sf, signaldur, freq);
signal = GenerateEnvelope(sf, signal);
signal = AttenuateSound(signal, var_level);

noise = GenerateNoise(sf, noisedur, 'bandpass', lf, hf);
noise = GenerateEnvelope(sf, noise);
noise = AttenuateSound(noise, -30);

variable = AddTwoSounds(sf, noise, signal, 140);
standard = noise;
% [2] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RANDOMIZE POSITION OF STANDARD AND VARIABLE AND SET, ACCORDINGLY, THE KEY
% THE SUBJECT HAS TO PRESS TO GIVE A CORRECT RESPONSE
if ~nAFC
    pos_ans = 1;
    sequence = variable;
else
    [sequence, pos_ans] = ShuffleSounds(sf, standard, variable, nAFC);
end;

% [3] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLAY THE SOUND
sound(sequence, sf, 16);

% [4] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASK THE QUESTION TO THE SUBJECTs
if ~nAFC
    q = 'Can you hear the signal ("1") or not ("0")?: ';
else
    q = ['Where was the signal (' num2str(1:nAFC) ')?: '];
end;