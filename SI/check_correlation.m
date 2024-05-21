clear;clear all;close all;clc;
format longg;

dir0 = '../dst-data-1000-fittings-20230804/';
data = readtable([dir0 'miminal-loss-parameters-add-clusters-manually.xlsx'],...
    'VariableNamingRule','preserve');
% countries = a.('Countries');

idx1 = 7:22;
idx2 = [29 30 32:34];
idx3 = 36:41;

a = table2array(data(:,idx1));
b = table2array(data(:,idx2));
c = table2array(data(:,idx3));

a1 = normalize(a,'range',[1,2]);
b1 = [b(:,1),log(b(:,2:end))];
b1 = log(1+b);
c1 = c;

for i = 1:size(b,2)
    b2 = b(:,i);
    mdl{i} = fitlm(a,b2);   
    rs(i) = mdl{i}.('Rsquared').('Adjusted');
    mdl{i} = fitlm(a,b2./(median(b2)+b2));   
    rs2(i) = mdl{i}.('Rsquared').('Adjusted');
end;
results = [rs;rs2]

% corr1 = corr(a,b);
% corr2 = corr(a,c);
% corr3 = corr(b,c);
% corr11 = corr(a,b,'type','Spearman');
% corr21 = corr(a,c,'type','Spearman');
% corr31 = corr(b,c,'type','Spearman');
% 
% [coeff2,score2,latent2,tsquared2,explained2,mu2] = pca(b1);
% [coeff1,score1,latent1,tsquared1,explained1,mu1] = pca(a1);