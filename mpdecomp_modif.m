function [atomos,residual]=mpdecomp_modif(eventoCardiaco,fs)
% Funcion que extrae los atomos de un evento cardiaco preservando el 1% de
% su energia. Si no se ha completado dicha operacion el algoritmo para en
% 30 atomos. El numero minimo de atomos es 10.
% Salida residual =====> Residual de la descomposicion
%        atomos   =====> Matriz con los parametros atomicos necesarios para la
%        reconstruccion.
%    Atomos = [numAtomo; Longitud; Amplitud; Frecuencia; Fase; Posicion; Chirp]
    if length(eventoCardiaco)>1024
        dict=dictread('/usr/local/mptk/reference/dictionary/gabor_64_128_256_512_1024.xml');
    else
        dict=dictread('/usr/local/mptk/reference/dictionary/gabor_64_128_256_512.xml');
    end
    
    numIter = 10;
    
    [book, residual, decay]  =   mpdecomp(eventoCardiaco,fs, dict, numIter);
        if (decay(end)>=0.01*decay(1))
            while (decay(end)>=0.01*decay(1))
                numIter = numIter+1;
                [book, residual, decay]  =   mpdecomp(eventoCardiaco,fs, dict, numIter);
                if numIter==30  %El maximo numero de iteraciones/atomos permitido es 30
                    [book, residual, ~]  =   mpdecomp(eventoCardiaco,fs, dict, numIter);
                    break;
                end
            end
        end
        
        % Creando una matriz con todos los parametros necesarios de la
        % descomposicion.
       
        atomos = zeros(7,numIter);
        
        amp   = zeros(1,numIter);
        freq  = zeros(1,numIter);
        len   = zeros(1,numIter);
        phase = zeros(1,numIter);
        chirp = zeros(1,numIter);
 % =================================================================================================
        for g=1:numIter     
                atomoType = book.index(2,g); % extrae informacion sobre el tipo de atomo
                atomosParIndex = book.index(3,g); % extrae el indice donde estan los parametros
                
                amp(g)         = book.atom(atomoType).params.amp(atomosParIndex);
                chirp(g)       = book.atom(atomoType).params.chirp(atomosParIndex);    
                freq(g)        = book.atom(atomoType).params.freq(atomosParIndex);
                len(g)         = book.atom(atomoType).params.len(atomosParIndex);
                phase(g)       = book.atom(atomoType).params.phase(atomosParIndex);
        end
        
  %    Atomos = [numAtomo; Longitud; Amplitud; Frecuencia; Fase; Posicion; Chirp]  
        atomos(1,:) = 1:numIter; % Numero de atomo
        atomos(6,:) = book.index(5,:); % Posicion
        atomos(2,:) = len;   % Longitud
        atomos(3,:) = amp;   % Amplitud
        atomos(4,:) = freq;  % Frecuencia
        atomos(5,:) = phase; % Fase 
        atomos(7,:) = chirp; % Chirp
     
end
