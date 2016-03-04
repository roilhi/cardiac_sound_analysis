function ret=trenImp(len,pos)
% Funcion que crea un tren de impulsos periodico de longitud "len" 
% teniendo que "pos" es el periodo del impulso

    %Obteniendo los ceros que iran al final del tren de impulsos
    % Ejemplo 
    %     0     0     1     0     0     1     0     0     1     0     0     1     0     0
    %  Hay dos ceros despues del ultimo impulso
    zfin= mod(len,pos);
    %  Se obtiene la posicion del ultimo pulso, sabiendo cuantos ceros hay al
    %  final
    posUltimo = len-zfin;
    % Sabiendo la posicion del ultimo pulso se obtiene el numero de pulso (primero, segundo, tercero, ...)
    numUltimo = posUltimo/pos;
    % Se obtienen ahora los indices de los impulsos por multiplicidad
    indicesImpulsos = pos.*[1:numUltimo];
    % Se agregan como unos a la senial final
    ret = zeros(1,len);
    ret(indicesImpulsos)=1;
end
