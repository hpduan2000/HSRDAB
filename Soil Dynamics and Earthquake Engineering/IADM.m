% Written by H. P. Duan; hpduan2000@csu.edu.cn; https://www.hpduan.cn  
clear
clc

dataTable2 = readtable('***');
dataTable3 = readtable('***');

for i = 1:30
    Lb = 299; % m
    notNaNIndex = rmmissing(dataTable2(:,i));
    notNaNIndex = table2array(notNaNIndex);
    numIndex = length(notNaNIndex);
    sumIndex = sum(notNaNIndex);
    meanIndex = sumIndex/numIndex;
    lamida = sumIndex/Lb;
    maxIndex = max(notNaNIndex);
    varIndex = var(notNaNIndex);
    IndexMatrix = [i;numIndex;sumIndex;meanIndex;lamida;maxIndex;varIndex];
    IAD2(i,:) = IndexMatrix; %#ok
end
for i = 1:30
    Lb = 299; % m
    notNaNIndex = rmmissing(dataTable3(:,i));
    notNaNIndex = table2array(notNaNIndex);
    numIndex = length(notNaNIndex);
    sumIndex = sum(notNaNIndex);
    meanIndex = sumIndex/numIndex;
    lamida = sumIndex/Lb;
    maxIndex = max(notNaNIndex);
    varIndex = var(notNaNIndex);
    IndexMatrix = [i;numIndex;sumIndex;meanIndex;lamida;maxIndex;varIndex];
    IAD3(i,:) = IndexMatrix; %#ok
end

RSN = [IAD2(:, 1)];
Num_IAD_area_length = [IAD2(:, 2),IAD3(:, 2)];
Sum_IAD_area_length = [IAD2(:, 3),IAD3(:, 3)];
Mean_IAD_area_length = [IAD2(:, 4),IAD3(:, 4)];
Ratio_IAD_area_length = [IAD2(:, 5),IAD3(:, 5)];
Max_IAD_area_length = [IAD2(:, 6),IAD3(:, 6)];
Var_IAD_area_length = [IAD2(:, 7),IAD3(:, 7)];

%  IAD martix 
IAD = table(RSN,Num_IAD_area_length,Sum_IAD_area_length,Mean_IAD_area_length,Ratio_IAD_area_length,Max_IAD_area_length,Var_IAD_area_length);
