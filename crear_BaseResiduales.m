% ======================================
%                   CICESE
%   Programa de prueba para la tesis de maestria 
%   Creacion de una estructura que contiene las ondas temporales 
%   de residual mas silencios y sus espectros correspondientes
% ======================================

clear 
close all
clc
% Entradas
fs = 8000; %frecuencia de muestreo

 %dict1 = dictread('/usr/local/mptk/reference/dictionary/gabor_64_128_256_512.xml'); %diccionario empleado en la descomposicion
 %dict2 = dictread('/usr/local/mptk/reference/dictionary/gabor_64_128_256_512_1024.xml'); %diccionario empleado en la descomposicion
 
% Asignando los nombres de las senales como primer atributo  
BaseResiduales.patologias(1).nombre = 'Soplo_Diastolico';
BaseResiduales.patologias(2).nombre = 'Click_Eyeccion';
BaseResiduales.patologias(3).nombre = 'Murmullo_Sistolico_Temprano';
BaseResiduales.patologias(4).nombre = 'Murmullo_Sistolico_Tardio';
BaseResiduales.patologias(5).nombre = 'Chasquido_Apertura';
BaseResiduales.patologias(6).nombre = 'S3';
BaseResiduales.patologias(7).nombre = 'S4';
BaseResiduales.patologias(8).nombre = 'Murmullo_Pansistolico';
BaseResiduales.patologias(9).nombre = 'Apertura_Normal_S1';
BaseResiduales.patologias(10).nombre = 'Apertura_Normal_S2';



BaseResiduales.normales(1).nombre = 'P22L';
BaseResiduales.normales(2).nombre = 'P22R';
BaseResiduales.normales(3).nombre = 'P54L';
BaseResiduales.normales(4).nombre = 'P82L';
BaseResiduales.normales(5).nombre = 'P84L';
BaseResiduales.normales(6).nombre = 'P92L';
BaseResiduales.normales(7).nombre = 'P94L';

% Formas de onda temporales de la base de datos
BaseResiduales.patologias(1).formaOnda = audioread('Diastolic_Rumble_resampled.wav');
BaseResiduales.patologias(2).formaOnda = audioread('Ejection_Click_resampled.wav');
BaseResiduales.patologias(3).formaOnda = audioread('Early_Systolic_Murmur_resampled.wav');
BaseResiduales.patologias(4).formaOnda = audioread('Late_Systolic_Murmur_resampled.wav');
BaseResiduales.patologias(5).formaOnda = audioread('Opening_Snap_resampled.wav');
BaseResiduales.patologias(6).formaOnda = audioread('S3_resampled.wav');
BaseResiduales.patologias(7).formaOnda = audioread('S4_resampled.wav');
BaseResiduales.patologias(8).formaOnda = audioread('Pansistolic_Murmur_resampled.wav');
BaseResiduales.patologias(9).formaOnda = audioread('Normal_Split_S1_resampled.wav');
BaseResiduales.patologias(10).formaOnda = audioread('Normal_Split_S2_resampled.wav');

BaseResiduales.normales(1).formaOnda = audioread('P22L_resampled.wav');
BaseResiduales.normales(2).formaOnda = audioread('P22R_resampled.wav');
BaseResiduales.normales(3).formaOnda = audioread('P54L_resampled.wav');
BaseResiduales.normales(4).formaOnda = audioread('P82L_resampled.wav');
BaseResiduales.normales(5).formaOnda = audioread('P84L_resampled.wav');
BaseResiduales.normales(6).formaOnda = audioread('P92L_resampled.wav');
BaseResiduales.normales(7).formaOnda = audioread('P94L_resampled.wav');


% Cargando los onset y offset de las senales (S1 y S2)
%patologias
load('onset_offset_Diastolic_Rumble.mat');
load('onset_offset_Ejection_Click.mat');
load('onset_offset_Early_Systolic_Murmur.mat');
load('onset_offset_Late_Systolic_Murmur.mat');
load('onset_offset_Opening_Snap.mat');
load('onset_offset_s3.mat');
load('onset_offset_s4.mat');
load('onset_offset_Pansistolic_Murmur.mat');
load('onset_offset_Normal_Split_S1');
load('onset_offset_Normal_Split_S2');

% Cargando los onset y offset a la base 
BaseResiduales.patologias(1).onset_offset =  (onset_offset_Diastolic_Rumble).*fs;
BaseResiduales.patologias(2).onset_offset =  (onset_offset_Ejection_Click).*fs;
BaseResiduales.patologias(3).onset_offset =  (onset_offset_Early_Systolic_Murmur).*fs;
BaseResiduales.patologias(4).onset_offset =  (onset_offset_Late_Systolic_Murmur).*fs;
BaseResiduales.patologias(5).onset_offset =  (onset_offset_Opening_Snap).*fs;
BaseResiduales.patologias(6).onset_offset =  (onset_offset_s3).*fs;
BaseResiduales.patologias(7).onset_offset =  (onset_offset_s4).*fs;
BaseResiduales.patologias(8).onset_offset =  (onset_offset_Pansistolic_Murmur).*fs;
BaseResiduales.patologias(9).onset_offset =  (onset_offset_Normal_Split_S1).*fs;
BaseResiduales.patologias(10).onset_offset=  (onset_offset_Normal_Split_S2).*fs;

% Cargando las ondas temporales residual mas silencios 
   for k=1:10
       BaseResiduales.patologias(k).formaOndaResidual = obtener_residual_silencios(BaseResiduales.patologias(k).formaOnda,fs, ...
           BaseResiduales.patologias(k).onset_offset);
   end
%================================================================================
   % Parametros para calcular los periodogramas de las seniales residual
   % mas silencios
                ventana= hamming(256);
                Nfft = 4096;
                Noverlap = 128;
% ================================================================================
% Calculando y cargando los periodogramas
 MPtemporal_patologias = cell(1,10);
% Periodograma de la senial normal y del MP
for k=1:10
    MPtemporal_patologias{k}=BaseResiduales.patologias(k).formaOnda-BaseResiduales.patologias(k).formaOndaResidual;
        BaseResiduales.patologias(k).periodograma=pwelch(BaseResiduales.patologias(k).formaOnda,ventana,Noverlap, ...
        Nfft,fs);
    BaseResiduales.patologias(k).periodogramaMP=pwelch( MPtemporal_patologias{k},ventana,Noverlap, ...
        Nfft,fs);   
end

% Periodograma de la onda residual
for k=1:10
    BaseResiduales.patologias(k).periodogramaResidual=pwelch(BaseResiduales.patologias(k).formaOndaResidual,ventana,Noverlap, ...
        Nfft,fs);
end

%sonidos normales 
load('onset_offset_P22L.mat');
load('onset_offset_P22R.mat');
load('onset_offset_P54L.mat');
load('onset_offset_P82L.mat');
load('onset_offset_P84L.mat');
load('onset_offset_P92L.mat');
load('onset_offset_P94L.mat');

BaseResiduales.normales(1).onset_offset=  (onset_offset_P22L).*fs;
BaseResiduales.normales(2).onset_offset=  (onset_offset_P22R).*fs;
BaseResiduales.normales(3).onset_offset=  (onset_offset_P54L).*fs;
BaseResiduales.normales(4).onset_offset=  (onset_offset_P82L).*fs;
BaseResiduales.normales(5).onset_offset=  (onset_offset_P84L).*fs;
BaseResiduales.normales(6).onset_offset=  (onset_offset_P92L).*fs;
BaseResiduales.normales(7).onset_offset=  (onset_offset_P94L).*fs;

% Cargando las ondas temporales residual mas silencios 
   for k=1:7
       BaseResiduales.normales(k).formaOndaResidual = obtener_residual_silencios(BaseResiduales.normales(k).formaOnda,fs, ...
           BaseResiduales.normales(k).onset_offset);
   end
   
% Calculando y cargando los periodogramas
% Periodograma de la senial normal y del MP
 MPtemporal_normales = cell(1,7);
for k=1:7
    MPtemporal_normales{k}=BaseResiduales.normales(k).formaOnda-BaseResiduales.normales(k).formaOndaResidual;
        BaseResiduales.normales(k).periodograma=pwelch(BaseResiduales.normales(k).formaOnda,ventana,Noverlap, ...
        Nfft,fs);
    BaseResiduales.normales(k).periodogramaMP=pwelch(MPtemporal_normales{k},ventana,Noverlap, ...
        Nfft,fs);   
end
%Periodograma del residual
 for k=1:7
    BaseResiduales.normales(k).periodogramaResidual=pwelch(BaseResiduales.normales(k).formaOndaResidual,ventana,Noverlap, ...
       Nfft,fs);
end
   


