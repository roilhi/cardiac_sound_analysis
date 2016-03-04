%=======================
%  CICESE
% En este programa se obtienen los parámetros de los átomos de la
% descomposición MP de los elementos de una señal de audio cardíaco
% Los eventos son extraidos de la señal y descompuestos por Matching
% Pursuit con atomos de Gabor con un minimo de 10 iteraciones, dicha
% cantidad se incrementa hasta retener un 99% de la energía de la señal en
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
   ataques{k}= sig(ataques_mat(k,1):ataques_mat(k,2));
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
    residuales{j}=residual;  % Guardando los residuales 
    reconstruida{j} = mprecons(book,dict); %Guardando las señales reconstruídas
    atomos{j} = book; %Guardando los átomos
end

for r=1:numel(atomos)
    [m,n]= size(atomos{r}.atom);
    BaseAtomos(r).numeroAtomos = atomos{r}.numAtoms;
    R = num2str(r);
    BaseAtomos(r).nombre = ['Evento' R];
    
    for rr=1:n
        % ################################################     
        BaseAtomos(r).grupo(rr).frecuencia = atomos{r}.atom(rr).params.freq*fs;
        BaseAtomos(r).grupo(rr).fase = atomos{r}.atom(rr).params.phase;
        BaseAtomos(r).grupo(rr).posicion = atomos{r}.atom(rr).params.pos;
        BaseAtomos(r).grupo(rr).longitud = atomos{r}.atom(rr).params.len;
        BaseAtomos(r).grupo(rr).amplitud = atomos{r}.atom(rr).params.amp;
    end
end








