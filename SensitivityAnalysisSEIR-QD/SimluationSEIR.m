clear all;clear;close all;clc;

load('results-SEIR.mat');
[num_countries,num_trials,len_par] = size(optimal_parameters);

dir0 = '../dst-data-1000-fittings-20230804/SEIR-model/';
if ~exist(dir0)
    mkdir(dir0);
end;


para_symbols = {'E0',
'I0',
'R0',
'beta',
'gamma',
'delta',
'N(population)',
'Q100/N (I)',
'R100/N',
'Half_time',
'Lag_time',
'Spreading_rate'
};

soln_symbols={
    't',
    'S',%t = soln(:,2);
    'E',%t = soln(:,3);
    'I',%t = soln(:,4);
    'R'%t = soln(:,5);
};

delete(gcp('nocreate'))
pool = parpool([1 100]);

for i = 1:floor(num_countries)
    data_to_export = 0;
    data_to_export(num_trials,length(para_symbols)) = 0;
    country = countries{i};
    i
    
    parfor j = 1:floor(num_trials)
        par = optimal_parameters(i,j,:);

        E0		=	par(	1	);
        I0		=	par(	2	);
        R0		=	par(	3	);
        beta		=	par(	4	);
        gamma		=	par(	5	);
        delta		=	par(	6	);
        population		=	par(	7	);

        soln = optimal_solutions{i,j};

        t = soln(:,1);
        dt = 0.5;
        [soln,beta,gamma,delta,ts] =...
            SEIR_model(par,[min(t),max([max(t),min(t)+110])],dt);
        t = soln(:,1);
        St = soln(:,2);
        Et = soln(:,3);
        It = soln(:,4);
        Rt = soln(:,5);

        idx100d = find(t==min(t)+100);

        sim_acc0 = It+Rt;
        sim_acc1 = sim_acc0 - sim_acc0(1);

        Q100 = sim_acc0(idx100d)/population;
        R100 = Rt(idx100d)/population;

        % the half time (days required for reaching one half of the cumulative number of quarantined cases on the 100th day), 
        % the lag time (days required for reaching 5% of the cumulative number of quarantined cases on the 100th day), 
        % and the apparent spreading rate (the slope of the curve for the number of confirmed cases at the half time).
        t1 = t - min(t);
        idx50 = find(sim_acc1>=0.5*sim_acc1(idx100d),1);
        idx05 = find(sim_acc1>=0.05*sim_acc1(idx100d),1);
        half_time = t1(idx50);
        lag_time = t1(idx05);
        spreading_rate = diff(sim_acc1([idx50-1 idx50+1]))/diff(t([idx50-1,idx50+1]));

        data_to_export(j,:) = [par(:)',Q100,R100,half_time,lag_time,spreading_rate];
        
    end;

    tbl_parameters = array2table(data_to_export,...
        'RowNames',string(1:size(data_to_export,1)),...
        'VariableNames',para_symbols);

    writetable(tbl_parameters,[dir0,country,'-paramters.xlsx'],...
        'WriteRowNames',true);

end;

delete(pool);