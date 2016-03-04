%=======================
%  CICESE
% Programa donde se obtiene la senial de residual y silencios del audio cardiaco
% Los eventos son extraidos de la senal y descompuestos por Matching
% Pursuit con atomos de Gabor con un minimo de 10 iteraciones, dicha
% cantidad se incrementa hasta retener un 99% de la energia de la senal en
% la reconstruccion
%   ==================
clear all
close all
clc
%leyendo la senal de audio cardiaco
[sig,fs]=audioread('Diastolic_Rumble_resampled.wav');
%================================================
 load('onset_offset_Diastolic_Rumble.mat'); 
 eventos = round(onset_offset_Diastolic_Rumble*fs);
 %sig(1:1000)=zeros(1000,1);
 prevsig = sig;
 [m,n]=size(eventos);
if n==4 % Quiere decir que solo hubo eventos s1 y s2, 4 columnas (no patologias)
    ataques_s1= [eventos(:,1) eventos(:,2)]; %columnas [onset offset] s1
    ataques_s2 = [eventos(:,3) eventos(:,4)]; %columnas [onset offset] s2
    % En la siguiente matriz se presentan en los primeros renglones los onset y
    % offset de s1 y en el resto los de s2. [ons1 offs1  ons1 offs1 , ... ons1 offs1; ons2 offs2 ons2 offs2, ... ons2 offs2]
    ataques_mat = cat(1,ataques_s1,ataques_s2);  
else   % Se presentaron patologias en el sonido
    ataques_s1= [eventos(:,1) eventos(:,2)]; %columnas onset, offset s1 u otro
    ataques_s2 = [eventos(:,3) eventos(:,4)]; %columnas onset offset s2 u otro
    ataques_pat = [eventos(:,5) eventos(:,6)]; %columnas onset offset patologia u otro
    ataques_mat = cat(1,ataques_s1,ataques_s2,ataques_pat); 
end
% ==== Cargando archivo de residuales tras realizar MP========
 load('residuales_diastolic_rumble.mat');
  newdir= addpath('/usr/local/mptk/matlab/WarpTB');    % Agregando directorio warped LPC
 n =256;
 residual = residuales{2};
 p=15;
 [bloque,ultimo]=segmentar_secuencia(residual,n);
 %lambda = barkwarp(fs);
 lambda=0.065;
 [m,n]=size(bloque);
for k=1:m
    [A(k,:),e(k)] = wlpc(bloque(k,:),p,lambda);
end
Nfft=256;
[Ylog,F]=PSD(bloque(1,:),fs,Nfft);
[Hlpc,Flpc]=freqz(sqrt(e(1)),A(1,:),Nfft,'whole',fs);
% s=rng;
% res = randn(1,n);
res=trenImp(n+54,54);
res = filter(hanning(15),1,res)/sum(hanning(15));
%res=wfilter(A(1,:),1,bloque(1,:),lambda);
syn=wfilter(sqrt(e(1)),A(1,:),res,lambda);
syn = syn(55:end);

figure
f(1)=subplot(1,2,2),plot(F,Ylog),
hold on,plot(F,20.*log10(fftshift(abs(Hlpc))),'r'),grid,xlabel('Frecuencia (Hz)'),ylabel('Magnitud (dB)'),
f(2)=subplot(1,2,1),plot(bloque(1,:)), hold on, plot(syn,'r'), grid,xlabel('Tiempo (muestras)'),ylabel('Amplitud'),
suptitle('Modelado en tiempo y frecuencia de un segmento de 256 muestras residuales con orden de predicción p=15'),






