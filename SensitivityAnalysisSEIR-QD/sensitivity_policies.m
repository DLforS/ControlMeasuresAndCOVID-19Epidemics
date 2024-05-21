clear;clear all;close all;clc;

listing = dir('../Z_data-20230814');

a = {listing.name}
h1 = [];
h2 = [];
for file = a
    file = file{1};
    if file(1) == '.'
        continue;
    end;
    file

    data = readtable(['../Z_data-20230814/' file],'VariableNamingRule','preserve');

    y = log(table2array(data(:,6)));
    y = normalize(y,'range',[0,1]);
    data.(['normalized']) = y;
    x = table2array(data(:,{'Z1','Z2','Z3','Z4'}));

    mdl = fitlm(x,y,'RobustOpts','on');
    data.(['fitted']) = mdl.Fitted;
    h1 = [h1,figure];
    h2 = [h2,figure];
    for i = 1:4
        y0 = predict(mdl,x);
        x1 = x;
        x1(:,i) = x1(:,i)*1.2;
        y1 = predict(mdl,x1);
        x2 = x;
        x2(:,i) = x2(:,i)*0.8;
        y2 = predict(mdl,x2);
        data.(['Z' num2str(i) '+20%']) = y1;
        data.(['Z' num2str(i) '-20%']) = y2;

        figure(h1(end));
        subplot(2,2,i);
        hold on;
        scatter(y0,y1,10,'b','filled');
        scatter(y0,y2,10,'r','filled');
        % scatter(y,y0,5,'k','filled');
        plot(sort(y),sort(y),'g-','LineWidth',0.5);
        legend('+20%','-20%','Diagonal');
        xlabel('fitted');
        ylabel('Perturbation');
        box on;
        title([replace(replace(file,'.xlsx',''),'_',' '), ' Z' num2str(i)]);

        figure(h2(end));
        subplot(2,2,i);
        hold on;
        scatter(y,y0,10,'k','filled');
        xlabel('True data');
        ylabel('Fitted value');
        title([replace(replace(file,'.xlsx',''),'_',' ')]);
        plot(sort(y),sort(y),'g:','LineWidth',0.5);
        
        box on;
        
    end;
    writetable(data,['../dst-data-1000-fittings-20230804/Z_data-20230814-results/' file '-results-Linear-regression.xlsx'],...
        'WriteMode','overwritesheet');
end;

for i = 1:length(h1)
    exportgraphics(h1(i),['Z-fit-perturbation-' num2str(i) '.png'],'Resolution',1000);
    exportgraphics(h2(i),['Z-true-fit-' num2str(i) '.png'],'Resolution',1000);
end;