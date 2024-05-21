clear all;clear;close all;clc;

load('results-SERIQD-from-cluster.mat');
[num_countries,num_trials,len_par] = size(optimal_parameters);

dir0 = '../dst-data-1000-fittings-20230804/SEIR-QD-model/';
if ~exist(dir0)
    mkdir(dir0);
end;


para_symbols = {'E0',
'I0',
'Q0',
'R0',
'D0',
'alpha',
'beta',
'gamma',
'delta',
'lambda',
'kappa',
'N(population)',
'Q100/N',
'R100/N',
'D100/N'
};

soln_symbols={
    't',
    'S',%t = soln(:,2);
    'E',%t = soln(:,3);
    'I',%t = soln(:,4);
    'Q',%t = soln(:,5);
    'R',%t = soln(:,6);
    'D'%t = soln(:,7);'
};

delete(gcp('nocreate'))
pool = parpool([1 100]);

for i = 1:floor(num_countries)
    data_to_export = 0;
    data_to_export(num_trials,len_par+3) = 0;
    country = countries{i}
    
    parfor j = 1:floor(num_trials)
        par = optimal_parameters(i,j,:);

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

        soln = optimal_solutions{i,j};

        t = soln(:,1);
        dt = 0.5
        [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = ...
            SEIRPQ_model(par,[min(t) max([max(t),min(t)+110])],dt);
        t = soln(:,1);
        St = soln(:,2);
        Et = soln(:,3);
        It = soln(:,4);
        Qt = soln(:,5);
        Rt = soln(:,6);
        Dt = soln(:,7);

        idx = find(t==min(t)+100);

        Q100 = Qt(idx)/population;
        R100 = Rt(idx)/population;
        D100 = Dt(idx)/population;

        data = real_data.(country){1};

        real_t = data(:,1);
        real_daily_new = data(:,5);
        real_acc = data(:,2);
        real_death = data(:,6);
        real_cure = data(:,7);

        data_to_export(j,:) = [par(:)',Q100,R100,D100];
        
    end;

    tbl_parameters = array2table(data_to_export,...
        'RowNames',string(1:size(data_to_export,1)),...
        'VariableNames',para_symbols);

    writetable(tbl_parameters,[dir0,country,'-paramters.xlsx'],...
        'WriteRowNames',true);

%     tbl_soln = array2table(soln,...
%         'RowNames',string(1:size(soln,1)),...
%         'VariableNames',soln_symbols);
% 
%     writetable(tbl_soln,[dir0,country,'-solutions.xlsx']);
end;

delete(pool);