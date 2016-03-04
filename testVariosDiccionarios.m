% =========================================================================
%    __   ____ _ _ __(_) ___  ___
%    \ \ / / _` | '__| |/ _ \/ __|
%     \ V / (_| | |  | | (_) \__ \
%      \_/ \__,_|_|  |_|\___/|___/
%   
%         _ _          _                        _
%      __| (_) ___ ___(_) ___  _ __   __ _ _ __(_) ___  ___
%     / _` | |/ __/ __| |/ _ \| '_ \ / _` | '__| |/ _ \/ __|
%    | (_| | | (_| (__| | (_) | | | | (_| | |  | | (_) \__ \
%     \__,_|_|\___\___|_|\___/|_| |_|\__,_|_|  |_|\___/|___/
%-------------------------------------------------------------------------
% Se ponen a prueba varios diccionarios en cuestion de su num de
% iteraciones vs SNR y vs energia decaida en el residual
%
clear
close all
clc

fs = 800;

dict{1} =   dictread('/usr/local/mptk/reference/dictionary/gabor_1block.xml');
dict{2} =   dictread('/usr/local/mptk/reference/dictionary/chirp_1block.xml');
dict{3} =   dictread('/usr/local/mptk/reference/dictionary/mdct_1block.xml');
dict{4} =   dictread('/usr/local/mptk/reference/dictionary/gabor_3block.xml');
dict{5} =   dictread('/usr/local/mptk/reference/dictionary/chirp_3block.xml');
dict{6} =   dictread('/usr/local/mptk/reference/dictionary/mdct_3block.xml');
dict{7} =   dictread('/usr/local/mptk/reference/dictionary/gabor_5block.xml');
dict{8} =   dictread('/usr/local/mptk/reference/dictionary/chirp_5block.xml');
dict{9} =   dictread('/usr/local/mptk/reference/dictionary/mdct_5block.xml');
dict{10} =   dictread('/usr/local/mptk/reference/dictionary/dic_mclt.xml');
load('eGeneralBase.mat');

L = 38;
%x = BaseResiduales.patologias(1).formaOnda;
numIter = 3000;
%book = cell(1,L);
%residual = cell(1,L);
decayM = zeros(numIter+1,L,10);
decay = zeros(numIter+1,L);
for i=1:L
    x = eGeneralBase(i).formaOnda;
    for j=1:10
        [~, ~, decay(:,j)]  =   mpdecomp(x,fs, dict{j}, numIter);
    end
    decayM(:,:,i) = decay;
end
decayT = mean(decayM,3);
normX = sum(x.^2);

plot(1:3001,10*log10(decayT/decayT(1,1)))
legend('Gabor 1', 'Gabor Chirp 1','MDCT 1','Gabor 3',...
    'Gabor Chirp 3','MDCT 3','Gabor 5', 'Gabor Chirp 5','MDCT 5','MCLT'),grid



% Test 1% energia en residual, usar despues
%         if (decay(end)>=0.01*decay(1))
%             while (decay(end)>=0.01*decay(1))
%                 numIter = numIter+1;
%                 [book, residual, decay]  =   mpdecomp(eventoCardiaco,fs, dict, numIter);
%             end
%         end

