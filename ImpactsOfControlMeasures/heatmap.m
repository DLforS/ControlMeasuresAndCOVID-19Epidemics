clc; clear; close all;
% fig3 B-C
allcountrypv=[6.43E-06	0.072449244	6.97E-09	0.733532524	0.389888364
1.83E-04	0.290604706	9.99E-08	0.228627537	0.63629925
3.46E-07	0.106588376	9.13E-09	0.262636734	0.056207557
6.42E-04	0.10043025	0.092200995	0.009555877	3.80E-04
0.076053829	0.058990143	0.740805119	0.37450684	0.016138588
0.009157524	0.058980523	8.93E-04	0.333812744	0.73736386];
allcountryr2=[0.36746751	0.132805636	0.281770831	0.004985649	0.005920419
0.31537669	0.094591367	0.249283384	0.023519976	0.001794476
0.407674184	0.12317841	0.278544027	0.021333403	0.028859166
0.293646118	0.124699611	0.050784078	0.072265476	0.096442821
0.190348056	0.137720617	0.010078428	0.015716242	0.045422593
0.241642496	0.137724466	0.125110455	0.017540711	9.03E-04];

subplot(1,2,1)
string_x={'\bf all','\bf Category 1','\bf Category 2','\bf Category 3','\bf Category 4'};
string_y={'\bf log(Q_{100}/N)','\bf log(R_{100}/N)','\bf log(D_{100}/N)','\bf log(t_{1/2})','\bf log(t_{lag})','\bf log(k_{app})'};
xvalues = string_x;
yvalues = string_y;
h1v = -log10(allcountrypv); 
h1 = heatmap(xvalues,yvalues,h1v, 'FontSize',10, 'FontName','Times New Roman');
title ('\bf -log(p-value) of Linear Regression - all Country');
xlabel('\bf Policy');ylabel('\bf Characteristics');
h1.CellLabelFormat = '%.4f';
subplot(1,2,2)
h2 = heatmap(xvalues,yvalues,allcountryr2, 'FontSize',10, 'FontName','Times New Roman');
title ('\bf R-squared of Linear Regression - all Country');
xlabel('\bf Policy'); ylabel('\bf Characteristics');
h2.CellLabelFormat = '%.4f';

% fig3 D-E
country2pv=[0.033149179	0.021635869	8.59E-04	0.880452604	0.437144099
0.125590652	0.211813683	0.002668585	0.208869004	0.744074054
0.032347716	0.027066042	0.039186947	0.984928049	0.005573952
0.297350051	0.92812624	0.913102618	0.038103089	0.084985966
0.062397706	0.127710748	0.483385606	0.289072481	0.305711258
0.090634081	0.108251052	0.013094367	0.82833291	0.95717787];
country2r2=[0.438804763	0.342941537	0.284824061	4.48E-04	0.011883913
0.370113787	0.228519629	0.249174915	0.030786057	0.002108125
0.439910495	0.33345965	0.155373658	7.07E-06	0.141110135
0.311215854	0.077277592	0.010574648	0.08162233	0.057052095
0.408506682	0.258353934	0.0484019	0.022008854	0.020558882
0.388781696	0.267365343	0.195424837	9.31E-04	5.71E-05];

subplot(1,2,1)
string_x={'\bf all','\bf Category 1','\bf Category 2','\bf Category 3','\bf Category 4'};
string_y={'\bf log(Q_{100}/N)','\bf log(R_{100}/N)','\bf log(D_{100}/N)','\bf log(t_{1/2})','\bf log(t_{lag})','\bf log(k_{app})'};
xvalues = string_x;
yvalues = string_y;
h1v = -log10(country2pv); 
h1 = heatmap(xvalues,yvalues,h1v, 'FontSize',10, 'FontName','Times New Roman');
title ('\bf -log(p-value) of Linear Regression - Cluster2');
xlabel('\bf Policy');ylabel('\bf Characteristics');
h1.CellLabelFormat = '%.4f';
subplot(1,2,2)
h2 = heatmap(xvalues,yvalues,country2r2, 'FontSize',10, 'FontName','Times New Roman');
title ('\bf R-squared of Linear Regression - Cluster2');
xlabel('\bf Policy'); ylabel('\bf Characteristics');
h2.CellLabelFormat = '%.4f';

% figure3 F-G
country3pv=[ 1.5132    0.7813    2.7777         0    0.1920
    1.1173    0.6470    2.1037         0    0.0785
    1.7083    0.5768    2.8216         0    0.3707
    0.5169    0.3163    0.0309         0    1.0304
    1.0313    1.2502    0.0813         0    0.6345
    1.1089    0.8502    1.3170         0    0.7483];
country3r2=[0.32925688	0.171540627	0.232091019	0	0.003672681
0.289800498	0.155925069	0.186424595	0	7.44E-04
0.346888922	0.147280896	0.234954563	0	0.01078028
0.213953486	0.110633453	0.00766824	0	0.047020471
0.280395587	0.219452172	0.015261115	0	0.024119638
0.288889816	0.179145464	0.128339141	0	0.03045983];

subplot(1,2,1)
string_x={'\bf all','\bf Category 1','\bf Category 2','\bf Category 3','\bf Category 4'};
string_y={'\bf log(Q_{100}/N)','\bf log(R_{100}/N)','\bf log(D_{100}/N)','\bf log(t_{1/2})','\bf log(t_{lag})','\bf log(k_{app})'};
xvalues = string_x;
yvalues = string_y;

h1 = heatmap(xvalues,yvalues,country3pv, 'FontSize',10, 'FontName','Times New Roman');
title ('\bf -log(p-value) of Linear Regression - Cluster3');
xlabel('\bf Policy');ylabel('\bf Characteristics');
h1.CellLabelFormat = '%.4f';
subplot(1,2,2)
h2 = heatmap(xvalues,yvalues,country3r2, 'FontSize',10, 'FontName','Times New Roman');
title ('\bf R-squared of Linear Regression - Cluster3');
xlabel('\bf Policy'); ylabel('\bf Characteristics');
h2.CellLabelFormat = '%.4f';