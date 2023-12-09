function [pos_ans, q] = ILD_DiscriminationPureTone_MLP(std_level, var_level, nAFC)

% ITD discrimination for a 5000-Hz, 250-ms pure tone. The subject has to
% tell whether the leading tone of the tone pair comes from the left or
% from the right. Both tones have a certain ILD.
% - PARAMETER VARIED ADAPTIVELY: the ILD of the variable tone (here it is
% the left tone). The same ITD value is also used for the standard tone
% however, with opposite sign;

if ~nAFC
    error('Discrimination thresholds must be estimated with nAFC tasks!');
end;

%EXPERIMENT'S PARAMETER %%%
sf = 44100; % sample frequency in Hz
freq = 5000; % frequency of the standard tone in Hz
amp = 1; % amplitude of the sine wave
phase = 0; % phase of the sine wave
dur = 250; % tones' duration in ms
ITD = 0; % tones' ITD

% [1] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE SOUNDS
standard = GenerateTone(sf, dur, freq, amp, phase, ITD, -var_level);
standard = GenerateEnvelope(sf, standard);
standard = AttenuateSound(standard, -10);

variable = GenerateTone(sf, dur, freq, amp, phase, ITD, var_level);
variable = GenerateEnvelope(sf, variable);
variable = AttenuateSound(variable, -10);

% [2] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RANDOMIZE POSITION OF STANDARD AND VARIABLE AND SET, ACCORDINGLY, THE KEY
% THE SUBJECT HAS TO PRESS TO GIVE A CORRECT RESPONSE
[sequence, pos_ans] = ShuffleSounds(sf, standard, variable, nAFC);

% [3] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLAY THE SOUND
sound(sequence, sf, 16);

% [4] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASK THE QUESTION TO THE SUBJECT
q = ['Is the leading tone from left or right (' num2str(1:nAFC) ')?: '];