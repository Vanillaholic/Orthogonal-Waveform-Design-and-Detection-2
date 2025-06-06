function FSP = cal_FSP(CW_f,N_fft,fs)
    CW_f = 2*CW_f(N_fft/2+1:end);
    delta_f = fs/N_fft;
    FSP = abs(sum(abs(CW_f).^2).*delta_f).^2 / (sum(abs(CW_f).^4)*delta_f);

end