clear;clear all;close all;clc;
format shortg;
clock

h = [];

%% Data
data = readtable('../dst-data-1000-fittings-20230804/miminal-loss-parameters-add-clusters-manually.xlsx',...
    'VariableNamingRule','preserve');% 中文
policies = data(:,7:22);
policies_class =  [1   1   1   1   1   1   1   1   1   1   3   2   2   3   2   4];
population = data.('N(population)');
for i = 1:4
    policy{i} = policies(:,find(policies_class==i));
    x = table2array(policy{i});
    y = normalize(x,'range',[0,1]);
    [coeff{i},score,latent,tsquared,explained{i},mu] = pca(y,"Centered",false,'Algorithm','eig');
    z(:,i) = score(:,1);
    data.(['Z' num2str(i) '_score']) = score(:,1);
end;
name_x0 = {'E0','I0','Q0','R0','D0'};
initial_value = data(:,name_x0);
keys = {'Q100/N','R100/N','D100/N','half time t_{1/2}', 'lag-time t_{lag}', 'spreading rate k_{app}'};
keys0 = {'real_Q100/N','real_R100/N','real_D100/N','real_Half_time','real_Lag_time','real_Spreading_rate'};
keys1 = {'Q100/N','R100/N','D100/N','Half_time','Lag_time','Spreading_rate'};
cols = {'alpha','beta','gamma','delta','lambda','kappa'};


%% Fitting
countries = data.('Countries');
y0 = [];
y1 = [];
y2 = [];
for i = 1:length(cols)
    y = log(data.(cols{i}));
    mdl = fitlm(z,y);
    y0(:,i) = exp(mdl.Fitted);
    coeff = mdl.Coefficients.Estimate;
    median_value = median(z);
    weights = coeff(:).*median_value;
    for j = 1:4
        z1 = z;
        z1(:,j) = z(:,j)*1.2;
        y1(:,i,j) = exp(predict(mdl,z1));
        z2 = z;
        z2(:,j) = z(:,j)*0.8;
        y2(:,i,j) = exp(predict(mdl,z2));
    end;
end;
fitted_param = y0;
opt_par = table2array(data(:,cols));
h = [h,figure];
for i = 1:6
    subplot(2,3,i);
    hold on;
    x = opt_par(:,i);
    y = fitted_param(:,i);
    scatter(x,y,8,'k','filled');
    box on;
    plot(x,x,'g--');
    xlabel('optimal value');
    ylabel('fitted value');
    xlim(quantile(x,[0.05,0.95]));
    ylim(quantile(x,[0.05,0.95]));
%     set(gca,'XScale','Log','YScale','Log');
%     xlim([1e-2,10]);
%     ylim([1e-2,10]);
    title(cols{i});
end;


% y: (countries,model-parameters,z-idx)

%% Simulation
ti = [0,120];
dt = 0.1;
par = [];
for i = 1:length(countries)
    N = population(i);
    x0 = table2array(initial_value(i,:));
    par0 = y0(i,:);
    par0 = [x0(:);par0(:);N];
    [soln0,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par0,ti,dt);
    [key0(i,:),Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln0,N);
    for j = 1:4
        par1 = y1(i,:,j);
        par1 = [x0(:);par1(:);N];
        par2 = y2(i,:,j);
        par2 = [x0(:);par2(:);N];
        [soln1,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par1,ti,dt);
        [soln2,alpha,beta,gamma,delta,lambda,kappa,ts] = SEIRPQ_model(par2,ti,dt);
        [key1(i,:,j),Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln1,N);
        [key2(i,:,j),Q100,R100,D100,half_time,lag_time,spreading_rate] = calculate_key_quantities(soln2,N);
    end;
end;
% key: (countires,quantities,z-idx)

%% Plot and export
clear i j k m l n;
for iz = 1:4;
    h = [h,figure];
    for iq = 1:6
        subplot(2,3,iq);
        hold on;
        x0 = key0(:,iq);
        x1 = key1(:,iq,iz);
        x2 = key2(:,iq,iz);
        c1 = repmat([1,0,0],length(x1),1);
        c2 = repmat([0,0,1],length(x2),1);
        c = [c1;c2];
        x = [x0(:);x0(:)];
        y = [x1(:);x2(:)];
        idx = randperm(length(x));
        ax(1) = plot(sort(x0),sort(x0),'k--');
        ax(2) = scatter(x(1),y(1),8,'r','filled');
        ax(3) = scatter(x(1),y(1),8,'b','filled');
        scatter(x(idx,:),y(idx,:),8,c(idx,:),'filled');

        legend(ax,'Diagonal','+20%','-20%');

        title({keys{iq},['Z',num2str(iz)]});
        box on;
        xlabel(['Fitted ' keys{iq}]);
        ylabel(['Perturbed ' keys{iq}]);
        x0 = quantile([x0(:);y(:)],0.95);
        xlim([0,max(x0)*1.1]);
        ylim([0,max(x0)]*1.1);
        x0 = [];
    end;
end;

h = [h,figure];
for i = 1:6
    subplot(2,3,i);
    hold on;
    title(keys{i});
    x = data.(keys0{i});
    y = key0(:,i);
    scatter(x,y,8,'k','filled');
    plot(x,x,'g--');
    x = [x(:);y(:)];
    xlim(quantile(x,[0.05 0.95]));
    ylim(quantile(x,[0.05 0.95]));
    x = [];
    y = [];
    xlabel('True values');
    ylabel('Values by fitted parameters');
    set(gca,'XScale','Log','YScale','Log');
    box on;
end;

a = corr(z,opt_par);
b = array2table(a,'RowNames',{'Z1','Z2','Z3','Z4'},'VariableNames',cols)

real_dynamics = data(:,keys0);
a = corr(z,table2array(real_dynamics));
b = array2table(a,'RowNames',{'Z1','Z2','Z3','Z4'},'VariableNames',keys0)

varnames = {'real_Q100/N','real_R100/N','real_D100/N','real_Half_time',...
    'real_Lag_time','real_Spreading_rate',...
    'alpha','beta','gamma','delta','lambda','kappa'};
data1 = [];
for i = 1:length(varnames)
    y = data.(varnames{i})
    y(find(y<=0)) = nan;
    y = log(y);
    mdl = fitlm(z,y);
    r2 = mdl.Rsquared.Adjusted;
    pvalue = mdl.Coefficients.pValue;
    pvalue = pvalue(2:end);
    data1(i,:) = [r2(:);pvalue(:)];
end;
data1 = array2table(data1,'RowNames',varnames,'VariableNames',...
    {'R2','Z1-pvalue','Z2-pvalue','Z3-pvalue','Z4-pvalue'});


% for i = 1:length(h)
%     exportgraphics(h(i),['./Z-' num2str(i),'.png'],'Resolution',500);
% end;
% writetable(data,'../dst-data-1000-fittings-20230804/all-data-Z.xlsx','WriteMode','overwritesheet');

clock