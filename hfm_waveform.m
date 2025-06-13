% ================================================================
% hfm_waveform.m
% Hyperbolic FM (HFM) generator  —   analytic (complex) signal
% ----------------------------------------------------------------
% s = hfm_waveform(fs, T, fmin, fmax, A)
%
%    fs    : Sampling rate (Hz)
%    T     : Pulse length  (s)
%    fmin  : Minimum (starting) frequency (Hz)
%    fmax  : Maximum (ending)  frequency (Hz)
%    A     : Amplitude (default 1)
%
% RETURNS
%    t     : Column-vector time axis  (s)
%    s     : Column-vector analytic HFM signal (complex)
%
%       SH(t) = A * exp( -j*2*pi*µ * ln(1 - f0*t/µ) ),  0 ≤ t ≤ T
% ----------------------------------------------------------------
% µ  = T * fmin * fmax / B
% B  = fmax - fmin
% f0 = (fmax + fmin)/2
% ================================================================
function [t, s] = hfm_waveform(fs, T, fmin, fmax, A)

    if nargin < 5,  A = 1;  end

    % --- parameters from the screenshot -------------------------
    B  =  fmax - fmin;           % bandwidth
    f0 = (fmax + fmin)/2;        % centre frequency
    mu =  T * fmin * fmax / B;   % µ   (mu)

    % --- time vector (rect window implicit) ---------------------
    t = (0 : 1/fs : T-1/fs).';   % column vector

    % --- validity check: 1 - f0*t/mu > 0  -----------------------
    if any(t >= mu / f0)
        error('Time vector extends beyond valid range (t >= µ/f0).');
    end

    % --- analytic HFM waveform ----------------------------------
    phase = -2*pi*mu * log( 1 - f0 .* t / mu );   % φ_H(t)
    s     = A * exp( 1j * phase );                % complex envelope

end
