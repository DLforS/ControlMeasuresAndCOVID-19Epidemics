function [y,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln,population)
% For SEIR-QD model
% [y,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln,population)
% y = [Q100,R100,D100,half_time,lag_time,spreading_rate];

t = soln(:,1);
t = t - t(1);
St = soln(:,2);
Et = soln(:,3);
It = soln(:,4);
Qt = soln(:,5);
Rt = soln(:,6);
Dt = soln(:,7);

idx100d = find(t>=min(t)+100,1);

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

y = [Q100,R100,D100,half_time,lag_time,spreading_rate];
end