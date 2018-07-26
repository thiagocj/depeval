%Raio R, ângulo de visão Theta, Lista de posição e orientação de sensores
%(x,y, alfa),  
%1. Pegar todos sensores (for de 1 até n)
%1.1. Para cada sensor, gerar uma struct com as coordenadas (x,  y) de cada
%vértice e guardar em um array.
%2. Para cada par de sensor, encontrar as intersecções de vértices, olhando
%'um lado de um com um lado de outro.

PLOT = 0;
PRINT = 0;

FOV = R*R*sin(theta)/2;

A = 300*600;
A_min= 0.20;

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
epsilon = 1e-3;

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

% for i=1:nSensors,
%    eval(['syms a' num2str(i)]); 
% end
% 
% NFC = '';
% nRules = size(activeNodes,2);
% for i=1:nRules,
%     
%     if(size(activeNodes{i},2) == 1),
%         if(i~=nRules),
%             NFC = [NFC '~a' num2str(activeNodes{i}) ' | '];
%         else,
%             NFC = [NFC '~a' num2str(activeNodes{i})];
%         end
%     else,
%         NFC = [NFC '('];
%         nItems = size(activeNodes{i},2);
%         for j=1:nItems,
%             if(j~=nItems),
%                 NFC = [NFC '~a' num2str(activeNodes{i}(j)) ' & '];
%             else,
%                 if(i~=nRules),
%                     NFC = [NFC '~a' num2str(activeNodes{i}(j)) ') | '];
%                 else,
%                     NFC = [NFC '~a' num2str(activeNodes{i}(j)) ')'];
%                 end
%             end
%         end
%     end
% end
% 
% NFC
% aux = eval(['simplify(' NFC ');']);
% 
% NFC = simplify(~aux);
% NFC
% 
% NFC = char(NFC);
% 
% strNFC = strsplit(NFC,[" ",'\f','\n','\r','\t','\v',")","(","a"]);
% 
% NFC = [];
% lengthSTR = size(strNFC,2);
% for i=1:lengthSTR,
%     if(~isempty(strNFC{i})),
%         
%         if(strNFC{i} == '|'),
%             ch = 'or';
%         elseif(strNFC{i} == '&'),
%             ch = 'and';
%         else,
%             ch = strNFC{i};
%         end
%         
%         if(i~=lengthSTR),
%             NFC = [NFC ch ' '];
%         else,
%             NFC = [NFC ch];
%         end
%     end
% end
% 
% NFC

NFC = '';
nRules = size(activeNodes,2);

s1 = num2cell(activeNodes{1});
for n=1:nRules-1,
    s2 = num2cell(activeNodes{n+1});
    aux = ones(size(s1,2),size(s2,2));
    cnt = 1;
    sol = {};
    for i=1:size(s1,2),%ROWS, 1 to i
        for j=1:size(s2,2),%COLUMNS, 1 to j
            %Regra 1
            if( aux(i,j) && (size(s1{i},2)==size(s2{j},2)) && (s1{i}==s2{j}) ),
                aux(i,:) = 0;
                aux(:,j) = 0;
                sol(cnt,:) = {s1{i},i,j,1};
                cnt = cnt+1;
                %break;
            end
            
            %Regra 2
            if( aux(i,j) && size(s1{i},2)~=size(s2{j},2) ),
                %SE FOR IGUAL A UM OU A OUTRO, REGRA 2
                uni = unique([s1{i} s2{j}]); 
                
                if( size(s1{i},2) > size(s2{j},2) ),
                    biggest = s1{i};
                    row=1;
                else,
                    biggest = s2{j};
                    row=0;
                end
                
                if(size(biggest,2)==size(uni,2)),
                    if(biggest==uni),
                        if(row),
                            aux(i,:) = 0;
                        else
                            aux(:,j) = 0;
                        end
                        sol(cnt,:) = {biggest,i,j,2};
                        cnt = cnt+1;
                        %break;
                    end
                end
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%  Regra 3  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:size(s1,2),%ROWS, 1 to i
        for j=1:size(s2,2),%COLUMNS, 1 to j
            if( aux(i,j)==1 ),%found some term of rule 3
                term3 = unique([s1{i} s2{j}]);
                added = 0;
                for m=1:size(sol,1),
                    if( (sol{m,4}==2) && ( i==sol{m,2} || j==sol{m,3}) ),
                        uni = unique([s1{i} s2{j} sol{m,1} ]);
                        if( size(term3,2) < size(sol{m,1},2) ),
                            smallest = term3;
                            biggest = sol{m,1};
                        else,
                            smallest = sol{m,1};
                            biggest = term3;
                        end
                        
                        if(size(biggest,2)==size(uni,2)),
                            if(biggest==uni),
                                aux(i,j) = 0;
                                %aux(i,:) = 0;
                                %aux(:,j) = 0;
                                %sol(cnt,:) = {smallest,i,j,3};
                                %cnt = cnt+1;
                                sol(m,:) = {smallest,i,j,3};
                                added = 1;
                                break;
                            end
                        end
                    end
                end
                if(~added),
                    aux(i,j) = 0;
                    sol(cnt,:) = {term3,i,j,3};
                    cnt = cnt+1;
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %s1 = sol;
    s1 = {};
    for m=1:size(sol,1),
        s1(m) = sol(m,1);
    end
end

NFC = [];
lengthS1 = size(s1,2);
for i=1:lengthS1,
    lengthItem = size(s1{i},2);
    for j=1:lengthItem,
        if(j ~= lengthItem),
            %NFC = [NFC num2str(s1{i}(j)) ' and '];
            NFC = [NFC num2str(Y(s1{i}(j))-1) ' and '];
        else,
            %NFC = [NFC num2str(s1{i}(j))];
            NFC = [NFC num2str(Y(s1{i}(j))-1)];
        end
    end
    
    if(i ~= lengthS1),
        NFC = [NFC ' or '];
    end
    
end

NFC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Criar uma funcao recursiva para buscar e calcular overlap, passando o
%nivel de redundancia: 2 sensores, 3 sensores, 4 sensores...
%A cada nova chamada da funcao, a NFC ira sendo gerada.

% para cada sensor, chamar getOverlap, passando DOIS sensores, depois TRES,
% ..., até o TOTAL DE SENSORES. Iserir sempres "os proximos sensores",
% desconsiderando os passados. A cada chamada de getOverlap, informar o
% triangulo da vez e o level de chamada (redundancia)