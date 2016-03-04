%============================================================================
%       CICESE
%   Programa para probar el aplanamiento espectral en una trama promedio del
%   residual de una senial de audio cardiaco 
%   Se calcularan las graficas de aplanamiento espectral contra orden del
%   filtro. Tambien se calcularan los eigenvalores de la matriz de
%   autocorrelacion (KLT) para evaluar la cantidad de coeficientes de la
%   DCT
%   Roilhi Ibarra 2014
%================================================================================
%                      _             _    __ _       _
%  ___ _ __   ___  ___| |_ _ __ __ _| |  / _| | __ _| |_ _ __   ___  ___ ___
% / __| '_ \ / _ \/ __| __| '__/ _` | | | |_| |/ _` | __| '_ \ / _ \/ __/ __|
% \__ \ |_) |  __/ (__| |_| | | (_| | | |  _| | (_| | |_| | | |  __/\__ \__ \
% |___/ .__/ \___|\___|\__|_|  \__,_|_| |_| |_|\__,_|\__|_| |_|\___||___/___/
%     |_|                            ____
%                                   |___ \
%                                     _) |
%                                   / __/_
%                                   |_____|
%===============================================================================
clear all
close all
clc
tic

fs = 8000; % Frecuencia de muestreo
load('BaseResiduales.mat') % Cargando base de residuales
x_n =BaseResiduales.patologias(1).formaOndaResidual; % Tomando un residual
load('onset_offset_Diastolic_Rumble.mat');
onset_offset = onset_offset_Diastolic_Rumble*fs;

wlen = 256;       % tamanio ventana de analisis
overlap = wlen/2; % traslape requerido entre ventanas
w = hamming(wlen,'periodic');

Y = buffer(x_n,wlen,wlen/2); % Matriz de bloques de 256 con overlap
[~,num_columnas] = size(Y);

[hay_evento]=definir_trama(onset_offset,overlap,num_columnas); %definiendo las columnas (tramas) donde hay evento cardiaco

for kk=1:num_columnas
    Y_m(:,kk) = Y(:,kk);
       % ====== Filtro de pre-enfasis y ventaneo -----------------------
    Y_m(:,kk) = w.*filter(1,[1 -0.93738],Y_m(:,kk));  
end

% ----------------- Realizando WLPC ---------------------------
newdir= addpath('/usr/local/mptk/matlab/WarpTB');    % Agregando directorio warped LPC
%newdir= addpath('/usr/local/mptk/matlab/voicebox');    % Agregando directorio LPC
lambda = 0.065;
p=1:100;
for g=1:length(p)
    for k=1:num_columnas
        [A(:,k),~]=wlpc(Y_m(:,k),p(g),lambda);
        e_n(:,k)= wfilter(A(:,k),1,Y_m(:,k),lambda); % Calculo de la senial de error (residual del residual)
        if hay_evento(k)==1
            tramas_evento(k,:)  =   e_n(:,k);
        else
            tramas_silencio(k,:)=   e_n(:,k);
        end
    end
        % Calculando las tramas promedio para cada valor de p
        trama_evento_prom   = sum(tramas_evento)/wlen;
        trama_silencio_prom = sum(tramas_silencio)/wlen;
        % Calculando la correlacion de la trama promedio 
        autocorr_evento_prom(g,:)   = xcorr(trama_evento_prom);
        autocorr_silencio_prom(g,:) = xcorr(trama_silencio_prom);
        [gamma2_sil(g),~,~] = sfm(trama_evento_prom,2*wlen);
        [gamma2_ev(g),~,~] = sfm(trama_silencio_prom,2*wlen);
    A=[];
    e_n=[];
    tramas_evento=[];
    tramas_silencio=[];
end
% Calculando la autocorrelacion promedio de las autocorrelaciones de las
% tramas promedio
autocorr_prom_silencio = sum(autocorr_silencio_prom(2:100,:))/numel(p);
autocorr_prom_evento =  sum(autocorr_evento_prom(2:100,:))/numel(p);

% Calculando las matrices de autocorrelacion (dadas las autocorrelaciones promedio)
mat_autoc_silencio = toeplitz(autocorr_prom_silencio);
mat_autoc_evento   = toeplitz(autocorr_prom_evento);

% Calculando los valores singulares de las matrices
S1 = svd(mat_autoc_silencio);
S2 = svd(mat_autoc_evento);



FontSize = 14;
f1=plot(p,gamma2_sil), 
hold on
plot(p,gamma2_ev,'r'),grid 
title('Aplanamiento espectral segun el orden de un filtro LPC','FontSize',FontSize)
legend('Trama de silencio cardiaco','Trama de evento cardiaco','Location','SouthEast')
xlabel('Orden del filtro','FontSize',FontSize),ylabel('Spectral flatness (\gamma_x^{2})','FontSize',FontSize)
definir_fuente_ejes_grafico(f1,FontSize)

figure
f2=plot(10*log10(S1./max(S1))), 
hold on
plot(10*log10(S2./max(S2)),'r'),grid 
%title('Valores singulares de la autocorrelacion','FontSize',FontSize)
% legend('Trama de silencio cardiaco','Trama de evento cardiaco','Location','SouthEast')
% xlabel('Orden del filtro','FontSize',FontSize),ylabel('Spectral flatness (\gamma_x^{2})','FontSize',FontSize)
definir_fuente_ejes_grafico(f2,FontSize)

toc





