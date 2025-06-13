
clear all
clc




% 1. 读取 WAV
[x, fs] = audioread('D:\Desktop\WaveformSet\wav_files\HFM_3kHz_3s_200Hz.wav', 'native');   % x 为 int16 / int24 / float

% 2. 量化到 float32
if isinteger(x)
    x = single(x) / double(intmax(class(x))); % ±1 归一化
else
    x = single(x);                            % 已是浮点
end

% 3. 写成二进制
fid = fopen('D:\Desktop\WaveformSet\bin_files\HFM_3kHz_3s_200Hz.bin', 'wb');
fwrite(fid, x, 'float32', 'ieee-le');         % 'ieee-le' → Little-Endian
fclose(fid);


fid = fopen('D:\Desktop\WaveformSet\bin_files\HFM_3kHz_3s_200Hz.bin', 'rb');
y = fread(fid, [size(x,2) Inf], 'float32=>single', 0, 'ieee-le')';
fclose(fid);