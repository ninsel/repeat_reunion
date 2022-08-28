%first create a table of each degu number, with the following format:
%
% degutable = ...
% [degu_num paircodecag paircodestr paircodenstr batch...
%   cag1 cag2 cag3 cag4 cag5...
%      str1 str2 str3 str4 str5 ... 
%          nstr1 nstr2 ...
%              ncag1 ncag2 ncag3 ncag4
%         ]
%
% script assumes the following variables in memory (from rr_part0
%    - rdb_rr
%    - fem_ind
%    - cagemateind
%    - oldstrangerind
%    - newstrangerind
%    - dategroup
%    - sumbehavID2 (a deguA is [1:4 9], deguB is [5:8 9], 
%


allfemales = unique([rdb_rr.deguA(fem_ind) ; rdb_rr.deguB(fem_ind)]);
dABind{1} = [1:4 9];
dABind{2} = [5:8 9];

csnABinds = {cagemateind, oldstrangerind, newstrangerind};

for i = 1:9
    exposurenum_ind{i} = find(rdb_rr.exposurenum == i);
end

cumdegutable = nan(length(allfemales), 25,601,5);

for i = 1:length(allfemales)
    curind_AB{1} = find(rdb_rr.deguA == allfemales(i));
    curind_AB{2} = find(rdb_rr.deguB == allfemales(i)); 
    cumdegutable(i,1) = allfemales(i);
    
    for j = 1:2
        for k = 1:3
            csnAB = intersect(curind_AB{j}, csnABinds{k});
                for m = 1:5
                    curind = intersect(csnAB, exposurenum_ind{m});
                   if ~isempty(curind)
                        cumdegutable(i,1+k) = rdb_rr.paircode(curind);
                        tableind = 5+ (k-1)*5 + m;
                        cumdegutable(i, tableind, :, :) = cumsumbehavID(curind, :, dABind{j});
                    end
                end  
                if k == 2
                    if j == 2
                        dbs = 1;
                    end
                    for n = 6:9
                        curind = intersect(csnAB, exposurenum_ind{n});
                        if ~isempty(curind)
                            tableind = 5+3*5+n-5;
                            cumdegutable(i, tableind, :,:) = cumsumbehavID(curind, :, dABind{j});                            
                        end
                        
                    end
                end
        end
    end
end