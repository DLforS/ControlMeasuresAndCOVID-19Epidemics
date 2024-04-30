clc; clear; close all;
% --------------------
% box plots
% --------------------
% Import all kinds of country parameter data
name = {'Sheet1','Sheet2','Sheet3','Sheet4'};
country_data = cell(1,4);
for i = 1:4
    country_data{i} = xlsread("boxplot-data.xlsx",name{i});
end

% Extract parameters by country
params = cell(1,4); % All parameters in each country are one cell
% The order in params
% 1-Q100/N; 2-R100/N; 3-D100/N;
% 4-Half_time; 5-Lag_time; 6-Spreading rate;
for i = 1:4 % Loop over all model parameters
    for j = 1:6
        params{i}(:,j) = country_data{i}(:,j+1);
    end
end

params{2}(27,2) = mean(params{2}(:,2));

% Logarithms of variables such as Q100
for i = 1:4
    for j = 1:3
        params{i}(:,j) = log10(params{i}(:,j));
    end
end

% Logarithm of the Spreading rate
for i = 1:4
    params{i}(:,6) = log10(params{i}(:,6));
end

% Set map title
title_ = {'\bf Q_{100}/N','\bf R_{100}/N','\bf D_{100}/N','\bf t_{1/2}','\bf t_{lag}','\bf k_{app}'};

figure1 = figure('WindowState','maximized');

% box plots?
for i = [1:6]
    country1 = params{1}(:,i);    country2 = params{2}(:,i);
    country3 = params{3}(:,i);    country4 = params{4}(:,i);
    
    C((1:3),1) = country_data{1}(:,1);  C((4:56),1) = country_data{2}(:,1);
    C((57:117),1) = country_data{3}(:,1);  C((118:127),1) = country_data{4}(:,1);
    COrder = ["Cluster1","Cluster2","Cluster3","Cluster4"];
    namedC = categorical(C,1:4,COrder);
    
    h(i) = subplot(2,3,i);
    hold on;
    boxchart(namedC,[country1;country2;country3;country4],'DisplayName','Data','JitterOutliers','on','MarkerStyle','.');
    idx1 = isoutlier(country1,'quartiles');idx2 = isoutlier(country2,'quartiles');idx3 = isoutlier(country3,'quartiles');idx4 = isoutlier(country4,'quartiles');
    country1(idx1==1) = [] ; country2(idx2==1) = [] ; country3(idx3==1) = [] ; country4(idx4==1) = [] ; 
    idx = [idx1; idx2; idx3; idx4];
    namedC(idx==1) = [];
    % Mean points and lines
    meanvalue = groupsummary([country1;country2;country3;country4],namedC,'mean');
    hold on
    plot(meanvalue,'-o','MarkerSize',3,'DisplayName','Mean')
    hold off
    set(gca,'FontSize',17)
    set(gca,'linewidth',1)
    ax = gca;
    ax.XAxis.FontSize = 15;
    title(title_{i},'FontSize', 17);
end

% Adjust coordinate system
ylim(h(1),[-5 -1]);
h(1) = subplot(2,3,1); ax = gca;
set(h(1),'YTick',[-5 -4 -3 -2 -1]);
ax.YAxis.TickLabels = ["10^{-5}" "10^{-4}" "10^{-3}" "10^{-2}" "10^{-1}"];

ylim(h(2),[-5 -1]);
h(2) = subplot(2,3,2); ax = gca;
set(h(2),'YTick',[-5 -4 -3 -2 -1]);
ax.YAxis.TickLabels = ["10^{-5}" "10^{-4}" "10^{-3}" "10^{-2}" "10^{-1}"];

h(3) = subplot(2,3,3); ax = gca;
ax.YAxis.TickLabels = ["10^{-7}" "10^{-6}" "10^{-5}" "10^{-4}" "10^{-3}" "10^{-2}"];

h(6) = subplot(2,3,6); ax = gca;
set(h(6),'YTick',[0 1 2 3 4 5]);
ax.YAxis.TickLabels = ["1" "10" "100" "1000" "10000" "100000"];

% % Create legend
% legend1 = legend(h(6),'show');
% set(legend1,...
%     'Position',[0.791666666666667 0.274361400189215 0.0750000000000001 0.0584791869629976],...
%     'FontSize',14);
% 
% % Create textbox
% annotation(figure1,'textbox',...
%     [0.728124999999999 0.0860927152317881 0.206250000000001 0.168401135288553],...
%     'String',{'1) "Cluster1", "Cluster2", "Cluster3" and','"Cluster4" includes 3, 53, 61 and 10','countries respectively.','2) Each box chart displays the median,','the lower and upper quartiles, any outliers,','and the minimum and maximum values.'},...
%     'FontSize',14,...
%     'FitBoxToText','off');