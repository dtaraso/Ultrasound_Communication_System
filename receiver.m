%% Read data.
[data, fs] = audioread('signal.wav');

%% FILTER
% lowpass -- demodulate the carrier signal and demodulate BPSK
% bandpass -- filter out noise in env as signal is around 20kHz
f = 100;
fc = 20000;
banded = bandpass(data, [fc-2000, fc+2000], fs);

%% EXTRACT THE SEGMENT OF THE SIGNAL ENCODED THE DATA BITS
% brute force method in order to determine optimal start and end index
start_index = 296804;
end_index = start_index + 98784 - 1;
banded = banded(start_index:end_index);

%% DEMODULATE THE CARRIER SIGNAL
t = 0:1/fs:(length(banded))/fs;
t(end) = [];
carrier = transpose(cos(2*pi*fc*t));
demodulated = banded .* carrier;
demodulated = lowpass(demodulated, fc, fs);

%% ELIMINATING THE FREQUENCY SHIFT
cfo = exp(2i*pi*0.62/fs*(1:length(demodulated)));
h = hilbert(demodulated); % - Hilbert Transform
h = h./cfo';
demodulated = imag(h);


%% BPSK DEMODULATION
% Received Signal
% Sine Wave
BPSK = sin(2*pi*f*t);
% Multiply
sig = demodulated .* transpose(BPSK);
% Low-Pass Filtering
low = lowpass(sig, 50, fs);

% Decoding
msg = [];
code_length = round(fs/f);

for i = 1:224
    msg(i) = mean(low((i-1)*code_length+1:i*code_length)) < 0;
end

%% Convert data bit to ascii character.
text_length = length(msg) / 8;
text_ascii = zeros(1, text_length);
for i = 1:text_length
    c_ascii = 0;
    c_bin = msg((i-1)*8+1:i*8);
    for j = 1:8
        c_ascii = c_ascii * 2 + c_bin(j);
    end
    text_ascii(i) = c_ascii;
end

disp(char(text_ascii));

%% Evaluation
original = transpose(b); % From transmitter.m
difference = sum(original~=msg);
disp("Difference in Bits: ");
disp(difference);
disp("Bit Error Rate: ");
disp(difference/224);
