function IVdist = IVdist_sess(sbehav, indset, u_p, lp, disttype)
%IVdist = IVdist_sess(sbehav, disttype)
%
% finds distances between all sessions in indset
% u_p with u_p being the set of indices
% (typically for cross-session analyses, u_p includes cagemates first and
% strangers second)
%
%options for disttype are:
%  'euclidean'
%  'seuclidean'
%  'mahalanobis'
%  'correlation'
%  'cosine
%
% nei 6/22
%

IVdist = nan(length(u_p)); 
%Distmat_Btw = nan(length(u_p));

C = nancov(sbehav); % for mahalanobis distance

sbID = sbehav;
sbIDs = sbID;
for i = 1:size(sbIDs,2)
    sbIDs(:,i) = sbID(:,i)/nanstd(sbID(:,i));
end
sbIDn = sbID./repmat(sum(sbID,2), 1, size(sbID,2));

%sbID = sumbehavID2.^(1/3)./repmat(nanstd(sumbehavID2.^(1/3)), size(sumbehavID2,1),1);

for i = 1:length(u_p)
    for j = 1:i % previously ran the full matrix, but as anticipated it was symmetric, so now only running 1 side
         curind = intersect(find((lp == u_p(i) | lp == u_p(j))), indset);
         curmat = sbID(curind,:);   
         scurmat = sbIDs(curind,:);
         ncurmat = sbIDn(curind,:);
         curlabels = lp(curind);
         ucl = unique(curlabels);

         curmat(isnan(curmat)) = 0;

         switch disttype
             case 'euclidean'
                 dist_ants = squareform(pdist(curmat, 'euclidean'));
             case 'mahalanobis'
                 dist_ants = squareform(pdist(curmat, 'mahalanobis', C));
             case 'seuclidean'
                 dist_ants = squareform(pdist(scurmat, 'euclidean'));
             case 'neuclidean'
                 dist_ants = squareform(pdist(ncurmat, 'euclidean'));
             case 'correlation'
                 dist_ants = squareform(pdist(curmat, 'correlation'));
             case 'cosine'
                 dist_ants = squareform(pdist(curmat, 'cosine'));
             case 'jsdist'
                 dist_ants = nan(size(curmat,1));
                 for k = 1:size(curmat,1)
                     for m = 1:size(curmat,1)
                        dist_ants(k,m) = sqrt(JSDiv(curmat(k,:),curmat(m,:)));
                     end
                 end
         end
         
          dist_ants(find(eye(length(dist_ants)))) = nan; % remove 0's on the diagonal
          if length(ucl) > 1
              distvec = reshape(dist_ants(curlabels == ucl(1), curlabels == ucl(2)), 1, []);                       
          else
              distvec = reshape(dist_ants, 1, []);         
          end
          IVdist(i,j) = nanmean(distvec);
    %        Distmat(i,j) = nanmean(distvec(randperm(length(distvec), 10)));
    end
end