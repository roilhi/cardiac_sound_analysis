function [events] = CardiacSlicingGrouped (sig,onset_offset)
% Output: events: cell containing s1-s2 or murmurs together
% {[s1 s1 s1 s1 ...],[s2 s2 s2, ....], [mur mur,....]
  [m,n] = size(onset_offset);
  %Sorting segmentation information onsets and offsets in columns
  % i.e. [onS1; offS1;...offS1; os2; os2;offs2; onPat; offPat; ... ]
  onset_offset = sort(reshape(onset_offset(:),2*m,n/2));
  [mm,nn] = size(onset_offset);
  % Cell which takes the group of s1's or s2's or murmurs
  eventsGroup = cell(1,mm/2);
  % Cell which contains sounds separated
  events = cell(1,nn);
  for k = 1:nn
      i=1;
      j=2;
      %Taking the column of onset-offsets
      Vonset_offset = onset_offset(:,k);
      % Checking non-zero elements
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



end