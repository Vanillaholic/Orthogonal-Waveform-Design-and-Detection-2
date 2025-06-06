function seq = m_seq(gen, init)
%M_SEQ  生成 m 序列
%   seq = M_SEQ(gen)             默认初始状态 [1 1 … 1]
%   seq = M_SEQ(gen, init)       指定 n 位初始状态向量（非零）
%
%   gen  —— 行向量 [1 c_{n-1} … c_0]，最高次项系数必须为 1
%           例如 x^4 + x + 1 写成 [1 0 0 1 1]
%   init —— 行向量 [a_{n-1} … a_0]，长度 n，至少有 1 个 1
%
%   参考：Sarwate & Pursley (1980)

    if gen(1) ~= 1
        error('Highest-degree coefficient must be 1.');
    end

    taps = fliplr(gen(2:end));   % c_{0: n-1}，顺序与寄存器位对齐
    n    = length(taps);         % 寄存器级数
    N    = 2^n - 1;              % 序列周期

    % 默认初始状态 111…1
    if nargin < 2
        reg = ones(1, n);
    else
        reg = init(:).';         % 强制成行向量
        if length(reg) ~= n
            error('INIT length must equal degree n = %d.', n);
        end
        if ~any(reg)
            error('Initial state must be non-zero.');
        end
    end

    seq = zeros(1, N);
    for k = 1:N
        seq(k)    = reg(1);                       % 输出最高位
        feedback  = mod(sum(reg & taps), 2);      % XOR 选中的 tap
        reg       = [reg(2:end) feedback];        % 左移并注入反馈
    end
end
