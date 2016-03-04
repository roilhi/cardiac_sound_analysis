function [book,T, F,residual] =obtener_atomos_tyf(sig,Fs,dict,numIter)
% Funci�n para extraer/obtener los par�metros necesarios en las gr�ficas
% tiempo-frecuencia de los �tomos de un diccionario
% Retorna los vectores T (tiempo)  y F (frecuencia) de ubicaci�n de los
% �tomos, as� como el residual de MPTK
% ----------------------------------------------------------------
% sig es la se�al original
% Fs es la frecuencia de muestreo
% dict es el diccionario creado en MPTK por dictread
%numIter es el n�mero de iteraciones o �tomos deseado
%Realizando la descomposici�n en MPTK
relleno = zeros(1,500);
sig =[relleno'; sig; relleno';];
[book, residual , ~]  =   mpdecomp(sig, Fs, dict, numIter);

indices = book.index; %Obteniendo los �ndices de los �tomos empleados en la descomposici�n (matriz)
num_bloque = indices(2,:); % Vector que indica en qu� bloque se encuentran los �tomos
num_atomo = indices(3,:); %Vector que indica el n�mero de �tomo del bloque 
T = indices(5,:)/Fs; %Vector que indica la posicion en el tiempo de los �tomos empleados (num_muestra/Fs)
F = zeros(size(T));
for k=1:book.numAtoms
   F(k) = book.atom(1,num_bloque(k)).params.freq(num_atomo(k))*Fs; %Extrayendo la frecuencia del �tomo seg�n el bloque
   % donde se encuentre (num_bloque) y qu� n�mero de �tomo sea (num_atomo)
end

end