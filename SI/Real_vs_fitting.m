clear;clear all;close all;clc;

a = readtable('../dst-data-1000-fittings-20230804/miminal-loss-parameters.xlsx',...
    'VariableNamingRule','preserve');
col1 = {'Q100/N', 'R100/N', 'D100/N', 'Half_time', 'Lag_time', 'Spreading_rate'};
col2 = cellfun(@(c)['real_' c],col1,'UniformOutput',false);
a(:,col1);

h = figure('Units','centimeters','Position',[1,1,20,30]);
rho = [];
dev = [];
for i = 1:length(col1)
    x = a.(col1{i});
    y = a.(col2{i});
    y(find(y<0)) = nan;

    rho(i) = corr(x,y,'rows','complete');
    dev(i) = nanmean(abs(x-y)./y);

    subplot(3,2,i);%ceil((i-0.9)/2*3));
    hold on;
    scatter(x,y,5,'k','filled');
    box on;
    xlabel('Predicted values');
    ylabel('True values');
    c1 = quantile([x(:);y(:)],0.05);
    c2 = quantile([x(:);y(:)],0.95);

    title(replace(col1{i},'_',' '));
    if i ~= 4 & i ~=5
        set(gca,'XScale','Log','YScale','Log');
    end

    xlim([c1 c2]);
    ylim([c1,c2]);
    plot([c1,c2],[c1,c2],'g:');
    % set(gca,'XScale','Log','YScale','Log');
end;

params = table(round(rho(:),3),round(dev(:),3),...
    'RowNames',cellfun(@(c)replace(c,'_',' '),col1,'UniformOutput',false),...
    'VariableNames',{'Correlation','Relative errors'});
% Tstr = evalc('disp(params)');
% Tstr = strrep(Tstr,'<strong>','');
% Tstr = strrep(Tstr,'</strong>',' ');
% Tstr = strrep(Tstr,'_','\_');
% % Tstr = strrep(Tstr,'<p>','\\');
% % Tstr = ['$\begin{array}{lcc} ' Tstr '\end{tabular}$' ]
% 
% ax = subplot(3,1,3);
% set(gca,'XTick',[],'YTick',[]);
% set(gca,'Visible','off');
% box off;
% hold on;
% % Tstr = '\begin{tabular}{lcc}  &Correlation&    Relative errors\\\hline         Q100/N        &      0.994      &      0.086     \\         R100/N        &       0.974     &        0.21  \\            D100/N        &       0.961    &         0.17  \\           Half time    &        0.945    &        0.078   \\           Lag time     &        0.926   &         0.395              Spreading rate    &   0.982     &       0.237     \\\end{tabular}';
% annotation(gcf,'Textbox','String',Tstr,'Interpreter','TeX',...
%     'Position',get(ax,'Position'),'Fontsize',15,'HorizontalAlignment','center');

writetable(params,'corrlation-erros.xlsx','WriteMode','overwritesheet','WriteRowNames',true);

saveas(h,'real-vs-fitting.svg');
exportgraphics(h,'real-vs-fitting.png','ContentType','image','Resolution',1000);



