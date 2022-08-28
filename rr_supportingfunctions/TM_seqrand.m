function sr = TM_seqrand(TM, incl_null)
%sr = TM_seqrand(TM, incl_null)
%
% computes the sequence randomness of a transition matrix.
% Some assumptions about the transition matrix (TM):
% 1) Assumes that there is a "self" and "other TM side-by-side
% 2) Assumes that the last column of the self and other columns is the
% "null" column; i.e., "no action occured"
% 
% inputs: 
% TM -- the transition matrix as described above
% incl_nell (optional, default is 0) -- whether or not to include the "no
% interaction" column.
%
% sr is an n x 2 matrix of entropy values 
%
%
% nei 11/21
%

if nargin < 2
    incl_null = 0;
end

sTM = size(TM);
hs = sTM(2)/2;
if length(sTM) < 3
    sTM(3) = 1;
end
    

    sr = nan(sTM(3),2);


for i = 1:sTM(3)
    cTM = TM(:,:,i);
    if ~incl_null
        cTM = cTM(:,[1:(hs-1) (hs+1):(sTM(2)-1)]); %remove the null columns
    end
    for j = 1:2
        if j == 1
            curinds = 1:size(cTM,2)/2;
        else
            curinds = (size(cTM,2)/2+1):size(cTM,2);
        end
        cTMn = cTM(:,curinds)./repmat(nansum(cTM(:,curinds),2),1,size(cTM(:,curinds),2)); %convert to probabilities
        psr = nan(4,1);
        for k = 1:sTM(1)
            ppsr = -1*cTMn(k,:).*log(cTMn(k,:));
             ppsr(isinf(ppsr)) = nan;
            psr(k) = nansum(ppsr); 
            if sum(isnan(ppsr)) == length(ppsr)
               psr(k) = nan; 
            end
        end
            sr(i,j) = nanmean(psr);
        end
    end
    
end