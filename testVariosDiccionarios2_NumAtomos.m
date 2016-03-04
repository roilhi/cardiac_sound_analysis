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
% Se ponen a prueba 10 diccionarios tiempo-frecuencia de varias
% caracteristicas en cuestion a la cantidad de atomos para reconstruir el
% 99% de la energia de un evento cardiaco (s1, s2 o murmullo)
% Tambien se prueba el NRMSE.
clear
close all
clc

fs = 8000;

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

group1 = [2 4:10 13:15 17 18 33];  % Signal indexes for order: s1-s2-pat

group2 = [1 3 16 19 20 23:26 28 30:32 36]; % s1-pat-s2

group3 = [11 12 29 34 35]; %pat-s1-s2

group4 = [21 22 37 38]; %pat-s1-s2

group5 = 27; % pat-s1-s2-pat


G1 = {eGeneralBase(group1).segmentos};
G2 = {eGeneralBase(group2).segmentos};
G3 = {eGeneralBase(group3).segmentos};
G4 = {eGeneralBase(group4).segmentos};
G5 = {eGeneralBase(group5).segmentos};
%groups  = {group1, group2, group3, group3, group4, group5};

% for k=1:length(groups)
%     n = length(groups{k});
%     for kk=1:n
%         ext = groups{k}(n);
%         [numIter,NRMSE] = ExtractEnergy (sig,fs,dict); 
%     end
% end




