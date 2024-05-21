uclear;clear all;close all;clc;
format longg;

clock
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
b0 = 10.^(b0);
h = [];
k = 2;
for i = 1:4
    h = [h,figure('Units','normalized','Position',[0.1,0.1,0.9,0.5])];
    flist{2*i}
    b1 = load([fullfile(dir0,flist{2*i})]);
    b1 = 10.^(b1);
    flist{2*i+1}
    b2 = load([fullfile(dir0,flist{2*i+1})]);
    b2 = 10.^(b2);
    x1 = b1./b0;
    x2 = b2./b0;
    g1 = arrayfun(@(x)(['Cluster ' num2str(x), ' ']),clusts,'UniformOutput',false);
    g2 = arrayfun(@(x)(['Cluster ' num2str(x), '']),clusts,'UniformOutput',false);
    ub1 = [];
    lb1 = [];
    ub2 = [];
    lb2 = [];
    for j = 1:4
        idx = find(clusts==j);
        ub1 = [ub1;quantile(x1(idx,:),0.9)];
        ub2 = [ub2;quantile(x2(idx,:),0.9)];
        lb1 = [lb1;quantile(x1(idx,:),0.1)];
        lb2 = [lb2;quantile(x2(idx,:),0.1)];
    end;
    ub1 = max(ub1)*1.01;
    ub2 = max(ub2)*1.01;
    lb1 = min(lb1)*0.99;
    lb2 = min(lb2)*0.99;
    for j = 1:6
        subplot(2,7,j+1);
        hold on;
        boxplot(x1(:,j),g1);
        box on;
        title(quantities{j});
        set(gca,'XTickLabelRotation',-65);
        plot([0.5,5.5],[1,1],'g--');
        ylim([lb1(j),ub1(j)]);
        xlim([0.5,5.5]);

        subplot(2,7,7+j+1);
        hold on;
        boxplot(x2(:,j),g2);
        box on;
        title(quantities{j});
        set(gca,'XTickLabelRotation',-65);
        plot([0.5,5.5],[1,1],'g--');
        ylim([lb2(j),ub2(j)]);
        xlim([0.5,5.5]);
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
end;

h1 = figure;
exportgraphics(h1,'sensitivity-peng.pdf','append',false);
for i = 1:length(h)
    exportgraphics(h(i),['sensitivity-peng' num2str(i) '.png'],'Resolution',1500);
    exportgraphics(h(i),'sensitivity-peng.pdf','append',true);
    savefig(h(i),['sensitivity-peng' num2str(i) '.fig']);
end;


clock

