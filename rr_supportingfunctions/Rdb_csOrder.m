function strorder_d = Rdb_csOrder(rdb_rr, degunums)
%strfirst = Rdb_strfirst(rdb, index)
%
% computes whether it was a stranger or cagemate first (1 or 0
% respectively)
%
%
% nei 11/21
%

ud = unique([rdb_rr.deguA ; rdb_rr.deguB]);

if nargin < 2
    index = 1:length(ud);
else
    index = find(ismember(ud, degunums));
end

dn_dates = datenum(rdb_rr.date_session);

strorder = nan(length(index),20);

for i = 1:length(index)
        deguinds = find((rdb_rr.deguA == ud(index(i)) | rdb_rr.deguB == ud(index(i))));
        [b, b_ind] = sort(dn_dates(deguinds));
        strnums = rdb_rr.strangernum(deguinds(b_ind));
        strorder(i, 1:length(strnums)) = strnums;
end

strorder_d = [ud(index) strorder];