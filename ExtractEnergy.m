function [numIter,NRMSE] = ExtractEnergy (sig,fs,dict) 
    if length(sig)<1024
        sig = [zeros(1024-length(sig),1); sig];
    end
numIter = 10;
         [~, residual, decay]  =   mpdecomp(sig,fs, dict, numIter);
% Test 1% energia en residual, usar despues
         if (decay(end)>=0.01*decay(1))
             if numIter >30 % Si no se alcanzan las 30 iteraciones, para avanzar rapido
                 numIter = numIter+5;
                while (decay(end)>=0.01*decay(1))
                    numIter = numIter+1;
                    [~, residual, decay]  =   mpdecomp(sig,fs, dict, numIter);
                end
             end
         end
    NRMSE = sqrt(sum((abs(sig-residual)).^2)/sum(abs(sig)).^2)*100;
         
end
