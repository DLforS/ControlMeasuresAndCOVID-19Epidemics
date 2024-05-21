clear all;clear;close all;clc;

load('results-SERIQD-from-cluster.mat');
[num_countries,num_trials,len_par] = size(optimal_parameters);

dir0 = '../dst-data-1000-fittings-20230804/sim-SEIR-QD-model/';
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
'D100/N',
'Half_time',
'Lag_time',
'Spreading_rate',
'loss',
'real_Q100/N',
'real_R100/N',
'real_D100/N',
'real_Half_time',
'real_Lag_time',
'real_Spreading_rate'
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
    data_to_export(num_trials,length(para_symbols)) = 0;
    country = countries{i}
    

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

    real_dynamical_quantities = [Q100;R100;D100;half_time;lag_time;spreading_rate];

    idx100d = nan;

    sim_acc0 = [];
    sim_acc1 = [];

    Q100 = [];
    R100 = [];
    D100 = [];

    t1 = [];
    idx50 = nan;
    idx05 = nan;
    half_time = [];
    lag_time = [];
    spreading_rate = [];

    % Initialize solns

    dt = 0.5;
    [solns,x,x,x,x,x,x,x] = SEIRPQ_model(rand(100,1),[0 110],dt);
    solns(num_trials,1) = 0;


    
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
        % par1 = [E0;I0;Q0;R0;D0;alpha;beta;gamma;delta;lambda;kappa;population];

        %% Calculate simulated quantities
        dt = 0.5;
        [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = ...
            SEIRPQ_model(par,[0 110],dt);
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

        Q100 = sim_acc0(idx100d)/population;
        R100 = Rt(idx100d)/population;
        D100 = Dt(idx100d)/population;

        % the half time (days required for reaching one half of the cumulative number of quarantined cases on the 100th day), 
        % the lag time (days required for reaching 5% of the cumulative number of quarantined cases on the 100th day), 
        % and the apparent spreading rate (the slope of the curve for the number of confirmed cases at the half time).
        t1 = t - min(t);
        idx50 = find(sim_acc1>=0.5*sim_acc1(idx100d),1);
        idx05 = find(sim_acc1>=0.05*sim_acc1(idx100d),1);
        half_time = t1(idx50);
        lag_time = t1(idx05);
        spreading_rate = diff(sim_acc1([idx50-1 idx50+1]))/diff(t([idx50-1,idx50+1]));

        sim_quantities = [Q100,R100,D100,half_time,lag_time,spreading_rate];


        %% Calculate erros
        ind = find(ts==floor(ts));
        m = min([105,length(real_t)]);
        ind = ind(1:m);
        ind1 = 1:m;
        
        t = soln(ind,1);
   
        % soln = [ts,S0,E0,I0,Q0,R0,D0];
        daily_new = delta*soln(ind,4);
        new_cure = lambda*soln(ind,5);
        new_death = kappa*soln(ind,5);
        acc = sum(soln(ind,5:7),2);
        acc_death = soln(ind,7);
        acc_cure = soln(ind,6);
        
        
        % real_data: [t,acc_conm,acc_death,acc_cure,daily_conm,daily_death,daily_cure];
        % real_t = real_data(:,1);
        real_daily_new = real_data(ind1,5);
        real_acc = real_data(ind1,2);
        real_death = real_data(ind1,6);
        real_cure = real_data(ind1,7);
        real_death_acc = real_data(ind1,3);
        real_cure_acc = real_data(ind1,4);
        
        
        err1 = daily_new-real_daily_new;
        err2 = new_cure-real_cure;
        err3 = new_death-real_death;
        err4 = acc-real_acc;
        err5 = acc_death-real_death_acc;
        err6 = acc_cure-real_cure_acc;
        
        err1 = err1*10;
        err3 = err3*150;
        err2 = err2*20;
        err5 = err5*10;
        % max([err1,err2,err3,err4]);
        
        
        err = [err1;err2;err3;err4;err5;err6];
        err = err(find(~isnan(err)));

        loss = mean(abs(err(:)));

        %% Store data
        
        data_to_export(j,:) = [par(:);sim_quantities(:);loss;real_dynamical_quantities(:)];
        
    end;

    tbl_parameters = array2table(data_to_export,...
        'RowNames',string(1:size(data_to_export,1)),...
        'VariableNames',para_symbols);

    writetable(tbl_parameters,[dir0,country,'-paramters.xlsx'],...
        'WriteRowNames',true);

end;

delete(pool);