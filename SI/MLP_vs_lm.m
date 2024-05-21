clear;clear all;close all;clc;
format longg;

clock

%% MLP
dir0 = '../dst-data-1000-fittings-20230804/data_to_plot-Peng/';
flist = {'ys_pred.txt',...
    'ys_predjia20P1.txt', 'ys_predfu20P1.txt',...
    'ys_predjia20P2.txt', 'ys_predfu20P2.txt',...
    'ys_predjia20P3.txt', 'ys_predfu20P3.txt',...
    'ys_predjia20P4.txt',  'ys_predfu20P4.txt'
     };
% 数据说明：
% data 是源数据文件，.m 文件分别是数据拟合、扰动，和画图程序，.txt 是新生成的数据文件， 
% ys_pred.txt 是拟合的、未扰动预测值，
% 其余的是扰动 20% 的预测值，jia 表示正扰动，fu 表示 *80%， P1-P4 表示单独对4类政策的扰动
a = readtable([dir0 'data.xlsx'],...
    'VariableNamingRule','preserve');
countries = a.('Countries');
clusts = a.('Cluster');

cols = {'E0','I0','Q0','R0','D0','alpha','beta','gamma','delta','lambda',...
    'kappa','N(population)'};
quantities = {'Q100/N','R100/N','D100/N','Half time t_{1/2}',...
    'Lag time t_{lag}','Spreading rate k_{app}'};
b0 = load([fullfile(dir0,'ys_pred.txt')]);
b0 = exp(b0);
h = [];
k = 2;
for i = 1:2 % Policies
    flist{2*i}
    b1 = load([fullfile(dir0,flist{2*i})]);
    b1 = exp(b1);
    flist{2*i+1}
    b2 = load([fullfile(dir0,flist{2*i+1})]);
    b2 = exp(b2);
    x1(:,:,i) = b1./b0;
    x2(:,:,i) = b2./b0;
end;
save('ToCompare-2.mat','x1','x2');
% xi: (countries,quantities,policies)

%% LM
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
            par1(1,6) = par1(1,6)*1.2;
            par1(1,7) = par1(1,7)*0.8;
            par1(1,9) = par1(1,9)*0.8;
            par2(1,6) = par2(1,6)*0.8;
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
y1 = [];
y2 = [];
for i = 1:num_poli_clust
    for j = 1:num_quantities
        x0 = data(:,i,j,1);
        x1 = data(:,i,j,2);
        x2 = data(:,i,j,3);
        y1(:,j,i) = x1(:)./x0(:);
        y2(:,j,i) = x2(:)./x0(:);
        y1(:,j,i) = x1(:)./x0(:);
        y2(:,j,i) = x2(:)./x0(:);
    end;
end;
save('ToCompare-1.mat','y1','y2');

%% Compare
clear;clear all;close all;clc;

load('ToCompare-1.mat');
load('ToCompare-2.mat');

quantities = {'Q100/N','R100/N','D100/N','Half time t_{1/2}',...
    'Lag time t_{lag}','Spreading rate k_{app}'};



h = figure('Units','centimeters','Position',[0.1,0.1,35,25]);

for i = 1:6
    a1 = x1(:,i,:);
    a2 = x2(:,i,:);
    b1 = y1(:,i,:);
    b2 = y2(:,i,:);
    
 


    subplot(2,3,i);
    hold on;

    x = [a1(:);a2(:)];
    y = [b1(:);b2(:)];

    plot(sort([x;y]),sort([x;y]),'g--');
    
    x = a1(:);
    y = b1(:);
    scatter(x,y,3,'r','filled');
    x = a2(:);
    y = b2(:);
    scatter(x,y,3,'b','filled');
    set(gca,'XScale','Log','YScale','Log');
    box on;
    title(quantities{i});
    xlabel('ODE');
    ylabel('Linear model');
    set(gca,'XTick',[0.1,0.5,1 2 5 10,20,50,100]);
    set(gca,'YTick',[0.1,0.5,1 2 5 10,20,50,100]);
end



h1 = figure;
exportgraphics(h1,'Compare-MLG-LM.pdf','append',false);
for i = 1:length(h)
    exportgraphics(h(i),['Compare-MLG-LM-' num2str(i) '.png'],'Resolution',1500);
    exportgraphics(h(i),'Compare-MLG-LM.pdf','append',true);
    savefig(h(i),['Compare-MLG-LM-' num2str(i) '.fig']);
end;


clock

