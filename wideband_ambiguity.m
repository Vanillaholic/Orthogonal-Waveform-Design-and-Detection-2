
function [RDM, vel_axis, range_axis] = wideband_ambiguity(tx_signal, rx_signal, fs, c, max_vel)
% RANGE_DOPPLER_MAP 生成距离多普勒图
%
% 输入参数:
%   tx_signal   - 发射的信号波形
%   rx_signal   - 接收的信号波形
%   fs          - 采样率
%   c           - 波速
%   max_vel     - 最大观测速度
%
% 输出参数:
%   RDM         - range doppler map,一个横轴是速度,纵轴是距离的矩阵
%   vel_axis    - 速度轴,以便可视化
%   range_axis  - 距离轴,以便可视化

% 确保输入为行向量
if iscolumn(tx_signal)
    tx_signal = tx_signal';
end
if iscolumn(rx_signal)
    rx_signal = rx_signal';
end

% 根据发射的波形获取模板
T = length(tx_signal) / fs;                    % 脉冲长度
sample_num = 3 * length(tx_signal);           % 设置RDM的samples数目为发射信号的三倍
tx_paddle = [zeros(1, length(tx_signal)), tx_signal, zeros(1, length(tx_signal))];

vel_resolution = 0.1;                         % 速度bin

delta_T = 1/fs;
range_resolution = c * delta_T / 2;                 % 距离分辨率,由脉宽决定：delta r = c*T/2
vel_axis = -max_vel:vel_resolution:max_vel;   % 速度范围
range_axis = (-sample_num/2: 1:sample_num/2-1)*range_resolution;  % 生成数组

% 根据发射波形获取不同的模板
doppler_factor = 1 + 2 * vel_axis / c;        % 多普勒因子

% 将多普勒因子变成分数，p是分母，q是分子
pq_list = zeros(length(vel_axis), 2);         % 存储(p, q)对
for i = 1:length(doppler_factor)
    [p, q] = rat(doppler_factor(i));          % MATLAB的rat函数：doppler_factor ≈ q/p
    pq_list(i, :) = [p, q];                   % 存储为(p, q)
end

% 初始化模板
templates = zeros(length(vel_axis), sample_num);

for i = 1:length(vel_axis)
    p = pq_list(i, 1);
    q = pq_list(i, 2);
    
    % 对发射信号进行重采样
    % MATLAB的resample函数: resample(x, up, down) => up=q, down=p
    temp_resamp = resample(tx_paddle, q, p);
    
    % 如果得到的长度不是 sample_num，就截断或补零
    if length(temp_resamp) > sample_num
        temp_resamp = temp_resamp(1:sample_num);
    elseif length(temp_resamp) < sample_num
        % 补零
        temp_resamp = [temp_resamp, zeros(1, sample_num - length(temp_resamp))];
    end
    
    % 存到第 i 行，并进行翻转（对应Python的[::-1]）
    templates(i, :) = fliplr(temp_resamp);
end

% 利用不同的模板与接收信号进行匹配滤波，以便获取速度信息
RDM = zeros(sample_num, length(vel_axis));    % 初始化RDM矩阵

for i = 1:length(vel_axis)
    % 使用conv函数进行卷积，'same'模式保持与接收信号同样长度
    conv_result = conv(templates(i, :), rx_signal, 'same');
    
    % 如果卷积结果长度与sample_num不匹配，进行调整
    if length(conv_result) > sample_num
        % 截断到中心部分
        start_idx = floor((length(conv_result) - sample_num) / 2) + 1;
        conv_result = conv_result(start_idx:start_idx + sample_num - 1);
    elseif length(conv_result) < sample_num
        % 补零
        pad_size = sample_num - length(conv_result);
        conv_result = [conv_result, zeros(1, pad_size)];
    end
    
    RDM(:, i) = conv_result';
end

% 取绝对值
RDM = abs(RDM);

end

% ===== 辅助函数：改进的卷积函数（可选） =====
function result = improved_conv_same(template, signal)
% 改进的卷积函数，更精确地模拟scipy.signal.fftconvolve的'same'模式
    
    % 使用FFT进行快速卷积
    N = length(template) + length(signal) - 1;
    
    % 补零到合适的长度
    template_padded = [template, zeros(1, N - length(template))];
    signal_padded = [signal, zeros(1, N - length(signal))];
    
    % FFT卷积
    result = ifft(fft(template_padded) .* fft(signal_padded));
    result = real(result);  % 取实部
    
    % 提取'same'部分
    if length(signal) >= length(template)
        start_idx = floor(length(template) / 2) + 1;
        result = result(start_idx:start_idx + length(signal) - 1);
    else
        start_idx = floor(length(signal) / 2) + 1;
        result = result(start_idx:start_idx + length(template) - 1);
    end
end