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

        continue;

        
        writetable(soln1,...
            ['../dst-data-1000-fittings-20230804/Sensitivity-data/soln-',country,'-' cols{j} '-1.xlsx'],...
            'WriteRowNames',false,'WriteVariableNames',true,...
            'WriteMode','overwritesheet');
        soln2 = array2table(soln,'VariableNames',soln_cols);
        writetable(soln2,...
            ['../dst-data-1000-fittings-20230804/Sensitivity-data/soln-',country,'-' cols{j} '-2.xlsx'],...
            'WriteRowNames',false,'WriteVariableNames',true,...
            'WriteMode','overwritesheet');
        writetable(soln3,...
            ['../dst-data-1000-fittings-20230804/Sensitivity-data/soln-',country,'-' cols{j} '-3.xlsx'],...
            'WriteRowNames',false,'WriteVariableNames',true,...
            'WriteMode','overwritesheet');
        soln1 = array2table(soln,'VariableNames',soln_cols);

    end;
    % xi: dim1:parameters;dim2:parameters;dim3:countries
    x1(:,:,i) = y(:,1,:)./y(:,2,:)-1;
    x2(:,:,i) = y(:,3,:)./y(:,2,:)-1;
    



    continue;

    save(['../dst-data-1000-fittings-20230804/Sensitivity-data/' country,'-key-quantities.mat'],'y');
end;

[m,n,p] = size(x1)
h = [];

for i = 1:12
    h(i) = figure('Units','centimeters','Position',[1,1,30,50]);
end;

for cl = 1:4
    b = a.Cluster;
    idx_countries = find(b==cl);
    y1 = [];
    y2 = [];
    y1(:,:,:) = x1(:,:,idx_countries);
    y2(:,:,:) = x2(:,:,idx_countries);
    idx_params = find(~isnan(offsets));
    if length(idx_countries) >0.10
        for i = idx_params(:)' % Parameters
            figure(h(i));
            sgtitle(['The relative change of the key quantities with '...
                'the increase (+) and decrease (-) of the paramter \' cols{i}...
                ' by ' num2str(offsets(i)*100) '%']);
            for j = 1:length(quantities)    % Quantities
                subplot(7,8,4*j+cl);
                hold on;
                z1 = y1(i,j,:);
                z2= y2(i,j,:);
                z = [z1(:);z2(:)];
                g1 = repmat(['+' num2str(offsets(i)*100) '%'],length(z1),1);
                g2 = repmat(['-' num2str(offsets(i)*100),'%'],length(z2),1);
                boxplot(z,[g1;g2],'BoxStyle','outline','OutlierSize',0.3,'Symbol','*','Widths',0.4);
                box on;
                title({['Cluster ' num2str(cl)],[quantities{j}]});
                xlim([0.5,2.5]);
                plot([0.5 2.5],[0,0],'k:');
                ylim(quantile(z,[0.03,0.97])+[-0.01,0.01]);
            end;
        end;
    else
        subplot(6,4,4*(cl-1)+j);
    end;
end;
% exportgraphics(h(1),'sensitivity.pdf','append',false);
for i = 1:length(h)
    saveas(h(i),['sensitivity-' cols{i} '.png'])
%     exportgraphics(h(i),'sensitivity.png','append',true);
end
% return;
% for i = find(~isnan(offsets))   % parameters
%     h = [h,figure];
%     for j = 1:n   % Quantities
%         subplot(3,2,j);
%         hold on;
%         % z1(:) = x1(i,j,:);
%         h1 = histogram(z1,15);
%         title([quantities{j} '(+)']);
%         box on;
% 
%         z2(:) = x2(i,j,:);
%         h2 = histogram(z2,15);
%         title([quantities{j},'(-)']);
%         title([quantities{j}]);
%         box on;
% 
%         hold off;
%         
% 
% %         h1.Normalization = 'probability';
% %         h1.BinWidth = 0.25;
% %         h2.Normalization = 'probability';
% %         h2.BinWidth = 0.25;
% % 
% % 
% %         subplot(4,4,12);
% %         text(0,0,quantities{j});
%     end;
%     sgtitle(['\' cols{i}]);
% end;

clock

