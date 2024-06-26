function [degutable scorercell] = Make_DeguTable(rdb_rr, inds, sumbehavID2)

%degutable = Make_DeguTable(rdb_rr, inds)
%
% Previously script mk_degutable (see also mk_degutable_count)
% degutable = ...
% [degu_num paircodecag paircodestr paircodenstr batch...
%   cag1 cag2 cag3 cag4 cag5...
%      str1 str2 str3 str4 str5 ... 
%          nstr1 nstr2 ...
%              ncag1 ncag2 ncag3 ncag4
%         ]
%
%
% nei 3/22 (based on mk_degutable)

if nargin < 3
    betypes = [-1 1 2 3 5]; % agonistic, grooming, rear sniffing, face-to-face, body sniffing
    sumbehav = reun_mksumbehav(rdb_rr, betypes);
    betypesID = [-1 1 2 5];
    sumbehavID = reun_mksumbehav(rdb_rr, betypesID, 2);
    sumbehavID2 = [sumbehavID sumbehav(:,4)];
end

oldstrangerind = find(rdb_rr.strangercode == 1);
newstrangerind = find(rdb_rr.strangercode == 2);
cagemateind = find(rdb_rr.strangercode == 0); 


alldegus = unique([rdb_rr.deguA(inds) ; rdb_rr.deguB(inds)]);

if size(sumbehavID2,2) == 9
    dABind{1} = [1:4 9]; % inds onto the sumbehavID2--currently hard-coded for he specific
    dABind{2} = [5:8 9]; %  behaviors used, but should be made flexible
else
    dABind{1} = [1:floor(size(sumbehavID2,2)/2)];
    dABind{2} = [(floor(size(sumbehavID2,2)/2)+1):size(sumbehavID2,2)];
end

csnABinds = {cagemateind, oldstrangerind, newstrangerind};

for i = 1:9
    exposurenum_ind{i} = find(rdb_rr.exposurenum == i);
end

degutable = nan(length(alldegus), 25,5); % the "5" should also change according to the number of behaviors
scorercell = cell(length(alldegus), 25);
for i = 1:length(alldegus)
    curind_AB{1} = find(rdb_rr.deguA == alldegus(i));
    curind_AB{2} = find(rdb_rr.deguB == alldegus(i)); 
    degutable(i,1) = alldegus(i);
    
    
    for j = 1:2 % when degu is "A", and when it is "B"
        for k = 1:3 %cagemate, old stranger, new stranger
            csnAB = intersect(curind_AB{j}, csnABinds{k});
                for m = 1:5
                    curind = intersect(intersect(csnAB, exposurenum_ind{m}), inds);                    
                   if ~isempty(curind)
                       curind = curind(1); %REMOVVE LATER 
                        degutable(i,1+k) = setdiff([rdb_rr.deguA(curind) rdb_rr.deguB(curind)], rdb_rr.alldegus(i));
                        tableind = 5+ (k-1)*5 + m;
                        degutable(i, tableind, :) = sumbehavID2(curind, dABind{j});
                        scorercell{i,tableind} = rdb_rr.scorer{curind};
                    end
                end  
                if k == 2
                    for n = 6:9
                        curind = intersect(intersect(csnAB, exposurenum_ind{n}), inds);
                        if ~isempty(curind)
                             curind = curind(1); %REMOVVE LATER 
                            tableind = 5+3*5+n-5;
                            degutable(i, tableind, :) = sumbehavID2(curind, dABind{j}); 
                            scorercell{i,tableind} = rdb_rr.scorer{curind};
                        end
                        
                    end
                end
        end
    end
end