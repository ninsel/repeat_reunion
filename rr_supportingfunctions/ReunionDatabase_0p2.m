function rdb = ReunionDatabase_CCSS()
% RRdb = ReunionDatabase_CCSS()
%
% puts all of the reunion data into a single database
%
% dependencies: 
%   - FindFiles.m
%   - ProcessBORIS.m
%
%
% the following excel spreadsheets should be available in the local
% directory:
%
% repeatreaunionall.xlsx
% Additionally, all of the BORIS eventsXXXXX.csv 
% NOTE: Both of the above should be located in the same directory
%
% Each element of the RRdb struct is a session. 
%  Fields are as follows:
%    First, basic degu info:
%       - deguA (the code number, e.g., 020201)
%       - deguB 
%       - sex
%       - date_session (this is a 3-element vector of year, month, day)
%       - exposurenum (the number of times that particular pair has seen
%                      one-another)
%       - stranger (1 for stranger, 0 for cagemates)
%       - age
%       - weight
%       - BORIS_filename
%       - startends
%
%    Here, the raw data (n = number of sessions)
%       - be_start_end 200 x 2 vector of times, start vs. end
%       - be_ident 200 x 1 vector of behavior identities
%       - be_who 200 x 2 vector of which degu (0 1, 1 0, 1 1) engaged in
%       action
%       - sl_start_end (200 x 2 vector)
%       - sl_ident (200 length cell array of syllable identities)
%    
%
% nei  12/18
%

global spreadsheetfilename
global pathname

%first let's define a few variables that will be used later

[posnegbehave, voctypes] = loadBehavTypes();


%NEXT: GETTING ALL OF THE INFORMATION FOR EACH PAIR AND SESSION
% load the excel spreadsheet with this info

%where is the folder? Ask user to select a folder

if isempty(spreadsheetfilename) | isempty(pathname)
    [spreadsheetfilename, pathname] = uigetfile({'*.xlsx' ; '*ods'}, 'Spreadsheet with all sessions');
end

[~,~,allsess]=xlsread([pathname spreadsheetfilename]);

allsess = allsess(2:end,:);

% Now let's initiate the struct, the fields will have as many elements as
% there are rows in our excel file

deguA_col = 4;
deguB_col = 5;
sex_col = 8;
date_col = 3;
exposure_col = 9;
strangercode_col = 7;
strangernum_col = 10;
filename_col = 12;
origfilename_col = 13;
datescored_col = 16;
scorer_col = 17;
condition_col = 6;

for i = 1:size(allsess,1)
    ss_ind(i) = length(allsess{i,scorer_col}) < 5 & ischar(allsess{i,scorer_col}); 
end


allsess = allsess(ss_ind,:);


rdb = struct();
rdb.deguA = [allsess{:,deguA_col}]';
rdb.deguB = [allsess{:,deguB_col}]';
alldegupairsaligned = sort([rdb.deguA rdb.deguB]')';
[c, ia, ic] = unique(alldegupairsaligned, 'rows');
rdb.paircode = ic; 
rdb.sex = allsess(:,sex_col);
pds = datevec(allsess(:,date_col));
rdb.date_session = pds(:,1:3);
rdb.exposurenum = [allsess{:,exposure_col}];
rdb.strangernum = [allsess{:,strangercode_col}]';
rdb.strangercode = [allsess{:,strangernum_col}]';
rdb.filename = allsess(:,filename_col);
rdb.origfilename = allsess(:,origfilename_col);
preds = datevec(allsess(:,datescored_col));
rdb.datescored = preds(:,1:3);
rdb.scorer = allsess(:,scorer_col);
rdb.condition = allsess(:,condition_col);

% age and weight, we decided to keep this info in a separate spreadsheet
%this is the "DeguReunion_Weight_Age.xlsx" spreadsheet. If you change the
%name, change the code!

try
    weights_ages = xlsread([pathname 'DeguReunion_Weight_Age_20200715.xlsx']);
catch
    try
        weights_ages = xlsread([pathname 'DeguReunion_Weight_Age.ods']);
    catch
        warning('No file for the weights and ages');
        weights_ages = [];
    end
end

agecolumn = 3;
weightcolumn = 2;

if ~isempty(weights_ages)
for i = 1:length(rdb.deguA)
    dA = rdb.deguA(i);
    dB = rdb.deguB(i);
    dAind = find(weights_ages(:,1) == dA);
    dBind = find(weights_ages(:,1) == dB);
    if ~isempty(dAind)
        rdb.age(i,1) = weights_ages(dAind,agecolumn);
        rdb.weight(i,1) = weights_ages(dAind, agecolumn);
    end
    if ~isempty(dBind)
        rdb.age(i,2) = weights_ages(dBind,agecolumn);
        rdb.weight(i,1) = weights_ages(dBind, agecolumn);
    end
end
end

% NEXT:
%now we get into the fun stuff: the actual BORIS data spreadsheets. 
% First we need to find which spreadsheet goes to each session
% Next we will load each spreadsheet in turn, and then use our code to
% convert the start and end times for each behavior into our matlab struct
% format
 

%alleventfiles = FindFiles('*Events*', 'StartingDirectory', pathname);

alleventfiles = FindFiles('*.csv', 'StartingDirectory', pathname);

if isempty(alleventfiles)
    alleventfiles = FindFiles('*.xlsx', 'StartingDirectory', pathname);
end


% here we are going to loop through each of the event files in our
% YDRIVE\degu_reunion directory and create a list of the dates, degu1, and
% degu2 names that we can then search through later.


alleventfiles_filenames = cell(size(alleventfiles));

for i = 1:length(alleventfiles)
    curfile = alleventfiles{i};
    splitfilefromdir = strsplit(curfile, '\');
    curfile = splitfilefromdir{end};
    curfilesplit = strsplit(curfile, '.');
    filewithoutextension = curfilesplit{1};
    if length(filewithoutextension) > 6
        if strcmpi(filewithoutextension(1:6), 'Events')
            alleventfiles_filenames{i} = filewithoutextension(8:end);
        else
            alleventfiles_filenames{i} = filewithoutextension(1:end);
        end
    else
        alleventfiles_filenames{i} = filewithoutextension(1:end);
    end
end

% now we want to walk through the rdb struct one by one and find the
% associated file


rdb.be_start_end = nan(1000,2,length(rdb.deguA));
rdb.be_identcode = nan(1000,length(rdb.deguA));
rdb.be_who = nan(1000, 2, length(rdb.deguA));
rdb.be_ident = cell(1000,length(rdb.deguA));
rdb.sessionstart_end = nan(length(rdb.deguA),2);


for i = 1:length(rdb.deguA)
    % here, use the "find" command to search for the alleventsfiles_filenames
    % that corresponds to the filename you are using
    if ~ischar(rdb.filename{i})
        rdb.filename{i} = num2str(rdb.filename{i});
    end
    indallevents = find(strcmpi(rdb.filename{i}, alleventfiles_filenames));
    
    %added next line because sometimes the events file is in the original
    %filename, not the blinded filename
    if isempty(indallevents)
        indallevents = find(strcmpi(rdb.origfilename{i}, alleventfiles_filenames));
    end
    
    
    if ~isempty(indallevents)
        curfile = alleventfiles{indallevents(1)};
       
        %Now you have identified the file that you want to load and process.
        %Use processBORIS on that file

            [be_start_end, be_identcode, be_who, be_ident, sess_se] = processBORIS(curfile, posnegbehave);

        if size(be_who,2) == 4
            be_who(:,1) = max([be_who(:,1) be_who(:,3)], [], 2);
            be_who(:,2) = max([be_who(:,2) be_who(:,4)], [], 2);
            be_who = be_who(:,1:2);
        elseif size(be_who,2) == 3
            be_who = be_who(:,1:2);
        end

      	if isempty(be_start_end)
            dbs = 1;
        end
        % reminder that you already have a "posnegbehave" object that you
        % created by calling this function--a function that you can find at the
        % end of this page: [posnegbehave, voctypes] = loadBehavTypes();
        
        rdb.be_start_end(1:size(be_start_end,1), :, i) = be_start_end;
        rdb.be_identcode(1:length(be_ident), i) = be_identcode;
        rdb.be_who(1:length(be_who), :, i) = be_who;
        rdb.be_ident(1:length(be_ident),i) = be_ident;
        rdb.sessionstart_end(i,:) = sess_se;
    else
        dbs = 1;
    end
    
end



end
  





    
    







function [posnegbehave, voctypes] = loadBehavTypes()

% Face to face
% Butt sniffing
% Marking
% Inactive 
% Boxing
% Wrestling
% Biting 
% Grooming 
% Huddling
% Rear push 
% Mounting
% Misc.
% Avoid
% Tail Shaking
% Sniffing
% Tail sniffing

posnegbehave = containers.Map({...
    'face to face'...
    'butt sniffing'...
    'marking'...
    'inactive'...
    'boxing'...
    'wrestling'...
    'biting'...
    'grooming'...
    'huddling'...
    'rear push'...
    'mounting'...
    'misc.'...
    'avoid'...
    'tail shaking'...
    'sniffing'...
    'start'...
    'stop'...
    'tail sniffing'},...
    {3 2 -1.2 0 -1.5 -1.7 -1.3 1 4 -1.1 -1.0 0 -2 -1.6 5 98 99 2});

voctypes = {...
    'whistle'...
    'pain'...
    'bark'...
    'chaff'...
    'chirp'...   
    'chitter'...
    'groan'...
    'groan/unknown'...
    'grunt'...
    'high freq chirp'...
    'high freq loud whistle'...
    'high freq squeal'...
    'high freq warble'...
    'long whine'...
    'loud whine'...
    'loud whistle'...  
    'low freq'...
    'low freq whistle'...
    'low warble'...
    'low whine'...
    'low whistle'...          
    'pain squeak'   ... 
    'pip'...
    'squeak'...
    'squeal'...
    'squeal pain'...
    'tweet'    ...
    'unknown'    ...
    'warble'...
    'wheep'...
    'whine'...
    'whine/warble'...
    };

% voctypes = {...
%  1   'whistle';...
%  2   'pain';...
%  3   'bark';...
%  4   'chaff';...
%  5   'chirp';...   
%  6   'chitter';...
%  7   'groan';...
%  8   'groan/unknown';...
%  9   'grunt';...
%  10   'high freq chirp';...
%  11   'high freq loud whistle';...
%  12   'high freq squeal';...
%  13   'high freq warble';...
%  14   'long whine';...
%  15   'loud whine';...
%  16   'loud whistle';...  
%  17   'low freq';...
%  18   'low freq whistle';...
%  19   'low warble';...
%  20   'low whine';...
%  21   'low whistle';...          
%  22   'pain squeak' ;  ... 
%  23   'pip';...
%  24   'squeak';...
%  25   'squeal';...
%  26   'squeal pain';...
%  27   'tweet';    ...
%  28   'unknown';    ...
%  29   'warble';...
%  30   'wheep';...
%  31   'whine';...
%  32   'whine/warble';...
%     };


%
end

