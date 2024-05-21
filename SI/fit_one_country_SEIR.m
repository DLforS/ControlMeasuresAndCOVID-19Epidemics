function [opt_par,soln,flag] = fit_one_country_SEIR(country,data,population,cols,varargin)
% Fixed lambda
% Lambda and 
% 
% 

% Extract columns
real_t = data(:,1);
real_acc = data(:,2);
acc_death = data(:,3);
acc_cure = data(:,4);
real_daily_new = data(:,5);
real_death = data(:,6);
real_cure = data(:,7);


%% Normalization
mint = min(real_t);
real_t = real_t - mint;

[tf,lu,c] = isoutlier(real_daily_new,'movmean',15);
ind = find(tf);
real_daily_new(ind) = nan;

[tf,lu,c] = isoutlier(real_death,'movmean',15);
ind = find(tf);
real_death(ind) = nan;

[tf,lu,c] = isoutlier(real_cure,'movmean',15);
ind = find(tf);
real_cure(ind) = nan;

%% Construct real data
real_data = data;

%% Set parameters
N = population;

lambda0 = nanmean(real_cure./(real_acc-acc_cure-acc_death));
gamma0 = 0.5;
kappa0 = nanmean(real_death./(real_acc-acc_cure-acc_death));
if isinf(kappa0)
    kappa0 = 0.1;
end;
if isinf(lambda0) | lambda0 == 0
    lambda0 = 0.04;
end;
par = [
    100+600*rand(1)	10	inf	;	%	E0
    100+800*rand(1)	10	inf	;	%	I0
    1	0	10	;	%	R0
    0.5	0	1	;	%	beta
    0.1	0	1	;	%	gamma
    0.01	0	1	;	%	delta
    N	N	N	;	%	N(population)
    ];

ti = [min(real_t) max(real_t)];
dt = 0.5;

[opt_par,err] = fit_epi(par,real_data,dt);

[soln,beta,gamma,delta,ts] = SEIR_model(opt_par,ti,dt);

soln(:,1) = soln(:,1) + mint;

flag = 1;

end





function [opt_par,err] = fit_epi(par,real_data,dt)
% [opt_par,err,soln] = fit_epi(par,real_data,dt)
% par: initial values or fixed values for all parameters. 
% n rows, 3 columns
% 
% dt is the time step in solving ODE. dt = 0.5 by default.
%
% soln is the trajectory of best fitted parameters.
% soln = [t,S,E,I,Q,R,D]
% 
% 

real_t = real_data(:,1);
tinv = [min(real_t);ceil(max(real_t))];

% ind1 = find(temp1==0);
ind = find(std(par,0,2)~=0);

par_all = par(:,1);

fun = @(x) obj_fun(x,par_all,ind,tinv,dt,real_data);
init_par = par(ind,1);
lb = par(ind,2);
ub = par(ind,3);
options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',1e6,...
    'FunctionTolerance',1e-6,'MaxIterations',1000,...
    'FiniteDifferenceType', 'central',...
    'display','off');

[x,resnorm,err,exitflag,output,lambda,jacobian] = lsqnonlin(fun,init_par,lb,ub,options);

opt_par = par_all;
opt_par(ind) = x;

% [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(opt_par,tinv,dt);


end

function err = obj_fun(par_fit,par_all,index,ti,dt,real_data)

par = par_all+1-1;
par(index) = par_fit;

[soln,beta,gamma,delta,ts] = SEIR_model(par,ti,dt);

ind = find(ts==floor(ts));

t = soln(ind,1);

% soln = [ts,S0,E0,I0,R0];

daily_new = gamma*soln(ind,3);
new_removed = delta*soln(ind,4);
acc = sum(soln(ind,4:5),2);

% real_data: [t,acc_conm,acc_death,acc_cure,daily_conm,daily_death,daily_cure];

real_daily_new = real_data(:,5);
real_acc = real_data(:,2);
real_death = real_data(:,6);
real_cure = real_data(:,7);
real_removed = real_death+real_cure;

err1 = daily_new-real_daily_new;
err2 = new_removed-real_removed;
err3 = acc-real_acc;
err4 = 0;

err1 = 0*err1*10;
err3 = err3;
err2 = 0*err2*5;
% max([err1,err2,err3,err4]);


err = [err1(:);err2(:);err3(:);err4(:)];
err = err(find(~isnan(err)));

end





