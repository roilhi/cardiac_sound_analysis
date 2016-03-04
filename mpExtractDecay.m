function [time,decay]=mpExtractDecay(eventoCardiaco,fs,dict)
% Funcion que extrae los atomos de un evento cardiaco preservando el 1% de
% su energia. Si no se ha completado dicha operacion el algoritmo para en
% 100 atomos. El numero minimo de atomos es 10.

tic
    if length(eventoCardiaco)>1024
        disp('Error: La longitud de la senal no puede ser empleada en este diccionario')
    end   
    numIter = 10;
    
    [~, ~, decay]  =   mpdecomp(eventoCardiaco,fs, dict, numIter);
        if (decay(end)>=0.01*decay(1))
            while (decay(end)>=0.01*decay(1))
                numIter = numIter+1;
                [~, ~, decay]  =   mpdecomp(eventoCardiaco,fs, dict, numIter);
                if numIter==200  %El maximo numero de iteraciones/atomos permitido es 100
                    [~, ~, decay]  =   mpdecomp(eventoCardiaco,fs, dict, numIter);
                    break;
                end
            end
        end
        
 time = toc;     
end
