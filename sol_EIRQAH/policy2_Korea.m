function [pol1, pol2] = policy2_Korea()
%% Description 
%  South Korea
%  Disturbance parameter after fitting
%% Raw parameters
alpha = 10^(-1.0624);
beta = 1;
gamma = 1/3;
delta = 10^(-0.56652);
lambda = 10^(-1.4758);
kappa = 10^(-3.0724);
E0=136.0714;
I0=306.9586;
R0 = 0;
Q0 = 0;
D0 = 0;
S0 = 51269183;

params_fix = [alpha  beta  gamma delta lambda kappa E0 I0 R0 Q0 D0];
[pol1, pol2] = out_feature(params_fix, S0);
