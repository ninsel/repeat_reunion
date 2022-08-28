function rdb = RR_cleanBehav(rdb)
% rdb_rr = RR_cleanBehav(rdb_rr)
%
% Improves data validity by removing unusually long interaction times.
% Limits on interaction times are done by using the following:
%   1. Eah interaction type has a limit of 6 s, determined by visual
%   inspection of the interaction bout length distribution
%   2. If the same degu engages in another interaction within that 6
%   seconds, then the behavior is considered "stopped" at that time.
%   3. If the same degu does not engage in another interaction during that
%   6 seconds, then the behavior is cut-off at 6 s
%
%  nei 4/25
%

limittime = 6;

for i = 1:length(rdb.deguA)
    indID = find(ismember(fix(rdb.be_identcode(:,i)), [-2 -1 1 2 3 5]));
    timelength = rdb.be_start_end(:,2,i) - rdb.be_start_end(:,1,i);
    indTooLong = find(timelength > 6);
    ind_IDTL = intersect(indID, indTooLong);
    for j = 1:length(ind_IDTL)
        whodat = find(rdb.be_who(ind_IDTL(j),:,i));
        if isempty(whodat) | length(whodat) > 1
            nextwho = 1;
        else
            nextwho = find(rdb.be_who((ind_IDTL(j)+1):end,whodat,i));
        end        
        nexttime = rdb.be_start_end(ind_IDTL(j)+nextwho(1),1,i);
        if nexttime - rdb.be_start_end(ind_IDTL(j),1,i) < 6
            rdb.be_start_end(ind_IDTL(j),2,i) = nexttime;
        else
            rdb.be_start_end(ind_IDTL(j),2,i) = rdb.be_start_end(ind_IDTL(j),1,i)+6;
        end
    end
end