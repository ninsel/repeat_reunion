function unionOfIntervalsMat = unionOfIntervals(intervalsMat)
%
%unionOfIntervalsMat = unionOfIntervals(intervalsMat) takes a set of
%(closed) intervals and returns the unions of those intervals.
%Each row of the input variable intervalsMat is an interval, with the first column 
%giving the lower bounds for the intervals and the second column giving the upper bounds.
%Each row of the output variable unionOfIntervalsMat is also an interval, defined similarly.
%
% taken from stack exchange on 4/2024 (Dan Bindman,
% https://www.mathworks.com/matlabcentral/answers/9141-union-and-interseciton-of-intervals)
%
%
if ~isempty(intervalsMat)
    intervalsMat=sortrows(intervalsMat,1);
nIntervals=size(intervalsMat,1);
unionOfIntervalsMat=zeros(size(intervalsMat));
unionOfIntervalsMat(1,:)=intervalsMat(1,:);
unionCount=1;
for i=2:nIntervals
    if intervalsMat(i,1) <= unionOfIntervalsMat(unionCount,2)
        unionOfIntervalsMat(unionCount,2)=max([intervalsMat(i,2) unionOfIntervalsMat(unionCount,2)]);
    else
        unionCount=unionCount+1;
        unionOfIntervalsMat(unionCount,:)=intervalsMat(i,:);
    end
end
unionOfIntervalsMat=unionOfIntervalsMat(1:unionCount,:);
else
    unionOfIntervalsMat = [];
end