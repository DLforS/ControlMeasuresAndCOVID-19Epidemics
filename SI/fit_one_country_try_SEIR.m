clear;clc;close all;clear all;
format shortg;

paths = {'../src-data/epi/',['../dst-data-' datestr(now,'yyyy-mm-dd-HH-MM-SS') '/']};

path1 = paths{1};
path2 = paths{2};

files = dir(path1);
% if ~exist(path2)
%     mkdir(path2);
% end;

params = table();
solns = table();
real_data = table();
countries = {};
file = '圣马力诺.csv';

country = replace(file,'.csv','');
file_path = [path1 country '.csv'];

%% Read real data
[data,population,cols] = read_data(file_path,'length',95,'cases',100,...
    'stopcases',100,'minimalcases',300);

i = 1;
data(find(data<0)) = 0;

max_trial = 2;

countries = {country};

data0 = data;


[opt_par,soln,flag] = fit_one_country_SEIR(country,data,population,cols);

beta = opt_par(4);
gamma = opt_par(5);
delta = opt_par(6);


real_t = data(:,1);
real_daily_new = data(:,5);
real_acc = data(:,2);
real_death = data(:,6);
real_cure = data(:,7);

t = soln(:,1);
S0 = soln(:,2);
E0 = soln(:,3);
I0 = soln(:,4);
R0 = soln(:,5);

figure;
            
subplot(2,2,1);
hold on;
plot(t(1:end-1),diff(I0+R0),real_t,real_daily_new,'k--');
box on;
title([country ' Daily new']);

subplot(2,2,2);
hold on;
plot(t,I0+R0);
plot(real_t,real_acc,'k--');
box on;
title(['Accumulative beta=' num2str(beta)]);

