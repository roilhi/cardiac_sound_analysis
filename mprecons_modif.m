function [Yrec] = mprecons_modif(atomos,longEvento)
% Funcion que reconstruye una senial descompuesta por Matching Pursuit del
% MPTK. El parametro de entrada es un arreglo cuyos renglones son los
% siguientes parametros: 

%    Atomos = [numAtomo; Longitud; Amplitud; Frecuencia; Fase; Posicion; Chirp]
        [~,numIter] = size(atomos);
        
        Yrec = zeros(1,longEvento);
  
        pos   = atomos(6,:);
        len   = atomos(2,:);  % Longitud 
        amp   = atomos(3,:);  % Amplitud
        freq  = atomos(4,:);  % Frecuencia
        phase = atomos(5,:);  % Fase 
        chirp = atomos(7,:);  % Chirp

    for n=1:numIter   
        % ahora construye el atomo en cuestion
        t = 0:len(n)-1;
        % primero se construye la parte cosenoidal del atomo
        singleAtomo = cos(2*pi*(chirp(n)*(t.^2)/2+ freq(n)*t) + phase(n));
        
        % despues se construye la envolvente y se normaliza la energia
        t2 = t-(len(n)-1)/2; 
        sigmaG = 1/(2*0.02*(len(n)+1)*(len(n)+1));
        w_t = exp(-t2.*t2*sigmaG);
        energiaW_t = sqrt(sum(w_t.*w_t));
        w_t = w_t/energiaW_t;
    
        % finaliza la construccion del atomo
        singleAtomo       =  amp(n)*w_t.*singleAtomo;
        %singleAtomo       =  singleAtomo(:);
        Yrec(pos(n)+t+1)  = Yrec(pos(n)+t+1) + singleAtomo;
    end
        
    
end