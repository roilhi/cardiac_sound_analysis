%function [events] = CardiacSlicingGrouped (sig,onset_offset)
clear 
close all
clc
load('eGeneralBase.mat');

sig = eGeneralBase(29).formaOnda;
onset_offset = eGeneralBase(29).OnsetOffset;
[m,n] = size(onset_offset);

  onset_offset = sort(reshape(onset_offset(:),2*m,n/2));
  [mm,nn] = size(onset_offset);
  eventsGroup = cell(1,mm/2);
  events = cell(1,nn);
  for k = 1:nn
      i=1;
      j=2;
      Vonset_offset = onset_offset(:,k);
      Vonset_offset = Vonset_offset(Vonset_offset~=0);
      for kk = 1:length(Vonset_offset)/2
          x1 = Vonset_offset(i);
          x2 = Vonset_offset(j);
          eventsGroup{kk} = sig(x1:x2);
        i = i+2;
        j= j+2;
      end
      events{k} = eventsGroup;
  end
  
  