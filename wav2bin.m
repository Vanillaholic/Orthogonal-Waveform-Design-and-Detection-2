clear all
clc

%%
[y, Fs] = audioread("D:\Desktop\WaveformSet\wav_files\single_HFM.wav");
T = length(y)/Fs;
Y = y / max(abs(y));  % 归一化到[-1, 1]
Y = round(Y*2048*0.05+2047);  
%2048 = 2^11  把 [-1, +1] 线性放大到 [-2048, +2048]，也就是 对准 12 bit 全刻度
%0.05 = 5%    再把幅度缩小 20 倍
%+2047        12 bit DAC 的零电平在中点码 2047.5。不能写小数，
%             所以取 2047 向下取整，确保加上振幅后永不超过 4095


file = "144k_single_HFM.bin";
fileID = fopen(file, 'wb');
fwrite(fileID, Y, 'short');
fclose(fileID);

% fileID = fopen(file, 'r');
% A = fread(fileID,'short');
% fclose(fileID);


%%



