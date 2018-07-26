function plotSensors( sensors, new )
%plotSensors Summary of this function goes here
%   Detailed explanation goes here

color = ['y' 'b' 'r' 'k' 'g' 'm' 'c' 'w'];
nC = size(color,2);

n = size(sensors,2);

if(new),
    figure, hold;
else
    hold on;
end

for i=1:n,
    line([sensors{i}.Ax sensors{i}.Bx],[sensors{i}.Ay sensors{i}.By],'Color',color(mod(i,nC)+1)), line([sensors{i}.Ax sensors{i}.Cx],[sensors{i}.Ay sensors{i}.Cy],'Color',color(mod(i,nC)+1)), line([sensors{i}.Bx sensors{i}.Cx],[sensors{i}.By sensors{i}.Cy],'Color',color(mod(i,nC)+1))
end

end

