%=======================
%       CICESE
%     Programa para tratar de reconstruir (sintetizar) el residual mas silencios
%     de la senial de audio cardiaco "soplo diastolico". 
%     La sintesis se realiza mediante WLPC por medio de un tren de pulsos
%     (ventanas Hanning periodicas)
%     el periodo de "pitch" se estima con una funcion externa
%     EN ESTE PROGRAMA NO SE USA FILTRO DE PRE-ENFASIS
%   =========================================
clear all
close all
clc

fs = 8000; % Frecuencia de muestreo
load('BaseResiduales.mat') % Cargando base de residuales
x_n =BaseResiduales.patologias(1).formaOndaResidual; % Residual a reconstruir
%load('res_silencios_normal_uwash.mat');
%x_n= res_silencios_normal_uwash;
%x_n=x_n/max(x_n);
Y = buffer(x_n,256,128); % Matriz de bloques de 256 con overlap
[~,n]=size(Y);
w=hamming(256,'periodic'); %Ventana deslizante
% ---------------Multiplicando por la ventana los elementos columna (segmentos con overlap)
for k=1:n
    Y_m(:,k) = w.*Y(:,k);
end

% ----------------- Realizando WLPC ---------------------------
newdir= addpath('/usr/local/mptk/matlab/WarpTB');    % Agregando directorio warped LPC
%newdir= addpath('/usr/local/mptk/matlab/voicebox');    % Agregando directorio LPC
lambda = 0.065;
p=25;
for k=1:n
    [A(:,k),e(k)]=wlpc(Y_m(:,k),p,lambda);
    %[A(:,k),e(k),~]=lpcauto(Y_m(:,k),p);
    [To(k)]= estimar_periodo_pitch(Y_m(:,k),0.1);
end

% ========= Etapa de sintesis WLPC ==================
for k=1:n
    if (To(k)~=0)
        syn=trenImp(256+To(k),To(k));
        syn = filter(hanning(floor(To(k)/4)),1,syn)/sum(hanning(floor(To(k)/4)));
         sigRecVec=wfilter(1,A(:,k),syn,lambda);
         sigRec(:,k)= sigRecVec(To(k)+1:end);
    else
            s=rng;
            nsyn = randn(1,256);
            sigRec(:,k)=w'.*wfilter(1,A(:,k),nsyn,lambda);
            %sigRec(:,k)=w'.*filter(1,A(:,k),nsyn);
    end
end

% ========= Realizando la reconstruccion OLA ==========

% ============ Etapa de overlap-add. ========================

m1 = [sigRec(1:128,1:n) zeros(128,1)]; 
m2 = [zeros(128,1) sigRec(129:256,1:n)];
% Las columnas se suman elemento a elemento:
% k va desde n+1 debido a la columna de ceros que se ha agregado
for k=1:n+1
    vec1= m1(:,k); vec2 = m2(:,k);
    RecSig(:,k) = vec1 +vec2;
end
    RecSigg = RecSig(:);
    final = numel(RecSigg)-numel(x_n)-128;
    RecSigg = RecSigg(128:end-final-1);
    
    %plot(x_n./max(x_n)), hold on, plot(RecSigg./max(RecSigg),'r'), grid on
    plot(x_n), hold on, plot(RecSigg,'r'), grid on
    
   % wavwrite(RecSigg./(1.05*max(RecSigg)),fs,'residual_soploDiastolico_reconstruido_noPreenfasis.wav');