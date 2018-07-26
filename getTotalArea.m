function [ area ] = getTotalArea( combination, nSensors, vertices, FOV )
%[ A_total ] = getTotalArea( combination, vertices, FOV )
%
%   UNTITLED Summary of this function goes here
%   Detailed explanation goes here

lengthComb = size(combination,2);
nSets = size(vertices,2);

area = 0;
%Verificar se os nodes da combinacao existem????????
area = FOV*lengthComb;

if(lengthComb==1),
    return;
end

% for i=1:nSets,
%     vertices{i}{2};
%     nodes = find(vertices{i}{2}==1);
%     res = find(nodes==combination);
%         
%     if(~isempty(res)),
%         area = area + (-1^(size(res,2)+1))*vertices{i}{3};
%     end    
% end

%Esse FOR Inicia em 2 pois as area individual de cada FOV foi computada em
%'area = FOV*lengthComb;'
for n=2:lengthComb,
	nodes = nchoosek(combination,n);
        
    for i=1:size(nodes,1),
        position = zeros(1,nSensors);
        for j=1:size(nodes,2),
            position(nodes(i,j)) = 1;
        end
        for k=1:nSets,
            if(vertices{k}{2} == position),
                area = area + ((-1)^(n+1))*vertices{k}{3};
                break;
            end
        end
    end   
end