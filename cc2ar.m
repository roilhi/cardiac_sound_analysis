function [a, a_gain, ngain, fa, fm, specC] = cc2ar(cc_o, ord_ar, N, mel_flag, FS, alpham);
%function [a, a_gain, ngain, fa, fm, specC] = cc2ar(cc_o, ord_ar, N, mel_flag, FS);
%
% computes an All-Pole system from a cepstrum based spectrum
%
% F. Villavicencio xdynamo@gmail.com
%


if nargin < 6
    alpham = 3/8; % default mel-scale value by Imai
end

ord_te     = length(cc_o)-1;
cc         = [cc_o; zeros(N-(ord_te*2+1),1); cc_o(end:-1:2)];
specC      = fft(cc);
specC      = real(specC)';
fa         = [0:N/2]/(N/2)*(FS/2);

% Apply mel-frequency scaliing (if enabled)
if mel_flag
    % previous code
    %aux = Flinear2mel(fa/(FS/2)*pi, alpham)./pi*(FS/2);
    %fm  = interp1(aux, fa, fa);    
    %if fm(end) > fa(end), fm(end) = fa(end);  end %force FS/2 as last freq.
    %specC =  interp1(fa, specC(round(end/2):1:end), fm);
    [specC fm] = Fscale_env(specC(round(end/2):1:end), fa, 'lin2mel', FS, alpham);    
else
    specC = specC(round(end/2):1:end);
    fm = fa;
end
specC = [specC specC(end-1:-1:2)];

% compute autoregressive model (all-pole)
env_ft    =  exp((specC/20)/log10(exp(1)));
rxx_env   =  real(ifft(abs(env_ft.*env_ft)));

[a ngain] = levinson(rxx_env(1:ord_ar+1), ord_ar); %%re_levinson = re_lpc*length(X); attention!
a_gain    = ngain/N;%Hpoints*2; % lpc gain using estimated signal length

return
