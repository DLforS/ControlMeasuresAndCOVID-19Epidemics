clear;clear all;close all;clc;
format longg;

clock
dir0 = '../dst-data-1000-fittings-20230804/';
a = readtable([dir0 'miminal-loss-parameters-add-clusters-manually.xlsx'],...
    'VariableNamingRule','preserve');
countries = a.('Countries');

cols = {'E0','I0','Q0','R0','D0','alpha','beta','gamma','delta','lambda',...
    'kappa','N(population)'};
quantities = {'Q100/N','R100/N','D100/N','Half time t_{1/2}',...
    'Lag time t_{lag}','Spreading rate k_{app}'};

ti = [0 120];
dt = 0.1;
soln_cols = {'t','S','E','I','Q','R','D'};
clst = a.('Cluster');
h = [];
for i = 1:length(countries)
    country = countries{i};
    population = table2array(a(i,'N(population)'));
    y0 = [];
    y1 = [];
    y2 = [];
    for j = 1:2
        par0 = [];
        par1 = [];
        par2 = [];
        par0 = table2array(a(i,cols));
        par1 = par0;
        par2 = par0;
        [soln0,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par0,ti,dt);
        [y0,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln0,population);
        % category 1加强-> alpha增, beta减; category 2加强-> alpha增, beta减,delta减;？
        if j == 1
            par1(1,6) = par1(1,6)*1.2;
            par1(1,7) = par1(1,7)*0.8;
            par2(1,6) = par2(1,6)*0.8;
            par2(1,7) = par2(1,7)*1.2;
        elseif j == 2
            % par1(1,6) = par1(1,6)*1.2;
            par1(1,7) = par1(1,7)*0.8;
            par1(1,9) = par1(1,9)*0.8;
            % par2(1,6) = par2(1,6)*0.8;
            par2(1,7) = par2(1,7)*1.2;
            par2(1,9) = par2(1,9)*1.2;
        end;
        [soln1,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par1,ti,dt);
        [soln2,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par2,ti,dt);
        [y1,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln1,population);
        [y2,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln2,population);
        data(i,j,:,1) = y0;
        data(i,j,:,2) = y1;
        data(i,j,:,3) = y2;
    end;
end;
% data: (countries,PolicyCluster,quantities,IncreaseOrDecrease)

%% Analysis
[num_country,num_poli_clust,num_quantities,~] = size(data);
for i = 1:num_poli_clust
    h = [h,figure('Units','normalized','Position',[0.1,0.1,0.9,0.5])];
    y1 = [];
    y2 = [];
    for j = 1:num_quantities
        data1 = [];
        group1 = [];
        data2 = [];
        group2 = [];
        for k = 1:4
            idx_coun_clust = find(clst==k);
            x0 = data(idx_coun_clust,i,j,1);
            x1 = data(idx_coun_clust,i,j,2);
            x2 = data(idx_coun_clust,i,j,3);
            val1 = x1(:)./x0(:);
            val2 = x2(:)./x0(:);
            g1 = repmat(['Cluster ',num2str(k),''],length(val1),1);
            g2 = repmat(['Cluster ',num2str(k),''],length(val2),1);
            data1 = [data1;val1(:)];
            idx1 = find(~isoutlier(val1(:)));
            ub1(k,1) = max(max(val1(idx1)));
            ub1(k,1) = quantile(val1(:),0.80);
            group1 = [group1;g1];

            data2 = [data2;val2(:)];
            idx2 = find(~isoutlier(val2(:)));
            ub2(k,1) = max(max(val2(idx2)));
            ub2(k,1) = quantile(val2(:),0.80);
            group2 = [group2;g2];

            idx1 = nan;
            idx2 = nan;
        end;
        subplot(2,7,1+j);
        hold on;
        boxplot(data1,group1);
        set(gca,'XTickLabelRotation',-65);
        box on;
        title(quantities{j});
        plot([0.5,5.5],[1,1],'g--');
        ylim([min(data1),max(ub1)*1.1]);
    
        subplot(2,7,8+j);
        hold on;
        boxplot(data2,group2);
        set(gca,'XTickLabelRotation',-65);
        box on;
        title(quantities{j});
        plot([0.5,5.5],[1,1],'g--');
        ylim([min(data2),max(ub2)*1.1]);

    end;
    subplot(2,7,1);
    text(0,0,['Policies ' num2str(i) ' (+)'],'FontSize',25,...
        'HorizontalAlignment','left','VerticalAlignment','middle');
    ylim([-1,1]);
    xlim([0,1]);
    set(gca,'visible','off');
    subplot(2,7,8);
    text(0,0,['Policies ' num2str(i) ' (-)'],'FontSize',25,...
        'HorizontalAlignment','left','VerticalAlignment','middle');
    set(gca,'Visible','off');
    ylim([-1,1]);
    xlim([0,1]);
    % sgtitle(['Policy ' num2str(i) ' (\pm20%)']);
end;
h1 = figure;
exportgraphics(h1,'sensitivity-20230817.pdf','append',false);
for i = 1:length(h)
    exportgraphics(h(i),['sensitivity-20230817-' num2str(i) '.png'],'Resolution',1500);
    exportgraphics(h(i),'sensitivity-20230817.pdf','append',true);
    savefig(h(i),['sensitivity-20230817-' num2str(i) '.fig']);
end;


clock

