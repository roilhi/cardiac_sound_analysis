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
%Eliminando los ceros (partes donde no hubo evento s1 o s2 desde la senal
%original y asi evitar conflictos en la descomposicion MP
ataques_mat=reshape(ataques_mat(ataques_mat~=0),numel(ataques_mat(ataques_mat~=0))/2,2);
% Guardando los s1, s2 en una celda para su descomposicion 
for k=1:length(ataques_mat) 
   ataques{k}= sig(ataques_mat(k,1):ataques_mat(k,2)) ;
end
for j=1:numel(ataques)
    %Extraccion del evento
     numIter = 10; % Minimo numero de iteraciones (atomos)
    % Extrayendo el evento del arreglo en celda de ataques 
     evento = ataques{j};
 % Si el evento tiene una longitud mayor a 512 se pide un diccionario que
% tenga elementos de longitud 1024
     if (length(evento)>1024)
         dict  =  dictread('/usr/local/mptk/reference/dictionary/gabor_64_128_256_512_1024.xml');
     else
        dict  =  dictread('/usr/local/mptk/reference/dictionary/gabor_64_128_256_512.xml');
     end
     %Descomposicion MP
     [book, residual, decay]  =   mpdecomp(evento,fs, dict, numIter);
% Si aun no se ha completado que se tenga un 99% de la energia de la senial
% se continua realizando el matching pursuit
% La energia es almacenada en el vector "decay", decay(1) es la energía
% inical de la señal y decay(end) es la energía del residual actual
    if (decay(end)>=0.01*decay(1))
        while (decay(end)>=0.01*decay(1))
            numIter = numIter+1;
            [book, residual, decay]  =   mpdecomp(evento,fs, dict, numIter);
            if numIter==30 %El maximo numero de iteraciones/atomos permitido es 30
                [book, residual, decay]  =   mpdecomp(evento,fs, dict, numIter);
                break;
            end
        end
    end
    % Guardando todos los residuales en otro arreglo de celda
    residuales{j}=residual; 
    reconstruida{j} = mprecons(book,dict);
    atomos{j} = book;
end
%Reemplazando por los residuales las partes donde habia eventos
for k=1:length(ataques_mat)
    sig(ataques_mat(k,1):ataques_mat(k,2)) = residuales{k};
end
figure
plot((1:numel(sig))/fs,sig),hold on, plot((1:numel(sig))/fs,prevsig,'r-.'),grid,xlabel('Tiempo (muestras)'), ylabel('Amplitud'),title('Extracción de la señal de residual más silencios')
legend('Residual MP mas silencios','Senial original')




 