%PLOT VERTICE
%plot(1,1,'go',...
%    'LineWidth',2,...
%    'MarkerSize',10,...
%    'MarkerEdgeColor','b',...
%    'MarkerFaceColor',[0.5,0.5,0.5])

%2. Para cada par de sensor (sensors{i} e sensors{j}), encontrar as intersecções de vértices, olhando
%'um lado de um com um lado de outro.
vertices = [];
cnt = 1;
angle = 0;

for currentSensor=1:n-1,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % para cada sensor, chamar getOverlap, passando DOIS sensores, depois TRES,
    % ..., até o TOTAL DE SENSORES. Iserir sempres "os proximos sensores",
    % desconsiderando os passados. A cada chamada de getOverlap, informar o
    % triangulo da vez e o level de chamada (redundancia)
    
    %vertices  = getOverlap(sensors, vertices, currentSensor, overlapLevel, epsilon, PLOT, PRINT)
    vertices  = getOverlap(sensors, vertices, currentSensor, epsilon, FOV, theta, PLOT, PRINT);
    %vertices = Celula de vertices (x,y), 0/1 para s1, 0/1 para s2, ... 0/1 para sn
end

nSensors = size(sensors,2);
A_total = [];
cnt = 1;
for i=1:n,
	C = nchoosek(1:n,i);
    for j=1:size(C,1),
        area = getTotalArea(C(j,:), nSensors, vertices, FOV);
        A_total{cnt} = {C(j,:), area};
        
        if(PRINT),
            disp(['Area([' num2str(C(j,:)) ']) = ' num2str(area) '.']);
        end
        cnt = cnt+1;
    end
end

activeNodes = [];
cnt = 1;
for i=1:size(A_total,2),
   if(A_total{i}{2}/A >= A_min);
       activeNodes{cnt} = A_total{i}{1};
       
       if(PRINT),
           disp(['NFC(' num2str(cnt) ') = [' num2str( A_total{i}{1}) '].']);
       end
       cnt = cnt+1;
   end
end