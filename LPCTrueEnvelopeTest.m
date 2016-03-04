% ========================================================================
%    _     ____   ____      _
%   | |   |  _ \ / ___|    | |_ _ __ _   _  ___
%   | |   | |_) | |   _____| __| '__| | | |/ _ \
%   | |___|  __/| |__|_____| |_| |  | |_| |  __/
%   |_____|_|    \____|     \__|_|   \__,_|\___|
%   
%                       _
%   ___  _ ____   _____| | ___  _ __   ___
%   / _ \ '_ \ \ / / _ \ |/ _ \| '_ \ / _ \
%  |  __/ | | \ V /  __/ | (_) | |_) |  __/
%   \___|_| |_|\_/ \___|_|\___/| .__/ \___]
%                              |_|
% ========================================================================
% Test de las funciones enviadas por Fernando Villavicencio

clear
close all
clc
fs = 8000;
load('resSilenciosHCT11_40')
sig= res_silencios;

sig = sig./max(sig);


wlen = 256;
overlap = wlen/2;
Y = buffer(res_silencios,wlen,overlap);

%     preemp = 0.901;
% 
     w = window(@gausswin,wlen);
     w=hamming(wlen,'periodic'); %Ventana deslizante
     [~,n] =size(Y);
    Y_m =zeros(size(Y));
% ---------------Multiplicando por la ventana los elementos columna (segmentos con overlap)
    for k=1:n
        Y_m(:,k) = w.*Y(:,k);
    % ====== Filtro de pre-enfasis -----------------------
        %Y_m(:,k) = w.*filter(1,[1 -preemp],Y(:,k));    
    end
    f0 = 100;
   To = fs/f0;
    a_gain = zeros(1,n);
    ord_ar = fs/(f0*0.5);
    ord_te = ord_ar;
    a = cell(1,n);
    % Etapa de analisis
    for k=1:n
        [a{k}, a_gain(k), ~, ~, ~] = trueEnv_AR(Y_m(:,k), ord_ar, ord_te, fs);
    end
    sigRec = zeros(size(Y));
    
    syn=trenImp(wlen,To);
    
    for k=1:n
        synT = sqrt(a_gain(k)).*filter(hanning(floor(To/10)),1,syn)/sum(hanning(floor(To/10)));
        sigRecVec=filter(1,a{k},synT);
        %sigRec(:,k)= sigRecVec(To+1:end);
        sigRec(:,k)= sigRecVec;
    end
    
    Yrec = OLA(sigRec,overlap,wlen,numel(sig)); 
    
[H,F] = corrSpectrum(sig,8000,40);

[Sxx,FF] = corrSpectrum(Yrec,8000,40);

figure
plot(F,20*log10(abs(H))),grid, hold on, plot(FF,20*log10(abs(Sxx)),'r')


% Etapa de sintesis


