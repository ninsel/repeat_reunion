function timevecs = Rdb_intvecsTime(cumsumbehavID, ivtime)
%
%IVdist = IVdist_within(cumsumbehavID, ivtime, disttype, indset)
%
% Splits sessions into timeset s blocks
%
% nei 7/21
%

ivtime = ivtime/2; %time is intered in seconds, but we use 2s bins!

indset = 1:size(cumsumbehavID,1);
numbehavs = size(cumsumbehavID,3);

numdists = floor(1200/ivtime);

%timevecs = nan(numbehavs, numdists, length(indset));
timevecs = cell(length(indset),1);

for i = 1:length(indset)
    sbehav_insess = nan(numbehavs,numdists);
 %   curmat = squeeze(cumsumbehavID(indset(i),:,:));
    prevvec = zeros(size(cumsumbehavID,3),1);
    k = 1;
    for j = 1:numdists
        curtimeind = ivtime*j;  
        if curtimeind < size(cumsumbehavID,2)
            curvec = squeeze(cumsumbehavID(indset(i), curtimeind, :));
            sbehav_insess(:,j) = curvec - prevvec;
            prevvec = curvec;
            k = k+1;
        end
    end
    timevecs{i} = sbehav_insess(:,1:(k-1));
end
