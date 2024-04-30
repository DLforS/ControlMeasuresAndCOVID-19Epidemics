clc; clear; close all;
%% 
% The model parameters were obtained by fitting the cases£»
% The new cases were obtained by perturbing the parameters corresponding to the policy
%%  Perturb the parameters corresponding to the policies
[pol1_Kor, pol2_Kor] = policy2_Korea();
[pol1_Ger, pol2_Ger] = policy2_Germany();
[pol1_Mex, pol2_Mex] = policy2_Mexico();
%% True value; column 11 £ºnew Q£¬ column 12£ºnew R£¬ column 13£ºnew D
Korea = xlsread('fit_data.xlsx','South Korea');
Germany = xlsread('fit_data.xlsx','Germany');
Mexico = xlsread('fit_data.xlsx','Mexico');
t_lim = 0:1:99; 
%% plot
figure1 = figure('WindowState','maximized');
% color = {'#30336b', '#cd6133', '#227093', '#cc8e35', '#00695C'};
%% South Korea
axes1 = subplot(2,3,1); % Q
hold(axes1,'on');
plot(t_lim, pol1_Kor{1}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Kor{1}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Kor{1}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Korea(:,11),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[13 44 74],...
    'XTickLabel',{'3/1','4/1','5/1'});
title('Daily new quarantined(Q)','FontSize',12,'FontWeight','bold');

axes2 = subplot(2,3,2); % R
hold(axes2,'on');
plot(t_lim, pol1_Kor{2}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Kor{2}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Kor{2}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Korea(:,12),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[13 44 74],...
    'XTickLabel',{'3/1','4/1','5/1'});
title('Daily new recovered(R)','FontSize',12,'FontWeight','bold');


axes3 = subplot(2,3,3); % R
hold(axes3,'on');
plot(t_lim, pol1_Kor{3}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Kor{3}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Kor{3}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Korea(:,13),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[13 44 74],...
    'XTickLabel',{'3/1','4/1','5/1'});
title('Daily new death(D)','FontSize',12,'FontWeight','bold');
legend('policies-20%', 'fitting data', 'policies+20%','real data','FontWeight','bold');

axes4 = axes('Parent',figure1,...
    'Position',[0.13 0.190924855491329 0.213405797101449 0.341162790697674]); % Q
hold(axes4,'on');
plot(t_lim, pol2_Kor{1}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Kor{1}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Kor{1}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Korea(:,11),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[13 44 74],...
    'XTickLabel',{'3/1','4/1','5/1'});

axes5 = axes('Parent',figure1,...
    'Position',[0.410797101449275 0.190924855491329 0.213405797101449 0.341162790697674]); % R
hold(axes5,'on');
plot(t_lim, pol2_Kor{2}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Kor{2}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Kor{2}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Korea(:,12),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[13 44 74],...
    'XTickLabel',{'3/1','4/1','5/1'});

axes6 = axes('Parent',figure1,...
    'Position',[0.691594202898551 0.190924855491329 0.213405797101449 0.341162790697674]); % R
hold(axes6,'on');
plot(t_lim, pol2_Kor{3}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Kor{3}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Kor{3}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Korea(:,13),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[13 44 74],...
    'XTickLabel',{'3/1','4/1','5/1'});


annotation(figure1,'textbox',...
    [0.0085520833333335 0.895394752491736 0.168010416666667 0.100549481257933],...
    'String',{'South Korea'},...
    'FontWeight','bold',...
    'FontSize',18,...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(figure1,'textbox',...
    [0.01328125 0.73743930709052 0.08984375 0.0390173403083245],...
    'String',{'Category 1'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure1,'textbox',...
    [0.01875 0.36460693714832 0.090625 0.0390173403083245],...
    'String',{'Categort 2'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');

%% Germany
figure2 = figure('WindowState','maximized');
axes1 = subplot(2,3,1); % Q
hold(axes1,'on');
plot(t_lim, pol1_Ger{1}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Ger{1}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Ger{1}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Germany(:,11),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[7 38 68 99],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});
title('Daily new quarantined(Q)','FontSize',12,'FontWeight','bold');

axes2 = subplot(2,3,2); % R
hold(axes2,'on');
plot(t_lim, pol1_Ger{2}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Ger{2}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Ger{2}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Germany(:,12),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[7 38 68 99],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});
title('Daily new recovered(R)','FontSize',12,'FontWeight','bold');


axes3 = subplot(2,3,3); % R
hold(axes3,'on');
plot(t_lim, pol1_Ger{3}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Ger{3}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Ger{3}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Germany(:,13),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[7 38 68 99],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});
title('Daily new death(D)','FontSize',12,'FontWeight','bold');
% legend('policies-20%', 'fitting data', 'policies+20%','real data','FontWeight','bold');

axes4 = axes('Parent',figure2,...
    'Position',[0.13 0.190924855491329 0.213405797101449 0.341162790697674]); % Q
hold(axes4,'on');
plot(t_lim, pol2_Ger{1}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Ger{1}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Ger{1}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Germany(:,11),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[7 38 68 99],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});

axes5 = axes('Parent',figure2,...
    'Position',[0.410797101449275 0.190924855491329 0.213405797101449 0.341162790697674]); % R
hold(axes5,'on');
plot(t_lim, pol2_Ger{2}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Ger{2}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Ger{2}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Germany(:,12),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[7 38 68 99],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});

axes6 = axes('Parent',figure2,...
    'Position',[0.691594202898551 0.190924855491329 0.213405797101449 0.341162790697674]); % R
hold(axes6,'on');
plot(t_lim, pol2_Ger{3}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Ger{3}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Ger{3}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Germany(:,13),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[7 38 68 99],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});


annotation(figure2,'textbox',...
    [0.0085520833333335 0.895394752491736 0.168010416666667 0.100549481257933],...
    'String',{'Germany'},...
    'FontWeight','bold',...
    'FontSize',18,...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(figure2,'textbox',...
    [0.01328125 0.73743930709052 0.08984375 0.0390173403083245],...
    'String',{'Category 1'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure2,'textbox',...
    [0.01328125 0.36460693714832 0.090625 0.0390173403083244],...
    'String',{'Categort 2'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');

%% Mexico
figure3 = figure('WindowState','maximized');
axes1 = subplot(2,3,1); % Q
hold(axes1,'on');
plot(t_lim, pol1_Mex{1}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Mex{1}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Mex{1}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Mexico(:,11),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[1 32 62 93],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});
title('Daily new quarantined(Q)','FontSize',12,'FontWeight','bold');

axes2 = subplot(2,3,2); % R
hold(axes2,'on');
plot(t_lim, pol1_Mex{2}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Mex{2}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Mex{2}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Mexico(:,12),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[1 32 62 93],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});
title('Daily new recovered(R)','FontSize',12,'FontWeight','bold');


axes3 = subplot(2,3,3); % R
hold(axes3,'on');
plot(t_lim, pol1_Mex{3}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol1_Mex{3}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol1_Mex{3}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Mexico(:,13),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[1 32 62 93],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});
title('Daily new death(D)','FontSize',12,'FontWeight','bold');
% legend('policies-20%', 'fitting data', 'policies+20%','real data','FontWeight','bold');

axes4 = axes('Parent',figure3,...
    'Position',[0.13 0.190924855491329 0.213405797101449 0.341162790697674]); % Q
hold(axes4,'on');
plot(t_lim, pol2_Mex{1}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Mex{1}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Mex{1}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Mexico(:,11),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[1 32 62 93],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});

axes5 = axes('Parent',figure3,...
    'Position',[0.410797101449275 0.190924855491329 0.213405797101449 0.341162790697674]); % R
hold(axes5,'on');
plot(t_lim, pol2_Mex{2}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Mex{2}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Mex{2}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Mexico(:,12),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[1 32 62 93],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});

axes6 = axes('Parent',figure3,...
    'Position',[0.691594202898551 0.190924855491329 0.213405797101449 0.341162790697674]); % R
hold(axes6,'on');
plot(t_lim, pol2_Mex{3}(:,1),'-','LineWidth',2,'color','#0000FF');
plot(t_lim, pol2_Mex{3}(:,2),'-','LineWidth',2,'color','#006400');
plot(t_lim, pol2_Mex{3}(:,3),'-','LineWidth',2,'color','#FF4500');
plot(t_lim, Mexico(:,13),'*:','LineWidth',1,'color','#006400');
box on;
set(gca,'FontWeight','bold','FontSize',10,'XTick',[1 32 62 93],...
    'XTickLabel',{'3/1','4/1','5/1','6/1'});


annotation(figure3,'textbox',...
    [0.0085520833333335 0.895394752491736 0.168010416666667 0.100549481257933],...
    'String',{'Mexico'},...
    'FontWeight','bold',...
    'FontSize',18,...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(figure3,'textbox',...
    [0.01328125 0.73743930709052 0.08984375 0.0390173403083245],...
    'String',{'Category 1'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');
annotation(figure3,'textbox',...
    [0.01328125 0.36460693714832 0.090625 0.0390173403083244],...
    'String',{'Categort 2'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'EdgeColor','none');