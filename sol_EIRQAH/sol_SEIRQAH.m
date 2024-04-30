function outp = sol_SEIRQAH(params_to_fit,params_fixed,t_lim)
% [t,x] = sol_SEIRQAH(params_to_fit,params_fixed,t_lim)
% x: [S,E,I,R,Q,H];
% y: [newH newH];


% parameters
fit = params_to_fit;

alpha = fit(1);
beta = fit(2);
gamma = fit(3);
delta = fit(4);
lambda = fit(5);
kappa = fit(6);
E0=fit(7);
I0=fit(8);

S0 = params_fixed;
R0 = fit(9);
Q0 = fit(10);
D0 = fit(11);
N = S0;

t(1) = 0;
S(1) = S0; 
E(1) = E0;
I(1) = I0;
R(1) = R0;
Q(1) = Q0; 
D(1) = D0;

steps = t_lim(2) - t_lim(1);
for i=1:steps-1
	t(i+1,1) = t_lim(1) + i;
    S(i+1,1) = max(0,S(i) - beta*S(i)*I(i)/N - alpha*S(i));
    E(i+1,1) = max(0,E(i) + beta*S(i)*I(i)/N - gamma*E(i));
    I(i+1,1) = max(0,I(i) + gamma*E(i) - delta*I(i));
    Q(i+1,1) = max(0,Q(i) + delta*I(i) - lambda*Q(i) - kappa*Q(i));
    R(i+1,1) = max(0,R(i) + lambda*Q(i));
	D(i+1,1) = max(0,D(i) + kappa*Q(i)); 
end

x = [S,E,I,R,Q,D];
x(find(x<0)) = 0;

newR = [R(1,:); diff(R)];
newD = [D(1,:); diff(D)];

newQ = delta*I;
newQ = [Q(1,:); newQ(1:end-1)];
y = [newQ, newR, newD];
y(find(y<0)) = 0;


% outp Q,R,D
outp = y; % 10+6=16 in all
end