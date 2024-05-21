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


idx_params = find(~isnan(offsets));

for i = 1:2
    h(i) = figure('Units','centimeters','Position',[1,1,90,50]);
    % h =[h h1]
end;
k = 0;
for i = idx_params(:)'  % Parameters
    data1 = [];
    data2 = [];
    group1 = [];
    group2 = [];
    for j = 1:length(quantities)    % Quantities
        for cl = 1:4
            b = a.Cluster;
            idx_countries = find(b==cl);
            z1 = x1(i,j,idx_countries);
            z2 = x2(i,j,idx_countries);
            g1 = repmat(string(['Cl-' num2str(cl),',',quantities{j},',',...
                cols{i},'+' num2str(offsets(i)*100) '%']),length(z1),1);
            g2 = repmat(string(['Cl-' num2str(cl),',',quantities{j},',',...
                cols{i},'-' num2str(offsets(i)*100) '%']),length(z2),1);
            g1 = repmat(string(['Cl-' num2str(cl),',',quantities{j},'']),length(z1),1);
            g2 = repmat(string(['Cl-' num2str(cl),',',quantities{j},'']),length(z2),1);

            data1 = [data1;z1(:)];
            group1 = [group1;g1];
            data2 = [data2;z2(:)];
            group2 = [group2;g2];
        end;
    end;
    k = k + 1;
    figure(h(1));
    subplot(3,2,k);
    hold on;
    boxplot(data1,group1,'OutlierSize',0.1);
    ylim(quantile(data1,[0.02,0.97])*1.1);
    if k == 2
        ylim([-1,20]);
    end;
    box on;
    set(gca,'XTickLabelRotation',-45);
    title(['\' cols{i} ' (+' num2str(offsets(i)*100) '%)']);
    plot([0,25],[0,0],'k:');
    for l = 1:2:5
        xedge = [4*l+0.5,4*l+0.5,4*(l+1)+0.5,4*(l+1)+0.5];
        yedge = quantile(data1,[0.01,0.99,0.99,0.01])*1.1;
        fill(xedge,yedge,'y','EdgeColor','none','FaceAlpha',0.4);
    end;

    figure(h(2));
    subplot(3,2,k);
    hold on;
    boxplot(data2,group2,'OutlierSize',0.1);
    ylim(quantile(data2,[0.02,0.97])*1.1);
    if k == 3
        ylim([-1,20]);
    end;
    box on;
    set(gca,'XTickLabelRotation',-45);
    title(['\' cols{i} ' (-' num2str(offsets(i)*100) '%)']);
    plot([0,25],[0,0],'k:');
    for l = 1:2:5
        xedge = [4*l+0.5,4*l+0.5,4*(l+1)+0.5,4*(l+1)+0.5];
        yedge = quantile(data2,[0.001,0.99,0.99,0.001])*1.1;
        fill(xedge,yedge,'y','EdgeColor','none','FaceAlpha',0.4);
    end;
end;

for i = 1:length(h)
    h1 = h(i);
    exportgraphics(h1,['sensititivity-all-' num2str(i) '.pdf'],'Append',false);
    exportgraphics(h1,['sensititivity-all-' num2str(i) '.png'],'Resolution',1000);
    saveas(h1,['sensitivity-all-' num2str(i) '.svg']);
end;

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