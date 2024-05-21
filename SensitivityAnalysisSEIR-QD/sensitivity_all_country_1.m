clear;clear all;close all;clc;
format longg;

clock
dir0 = '../dst-data-1000-fittings-20230804/';
a = readtable([dir0 'miminal-loss-parameters-add-clusters-manually.xlsx'],...
    'VariableNamingRule','preserve');
countries = a.('Countries');

cols = {'E0','I0','Q0','R0','D0','alpha','beta','gamma','delta','lambda',...
    'kappa','N(population)'};
quantities = {'Q100/N','R100/N','D100/N','Half time',...
    'Lag time','Spreading rate'};

ti = [0 120];
dt = 0.1;
% 这是一组代表国家的参数敏感性分析结果，
% alpha，beta，delta参数变化范围是*0.8；*1；*1.2；
% lambda,kappa变化范围是*0.5；*1；*1.5
offsets = [nan,nan,nan,nan,nan,0.2,0.2,nan,0.2,0.5,0.5,nan];
soln_cols = {'t','S','E','I','Q','R','D'};
cl = a.('Cluster');
for i = 1:length(countries)
    country = countries{i};
    par = table2array(a(i,cols));
    population = table2array(a(i,'N(population)'));
    y = [];
    for j = 1:length(cols)
        if isnan(offsets(j))
            continue;
        end;
        par1 = par;
        par1(j) = (1+offsets(j))*par(j);
        [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par1,ti,dt);
        [y(j,1,:),Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln,population);
        

        par1 = par;
        par1(j) = (1+0*offsets(j))*par(j);
        [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par1,ti,dt);
        [y(j,2,:),Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln,population);
        

        par1 = par;
        par1(j) = (1-offsets(j))*par(j);
        [soln,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par1,ti,dt);
        [y(j,3,:),Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln,population);
        soln3 = array2table(soln,'VariableNames',soln_cols);

        

    end;
    % xi: dim1:parameters;dim2:parameters;dim3:countries
    x1(:,:,i) = y(:,1,:)./y(:,2,:)-1;
    x2(:,:,i) = y(:,3,:)./y(:,2,:)-1;
    
end;

[m,n,p] = size(x1)
h = [];

% for i = 1:12
%     h(i) = figure('Units','centimeters','Position',[1,1,30,50]);
% end;

idx_params = find(~isnan(offsets));

h = figure('Units','centimeters','Position',[1,1,90,50]);
for j = 1:length(quantities)    % Quantities
    data = [];
    group = [];
    subplot(3,2,j);
    hold on;
    for i = idx_params(:)'  % Parameters
        for cl = 1:4
            b = a.Cluster;
            idx_countries = find(b==cl);
            z1 = x1(i,j,idx_countries);
            z2 = x2(i,j,idx_countries);
            g1 = repmat(string(['Cl-' num2str(cl),',',quantities{j},',',...
                cols{i},'+' num2str(offsets(i)*100) '%']),length(z1),1);
            g2 = repmat(string(['Cl-' num2str(cl),',',quantities{j},',',...
                cols{i},'-' num2str(offsets(i)*100) '%']),length(z2),1);
            g1 = repmat(string(['Cl-' num2str(cl),',',quantities{j},' (+)']),length(z1),1);
            g2 = repmat(string(['Cl-' num2str(cl),',',quantities{j},' (-)']),length(z2),1);

            data = [data;z1(:);z2(:)];
            group = [group;g1;g2];
        end;
    end;
    boxplot(data,group,'OutlierSize',0.1);
    ylim(quantile(data,[0.02,0.98]));
    box on;
    set(gca,'XTickLabelRotation',-45);
    title(['Relative changes when \' cols{i} ...
        ' changes by \pm ' num2str(offsets(i)) '%']);
    plot([0,50],[0,0],'k:');
end;

exportgraphics(h,'sensititivity-all.pdf','Append',false);
exportgraphics(h,'sensititivity-all.png','Resolution',1000);
saveas(h,'sensitivity-all.svg');

clock

function [y,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln,population)
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