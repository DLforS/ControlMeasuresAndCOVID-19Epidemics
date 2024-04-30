function [pol1, pol2] = out_feature(params_fix, S0)
% Output 6 dynamic variables: 1-alpha; 2-beta; 3-gamma; 4-delta; 5-lambda; 6-kappa
%% Optimize parameters 
t_lim = [0 100]; % 219
range = [0.8 1 1.2]'; 
change_up = [0.8 1 1.2]';
change_down = [1.2 1 0.8]';

params_ahead = repmat(params_fix, size(range,1), 1); % copy params_fix
for i = 1:2 % 2个政策
    change = ['change',num2str(i)];
    eval([change,'= ones(size(range,1), 11);']);
end
% Category 1
change1(:,1) = change_up;
change1(:,2) = change_down; 
% Category 2
% change2(:,1) = change_up;
change2(:,2) = change_down; 
change2(:,4) = change_down; 
change_all = {change1, change2};

pol1_Q = zeros(100,size(range,1));
pol1_R = zeros(100,size(range,1));
pol1_D = zeros(100,size(range,1));
pol2_Q = zeros(100,size(range,1));
pol2_R = zeros(100,size(range,1));
pol2_D = zeros(100,size(range,1));

pol1 = {pol1_Q, pol1_R, pol1_D};
pol2 = {pol2_Q, pol2_R, pol2_D};

for i = 1: size(change_all,2) % 2
    params_adjust = change_all{i} .* params_ahead; % 最后形成的参数
    for j = 1:size(params_adjust,1) % 3
        QRD = sol_SEIRQAH(params_adjust(j,:)', S0, t_lim); 
        if i == 1
            pol1{1}(:,j) = QRD(:,1);  % Q
            pol1{2}(:,j) = QRD(:,2);  % R
            pol1{3}(:,j) = QRD(:,3);  % D
        elseif i == 2
            pol2{1}(:,j) = QRD(:,1);  % Q
            pol2{2}(:,j) = QRD(:,2);  % R
            pol2{3}(:,j) = QRD(:,3);  % D
        end
    end
end

