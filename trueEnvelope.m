function [cc, eerror, errVCO] = trueEnvelope(spec, ord, FS, do_presmooth, vco_f, do_optimal, do_plot)
%  Simple Cepstrum based "True Envelope" spectral envelope estimator
%  
%   Inputs
%       spec:         signal spectrum (20*log10(abs(fft)))
%       ord:          cepstral order (theorical optimal --> Fs/(2*F0)
%       FS:           samplerate
%       do_presmooth: pre-estimation of envelope to fix 0 and FS/2 Hertz
%                     values.
%       vco_f:        max. voicing frequency to consider in the optimization
%                     (not critical but 1 or 2KHz may help in some cases),
%                     let empty otherwise.
%       do_optimal:   minimum error order search (to improve), empty otherwise.
%
%   Outputs
%       cc:     optimized cepstrum coefficients
%       aveE:   average spectral error related to the spectral peaks
%
%  F. Villavicencio, xdynamo@gmail.com (2012)


% processing settings 
max_iter  = 150;  % maximum # of iterations (optimization loop) 
eThres    = 1e-6; % spectral error minimization threshold

do_debug = 0; % allow pause at optimal search steps 

if nargin < 7
    do_plot = 0;
    if nargin < 6
        do_optimal = 0;
        if nargin < 5
            vco_f = [];
            if nargin < 4
                do_presmooth = 1;
            end
        end
    end
end


% Initialize spectra
if iscolumn(spec)
    spec  = [spec(end/2+1:end); spec(1:end/2)];
else
    spec  = [spec(end/2+1:end) spec(1:end/2)];
end
specU = spec;


% find VCO or frequency check points
if ~isempty(vco_f) & ~isempty(FS)
    fa = [0:length(spec)/2]/(length(spec))*(FS);
    
    if length(vco_f)>1
        for m=1:length(vco_f)
            id       = find(fa<=vco_f(m));
            vco_i(m) = id(end);            
        end
    else
        id = find(fa<=vco_f);
        vco_i = id(end);
    end    
else
    vco_i = []; % full spectrum
end


% presmoothing (fix spectrum at F=0,FS/2)
if do_presmooth
    ord_ps = floor(ord/2);
    eThres = 1e-6;
    [specPS, cc, aveE] = teloop(spec, ord_ps, eThres, max_iter, [], FS, 0);
    specU(1)       = specPS(1);
    specU(end)     = specPS(end);
    specU(end/2+1) = specPS(end/2+1);
end

% ===================================================================== %

% estimation with optimal or given order
%[specC, cc, aveE, errVCO] = teloop(specU, ord, eThres, max_iter, vco_i, do_plot);
[specC, cc, eerror] = teloop(specU, ord, eThres, max_iter, vco_i, FS, do_debug);

cc = cc(1:ord+1);    

% plots
if do_plot    
    
    figure(10)
    plot(spec); hold on

    if do_presmooth 
        plot(specPS,'r--');  
        plot(specC,'k');
        legend('spectrum','pre-smoothing','true envelope')
    else
        plot(specC,'k');
        legend('spectrum','true-envelope')
    end
    hold off
    grid on
    title(sprintf('True Envelope optimization result. Order: %d', ord));
    xlim([length(spec)/2 length(spec)])
end

if isrow(cc), cc = cc'; end

return


%================ optimization loop =================%
%function [specC, cc, aveE, errVCO] = teloop(spec, ord, eThres, max_iter, vco_i, FS, do_debug)
function [specC, cc, eerror, errVCO] = teloop(spec, ord, eThres, max_iter, vco_i, FS, do_debug)

specU = spec;
aveE  = 1;
id    = 1;
errVCO = nan;

% find limit bins if given VCO 
if ~isempty(vco_i)
    if length(vco_i)==1
        fv_min = length(spec)/2+1-vco_i;
        fv_max = length(spec)/2+1+vco_i;
    else
        fv_points = [length(spec)/2+1-vco_i+1 length(spec)/2+1+vco_i-1]; 
    end
end

% optimization loop
while ((aveE > eThres) & (id < max_iter))
    cc = ifft(specU);
    cc = real(cc); % discard imaginary values
    
    zpad  = ceil(length(cc)/2)-ord;
    cc(end/2+1-zpad+1:end/2+1+zpad) = 0;
    specC = fft(cc);
    specC = real(specC);
    errE  = specU-specC;
    
    % compute cost and final error 
    if length(vco_i)==1 
        aveE = sum(errE(fv_min:fv_max).^2)./length(errE(fv_min:fv_max));
        eerror = sum(errE.^2)./length(errE);
    else
        aveE = sum(errE.^2)./length(errE);
        eerror = aveE;
    end
    
    % update cepstral spectra
    idx = find(errE<0);
    errE(idx) = 0;
    specU = specC+errE;
    id    =  id+1;

    if do_debug % plot loop evolution
        fa = [0:(length(spec)/2)-1]/(length(spec)/2)*(FS/2);
        fi = find(fa<=6e3);
        fi = fi(end);
        figure(103)
        plot(spec); hold on
        plot(specC,'k');
        plot(specU,'m')
        if ~isempty(vco_i) & length(vco_i)==1
            stem([fv_min fv_max], specC([fv_min fv_max]),'r--');
        end
        hold off
        grid on
        xlim([length(spec)/2 length(spec)/2+fi])
        legend('input spectrum','final envelope', 'updated envelope')
        title(sprintf('True Envelope optimization loop. Order: %d, iteration: %d', ord, id))
        %pause
    end
        
end

if length(vco_i)>1
    errVCO = sqrt(sum((specC(fv_points)-spec(fv_points)).^2)./length(fv_points));
else
    errVCO = aveE;
end

return 



%%% test code %%%%%
if 0    
% optimal estimation loop %
% ======================= %
if do_optimal
    ord_step = 2;
    oo = [floor(ord/(1.5)):ord_step:(ord+ord_step+1)];
    oo = [oo ord];
    
    % order optimization loop
    id = 1;
    errL = zeros(size(oo));
    errVCO = zeros(size(oo));
   
    ord  = 0;
    while id<=length(oo)        
        ord = oo(id);
        if do_presmooth
            ord_ps = floor(ord/2);
            eThres = 1e-6;
            [specPS, cc, aveE] = teloop(spec, ord_ps, eThres, max_iter, [], 0);
            specU(1)       = specPS(1);
            specU(end)     = specPS(end);
            specU(end/2+1) = specPS(end/2+1);
            figure(77)
            plot(spec); hold on
            plot(specPS,'k');
            plot(specU,'r'); hold off
            xlim([500 700])
            ylim([-30 40])
        end        
        [specC, cc, errL(id), errVCO(id)] = teloop(specU, ord, eThres, max_iter, vco_i, FS, do_plot);
        id = id+1;
        
        if do_debug
            fprintf('\n cepstral order: %d', ord)
            pause            
        end
        %pause        
    end
    
    % select best order
    [aveE oi] = min(errVCO);
    ord = oo(oi);
end
end
