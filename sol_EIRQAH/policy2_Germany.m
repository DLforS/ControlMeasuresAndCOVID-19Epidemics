function [pol1, pol2] = policy2_Germany()
%% Description 
%  Germany
%  Disturbance parameter after fitting
%% Raw parameters
alpha = 10^(-1.3622);
beta = 1;
gamma = 1/2.3;
delta = 10^(-0.76232);
lambda = 10^(-0.97268);
kappa = 10^(-2.2591);
E0=69.985;
I0=69.9708;
R0 = 0;
Q0 = 0;
D0 = 0;
S0 = 65273512;

params_fix = [alpha  beta  gamma delta lambda kappa E0 I0 R0 Q0 D0];
[pol1, pol2] = out_feature(params_fix, S0);