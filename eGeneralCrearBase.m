% =========================================================================
%                   CICESE
%    ____                         ____                           _
%   | __ )  __ _ ___  ___    ___ / ___| ___ _ __   ___ _ __ __ _| |
%   |  _ \ / _` / __|/ _ \  / _ \ |  _ / _ \ '_ \ / _ \ '__/ _` | |
%   | |_) | (_| \__ \  __/ |  __/ |_| |  __/ | | |  __/ | | (_| | |
%   |____/ \__,_|___/\___|  \___|\____|\___|_| |_|\___|_|  \__,_|_|
%
%   Se seleccionaron 30 audios de la base eGeneral medical (disponible en linea)
%   para generar una base de pruebas posteriores. Se incluye la senial
%   completa en forma de onda y por eventos, ademas de su segmentacion
% =========================================================================
clear 
close all
clc
% Entradas
% Cargando directorio audios eGeneral
newDir = addpath('/Users/roilhi/Dropbox/eGeneralMedical');
% Cargando base sonidos Litmann
load('BaseResiduales.mat')

% Asignando los nombres de las senales como primer atributo  
eGeneralBase(1).nombres = 'DiastolicAtrialSeptalDefect';
eGeneralBase(2).nombres = 'DiastolicAorticRegurgitation';
eGeneralBase(3).nombres = 'AorticStenosis2';
eGeneralBase(4).nombres = 'DiastolicAtrialGallop';
eGeneralBase(5).nombres = 'DiastolicFixedS2Split';
eGeneralBase(6).nombres = 'DiastolicFixedS2Split2';
eGeneralBase(7).nombres = 'DiastolicMitralStenosis';
eGeneralBase(8).nombres = 'DiastolicPhysiologicS2Split';
eGeneralBase(9).nombres = 'DiastolicPhysiologicS2Split2';
eGeneralBase(10).nombres = 'DiastolicS3Gallop';
eGeneralBase(11).nombres = 'DiastolicS4Gallop';
eGeneralBase(12).nombres = 'DiastolicSummationGallop';
eGeneralBase(13).nombres = 'DiastolicSummationGallop2';
eGeneralBase(14).nombres = 'DiastolicVentricularGallopS3';
eGeneralBase(15).nombres = 'DiastolicWideS2Split';
eGeneralBase(16).nombres = 'EarlyAorticStenosis';
eGeneralBase(17).nombres = 'EjectionMurmur';
eGeneralBase(18).nombres = 'EjectionMurmur2';
eGeneralBase(19).nombres = 'LateSystolicAorticStenosis';
eGeneralBase(20).nombres = 'MildAorticStenosis';
eGeneralBase(21).nombres = 'NormalHeartSound';
eGeneralBase(22).nombres = 'PericardialFrictionRub2';
eGeneralBase(23).nombres = 'SystolicAorticStenosis3';
eGeneralBase(24).nombres = 'SystolicMitralProlapse';
eGeneralBase(25).nombres = 'SystolicMitralProlapse3';
eGeneralBase(26).nombres = 'SystolicMitralRegurgitation';
eGeneralBase(27).nombres = 'SystolicPulmonaryStenosis2';
eGeneralBase(28).nombres = 'SystolicSplitS1_3';
eGeneralBase(29).nombres = BaseResiduales.patologias(1).nombre;
eGeneralBase(30).nombres = BaseResiduales.patologias(2).nombre;
eGeneralBase(31).nombres = BaseResiduales.patologias(3).nombre;
eGeneralBase(32).nombres = BaseResiduales.patologias(4).nombre;
eGeneralBase(33).nombres = BaseResiduales.patologias(5).nombre;
eGeneralBase(34).nombres = BaseResiduales.patologias(6).nombre;
eGeneralBase(35).nombres = BaseResiduales.patologias(7).nombre;
eGeneralBase(36).nombres = BaseResiduales.patologias(8).nombre;
eGeneralBase(37).nombres = BaseResiduales.patologias(9).nombre;
eGeneralBase(38).nombres = BaseResiduales.patologias(10).nombre;
%--------------------------------------------------------------------------
% Formas de onda temporales de la base de datos
eGeneralBase(1).formaOnda = audioread('DiastolicAtrialSeptalDefect.wav');
eGeneralBase(2).formaOnda = audioread('DiastolicAorticRegurgitation.wav');
eGeneralBase(3).formaOnda = audioread('AorticStenosis2.wav');
eGeneralBase(4).formaOnda = audioread('DiastolicAtrialGallop.wav');
eGeneralBase(5).formaOnda = audioread('DiastolicFixedS2Split.wav');
eGeneralBase(6).formaOnda = audioread('DiastolicFixedS2Split2.wav');
eGeneralBase(7).formaOnda = audioread('DiastolicMitralStenosis.wav');
eGeneralBase(8).formaOnda = audioread('DiastolicPhysiologicS2Split.wav');
eGeneralBase(9).formaOnda = audioread('DiastolicPhysiologicS2Split2.wav');
eGeneralBase(10).formaOnda = audioread('DiastolicS3Gallop.wav');
eGeneralBase(11).formaOnda = audioread('DiastolicS4Gallop.wav');
eGeneralBase(12).formaOnda = audioread('DiastolicSummationGallop.wav');
eGeneralBase(13).formaOnda = audioread('DiastolicSummationGallop2.wav');
eGeneralBase(14).formaOnda = audioread('DiastolicVentricularGallopS3.wav');
eGeneralBase(15).formaOnda = audioread('DiastolicWideS2Split.wav');
eGeneralBase(16).formaOnda = audioread('EarlyAorticStenosis.wav');
eGeneralBase(17).formaOnda = audioread('EjectionMurmur.wav');
eGeneralBase(18).formaOnda = audioread('EjectionMurmur2.wav');
eGeneralBase(19).formaOnda = audioread('LateSystolicAorticStenosis.wav');
eGeneralBase(20).formaOnda = audioread('MildAorticStenosis.wav');
eGeneralBase(21).formaOnda = audioread('NormalHeartSound.wav');
eGeneralBase(22).formaOnda = audioread('PericardialFrictionRub2.wav');
eGeneralBase(23).formaOnda = audioread('SystolicAorticStenosis3.wav');
eGeneralBase(24).formaOnda = audioread('SystolicMitralProlapse.wav');
eGeneralBase(25).formaOnda = audioread('SystolicMitralProlapse3.wav');
eGeneralBase(26).formaOnda = audioread('SystolicMitralRegurgitation.wav');
eGeneralBase(27).formaOnda = audioread('SystolicPulmonaryStenosis2.wav');
eGeneralBase(28).formaOnda = audioread('SystolicSplitS1_3.wav');
eGeneralBase(29).formaOnda = BaseResiduales.patologias(1).formaOnda;
eGeneralBase(30).formaOnda = BaseResiduales.patologias(2).formaOnda;
eGeneralBase(31).formaOnda = BaseResiduales.patologias(3).formaOnda;
eGeneralBase(32).formaOnda = BaseResiduales.patologias(4).formaOnda;
eGeneralBase(33).formaOnda = BaseResiduales.patologias(5).formaOnda;
eGeneralBase(34).formaOnda = BaseResiduales.patologias(6).formaOnda;
eGeneralBase(35).formaOnda = BaseResiduales.patologias(7).formaOnda;
eGeneralBase(36).formaOnda = BaseResiduales.patologias(8).formaOnda;
eGeneralBase(37).formaOnda = BaseResiduales.patologias(9).formaOnda;
eGeneralBase(38).formaOnda = BaseResiduales.patologias(10).formaOnda;
%--------------------------------------------------------------------------
% Matrices de onsets y offsets producto de la segmentacion
load('OnOff_DiastolicAtrialSeptalDefect');
load('OnOff_DiastolicAorticRegurgitation');
load('OnOff_AorticStenosis2');
load('OnOff_DiastolicAtrialGallop');
load('OnOff_DiastolicFixedS2Split');
load('OnOff_DiastolicFixedS2Split2');
load('OnOff_DiastolicMitralStenosis');
load('OnOff_DiastolicPhysiologicS2Split');
load('OnOff_DiastolicPhysiologicS2Split2');
load('OnOff_DiastolicS3Gallop');
load('OnOff_DiastolicS4Gallop');
load('OnOff_DiastolicSummationGallop');
load('OnOff_DiastolicSummationGallop2');
load('OnOff_DiastolicVentricularGallopS3');
load('OnOff_DiastolicWideS2Split');
load('OnOff_EarlyAorticStenosis');
load('OnOff_EjectionMurmur');
load('OnOff_EjectionMurmur2');
load('OnOff_LateSystolicAorticStenosis');
load('OnOff_MildAorticStenosis');
load('OnOff_NormalHeartSound');
load('OnOff_PericardialFrictionRub2');
load('OnOff_SystolicAorticStenosis3');
load('OnOff_SystolicMitralProlapse');
load('OnOff_SystolicMitralProlapse3');
load('OnOff_SystolicMitralRegurgitation');
load('OnOff_SystolicPulmonaryStenosis2');
load('OnOff_SystolicSplitS1_3');


eGeneralBase(1).OnsetOffset = OnOff_DiastolicAtrialSeptalDefect;
eGeneralBase(2).OnsetOffset = OnOff_DiastolicAorticRegurgitation;
eGeneralBase(3).OnsetOffset = OnOff_AorticStenosis2;
eGeneralBase(4).OnsetOffset = OnOff_DiastolicAtrialGallop;
eGeneralBase(5).OnsetOffset = OnOff_DiastolicFixedS2Split;
eGeneralBase(6).OnsetOffset = OnOff_DiastolicFixedS2Split2;
eGeneralBase(7).OnsetOffset = OnOff_DiastolicMitralStenosis;
eGeneralBase(8).OnsetOffset = OnOff_DiastolicPhysiologicS2Split;
eGeneralBase(9).OnsetOffset = OnOff_DiastolicPhysiologicS2Split2;
eGeneralBase(10).OnsetOffset = OnOff_DiastolicS3Gallop;
eGeneralBase(11).OnsetOffset = OnOff_DiastolicS4Gallop;
eGeneralBase(12).OnsetOffset = OnOff_DiastolicSummationGallop;
eGeneralBase(13).OnsetOffset = OnOff_DiastolicSummationGallop2;
eGeneralBase(14).OnsetOffset = OnOff_DiastolicVentricularGallopS3;
eGeneralBase(15).OnsetOffset = OnOff_DiastolicWideS2Split;
eGeneralBase(16).OnsetOffset = OnOff_EarlyAorticStenosis;
eGeneralBase(17).OnsetOffset = OnOff_EjectionMurmur;
eGeneralBase(18).OnsetOffset = OnOff_EjectionMurmur2;
eGeneralBase(19).OnsetOffset = OnOff_LateSystolicAorticStenosis;
eGeneralBase(20).OnsetOffset = OnOff_MildAorticStenosis;
eGeneralBase(21).OnsetOffset = OnOff_NormalHeartSound;
eGeneralBase(22).OnsetOffset = OnOff_PericardialFrictionRub2;
eGeneralBase(23).OnsetOffset = OnOff_SystolicAorticStenosis3;
eGeneralBase(24).OnsetOffset = OnOff_SystolicMitralProlapse;
eGeneralBase(25).OnsetOffset = OnOff_SystolicMitralProlapse3;
eGeneralBase(26).OnsetOffset = OnOff_SystolicMitralRegurgitation;
eGeneralBase(27).OnsetOffset = OnOff_SystolicPulmonaryStenosis2;
eGeneralBase(28).OnsetOffset = OnOff_SystolicSplitS1_3;
eGeneralBase(29).OnsetOffset = BaseResiduales.patologias(1).onset_offset;
eGeneralBase(30).OnsetOffset = BaseResiduales.patologias(2).onset_offset;
eGeneralBase(31).OnsetOffset = BaseResiduales.patologias(3).onset_offset;
eGeneralBase(32).OnsetOffset = BaseResiduales.patologias(4).onset_offset;
eGeneralBase(33).OnsetOffset = BaseResiduales.patologias(5).onset_offset;
eGeneralBase(34).OnsetOffset = BaseResiduales.patologias(6).onset_offset;
eGeneralBase(35).OnsetOffset = BaseResiduales.patologias(7).onset_offset;
eGeneralBase(36).OnsetOffset = BaseResiduales.patologias(8).onset_offset;
eGeneralBase(37).OnsetOffset = BaseResiduales.patologias(9).onset_offset;
eGeneralBase(38).OnsetOffset = BaseResiduales.patologias(10).onset_offset;



for i = 1:38
    eGeneralBase(i).segmentos = CardiacSlicingGrouped(eGeneralBase(i).formaOnda, ...
        eGeneralBase(i).OnsetOffset);
end

save('eGeneralBase.mat','eGeneralBase');

