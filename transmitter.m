%% Define the message we want to send to the receiver.
message = 'Welcome to CSE891 section 4!';

%% Convert the message to ascii code.
message = abs(message);

%% Convert the ascii code to binary data bits.
len_msg = length(message);
b = zeros(len_msg*8, 1);
for i = 1:len_msg
    t = zeros(8, 1);
    for j = 1:8
        t(8-j+1) = mod(message(i),2);
        message(i) = floor(message(i) / 2);
    end
    b((i-1)*8+1: i*8) = t;
end

%% BPSK modulation.
fs = 44100;
f = 100;
code_length = round(fs/f);
code = [];
for i = 1:length(b)
    code((i-1)*code_length+1:i*code_length) = b(i);
end

code = 2 * code - 1;
t = 0:1/fs:(code_length * length(b) - 1)/fs;
BPSK = sin(2*pi*f*t);
sig = BPSK.*code;

%% Modulate with a high-frequency carrier.
fc = 20000;
carrier = cos(2*pi*fc*t);
sig_out = [carrier carrier sig.*carrier carrier];

%% Transmit by the ultrasounic speaker.
sound(sig_out, fs);