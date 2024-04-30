function [pol1, pol2] = policy2_Mexico()
%% Description 
%  Mexico
%  Disturbance parameter after fitting
%% Raw parameters
alpha = 10^(-1.4613);
beta = 0.57607; %10^(-0.361);
gamma = 1/4.1641;
delta = 10^(-2.3642);
lambda = 10^(-0.8407);
kappa = 10^(-1.6099);
E0=100.186;
I0=69.6981;
R0 = 0;
Q0 = 0;
D0 = 0;
S0 = 128932753;

params_fix = [alpha  beta  gamma delta lambda kappa E0 I0 R0 Q0 D0];
[pol1, pol2] = out_feature(params_fix, S0);