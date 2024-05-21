function [data,population,cols] = read_data(file,varargin)
% file = /Users/zhuge/Documents/2019-nCoV/data/github/countries
% [data,population] = read_github_data(file,name,value)
% name, value options:
% length: length of data in days.
% cases: starting point (accumulative cases)
% 'stopcases' creterion of stop of the first wave.
%      Unit: cases per million population.
% 'minimalcases' minimal cases considered as effective. 
%      Less cases than the threshold will be dropped.
% 

tf = 120;
threshold = 100;
stopcases = inf;
cols = {};

for i = 1:2:length(varargin)
    if strcmp(varargin{i}, 'length')
        tf = varargin{i+1};
    elseif strcmp(varargin{i}, 'cases')
        threshold = varargin{i+1};
    elseif strcmp(varargin{i}, 'stopcases')
        stopcases = varargin{i+1};
    elseif strcmp(varargin{i}, 'minimalcases')
        minimalcases = varargin{i+1};
    end;
end;

% range_str = ['B2:J' num2str(tf+1)];
a = readmatrix(file,'Range',[2,2]);
t = a(:,1);
acc_conm = a(:,2);
acc_death = a(:,3);
acc_cure = a(:,4);
daily_conm = a(:,6);
daily_death = a(:,5);
daily_cure = a(:,7);

t = a(:,1);

population = a(1,10);
stopcases = stopcases/population*1e6;
if max(acc_conm)<minimalcases
    data = max(acc_conm);
    return;
end;

data = [t,acc_conm,acc_death,acc_cure,daily_conm,daily_death,daily_cure];
cols = {'t','acc conm','acc death','acc cure','daily conm','daily death','daily cure'};



ind = find(acc_conm>=threshold);
if length(ind)>=tf
    ind = ind(1:tf);
else
    warning([file, 'epidemics is short']);
end;

data = data(ind,:);

if ~isinf(stopcases)
    x = (data(:,5)<stopcases);
    y = (movsum(x(30:end),[6,1])>=7);
    i = find(y,1)+30;
    if length(i)~=0
        i = max([80;i(:)]);
        data = data(1:i,:);
    end;
end;

end


