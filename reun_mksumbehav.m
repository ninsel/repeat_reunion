function sumbehav = reun_mksumbehav(rdb, betypes, whop)
% sumbehav = reun_mksumbehav(rdb, betypes, whop)
%
% creates the sumbehav matrix that sums/summarizes the proportion of time
% each degu spent engaged in a particular event
%
%INPUTS:
% rdb -- the reunion database struct
% betypes -- the indcodes for each behavior type to analyze (e.g., [-1 1 2
% 3]
% whop (optional) -- 1 for collapsing the two degus (default), 2 for analyzing them
% independently
%
% nei 1/19
%
% Edited 9/19 by nei to accommodate sub-behaviors (see comment in code)
%

if nargin < 3
    whop = 1;
end

%we decided to code subdivisions of certain behaviors--particularly the
%agonistic behaviors--as decimals. E.g., mounting may be -1.1, and wrestling
%-1.6. If our betypes are all integers, then we will round the behavioral
%codes toward zero; if not, then we will not do so.
be_identcode = rdb.be_identcode;
if sum(betypes == fix(betypes)) == length(betypes)
    be_identcode = fix(be_identcode);
end


if whop == 1
    sumbehav = nan(length(rdb.paircode), length(betypes));
    allsesstimes = rdb.sessionstart_end(:,2)-rdb.sessionstart_end(:,1);
    for i = 1:length(rdb.paircode)
        if i == 47
            dbs = 1;
        end
        for j = 1:length(betypes)
            curind = find(be_identcode(:,i) == betypes(j));
            starttimes_fix = rdb.be_start_end(curind,1, i) - rdb.sessionstart_end(i);
            indonind = find(starttimes_fix < 1200);
            curind = curind(indonind);
            sumbehav(i,j) = nansum(rdb.be_start_end(curind,2, i) - rdb.be_start_end(curind,1,i))/allsesstimes(i);
        end
    end
elseif whop == 2
    sumbehavID = nan(length(rdb.paircode), 6);
    allsesstimes = rdb.sessionstart_end(:,2)-rdb.sessionstart_end(:,1);
    
    for i = 1:length(rdb.paircode)
        for j = 1:length(betypes)
            for k = 1:2
                curind = find(be_identcode(1:size(rdb.be_who,1),i) == betypes(j) & rdb.be_who(:,k,i) == 1);
                starttimes_fix = rdb.be_start_end(curind,1, i) - rdb.sessionstart_end(i);
                indonind = find(starttimes_fix < 1200);
                curind = curind(indonind);
                sumbehavID(i,j+(k-1)*length(betypes)) = nansum(rdb.be_start_end(curind,2, i) - rdb.be_start_end(curind,1,i))/allsesstimes(i);
            end
        end
    end
    
    sumbehav = sumbehavID;
end
