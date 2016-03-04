function [Sxx,F] = peakFT(s,fs)
    n = length(s);
    m = mean(s);
    F = -fs/2:fs/(n-1):fs/2;
    Sxx = abs(fft(s-m)/n);
end
    