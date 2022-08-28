function [csum, csum_ht] = RR_mkcsums(rdb, betypes)
%[csum, h_cs, pt] = RR_mkcsums(rdb_rr, betypes, pt_time)
%
%generates the cumulative sum matrix and associated variables for
%interactions in a set of animals. 
%
%
% nei 7/20

csum = nan(length(rdb.paircode), 601);
csum_ht = nan(length(rdb.paircode),1);

for k = 1:length(rdb.paircode)
    curind = k;
    a_ind = find(ismember(rdb.be_identcode(:,curind), betypes));
    if ~isempty(a_ind)
        be_time = rdb.be_start_end(:,2,curind)-rdb.be_start_end(:,1,curind);
        be_zeros = zeros(size(be_time));
        timeandzeros = [be_zeros be_time];
        
        data_a = reshape(timeandzeros(a_ind,:)', 1, length(a_ind)*2);
        time_a = reshape(rdb.be_start_end(a_ind, :,curind)'-rdb.sessionstart_end(curind,1), 1, length(a_ind)*2);
        
        data_a = [0 cumsum(data_a) max(cumsum(data_a))];
        time_a = [0 time_a 2000];
        indnan = find(~isnan(time_a));
        data_a = data_a(indnan);
        time_a = time_a(indnan);
        
        t = timeseries(data_a, time_a);
        rt = resample(t, [0:2:1200]);
        vrt = squeeze(rt.Data)';
        
        csum(k,:) = vrt;
        if max(vrt) > 0
            hs = find(vrt > max(vrt)/2);
            csum_ht(k) = hs(1) * 2; % multiply by 2 because bin size is 2 seconds
        end
    end
end