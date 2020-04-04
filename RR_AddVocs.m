function rdb = RR_AddVocs(rdb, infolder)
%rdb = RR_AddVocs(rdb, infolder)
%
%adds vocalization information to the rdb_rr struct
%created by ReunionDatabase_0p2.  
%
% if input infolder is not provided, user is asked to select
%
% nei 10/19
%

if nargin < 2
    infolder = uigetdir([], 'Select folder containing Raven text files');
end

allaudio = FindFiles('*.txt', 'StartingDirectory', infolder);

rdb.voc_start_end = nan(500,2, length(rdb.deguA));
rdb.voc_lowfreq_highfreq = nan(500,2, length(rdb.deguA));
rdb.voc_amp_dbfs = nan(500,1, length(rdb.deguA));
rdb.vtype_manscored = cell(500,1, length(rdb.deguA));



for i = 1:length(allaudio)
    curfile = allaudio{i};
    cf_split = split(curfile, '\');
    curfilefileonly = cf_split{end}(1:end-4);
    curind = find(strcmpi(curfilefileonly, rdb.origfilename));
    if isempty(curind) %some of the degu numbers in the filenames were rearranged (ugh!) so let's try this the long way...)
       splitfilename = split(curfilefileonly, '_');       
       newfilename = [splitfilename{1} '_' splitfilename{3} '_' splitfilename{2} '_' splitfilename{4}];             
        curind = find(strcmpi(newfilename, rdb.origfilename));
    end
%    g = importdata(allaudio{i}); %This turns out not to work on all of hte
%    files (depends on which newline/carriage return is used
    g = readtable(allaudio{i});
    audiodata_c = table2cell(g);
    if ~isempty(audiodata_c) & ~isempty(curind)
        audiodata_c = audiodata_c(2:2:end,:);
        bt = [audiodata_c{:,4}]';
        et = [audiodata_c{:,5}]';
        lf = [audiodata_c{:,6}]';
        hf = [audiodata_c{:,7}]';
        apd = [audiodata_c{:,10}]';
        vtype = audiodata_c(:,11);
        rdb.voc_start_end(1:length(bt), 1:2, curind) = [bt et];
        rdb.voc_lowfreq_highfreq(1:length(bt), 1:2, curind) = [lf hf];
        rdb.voc_amp_dbfs(1:length(bt), 1, curind) = apd;
        rdb.vtype_manscored(1:length(bt), 1, curind) = vtype;
    elseif isempty(curind)
        warning('no filename for %s', curfilefileonly);
    elseif ~isstruct(g)
        rdb.voc_start_end(1, 1:2, curind) = [0 0];
        rdb.voc_lowfreq_highfreq(1, 1:2, curind) = [0 0];
        rdb.voc_amp_dbfs(1, 1, curind) = 0;
    end
end