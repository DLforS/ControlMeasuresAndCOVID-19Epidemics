clear;clear all;close all;clc;



load('results-SERIQD-from-cluster.mat');
[num_countries,num_trials,len_par] = size(optimal_parameters);

policies = readtable('../政策指标得分+四个国家拟合参数/各国政策指标得分-with-cn-names.xlsx',...
    'VariableNamingRule','preserve');

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
'D100/N',
'Half_time',
'Lag_time',
'Spreading_rate'
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


policy_country_name = policies.('name_cn');
for i = 1:num_countries
    country = countries{i}

    par = optimal_parameters(i,1,:);
    population = par( 12 );

    param = [];
    for j = 1:len_par
        param(j) = mean(optimal_parameters(i,:,j));
    end;
    
    dir1 = '../src-data/epi/';
    file_path = [dir1 country '.csv'];
    [real_data,population,cols] = read_data(file_path,'length',125,'cases',100,...
        'stopcases',0,'minimalcases',300);

    real_t = real_data(:,1);
    real_daily_new = real_data(:,5);
    real_acc = real_data(:,2);
    real_death = real_data(:,6);
    real_cure = real_data(:,7);
    real_death_acc = real_data(:,3);
    real_cure_acc = real_data(:,4);

    idx100d = 100;

    countries_to_write{i} = country;
    
    Q100 = mean(real_acc(idx100d-1:idx100d+1))/population;
    R100 = mean(real_cure_acc(idx100d-1:idx100d+1))/population;
    D100 = mean(real_death_acc(idx100d-1:idx100d+1))/population;

    idx50 = find(real_acc-real_acc(1)>=0.5*(Q100*population-real_acc(1)),1);
    idx05 = find(real_acc-real_acc(1)>=0.05*(Q100*population-real_acc(1)),1);
    half_time = real_t(idx50)-real_t(1);
    lag_time = real_t(idx05)-real_t(1);
    x = real_t(idx50-3:idx50+3);
    y = real_acc(idx50-3:idx50+3);
    p = polyfit(x,y,1);
    spreading_rate = p(1);

    record0(i,:) = [param(:);Q100;R100;D100;half_time;lag_time;spreading_rate];


    [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = ...
            SEIRPQ_model(param,[0 110],dt);
    t = soln(:,1);
    St = soln(:,2);
    Et = soln(:,3);
    It = soln(:,4);
    Qt = soln(:,5);
    Rt = soln(:,6);
    Dt = soln(:,7);

    idx100d = find(t==min(t)+100);

    sim_acc0 = Qt+Rt+Dt;
    sim_acc1 = sim_acc0 - sim_acc0(1);

    simQ100 = sim_acc0(idx100d)/population;
    simR100 = Rt(idx100d)/population;
    simD100 = Dt(idx100d)/population;

    t1 = t - min(t);
    idx50 = find(sim_acc1>=0.5*sim_acc1(idx100d),1);
    idx05 = find(sim_acc1>=0.05*sim_acc1(idx100d),1);
    sim_half_time = t1(idx50);
    sim_lag_time = t1(idx05);
    sim_spreading_rate = diff(sim_acc1([idx50-1 idx50+1]))/diff(t([idx50-1,idx50+1]));

    sim_data(i,:) = [simQ100;simR100;simD100;sim_half_time;sim_lag_time;sim_spreading_rate];



    

end;
tbl_parameters = array2table(record0,'RowNames',countries_to_write,...
    'VariableNames',para_symbols);

writetable(tbl_parameters,['../zhongjiecanshu20230807/m_t-中介参数.xlsx'],...
    'WriteRowNames',true,'WriteMode','overwritesheet');
