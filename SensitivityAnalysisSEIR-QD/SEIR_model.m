function [soln,beta,gamma,delta,ts] = SEIR_model(par,ti,dt)
% par: 6-dim
% 1	E0	%	=	par(	1	);
% 2	I0	%	=	par(	2	);
% 3	R0	%	=	par(	3	);
% 4	beta	%	=	par(	4	);
% 5	gamma	%	=	par(	5	);
% 6	delta	%	=	par(	6	);
% 7	N(population)	%	=	par(	7	);
% Initial values are not known.

% Time interval
t0 = ti(1);
t1 = ti(2);

% Population
N	=	par(7);

% Initial values
S0 = N;
E0 = par(1);
I0 = par(2);
R0 = par(3);



% Time interval
ts = min(ti);

% Dynamical parameters

beta = par(4);
gamma = par(5);
delta = par(6);


tf = floor((t1-t0)/dt)+1;
S0(tf,1) = nan;
E0(tf,1) = nan;
I0(tf,1) = nan;
R0(tf,1) = nan;
ts(tf,1) = nan;
    
    
for t = 1:tf-1
    func1 = [-beta*S0(t)*I0(t)/N;
        +beta*S0(t)*I0(t)/N-gamma*E0(t);
        +gamma*E0(t)-delta*I0(t);
        +delta*I0(t)];
    S0(t+1,1) = S0(t)+func1(1)*dt;
    E0(t+1,1) = E0(t)+func1(2)*dt;
    I0(t+1,1) = I0(t)+func1(3)*dt;
    R0(t+1,1) = R0(t)+func1(4)*dt;
    ts(t+1,1) = ts(t,1)+dt;
end;

soln = [ts,S0,E0,I0,R0];


end