function [be_xcorr_self, be_xcorr_other, xaxis, codes] = Behav_Xcorr_selfother(rdb, betypes, lags, maxlag, normvals)
% be_xcorr = Behav_Xcorr_selfother(be_start_end, be_identcode, betypes, normvals)
%
% Computes a time-lag cross correlogram between behaviors. Y axis is the
% proportion of behavior B instances relative to behavior A instances
%
% For this analysis, positive time lags will be from the end of a behavior,
% negative will be before the beginning of the behavior. The time the
% behavior takes therefore does not get included 
%
%
%Inputs: 
% rdb -- database of social exposure sessions that includes the following fields
%       - be_start_end -- an n x 2 matrix of start and end times (if 3D,
%                   then function will loop over the layers)
%        - be_identcode -- the identity codes of each 
%        - be_who -- n x 2 matrices of which animal initiated
% betypes -- which identity codes to use (default is all)
% lags -- time lags each bin (default is 0.5 s)
% maxlag -- the edge of the xcorr (default is 10 s)
% normvals -- whether to normalize the values by the percent behavior
%
% outputs:
% be_xcor --- a cross correlogram of each pairwise relationship between
% behaviors
% xaxis --- the time lags
% codes --- an m x 2 matrix of which behavior codes correspond to the
% be_xcor rows
%
% nei 1/20
%
% 3/21 added compatibility with different agonistic/play (decimal betypes)
%


if nargin < 5
    normvals = 1;
end

if nargin < 4
    maxlag = 10;
end
if nargin < 3
    lags = 0.5;
end

if nargin < 2
    betypes = unique(be_identcode(:,1));
end
if isempty(lags)
    lags = .5;
end

timelags = [-1*maxlag:lags:0 0:lags:maxlag];


%Here we combine all "agonistic" (or play) together, unless they are
%separately specified (as decimals between -1 to -2)
if sum(betypes == fix(betypes)) == length(betypes)
    be_identcode_allsess = fix(rdb.be_identcode);
end


s = size(rdb.be_start_end,3);

be_xcorr_self = nan(length(betypes)^2, length(timelags), s);
be_xcorr_other = nan(length(betypes)^2, length(timelags), s);
codes = nan(length(betypes)^2, 2, s);
xaxis = timelags;

for sess = 1:s
    
    be_who = rdb.be_who(:,:,sess);
    s_e_mat = rdb.be_start_end(:,:,sess);
    be_identcode = be_identcode_allsess(:,sess);
    sessionstart_end = rdb.sessionstart_end(sess,:);
    beinds = find(ismember(be_identcode, betypes));
    
    %pull the indices
    for i = 1:length(betypes)
        typeinds{i} = find(be_identcode == betypes(i));
    end
    
    %loop across each pair of behaviors, including the autocorrs
    
    be_ind = 1;
        
    for i = 1:length(betypes)
        for j = 1:length(betypes)
            curind_ref = typeinds{i};
            curind_comp_all = typeinds{j};
        
            for n = 1:2
                wh = find(be_who(:,n) == 1);
                curind_comp{n} = intersect(curind_comp_all, wh);
                totcomptime(n) = nansum(s_e_mat(curind_comp{n},2)-s_e_mat(curind_comp{n},1))/(sessionstart_end(2)-sessionstart_end(1)); %previously divided by session time?? Watch for bugs
            end
            
            M = cell(2,1);
%             for n = 1:2
%                 M{n} = zeros(length(curind_ref), length(timelags));
%             end
            %M = zeros(length(curind_ref), length(timelags));
            mind_self = 1;
            mind_other = 1;
            for k = 1:length(curind_ref)
                for n = 1:2
                    if ~isempty(curind_comp{n})
                    tse_startbefore = s_e_mat(curind_comp{n},:) - s_e_mat(curind_ref(k),1); %time relative to start, animal A
                
                   %find the comp behaviors that start before the reference,
                   %then fill in the the start and end bins with one
                
                     % we will create separate vectors for the start time and
                    % end time of the comp behavior (relative to the ref). Then
                    % we will find where those are, and fill ones for
                    % everything in between
                
                    V1a = histc(tse_startbefore(:,1), timelags(1:length(timelags)/2));
                    V1b = histc(tse_startbefore(:,2), timelags(1:length(timelags)/2));
                                
                    iV1a = find(V1a);
                    iV1b = find(V1b);
                
                    if length(iV1a) > length(iV1b)
                        iV1b = [iV1b ; repmat(length(timelags)/2, length(iV1a)-length(iV1b), 1)];
                    elseif length(iV1a) < length(iV1b)
                        iV1a = [1 ; iV1a];
                    end
                    V1 = V1a;
                
                    % here we fill the ones...
                    for m = 1:length(iV1a)
                        V1(iV1a(m):iV1b(m)) = 1;
                    end
                
                    tse_endafter = s_e_mat(curind_comp{n},:) - s_e_mat(curind_ref(k),2);
                
                     %Now do the same for the events following the end
                
                    V2a = histc(tse_endafter(:,1), timelags((length(timelags)/2+1):end));
                    V2b = histc(tse_endafter(:,2), timelags((length(timelags)/2+1):end));
                    iV2a = find(V2a);
                    iV2b = find(V2b);
                    
                  if length(iV2a) > length(iV2b)
                        iV2b = [iV2b ; repmat(length(timelags)/2, length(iV2a)-length(iV2b), 1)];
                    elseif length(iV2a) < length(iV2b)
                        iV2a = [1 ; iV2a];
                  end
                  
                  V2 = V2a;
                
                  %fill in the ones again...
                  for m = 1:length(iV2a)
                    V2(iV2a(m):iV2b(m)) = 1;
                  end               
                
                  if size(V1,1) == 1
                    V1 = V1';
                    V2 = V2';
                  end
                if find(be_who(curind_ref(k),:)) == n %here's where we switch animal A/B to SELF/OTHER
                    M{1}(mind_self,:) = [V1' V2'];                                         
                    if normvals == 1                        
                        M{1}(mind_self,:) = M{1}(mind_self,:)/totcomptime(n);
                    end
                    mind_self = mind_self + 1;
                elseif find(be_who(curind_ref(k),:)) == mod(n,2)+1
                    M{2}(mind_other,:) = [V1' V2'];                    
                 	if normvals == 1                        
                        M{2}(mind_other,:) = M{2}(mind_other,:)/totcomptime(n);
                    end 
                    mind_other = mind_other + 1;
                else
                    dbs = 1;
                end
                
                if length(find(isinf(M{2}))) > 0
                    dbs = 1;
                end
%                M{n}(k,:) = [V1' V2'];
               % mind = mind + 1;
                    end
                end
            end
            if ~isempty(M{1})
               be_xcorr_self(be_ind,:,sess) = sum(M{1},1)/length(curind_ref); %notice normalization by number of reference behaviors
            end
            if ~isempty(M{2})
               be_xcorr_other(be_ind,:,sess) = sum(M{2},1)/length(curind_ref);
            end
            codes(be_ind,:,sess) = [i j];            
            be_ind = be_ind + 1;
        end
    end
end