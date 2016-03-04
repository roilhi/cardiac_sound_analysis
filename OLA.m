function RecSig = OLA(sig_block,overlap,wlen,NewLength)
%-------------------------------------------------------
% Funcion que realiza el overlapp and add a una senal recostruyendola desde
% sus bloques o tramos
% sigblock contiene la senal ventaneada
% overlap es el traslape entre ventanas
% wlen tamano de la ventana
% NewLength es la nueva longitud de senal tras el overlap
    [~,n] = size(sig_block);
    m1 = [sig_block(1:overlap,1:n) zeros(overlap,1)];
    m2 = [zeros(overlap,1) sig_block(overlap+1:wlen,1:n)];
% Las columnas se suman elemento a elemento:
% k va desde n+1 debido a la columna de ceros que se ha agregado
    Recons = zeros(overlap,wlen+1);
%--------------------------------------------------------------
    for k=1:n+1
        vec1 = m1(:,k); vec2 = m2(:,k);
        Recons(:,k) = vec1 + vec2 ; 
    end
        RecSig = Recons(:);
        final = numel(RecSig) - NewLength - overlap;
        RecSig = RecSig(overlap:end-final-1);
end
    
    