clear;clear all;close all;clc;
format longg;

clock
dir0 = '../dst-data-1000-fittings-20230804/';
a = readtable([dir0 'miminal-loss-parameters-add-clusters-manually.xlsx'],...
    'VariableNamingRule','preserve');
countries = a.('Countries');

cols = {'E0','I0','Q0','R0','D0','alpha','beta','gamma','delta','lambda',...
    'kappa','N(population)'};
quantities = {'Q100/N','R100/N','D100/N','t_{1/2}',...
    't_{lag}','k_{app}'};

ti = [0 120];
dt = 0.1;
soln_cols = {'t','S','E','I','Q','R','D'};
clst = a.('Cluster');
h = [];
clock
data = 0;
num_of_perturbation = 10000;
if ~exist('Uncertainty.mat')
    data(length(countries),6,num_of_perturbation) = 0;
    delete(gcp('nocreate'));
    pool = parpool([1 100])
    for i = 1:length(countries)
        country = countries{i};
        population = table2array(a(i,'N(population)'));
        par0 = table2array(a(i,cols));
        [soln0,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par0,ti,dt);
        [y0,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln0,population);
        parfor j = 1:num_of_perturbation
            par1 = par0;
            r = randn(size(par1(6:11)))*0.05;
            par1(6:11) = par1(6:11).*(1+r);
            [soln1,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par1,ti,dt);
            [y1,Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln1,population);
            data(i,:,j) = y1./y0;
        end;
    end;
    delete(pool);
    clock
    save('Uncertainty.mat','data');
    % data: (countries,PolicyCluster,quantities,IncreaseOrDecrease)

end;

load('Uncertainty.mat');
%% Analysis
[num_country,num_quantities,num_perturbation] = size(data);
h = [h,figure];
for i = 1:num_quantities
    subplot(2,3,i);
    hold on;
    x = data(:,i,:);
    x = log10(x(:));
    [N,edges,bin] = histcounts(x,100,'Normalization','pdf');
    plot(edges(1:end-1),N);
    xlabel('relative errors');
    ylabel('Probability density');
    box on;
    title(['log_{10}(' quantities{i} ')']);
    xlim(quantile(x,[0.01,0.99])*1.1);
    ylim([0,max(N)*1.05]);
    quantities{i}
    sigma = std(x);
    errs = 2*sigma
    x1 = [-2*sigma,-2*sigma,2*sigma,2*sigma];
    y1 = [0,max(N)*1.1,max(N)*1.1,0];
    fill(x1,y1,'y','EdgeColor','none','FaceAlpha',0.5);
    ylim([0,max(N)*1.05]);

end;
h1 = figure;
figname = 'Uncertainty';
exportgraphics(h1,[figname '.pdf'],'append',false);
for i = 1:length(h)
    i
    exportgraphics(h(i),[figname '-' num2str(i) '.png'],'Resolution',1500)
    exportgraphics(h(i),[figname '.pdf'],'append',true)
    savefig(h(i),[figname '-' num2str(i) '.fig'])
end;


clock

