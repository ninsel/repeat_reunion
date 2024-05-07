function sumbehav = reun_mksumbehav3(rdb, betypes, whop, T)
% sumbehav = reun_mksumbehav(rdb, betypes, whop, T)
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
% T -- amount of time to include in s (default is 20 min -- 1200 s)
%
% nei 1/19
%
% Edited 9/19 by nei to accommodate sub-behaviors (see comment in code)
%

if nargin < 4
    T = 1200;
    if nargin < 3
        whop = 1;
    end
end
if isempty(whop)
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

allsesstimes = min([rdb.sessionstart_end(:,2)-rdb.sessionstart_end(:,1) repmat(T, length(rdb.paircode),1)], [], 2);

if whop == 1
    sumbehav = zeros(length(rdb.paircode), length(betypes));  
    for i = 1:length(rdb.paircode)
        for j = 1:length(betypes)
            curind = find(be_identcode(:,i) == betypes(j));
            starttimes_fix = rdb.be_start_end(curind,1, i) - rdb.sessionstart_end(i,1);
            indonind = find(starttimes_fix < T);
            curind = curind(indonind);
            if  isnan(rdb.be_start_end(curind,2,i)) & isnan(rdb.be_start_end(curind+1,1,i))  %
                rdb.be_start_end(curind,2,i) = rdb.sessionstart_end(i,1) + 1200;
            elseif  rdb.be_start_end(curind,2,i) > rdb.sessionstart_end(i,1) + 1200
                rdb.be_start_end(curind,2,i) = rdb.sessionstart_end(i,1) + 1200;
            end 
            newints = unionOfIntervals([rdb.be_start_end(curind,1,i) rdb.be_start_end(curind,2,i)]);
            if ~isempty(newints)                  
                sumbehav(i,j) = nansum(newints(:,2) - newints(:,1))/allsesstimes(i);
            end
            if sumbehav(i,j) >= 1
                dbs = 1;
            end
        end
    end
elseif whop == 2
    sumbehavID = nan(length(rdb.paircode), length(betypes));
   
    for i = 1:length(rdb.paircode)
        for j = 1:length(betypes)
            for k = 1:2
                curind = find(be_identcode(1:size(rdb.be_who,1),i) == betypes(j) & rdb.be_who(:,k,i) == 1);
                starttimes_fix = rdb.be_start_end(curind,1, i) - rdb.sessionstart_end(i);
                indonind = find(starttimes_fix < T);
                if ~isempty(indonind)
                    db = 1;
                end
                curind = curind(indonind);
                sumbehavID(i,j+(k-1)*length(betypes)) = nansum(rdb.be_start_end(curind,2, i) - rdb.be_start_end(curind,1,i))/allsesstimes(i);
            end
        end
    end
    
    sumbehav = sumbehavID;
end
