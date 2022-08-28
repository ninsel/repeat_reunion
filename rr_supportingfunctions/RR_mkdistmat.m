function [SameDifCell, subseqdists, Dmat] = RR_mkdistmat(bigmat, indcell, distmet)
%SameDifCell = RR_mkdistmat(bigmat, indcell)
%
% Creates a distance matrix from the rdb and big ("condition") matrix.
% input indcell is a cell array of indices (of the bigmatpairnums) to compare. 
% output SamDifcell will be a cell array of "within" vs "between" pairs
% for each set of indcell
%
%inputs:
%  bigmat is 
%
% nei 10/19

if nargin < 3
    distmet = 'mahalanobis';
end

allmat = cell(length(indcell),1);
allpairind = cell(length(indcell),1);

%Need to do this in two stages so that we can get the covariance matrix for
%mahalanobis distance.

%Stage 1: get the matrices for each indcell
for i = 1:length(indcell)
    curmat = cell(length(indcell{1}),1);
    pairind = cell(length(indcell{1}),1);
    for j = 1:length(indcell{i})        
        curmat{j} = squeeze(bigmat(indcell{i}(j),:,:))';  
        pairind{j} = j*ones(size(curmat{j},1),1);
    end
    allmat{i} = cat(1,curmat{:});
    allpairind{i} = cat(1,pairind{:});  
end

%Stage 2: calc the distance matrices for each indcell
C = nancov(cat(1,allmat{:}));
S= nanstd(cat(1,allmat{:}));
SameDifCell = cell(length(indcell),1);
subseqdists = cell(length(indcell),1);

    

for i = 1:length(indcell)    
    if strcmp(distmet, 'mahalanobis')
        Dmat{i} = squareform(pdist(allmat{i}, 'mahalanobis', C));
    elseif strcmp(distmet, 'seuclidean')
        Dmat{i} = squareform(pdist(allmat{i}, 'seuclidean', S));
    else
        Dmat{i} = squareform(pdist(allmat{i}, distmet));
    end
    E = eye(length(Dmat{i}));
    E(E==1) = nan;
    Dmat{i} = Dmat{i}+E;
    U{i} = unique(allpairind{i}); 
    for j = 1:length(U{i})
        indD = find(allpairind{i} == j);
        currows = indD;
        samecols = indD;
        difcols = setdiff(1:length(allpairind{i}), indD);
        
        withindists = reshape(Dmat{i}(currows, samecols), length(currows)*length(samecols), 1);
        betweendists = reshape(Dmat{i}(currows, difcols), length(currows)*length(difcols), 1);
        
        SameDifCell{i}(j,:) = [nanmean(withindists) nanmean(betweendists)];
        
     %   subseqdists{i}(j,:) = nan(length(U{i}),length(currows)-1); 
        if length(indD) > 1 
            subseqind = [currows(1:end-1) currows(2:end)];
            for k = 1:length(subseqind)
                allsubseq(k) = Dmat{i}(subseqind(k,1), subseqind(k,2));                                 
            end  
            subseqdists{i}(j,:) = allsubseq;
        end
    end
end

