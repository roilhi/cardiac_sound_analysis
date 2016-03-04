function [Yrec] = sintetizar_residual_velpc(sig,wlen,overlap,p,n_dct)

%=======================
%       CICESE
%     Función para tratar de reconstruir (sintetizar) el residual mas silencios
%     de la senial de audio cardiaco "soplo diastolico". 
%     La sintesis se realiza mediante WLPC por medio de un tren de pulsos
%     (ventanas Hanning periodicas)
%     Se toma la senial de error a la salida del filtro predictor, se
%     calculan y envian "n_dct" coeficientes de la DCT para sintetizar el
%     filtro en el receptor
%   =========================================

    Y = buffer(sig,wlen,overlap); % Matriz de bloques de 256 con overlap
    [~,n]=size(Y);

    preemp = 0.93738; % Parámetro del filtro de pre-énfasis

    w=hamming(wlen,'periodic'); %Ventana deslizante
% ---------------Multiplicando por la ventana los elementos columna (segmentos con overlap)
    for k=1:n
        Y_m(:,k) = w.*Y(:,k);
        % ====== Filtro de pre-enfasis -----------------------
        Y_m(:,k) = w.*filter(1,[1 -preemp],Y_m(:,k));  
    end

    % ----------------- Realizando VELPC --------------------------
    for k=1:n
            [A(:,k),e(k)]=lpc(Y_m(:,k),p);    
            %e_n(:,k)= wfilter(A(:,k),1,Y_m(:,k),lambda); % Calculo de la senial de error (residual del residual)
            e_n(:,k)= filter(A(:,k),1,Y_m(:,k)); % Calculo de la senial de error (residual del residual)
            syn(:,k)= dct(e_n(:,k)); 
    end


    %Numero de coeficientes de la DCT a enviar
    syn = syn(1:n_dct,:,:);

    % % ========= Etapa de sintesis WLPC ==================
    for k=1:n
        sigRec(:,k)=sqrt(e(k)).*filter(1,A(:,k),idct([syn(:,k)' zeros(1,wlen-n_dct)]));
        % ====== Filtro de pre-enfasis inverso -----------------------
        sigRec(:,k) = w.*filter(1,[1 preemp],sigRec(:,k));
    end

    % ========= Realizando la reconstruccion OLA ==========

    %============ Etapa de overlap-add. ========================
        m1 = [sigRec(1:overlap,1:n) zeros(overlap,1)]; 
        m2 = [zeros(overlap,1) sigRec(overlap+1:wlen,1:n)];
    % Las columnas se suman elemento a elemento:
    % k va desde n+1 debido a la columna de ceros que se ha agregado
    for k=1:n+1
        vec1= m1(:,k); vec2 = m2(:,k);
        RecSig(:,k) = vec1 +vec2;
    end
        RecSigg = RecSig(:);
        final = numel(RecSigg)-numel(sig)-overlap;
        Yrec = RecSigg(overlap:end-final-1);       
   
end
   
   