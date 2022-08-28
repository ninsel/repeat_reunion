function [TM, TM2, TMc] = rdb_transitionmats4(rdb, betypes, timewindow, normprob, index)
%
%TM = rdb_transitionmats(rdb, timewindow)
%
% creates transition probability matrices (TM) for each element of index in rdb.
% Rows of TM are the reference interaction types, columns are the comparison interaction types
% 
% A transition from interaction to "no interaction" takes place if
% "timewindow" amount of time passes after the _offset_ of the interaction. 
%Default time window is 5 s (chosen based on cross correlogram patterns). 
%
% The first length(betypes)+1 elements refer to "self", the next refer to
% "other". These are computed independently, such that one interaction step includes
% both a self and an "other" transition. 
%
%NOT YET IMPLEMENTED
% If "combinedegus" is set to 0, then TM will consist of twice as many
% rows, with the first set referring to degu A and second set degu B.
%
% NOT YET IMPLEMENTED, ONLY STEPNUM = 1 ALLOWED: 
%   //Default stepnums is "1", meaning we are looking at the next interaction
% that takes place, given a particular interaction. Stepnums can be set to
% a scalar or vector, but must consist of positive integers between 1 and
% 10. If stepnums is a vector, then output variable TM will be a 3
% dimensional matrix.//
%
% in v4 added a third output: control TM (TM based on baseline
% probabilities of actions)
%
% This code is not very good, but it works. 
%
% nei 8/2021
%

if nargin < 5
    index = 1:length(rdb.paircode);
    if nargin < 4
        normprob = 0;
        if nargin < 3
            timewindow = 5; %5 seconds
        end
    end
end

TM = nan(length(betypes), (length(betypes)+1)*2, length(index));

if nargout > 1
    TM2 = TM;
    if nargout > 2
        TMc = TM2;
    end
end

for sess = 1:length(index)
   s_e_mat = rdb.be_start_end(:,:,index(sess));
   beinds = find(ismember(rdb.be_identcode(:,index(sess)), betypes));
   
%   s_e_mat = s_e_mat(beinds, :);
%   i_mat = rdb.be_identcode(beinds,sess);
    
       %pull the indices
       typeinds = cell(length(betypes),1);
    for i = 1:length(betypes) %NOTE: changed this from index onto i_mat to inde onto original matrix
        typeinds{i} = find(rdb.be_identcode(:,index(sess)) == betypes(i));
    end
           
    for i = 1:length(betypes)
        numtransvec = zeros(1,(length(betypes)+1)*2);
        numtransvec2 = zeros(1,(length(betypes)+1)*2);
        curind_ref = typeinds{i};
      	curind_comp = beinds; %we'll use ALL other behaviors of interest as our comparison. 
                    %Since the transition requires a >0 from onset time lag, we will avoid including self transitions
                    % This may incidentally remove "other" behaviors that
                    % initiate at the same time, though these wouldn't
                    % properly be called "transitions" since they are
                    % simultaneous
                    
        %s_e_ref = s_e_mat(curind_ref, :);
        %s_e_comp = s_e_mat(curind_comp,:);
        
            
        for k = 1:length(curind_ref)
            tse_on = s_e_mat(curind_comp,:) - s_e_mat(curind_ref(k),1); %gives time from onset
            tse_off = s_e_mat(curind_comp,:) - s_e_mat(curind_ref(k),2); % gives us comp vector relative to reference
            indtrans = find(tse_off(:,1) < timewindow & tse_on(:,1) > 0); %transition from start of interaction to 5 s after offset, if none exist, then transition is to "no-interaction"
            if isempty(indtrans) %neither self nor other had a subsequent behavior
                    numtransvec(length(betypes)+1) = numtransvec(length(betypes)+1)+1;
                    numtransvec((length(betypes)+1)*2) = numtransvec((length(betypes)+1)*2)+1;
            else
                who_curbehav_self = find(rdb.be_who(curind_ref(k),:,index(sess)));
                [ind_nextbehaves, who_nextbehaves] = find(rdb.be_who(curind_comp(indtrans),:,index(sess)));
                selfbe = find(who_nextbehaves == who_curbehav_self);
                otherbe = find(who_nextbehaves ~= who_curbehav_self); 
                index_on_numtrans_s = [];
                    d = 0;
                    while ~isempty(selfbe) & ~d %ADDED THIS FOR V3: CAN"T TRANSITION TO THE SAME STATE
                        index_on_numtrans_s = find(betypes == rdb.be_identcode(curind_comp(indtrans(ind_nextbehaves(selfbe(1)))), index(sess)));
                        if index_on_numtrans_s ~= i                           
                            numtransvec(index_on_numtrans_s) = numtransvec(index_on_numtrans_s) +1;
                            d = 1;
                        else 
                            selfbe = selfbe(2:end);
                        end
                    end
                if isempty(selfbe)
                    numtransvec(length(betypes)+1) = numtransvec(length(betypes)+1)+1;
                end
                if isempty(otherbe)
                    numtransvec(2*(length(betypes))+1) = numtransvec(2*(length(betypes)+1))+1;
                else % we don't have to remove same-behavior transitions if it's the other individual 
                    index_on_numtrans_o = find(betypes == rdb.be_identcode(curind_comp(indtrans(ind_nextbehaves(otherbe(1)))), index(sess))); 
                    numtransvec(index_on_numtrans_o + length(betypes)+1) = numtransvec(index_on_numtrans_o + length(betypes)+1) +1;
                end             
            end
            if nargout > 1 %if we're including a second-order transition matrix...
                nonext = 0;
                indtrans2 = [];
                if isempty(indtrans) | (isempty(selfbe) & isempty(otherbe))
                    indtrans2 = find(tse_off(:,1) < timewindow*2 & tse_on(:,1) > 0);
                    if isempty(indtrans2)
                        nonext = 1;
                    end
             	elseif isempty(otherbe) 
                    tse_on2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(selfbe(1)))),1); %gives time from onset of next action
                    tse_off2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(selfbe(1)))),2); %gives time from onset of next action
                    indtrans2 = find(tse_off2(:,1) < timewindow & tse_on2(:,1) > 0); %transition from start of interaction to 5 s after offset, if none exist, then transition is to "no-interaction"
            	elseif isempty(selfbe)
                 	tse_on2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(otherbe(1)))),1); %gives time from onset of next action
                    tse_off2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(otherbe(1)))),2); %gives time from onset of next action
                    indtrans2 = find(tse_off2(:,1) < timewindow & tse_on2(:,1) > 0); %transition from start of interaction to 5 s after offset, if none exist, then transition is to "no-interaction"
                elseif selfbe(1) < otherbe(1)
                    tse_on2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(selfbe(1)))),1); %gives time from onset of next action
                    tse_off2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(selfbe(1)))),2); %gives time from onset of next action
                    indtrans2 = find(tse_off2(:,1) < timewindow & tse_on2(:,1) > 0); %transition from start of interaction to 5 s after offset, if none exist, then transition is to "no-interaction"
                elseif  otherbe(1) < selfbe(1)
              		tse_on2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(otherbe(1)))),1); %gives time from onset of next action
                    tse_off2 = s_e_mat(curind_comp,:) - s_e_mat(curind_comp(indtrans(ind_nextbehaves(otherbe(1)))),2); %gives time from onset of next action
                    indtrans2 = find(tse_off2(:,1) < timewindow & tse_on2(:,1) > 0); %transition from start of interaction to 5 s after offset, if none exist, then transition is to "no-interaction"          
                end
                
                
                if isempty(indtrans2) 
                    if ~nonext
                        numtransvec2(length(betypes)+1) = numtransvec2(length(betypes)+1)+1;
                        numtransvec2((length(betypes)+1)*2) = numtransvec2((length(betypes)+1)*2) + 1;
                    end                                       
                else
                    [ind_nextbehaves2, who_nextbehaves2] = find(rdb.be_who(curind_comp(indtrans2),:,index(sess)));
                   	selfbe2 = find(who_nextbehaves2 == who_curbehav_self);
                 	otherbe2 = find(who_nextbehaves2 ~= who_curbehav_self);
                    d = 0;
                	while ~isempty(selfbe2) & ~d%ADDED THIS FOR V3: CAN"T TRANSITION TO THE SAME STATE
                        index_on_numtrans_s2 = find(betypes == rdb.be_identcode(curind_comp(indtrans2(ind_nextbehaves2(selfbe2(1)))), index(sess)));
                        if isempty(index_on_numtrans_s) %added this because ran into error where sometimes there's an empty on the first cycle but non-empty on the next. When that happens the conditional below breaks. May want to check it at some point...
                            idprev = index_on_numtrans_s;
                        else
                            indprev = i;
                        end
                        if index_on_numtrans_s2 ~= index_on_numtrans_s                     
                            numtransvec2(index_on_numtrans_s2) = numtransvec2(index_on_numtrans_s2) +1;
                            d =1;
                        else 
                            selfbe2 = selfbe2(2:end);
                        end
                    end
                    if isempty(selfbe2) & ~nonext
                        numtransvec2(length(betypes)+1) = numtransvec2(length(betypes)+1)+1;
                    end
                    d = 0;
                	while ~isempty(otherbe2) & ~d %ADDED THIS FOR V3: CAN"T TRANSITION TO THE SAME STATE
                        index_on_numtrans_o2 = find(betypes == rdb.be_identcode(curind_comp(indtrans2(ind_nextbehaves2(otherbe2(1)))), index(sess)));
                        if index_on_numtrans_o2 ~= index_on_numtrans_o                    
                            numtransvec2(index_on_numtrans_o2 + length(betypes)+1) = numtransvec2(index_on_numtrans_o2 + length(betypes)+1) +1;
                            d = 1;
                        else 
                            otherbe2 = otherbe2(2:end);
                        end
                    end
                    if isempty(otherbe2) & ~nonext
                        numtransvec2(2*(length(betypes)+1)) = numtransvec2(2*(length(betypes)+1))+1;
                    end      
                end              
            end            
        end
        numtransvec = numtransvec/length(curind_ref); %worth noting that we are not normalizing the probabillty by baseline probability that the next event will take place. 
        TM(i,:,sess) = numtransvec;
        if nargout > 1
            numtransvec2 = numtransvec2/length(curind_ref);
            TM2(i,:,sess) = numtransvec2;
        end        
    end
    if nargout > 2
        sesstime = rdb.sessionstart_end(sess,2)-rdb.sessionstart_end(sess,1);
        timebehave = nan(1,length(betypes)+1);
        for p = 1:length(betypes)
            timebehave(p) = nansum(s_e_mat(typeinds{p},2)-s_e_mat(typeinds{p},1))./sesstime;
        end
        timebehave(length(betypes)+1) = (sesstime - nansum(s_e_mat(beinds,2)-s_e_mat(beinds,1)))/sesstime;
        TMc(:,:,sess) =  repmat(timebehave,length(betypes),2);
    end
    
    
%     if normprob
%        	sesstime = rdb.sessionstart_end(index(sess),2)-rdb.sessionstart_end(index(sess),1);
%         for i = 1:length(betypes)
%            timebehave = nansum(s_e_mat(typeinds{i},2)-s_e_mat(typeinds{i},1));
%            probbehave = timebehave/sesstime; %likelihood of a behavior, relative to other or non-behaviors
%            TM(:,i) = TM(:,i)/probbehave; %don't need to 
%            TM(:,i + length(betypes)+1) = TM(:,i + length(betypes)+1)/probbehave; %again for other's interactions           
%         end
%         numallbehavs = length(beinds);
%         proballbehave = numallbehavs/sesstime;
%         proballbehave_timewindow = proballbehave * 
%         
%     end    
    
end