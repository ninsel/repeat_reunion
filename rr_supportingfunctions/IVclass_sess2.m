function [ClassDist, CDbyday] = IVclass_sess2(sbID, indset, u_p, lp, classtype, expnum)
%[ClassDist, CDbyday] = IVclass_sess(sbehav, indset, u_p, paircodes, lp, disttype)
%
% finds classification success between all sessions in indset
% u_p with u_p being the set of indices
% (typically for cross-session analyses, u_p includes cagemates first and
% strangers second)
%
% nei 6/22
%

ClassDist = nan(length(u_p)); 
CDbyday = nan(length(u_p), length(u_p), 5);


for i = 1:length(u_p)
    fprintf('%d of %d', i, length(u_p));
    for j = 1:i % previously ran the full matrix, but as anticipated it was symmetric, so now only running 1 side
         curind = intersect(find((lp == u_p(i) | lp == u_p(j))), indset);
         curmat = sbID(curind,:);   
         curlabels = lp(curind);
         curexposures = expnum(curind);
         uexp = unique(curexposures);
         ucl = unique(curlabels);
        if i == j
            curmat = [curmat ; curmat];
            curlabels = [curlabels ; zeros(length(curlabels),1)];
        end
         curmat(isnan(curmat)) = 0;

        if length(unique(curlabels)) < 2
            continue %cheap way to skip cases where one pair isn't found, e.g., pairs that were in juvenile but not adolescent groups
        end

        if length(curlabels) > 10
            dbs =1;
        end
        if length(find(curlabels == ucl(1))) ~= 5
            dbs = 1        
        end

        switch classtype
            case 'rbf'
                [predlabel_all, prob_estimates_all] = SVM_NI_Matlab(curmat, curlabels, 1, 0, [], 'rbf');
            case 'linear'
               	[predlabel_all, prob_estimates_all] = SVM_NI_Matlab(curmat, curlabels, 1, 0, [], 'linear');
        end
        
        successrate = length(find(predlabel_all-curlabels == 0))/length(predlabel_all);

        ClassDist(i,j) = successrate;
        
        for k = 1:length(uexp)
            expind = find(curexposures == uexp(k));
            srate_day = length(find(predlabel_all(expind)-curlabels(expind) == 0))/length(expind);
            CDbyday(i,j,uexp(k)) = srate_day;
        end
          
    end
end