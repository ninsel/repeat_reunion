function IVdist = IVdist_sess_all(sbehav, indset, u_p, lp, e_p, disttype)
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

IVdist = cell(length(u_p));  
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
    for j = i:length(u_p); % previously ran the full matrix, but as anticipated it was symmetric, so now only running 1 side
         curind = intersect(find((lp == u_p(i) | lp == u_p(j))), indset);
         curind_exposures = e_p(curind);
         [ex exind] = sort(curind_exposures);
         curind = curind(exind);
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
         end
         
          dist_ants(find(eye(length(dist_ants)))) = nan; % remove 0's on the diagonal

          if i == 50
              dbs = 1;
          end
          
          IVdist{i,j} = dist_ants;
    %        Distmat(i,j) = nanmean(distvec(randperm(length(distvec), 10)));
    end
end