clear all
clc

%%
[y, Fs] = audioread("D:\Desktop\WaveformSet\wav_files\single_HFM.wav");
T = length(y)/Fs;
Y = y / max(abs(y));  % ��һ����[-1, 1]
Y = round(Y*2048*0.05+2047);  
%2048 = 2^11  �� [-1, +1] ���ԷŴ� [-2048, +2048]��Ҳ���� ��׼ 12 bit ȫ�̶�
%0.05 = 5%    �ٰѷ�����С 20 ��
%+2047        12 bit DAC �����ƽ���е��� 2047.5������дС����
%             ����ȡ 2047 ����ȡ����ȷ������������������� 4095


file = "144k_single_HFM.bin";
fileID = fopen(file, 'wb');
fwrite(fileID, Y, 'short');
fclose(fileID);

% fileID = fopen(file, 'r');
% A = fread(fileID,'short');
% fclose(fileID);


%%



