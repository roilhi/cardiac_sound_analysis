function [Yrec] = sintetiza_residual_lpc(sig,onset_offset,wlen,overlap,p1,p2)
%   =========================================
%      _       _            _                     _     _             _
%  ___/_/_ __ | |_ ___  ___(_)___   _ __ ___  ___(_) __| |_   _  __ _| |
% / __| | '_ \| __/ _ \/ __| / __| | '__/ _ \/ __| |/ _` | | | |/ _` | |
% \__ \ | | | | ||  __/\__ \ \__ \ | | |  __/\__ \ | (_| | |_| | (_| | |
% |___/_|_| |_|\__\___||___/_|___/ |_|  \___||___/_|\__,_|\__,_|\__,_|_|
%=========================================================================
%   Función que realiza la síntesis de un residual más silencios de audio
%   cardiaco.  Se agrega una etapa de pre-énfasis
%   Es el método tradicional donde se detecta "pitch" por medio de la
%   función de autocorrelación. 
%   
%   @@@@@@@@@@@@@@@@@@@@ Entradas: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%   sig ---->    Residual más silencios
%   wlen --->    Tamaño de la ventana de análisis
%   overlap ---> Traslape entre ventanas
%   p1 ----->     Orden del filtro predictor cuando hay evento cardiaco (se recomienda 20)
%   p2 ------->   Orden del filtro predictor cuando no hay evento cardiaco (se recomienda 15)

%   ##################  Salidas ##################################
%   Yrec -----> Señal reconstruida

    Y = buffer(sig,wlen,overlap); % Matriz de bloques de 256 con overlap
    [~,n]=size(Y);
    %preemp = 0.93738; % Parámetro del filtro de pre-énfasis
    preemp = 0.901;

    w = window(@gausswin,wlen);
    %w=hamming(wlen,'periodic'); %Ventana deslizante
    
    Y_m =zeros(size(Y));
% ---------------Multiplicando por la ventana los elementos columna (segmentos con overlap)
    for k=1:n
        Y_m(:,k) = w.*Y(:,k);
    % ====== Filtro de pre-enfasis -----------------------
        Y_m(:,k) = w.*filter(1,[1 -preemp],Y(:,k));    
    end

% ----------------- Realizando LPC ---------------------------
        [hay_evento]=definir_trama(onset_offset,overlap,n);
        e = zeros(1,n);
        A = cell(1,n);
        To = zeros(1,n);

    for k=1:n      
            if hay_evento(k)==1
                [A{k},e(k)]=lpc(Y_m(:,k),p1);
            else
                [A{k},e(k)]=lpc(Y_m(:,k),p2);
            end
        [To(k)]= estimar_periodo_pitch(Y_m(:,k),0.09);
    end

% ========= Etapa de sintesis LPC ==================
       sigRec = zeros(size(Y));
    for k=1:n
        if (To(k)~=0)
            syn=trenImp(wlen+To(k),To(k));
            syn = sqrt(e(k)).*filter(hanning(floor(To(k)/4)),1,syn)/sum(hanning(floor(To(k)/4)));
            sigRecVec=filter(1,A{k},syn);
            sigRec(:,k)= sigRecVec(To(k)+1:end);
         % ====== Filtro de pre-enfasis inverso -----------------------
            sigRec(:,k) = w.*filter([1 preemp],1,sigRec(:,k)); 
            
        else
            s=rng;
            nsyn = sqrt(e(k)).*randn(1,wlen);
            %sigRec(:,k)=w'.*wfilter(sqrt(e(k)),A(:,k),nsyn,lambda);
            sigRec(:,k)=filter(1,A{:,k},nsyn);
            % ====== Filtro de pre-enfasis inverso -----------------------
            sigRec(:,k) = w.*filter(1,[1 preemp],sigRec(:,k)); 
        end
    end

    % ========= Realizando la reconstruccion OLA ==========

    % ============ Etapa de overlap-add. ========================

        Yrec = OLA(sigRec,overlap,wlen,numel(sig));   
end