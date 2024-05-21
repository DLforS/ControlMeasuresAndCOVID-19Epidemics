clear;clc;close all;clear all;
format shortg;

paths = {'../src-data/epi/',['../dst-data-' datestr(now,'yyyy-mm-dd-HH-MM-SS') '/']};

path1 = paths{1};
path2 = paths{2};

files = dir(path1);
% if ~exist(path2)
%     mkdir(path2);
% end;

params = table();
solns = table();
real_data = table();
countries = {};
for i = 1:length(files)
    file = files(i).name;
    if strncmp(file,'.',1)
        continue;
    end;
    country = replace(file,'.csv','');
    file_path = [path1 country '.csv'];

    %% Read real data
    [data,population,cols] = read_data(file_path,'length',95,'cases',100,...
        'stopcases',100,'minimalcases',300);
    if population < 0 | length(data) < 10
        warning([country ' omitted. ' num2str(population) ','...
            num2str(max(data(:)))]);
        opt_par = [];
        soln = [];
        flag = 0;
        continue;
    end;
    data(find(data<0)) = 0;
    real_data.(country) = {data,population,cols};
    countries{length(countries)+1} = country;
end;


max_trial = 10;

delete(gcp('nocreate'))
pool = parpool(3)

clock1 = clock
parfor i = 1:length(countries)

    country=countries{i}
    
    data0 = real_data.(country);
    data = data0{1};
    population = data0{2};
    cols = data0{3};
    data0 = [];

    opt_par = [];
    for j = max_trial:-1:1
        [opt_par,soln,flag] = fit_one_country_SEIRQD(country,data,population,cols);
        optimal_parameters(i,j,:) = opt_par;
        optimal_solutions{i,j,:} = soln;
        optimal_flags(i,j) = flag;
    end;
end;

clock2 = clock

delete(pool)

save('results-SERIQD.mat','optimal_parameters','optimal_solutions','optimal_flags','countries','real_data');

test
