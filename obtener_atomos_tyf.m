function [book,T, F,residual] =obtener_atomos_tyf(sig,Fs,dict,numIter)
% Función para extraer/obtener los parámetros necesarios en las gráficas
% tiempo-frecuencia de los átomos de un diccionario
% Retorna los vectores T (tiempo)  y F (frecuencia) de ubicación de los
% átomos, así como el residual de MPTK
% ----------------------------------------------------------------
% sig es la señal original
% Fs es la frecuencia de muestreo
% dict es el diccionario creado en MPTK por dictread
%numIter es el número de iteraciones o átomos deseado
%Realizando la descomposición en MPTK
relleno = zeros(1,500);
sig =[relleno'; sig; relleno';];
[book, residual , ~]  =   mpdecomp(sig, Fs, dict, numIter);

indices = book.index; %Obteniendo los índices de los átomos empleados en la descomposición (matriz)
num_bloque = indices(2,:); % Vector que indica en qué bloque se encuentran los átomos
num_atomo = indices(3,:); %Vector que indica el número de átomo del bloque 
T = indices(5,:)/Fs; %Vector que indica la posicion en el tiempo de los átomos empleados (num_muestra/Fs)
F = zeros(size(T));
for k=1:book.numAtoms
   F(k) = book.atom(1,num_bloque(k)).params.freq(num_atomo(k))*Fs; %Extrayendo la frecuencia del átomo según el bloque
   % donde se encuentre (num_bloque) y qué número de átomo sea (num_atomo)
end

end