function [segments] = cardiacSoundSlicing(sig,onset_offset)
%------------------------------------------------------------------------
% This function returns a cell 'segments' which contains all the sounds of
% the phonocardiogram separated from silences. 
    onset_offset = sort(onset_offset(:)); %sorting elements in ascending 
    %order to take cardiac events separately.

    i=1; j=2;
    onset_offset = onset_offset(onset_offset~=0);
    segments = cell(1,length(onset_offset)/2);
    for k=1:length(onset_offset)/2
        x1 = onset_offset(i);
        x2 = onset_offset(j);
        segments{k} = sig(x1:x2);
        i = i+2;
        j= j+2;
    end
    

end