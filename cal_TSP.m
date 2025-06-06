function Tc = cal_TSP(pulse_CW,fs)
    delta_t = 1/fs;
    Tc =  abs(sum( abs(pulse_CW).^2)*delta_t).^2/(sum(abs(pulse_CW).^4)*delta_t ) ;
end