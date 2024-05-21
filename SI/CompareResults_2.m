clear;clear all;close all;clc;
format longg;

clock

%% MLP-Yang
dir0 = '../dst-data-1000-fittings-20230804/mlp-data-Yang';
flist = {'ys_pre_0.txt',...  % 没有扰动的值做为参考
    'ys_pre_Z1_jia20cl.txt', 'ys_pre_Z1_fu20cl.txt',...
    'ys_pre_Z2_jia20cl.txt','ys_pre_Z2_fu20cl.txt', ...
    'ys_pre_Z3_jia20_cl.txt','ys_pre_Z3_fu20_cl.txt',...
    'ys_pre_Z4_fu20_cl.txt', 'ys_pre_Z4_jia20_cl.txt'
     };

b0 = readtable([fullfile(dir0,flist{1})],'NumHeaderLines',1);  % 读取未扰动的参数
b0 = table2array(b0(:,2:7));
b0 = 10.^(b0);  % 如果取了对数，就在这里面
h = [];
for i = 1:2
    flist{2*i}
    b1 = readtable([fullfile(dir0,flist{2*i})],'NumHeaderLines',1);
    b1 = table2array(b1(:,2:7));
    b1 = 10.^(b1);  % 如果结果取了对数就取回来
    flist{2*i+1}
    b2 = readtable([fullfile(dir0,flist{2*i+1})],'NumHeaderLines',1);
    b2 = table2array(b2(:,2:7));
    b2 = 10.^(b2);  % 如果结果取了对数就取回来
    x1(:,:,i) = b1./b0;
    x2(:,:,i) = b2./b0;
end;
yang1 = x1;
yang2 = x2;
save('ToCompare-2-1.mat','yang1','yang2');
%这里 xi 各dimension的含义: (countries,quantities,policies)

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
peng1 = x1;
peng2 = x2;
save('ToCompare-2-2.mat','peng1','peng2');
% xi: (countries,quantities,policies)

%% Compare
clear;clear all;close all;clc;

load('ToCompare-2-1.mat');
load('ToCompare-2-2.mat');

quantities = {'Q100/N','R100/N','D100/N','Half time t_{1/2}',...
    'Lag time t_{lag}','Spreading rate k_{app}'};



h = figure('Units','centimeters','Position',[0.1,0.1,35,25]);

for i = 1:6
    a1 = yang1(:,i,:);
    a2 = yang2(:,i,:);
    b1 = peng1(:,i,:);
    b2 = peng2(:,i,:);
    
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
    xlabel('MLP');
    ylabel('Linear model');
    set(gca,'XTick',[0.1,0.5,1:10]);
    set(gca,'YTick',[0.1,0.5,1:10]);
end







h1 = figure;
exportgraphics(h1,'Compare-MLP-Linear.pdf','append',false);
for i = 1:length(h)
    exportgraphics(h(i),['Compare-MLP-Linear-' num2str(i) '.png'],'Resolution',1500);
    exportgraphics(h(i),'Compare-MLP-Linear.pdf','append',true);
    savefig(h(i),['Compare-MLP-Linear-' num2str(i) '.fig']);
end;


clock

