function [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par,ti,dt)
% par: 12-dim
%	1	E0
%	2	I0
%	3	Q0
%	4	R0
%	5	D0
%	6	alpha
%	7	beta
%	8	gamma
%	9	delta
%	10	lambda
%	11	kappa
%	12	N(population)

% Time interval
t0 = ti(1);
t1 = ti(2);

% Population
N = par(12);

% Initial values
S0 = N;
E0 = par(1);
I0 = par(2);
Q0 = par(3);
R0 = par(4);
D0 = par(5);


% % Population
% N = par(12);
% % S0 = N;
% 
% % % Known initial values
% % S0 = par0(1);
% % Q0 = par0(2);
% % R0 = par0(3);
% % D0 = par0(4);

% Time interval

ts = min(ti);

% Dynamical parameters

alpha = par(6);
beta = par(7);
gamma = par(8);
delta = par(9);
lambda = par(10);
kappa = par(11);


tf = floor((t1-t0)/dt)+1;
S0(tf,1) = nan;
E0(tf,1) = nan;
I0(tf,1) = nan;
Q0(tf,1) = nan;
R0(tf,1) = nan;
D0(tf,1) = nan;
ts(tf,1) = nan;
    
    
for t = 1:tf-1
    func1 = [-beta*S0(t)*I0(t)/N-alpha*S0(t);
        +beta*S0(t)*I0(t)/N-gamma*E0(t);
        +gamma*E0(t)-delta*I0(t);
        +delta*I0(t)-lambda*Q0(t)-kappa*Q0(t);
        +lambda*Q0(t);
        +kappa*Q0(t)];
    S0(t+1,1) = S0(t)+func1(1)*dt;
    E0(t+1,1) = E0(t)+func1(2)*dt;
    I0(t+1,1) = I0(t)+func1(3)*dt;
    Q0(t+1,1) = Q0(t)+func1(4)*dt;
    R0(t+1,1) = R0(t)+func1(5)*dt;
    D0(t+1,1) = D0(t)+func1(6)*dt;
    ts(t+1,1) = ts(t,1)+dt;
end;

soln = [ts,S0,E0,I0,Q0,R0,D0];


end