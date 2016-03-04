% =========================================================================
%       CICESE
%     Programa para tratar de reconstruir (sintetizar) el residual mas silencios
%     de la senial de audio cardiaco "soplo diastolico". 
%     La sintesis se realiza mediante WLPC por medio de un tren de pulsos
%     (ventanas Hanning periodicas)
%     el periodo de "pitch" se estima con una funcion externa (además de usar peakdet)
% =========================================================================
%      _       _            _                     _     _             _
%  ___/_/_ __ | |_ ___  ___(_)___   _ __ ___  ___(_) __| |_   _  __ _| |
% / __| | '_ \| __/ _ \/ __| / __| | '__/ _ \/ __| |/ _` | | | |/ _` | |
% \__ \ | | | | ||  __/\__ \ \__ \ | | |  __/\__ \ | (_| | |_| | (_| | |
% |___/_|_| |_|\__\___||___/_|___/ |_|  \___||___/_|\__,_|\__,_|\__,_|_|
%==========================================================================

clear all
close all
clc

fs = 8000; % Frecuencia de muestreo
load('BaseResiduales.mat') % Cargando base de residuales
x_n =BaseResiduales.patologias(1).formaOndaResidual; % Residual a reconstruir
onset_offset = BaseResiduales.patologias(1).onset_offset*fs;

%load('res_silencios_normal_uwash.mat');
%x_n= res_silencios_normal_uwash;
%x_n=x_n/max(x_n);
wlen = 256;
overlap = wlen/2;
Y = buffer(x_n,wlen,overlap); % Matriz de bloques de 256 con overlap
[~,n]=size(Y);
preemp = 0.93738; % Parámetro del filtro de pre-énfasis
%preemp = 0.901;


w=blackman(wlen,'periodic'); %Ventana deslizante
Y_m =zeros(size(Y));
% ---------------Multiplicando por la ventana los elementos columna (segmentos con overlap)
for k=1:n
   Y_m(:,k) = w.*Y(:,k);
   % ====== Filtro de pre-enfasis -----------------------
   Y_m(:,k) = w.*filter(1,[1 -preemp],Y(:,k));    
end

% ----------------- Realizando WLPC ---------------------------
%newdir= addpath('/usr/local/mptk/matlab/WarpTB');    % Agregando directorio warped LPC
%newdir= addpath('/usr/local/mptk/matlab/voicebox');    % Agregando directorio LPC
%lambda = 0.065;
p1 = 15;
p2 = 10;
[hay_evento]=definir_trama(onset_offset,overlap,n);
    e = zeros(1,n);
    A = cell(1,n);
    To = zeros(1,n);

for k=1:n
    %[A(:,k),e(k)]=wlpc(Y_m(:,k),p,lambda); 
        if hay_evento(k)==1
            [A{k},e(k)]=lpc(Y_m(:,k),p1);
        else
            [A{k},e(k)]=lpc(Y_m(:,k),p2);
        end

    %[A(:,k),e(k),~]=lpcauto(Y_m(:,k),p);
    [To(k)]= estimar_periodo_pitch(Y_m(:,k),0.3);
end


% ========= Etapa de sintesis LPC ==================
sigRec = zeros(size(Y));
for k=1:n
    if (To(k)~=0)
    %if (hay_evento(k)==1)
        syn=trenImp(wlen+To(k),To(k));
        syn = sqrt(e(k)).*filter(hanning(floor(To(k)/4)),1,syn)/sum(hanning(floor(To(k)/4)));
         %sigRecVec=wfilter(sqrt(e(k)),A(:,k),syn,lambda);
         sigRecVec=filter(1,A{k},syn);
         sigRec(:,k)= sigRecVec(To(k)+1:end);
         % ====== Filtro de pre-enfasis inverso -----------------------
         sigRec(:,k) = w.*filter([1 preemp],1,sigRec(:,k)); 
    else
            
            nsyn = sqrt(e(k)).*randn(1,wlen);
            s=rng;
            %sigRec(:,k)=w'.*wfilter(sqrt(e(k)),A(:,k),nsyn,lambda);
            sigRec(:,k) = filter(1,A{:,k},nsyn);
            % ====== Filtro de pre-enfasis inverso -----------------------
            sigRec(:,k) = w.*filter(1,[1 preemp],sigRec(:,k)); 
    end
end

% ========= Realizando la reconstruccion OLA ==========

% ============ Etapa de overlap-add. ========================

RecSig = OLA(sigRec,overlap,wlen,numel(x_n));

plot(x_n), hold on, plot(RecSig,'r'), grid on

R = corrcoef(x_n,RecSig)
        
     
     


