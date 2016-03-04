function [Sxx,F] = corrSpectrum(x,fs,numIter)
   
   N = length(x);
  
   X = buffer(x,round(N/numIter));
  [M,NN] = size(X);
  
  Sxx = zeros(2*M-1,NN);
  for k = 1:numIter
    Sxcorr = xcorr(X(:,k),'biased');
    Sxx   (:,k) = fft(Sxcorr);
  end
  
  Sxx = mean(Sxx,2);
  Sxx = Sxx(1:M);
  F = 0:fs/(2*M-1):fs/2;

end