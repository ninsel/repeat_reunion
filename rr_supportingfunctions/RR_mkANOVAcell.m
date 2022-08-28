function anovacell = RR_mkANOVAcell(condmat, indgroupscell, igc2)
%anovacell = RR_mkANOVAcell(condmat, indgroupscell, igc2)
%
% makes a cell array with data for a 2 way anova
%
% condmat is an matrix of observations x factor1 x factor2
% indgroupscell is a cell array of how observations should be grouped
% (usually 2 groups), or a vector list of group membership codes.
%
% 1st cell: the data (reshaped)
% 2nd cell: the rows
% 3rd cell: the row groups
% 4th cell: the columns
%
% nei 10/19
%

if nargin < 2
    indgroupscell = [];
end

factor1 = nan(size(condmat,1),1);
if iscell(indgroupscell)
    for i = 1:length(indgroupscell)
        factor1(indgroupscell{i}) = i;
    end
else
    if size(indgroupscell,2) > 1
        indgroupscell = indgroupscell';
    end
    factor1 = indgroupscell;
end

if ~isempty(factor1)
    condmat = condmat(~isnan(factor1),:);
    factor1 = factor1(~isnan(factor1));
end
    
s1 = size(condmat,1);
s2 = size(condmat,2);

anovacell{1} = reshape(condmat, s1*s2, 1);
anovacell{2} = reshape(repmat([1:s1]', 1, s2), s1*s2, 1);

if ~isempty(factor1)
    anovacell{3} = reshape(repmat(factor1,1,s2), s1*s2, 1);
end
    anovacell{4} = reshape(repmat([1:s2], s1,1), s1*s2, 1);

if nargin > 2   
    factor2 = nan(size(condmat,1),1);
if iscell(igc2)
    for i = 1:length(igc2)
        factor2(igc2{i}) = i;
    end
else
    if size(indgroupscell,2) > 1
        igc2 = igc2';
    end
    factor2 = igc2;
end
    factor2 = factor2(~isnan(factor1));
    anovacell{5} = reshape(repmat(factor2, 1, s2), s1*s2, 1);
end
