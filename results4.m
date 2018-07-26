close all, clear all, clc;
x = 0:600;

for(R=300:-50:0),
y = sqrt(R.^2 - (x-300).^2)+00;
plot(x,y);
grid, hold on;
pbaspect([1 0.5 1]);
end


gtw = [300 0];
pos = [85 155; 140 0; 155 260; 220 125; 300 215; 380 125; 450 250; 455 0; 510 160];
pos = [gtw; pos];
plot(pos(:,1)',pos(:,2)', 'ok');


R = 150;
theta = 60*pi/180;
 
Y = [2,4,6,8,10];
Y = unique(Y)
n = max(size(Y));

load('result4_sensors.mat')

plotSensors(sensors,0);

DIRECT = 0;
FLOODING = 1;
HIERARCHICAL = 2;

FoV_results4
save('wks_results4.mat');

protocol = DIRECT;
data_results4
dataInComp
figure;
silva2012Comp
title('DIRECT');
values_Direct = values_FULL;
save('wks_results4_values_Direct.mat','values_Direct');

clear all;
load('wks_results4.mat');
protocol = FLOODING;
data_results4
dataInComp
figure;
silva2012Comp
title('FLOODING');
values_Flooding = values_FULL;
save('wks_results4_values_Flooding.mat','values_Flooding');

clear all;
load('wks_results4.mat');
protocol = HIERARCHICAL;
data_results4
dataInComp
figure;
silva2012Comp
title('HIERARCHICAL');
values_Hierarchical = values_FULL;

load('wks_results4_values_Direct.mat');
load('wks_results4_values_Flooding.mat');

figure, plot(t(1:ceil(size(t,2)/20)),values_Direct(1:ceil(size(t,2)/20)),'-*k',...
t(1:ceil(size(t,2)/20)),values_Flooding(1:ceil(size(t,2)/20)),'--dr','MarkerIndices',1:50:size(t,2));
legend('DIRECT','FLOODING');
xlabel('t');
ylabel(prop);
grid;

figure, plot(t(1:ceil(size(t,2)/20)),values_Direct(1:ceil(size(t,2)/20)),'-*k',...
t(1:ceil(size(t,2)/20)),values_Flooding(1:ceil(size(t,2)/20)),'--dr',...
t(1:ceil(size(t,2)/20)),values_Hierarchical(1:ceil(size(t,2)/20)),':ob','MarkerIndices',1:50:size(t,2));
legend('DIRECT','FLOODING','HIERARCHICAL');
xlabel('t');
ylabel(prop);
grid;

