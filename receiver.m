%% Read data.
[data, fs] = audioread('signal.wav');

%% Start your code here.

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