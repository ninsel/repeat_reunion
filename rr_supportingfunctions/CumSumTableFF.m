function cumdegutable = CumSumTableFF(alldegus, rdb_rr, cumsumbehavID, restrictinds)

% cumsumtable = CumSumTable(alldegus, rdb_rr)
%
% creates a table of degu x session x bins(601) x behavior types 
% emulates the dtt but with bins = 601 timesteps instead of 1 full session
% value
%
% "alldegus" is the list of degu numbers (usually from dtt(:,1))
%
% replaces mk_cumsumtable and mk_cumsumtable_m
%
%
% nei 11/2023
%



%alldegus = dtt(:,1);

numbehaves = size(cumsumbehavID,3)/2;

dABind{1} = [1:numbehaves];
dABind{2} = [(numbehaves+1):size(cumsumbehavID,3)];

if isfield(rdb_rr, 'strangercode')
    oldstrangerind = find(rdb_rr.strangercode == 1);
    newstrangerind = find(rdb_rr.strangercode == 2);
    cagemateind = find(rdb_rr.strangercode == 0); 
else
    oldstrangerind = find(rdb_rr.stranger == 1);
    newstrangerind = find(rdb_rr.stranger == 4);
    cagemateind = find(rdb_rr.stranger == 0);
end

csnABinds = {cagemateind, oldstrangerind, newstrangerind};

for i = 1:9
    exposurenum_ind{i} = find(rdb_rr.exposurenum == i);
end

cumdegutable = nan(length(alldegus), 25,size(cumsumbehavID,2),numbehaves);

for i = 1:length(alldegus)
    curind_AB{1} = find(rdb_rr.deguA == alldegus(i));
    curind_AB{2} = find(rdb_rr.deguB == alldegus(i)); 
    cumdegutable(i,1) = alldegus(i);
    
    for j = 1:2
        for k = 1:3
            csnAB = intersect(curind_AB{j}, csnABinds{k});
            if nargin > 3
                csnAB = intersect(csnAB, restrictinds);
            end
                for m = 1:5
                    curind = intersect(csnAB, exposurenum_ind{m});
                   if ~isempty(curind)
             %           degutable(i,1+k) = setdiff([rdb_rr.deguA(curind) rdb_rr.deguB(curind)], alldegus(i));
   
%                        cumdegutable(i,1+k) = rdb_rr.paircode(curind);
                        tableind = 5+ (k-1)*5 + m;
                        cumdegutable(i, tableind, :, :) = cumsumbehavID(curind, :, dABind{j});
                    end
                end  
                if k == 2
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