    function [a, a_gain, N, cc_o, errE] = trueEnv_AR(sframe, ord_ar, ord_te, FS, mel_flag, alpham, vco_f, do_plot)
% Computes autoregressive (all-pole) model based on a True-Envelope
% estimation
% Inputs
%   -> sframe:   signal (Note: windowing is not applied internally)
%   -> ord_ar:   all-pole model order (optimal ~ <= FS/F0*0.5 or FS/F0*0.15 for mel-scaling) 
%   -> ord_te:   true-envelope order (optimal = FS/F0*0.5)
%   -> FS:       samplerate
%   -> mel_flag: if 1 apply mel-scaling to the true-envelope estimate
%                (MTEAP) with alpham as scaling factor (default= 3/8,
%                proposed by Imai for full range freq; 1/8 seems OK for
%                16KHz signals)
%
% Outputs
%   a = all-pole filter coefficients
%   a_gain = residual energy
%
%  F. Villavicencio, xdynamo@gmail.com (2012)
%


dbstop if error

if nargin < 8
    do_plot = 0;  % default mel scaling factor proposed by Imai
    if nargin < 7
        vco_f = [];
        if nargin < 6
            alpham = 3/8;  % for FS = 44.1KHz, for FS = 16KHz aplha = 1/8 is suggested.
            if nargin < 5
                mel_flag = 0;
            end
        end
    end
end

do_presmooth = 1;  % intermediary step of TE estimation to fix 0 and FS/2 values

N = length(sframe);
if mod(N,2), N = N+1; end
spec = 20*log10(abs(fft(sframe,N)));

% True Envelope estimation
[cc_o errE] = trueEnvelope(spec', ord_te, FS, do_presmooth, vco_f, 0, 0); 

% from cepstrum to AR
[a a_gain ngain fa fm specC] = cc2ar(cc_o, ord_ar, N, mel_flag, FS, alpham);


% ================================================================== %


if do_plot
    
    [alp glp] = lpc(sframe,ord_ar);
    specLP    =  freqz(1, alp, N,'whole');
    
    specAR  =  freqz(1, a, N,'whole');    
    figure (100)
    is = floor(N/2);  ie = N;
    plot(fa, spec(1:end/2+1)); hold on
    plot(fm, specC(ie:-1:is),'k--','LineWidth',1);    
    plot(fa, 20*log10((abs(specLP(1:end/2+1))))+20*log10(glp*length(sframe))/2,'m','LineWidth',1);

    plot(fm, 20*log10((abs(specAR(ie:-1:is))))+20*log10(ngain)/2,'r','LineWidth',1);
    grid on; hold off
    xlim([0 FS/2]);
    
    if mel_flag
        legend('S_k(\omega)','TE', 'TEAP (mel)', 'LP');
        title(sprintf('True Envelope AR Envelope Estimation. TE order: %d, AR order: %d, alpha (mel-scale): %d',ord_te, ord_ar, alpham));
    else
        legend('S_k(\omega)','TE', 'TEAP', 'LP');
        title(sprintf('True Envelope AR Envelope Estimation. TE order: %d, AR order: %d',ord_te, ord_ar));
    end
    
    %figure(200)
    %plot(sframe); grid on    
    
end



return    


    