function [out, r_axis,v_axis] = widebandAF(x,fs,t,vel,c)

    pad_len=length(x)/2;
    signal = [zeros(1,pad_len),x,zeros(1,pad_len)];
    conj_rev_signal = conj(signal(end:-1:1));%共轭之后，再翻转


    time = linspace(-t(end),t(end),length(signal));
    delay = linspace(2 * time(1), 2 * time(end), 2 * length(signal) - 1);

    alpha = (c+vel)./(c-vel);
    %alpha = linspace(0.8, 1 / 0.8, 512);
    out = zeros(length(alpha), 2 * length(signal) - 1);

    for i = 1:length(alpha)
        out(i, :) = conv(signal, interp1(time, conj_rev_signal, time * alpha(i), 'spline'));
    end


    r_axis = c*delay/2;
    v_axis = vel;

end



c=1500;
vel=-10:1:10;
[AF, r_axis,v_axis] = widebandAF(pulse_HFM.',fs,t,vel,c);%输入信号必须为行向量

%插值
% 1) 构造原网格
[RR, VV] = meshgrid(r_axis, v_axis);      % RR, VV 与 AF 同尺寸

% 2) 构造细网格（倍率可自行调整）
Nfine_r = 8096;                  % 距离方向点数 (e.g. 4×原始)
Nfine_v = 8096;                  % 速度方向点数
r_fine  = linspace(min(r_axis), max(r_axis), Nfine_r);
v_fine  = linspace(min(v_axis), max(v_axis), Nfine_v);
[RRq, VVq] = meshgrid(r_fine, v_fine);

% 3) 二维插值 (spline / linear / cubic)
AF_fine = interp2(RR, VV, AF, RRq, VVq, 'linaer');  % 超界返回 NaN
AF_fine(isnan(AF_fine)) = 0;                     % 处理 NaN



imagesc(v_fine, r_fine, abs(AF_fine).'./max(max(abs(AF_fine))));
xlabel('velocity(m/s)');
ylabel('range(m)');
title('Wideband Ambiguity');
axis xy tight;
colorbar;
axis([-10,10,-1500,1500]);