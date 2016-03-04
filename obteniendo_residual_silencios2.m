%=======================
%  CICESE
% Programa donde se obtiene la senial de residual y silencios del audio cardiaco
% Los eventos son extraidos de la senal y descompuestos por Matching
% Pursuit con atomos de Gabor con un minimo de 10 iteraciones, dicha
% cantidad se incrementa hasta retener un 99% de la energia de la senal en
% la reconstruccion
%   ==================

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%  Diferencias ----> La matriz de la segmentacion se ordena en un solo
%  vector de indices donde se presentan los eventos, es decir, una
%  concatenacion de sus renglones

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
    hay_pat = 0;
else   % Se presentaron patologias en el sonido (hay mas de 4 columnas)
    hay_pat = 1;
end

eventos_vec = [];
for h=1:m
    eventos_reng = eventos(h,:);
    eventos_vec = cat(2,eventos_vec,eventos_reng);    
end

%Eliminando los ceros (partes donde no hubo evento s1 o s2 desde la senal
%original y asi evitar conflictos en el indizado (no existen indices cero)
eventos_vecZ = eventos_vec(eventos_vec~=0);

% Guardando los eventos en una celda para su descomposicion 

k = 1;
x1 = 1;
x2 = 2;
while k<=length(eventos_vecZ)/2
    ataques{k}= sig(eventos_vecZ(x1):eventos_vecZ(x2));
    x1 = x1+2;
    x2 = x2+2;
    k = k+1;
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
    reconstruida{j} = mprecons(book);
    atomos{j} = book;
    numIters(j) = numIter;
end
%Reemplazando por los residuales las partes donde habia eventos
k = 1;
x1 = 1;
x2 = 2;
while k<=length(eventos_vecZ)/2
    sig(eventos_vecZ(x1):eventos_vecZ(x2))=residuales{k};
    x1 = x1+2;
    x2 = x2+2;
    k = k+1;
end

figure
plot((1:numel(sig))/fs,sig),hold on, plot((1:numel(sig))/fs,prevsig,'r-.'),grid,xlabel('Tiempo (muestras)'), ylabel('Amplitud'),title('Extracción de la señal de residual más silencios')
legend('Residual MP mas silencios','Senial original')