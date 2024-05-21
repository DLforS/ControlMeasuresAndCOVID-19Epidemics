% Change the name of the country at line 20 to fit each individual country

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
file = '美国.csv';

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


[opt_par,soln,flag] = fit_one_country_SEIRQD(country,data,population,cols);
par = opt_par;
E0 = par(1);
I0 = par(2);
Q0 = par(3);
R0 = par(4);
D0 = par(5);
alpha = par(6);
beta = par(7);
gamma = par(8);
delta = par(9);
lambda = par(10);
kappa = par(11);
population = par( 12 );

par1 = [E0;I0;Q0;R0;D0;alpha;beta;gamma;delta;lambda;kappa;population];

real_t = data(:,1);
real_daily_new = data(:,5);
real_acc = data(:,2);
real_death = data(:,6);
real_cure = data(:,7);
real_death_acc = data(:,3);
real_cure_acc = data(:,4);

dt = 1;
[soln,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par1,[min(real_t),min(real_t)+120],dt);


t = soln(:,1);
St = soln(:,2);
Et = soln(:,3);
It = soln(:,4);
Qt = soln(:,5);
Rt = soln(:,6);
Dt = soln(:,7);

acc = Qt+Rt+Dt;



figure;
            
subplot(2,2,1);
hold on;
plot(t(1:end-1),diff(acc),real_t,real_daily_new,'k--');
box on;
title([country ' Daily new']);

subplot(2,2,2);
hold on;
plot(t,acc);
plot(real_t,real_acc,'k--');
box on;
title(['Accumulative alpha=' num2str(alpha)]);


subplot(2,2,3);
hold on;
plot(t,Rt,real_t,real_cure_acc,'k--');
box on;
title('Cured');


subplot(2,2,4);
hold on;
plot(t,Dt,real_t,real_death_acc,'k--');
box on;
title('Death');
