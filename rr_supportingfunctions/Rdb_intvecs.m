function IntVecs = Rdb_intvecs(rdb_rr, chunklength, betypes)
% IntVecs = Rdb_intvecs(rdb_rr)
%
%IntVecs is the same length as rdb, a cell array of vectors that have
%"chunklength" number of interactions
%
% Note: be careful if using a betypes other than [-1 1 2 3 5] (see notes in
% code)
%
% nei 6/21
%

if nargin < 3
    betypes = [-1 1 2 3 5];
end

if nargin < 2
    chunklength = 10;
end

IntVecs = cell(length(rdb_rr.paircode),1);

len_vec = length(betypes)*2;

if ismember(3,betypes)  % This is really clunky, but it maintains consistency with the convention we've been using. 
    %In the case where our betypes are [-1 1 2 3 5], we stay neutral about
    %which degu was responsible for face-to-face (3), and therefore add
    %both degus together for the summed total. The vector is therefore 9
    %elements long, instead of 10. 
    len_vec = len_vec-1;
end

for i = 1:length(rdb_rr.paircode)
    if rem(i,40) == 0
        fprintf('%d', i);
    end
	if i == length(rdb_rr.paircode)
    	fprintf('\n done \n'); 
  	end
    curind = find(ismember(fix(rdb_rr.be_identcode(:,i)), betypes));
    numrounds = floor(length(curind)/chunklength);
    IntVecs{i} = nan(len_vec,numrounds);
    for j = 1:numrounds
        startind = (j-1)*chunklength;
        zerovec = zeros(length(betypes) * 2, 1);
        for k = 1:chunklength
            ind_plus_be = find(betypes == rdb_rr.be_identcode(curind(startind+k), i));
            ind_plus_wh = find(rdb_rr.be_who(curind(startind+k),:,i));
            if isempty(ind_plus_wh)
                ind_plus_wh = 1;
            end            
            zerovec(ind_plus_be + (ind_plus_wh(1)-1)*length(betypes)) = ...
                zerovec(ind_plus_be + (ind_plus_wh(1)-1)*length(betypes)) + 1;                                                       
        end
        if ismember(3,betypes) %see note above about maintaining convention 
            ind3 = find(betypes == 3);
            otherind3 = ind3+length(betypes);
            notmemberbe = setdiff(1:(length(betypes)*2), [ind3 otherind3]);
            zerovec = [zerovec(notmemberbe) ; zerovec(ind3)+zerovec(otherind3)];
        end
        IntVecs{i}(:,j) = zerovec;
    end
end


    

