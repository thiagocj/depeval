function [vertices] = getOverlap(sensors, vertices, combination, epsilon, FOV, theta, PLOT, PRINT)
%[vertices] = getOverlap(sensors, vertices, epsilon, FOV, theta, PLOT, PRINT)
%
%   getIntersection Summary of this function goes here
%   Detailed explanation goes here


nCombs = size(combination,2);
lastSensor = combination(nCombs);

nSensors = size(sensors,2);

if(lastSensor == nSensors),
    return;
end

nSensors = size(sensors,2);
newVertices = [];
angle = 0;
cnt = 1;

for i=lastSensor+1:nSensors,
    newComb = [combination i]; 
    
    if(PRINT),
        disp(['Opa: [' num2str(newComb) '].']);
    end
    
    overlapLevel = size(newComb,2);
    
    if(overlapLevel==2),
        
        %for nextSensor=currentSensor+1:nSensors,
        newVertices = [];
        cnt = 1;

        s1 = sensors{newComb(1)};
        s1c = struct2cell(sensors{newComb(1)});
        s2 = sensors{newComb(2)};
        s2c = struct2cell(sensors{newComb(2)});

        A.x = s1.Ax;
        A.y = s1.Ay;
        A.alfa = s1.alfa;
        B.x = s1.Bx;
        B.y = s1.By;
        C.x = s1.Cx;
        C.y = s1.Cy;

        D.x = s2.Ax;
        D.y = s2.Ay;
        D.alfa = s2.alfa;
        E.x = s2.Bx;
        E.y = s2.By;
        F.x = s2.Cx;
        F.y = s2.Cy;

        for Vi=1:3, %Vertex of sensor i
            %inside = isInsideTri(x}, y, Ax, Ay, Bx, By, Cx, Cy, FOV, epsilon)
            inside = isInsideTri(s1c{2*Vi}, s1c{2*Vi+1}, D.x, D.y, E.x, E.y, F.x, F.y, FOV, epsilon);
            if(inside),
                %Initialize all angles equals ZERO
                newVertices(cnt,:) = [angle s1c{2*Vi} s1c{2*Vi+1}];
                cnt = cnt+1;
            end

            for Vj=1:3, %Vertex of sensor j

                [intersect, Vx, Vy] = getIntersection(A,B,C,Vi, D,E,F,Vj, theta, epsilon);

                if(intersect),
                    %Initialize all angles equals ZERO
                    newVertices(cnt,:) = [angle Vx Vy];
                    cnt = cnt+1;
                end

                if(Vi==1),
                    inside = isInsideTri(s2c{2*Vj}, s2c{2*Vj+1}, A.x, A.y, B.x, B.y, C.x, C.y, FOV, epsilon);
                    if(inside),
                        %Initialize all angles equals ZERO
                        newVertices(cnt,:) = [angle s2c{2*Vj} s2c{2*Vj+1}];
                        cnt = cnt+1;
                    end
                end
            end
        end

        if( ~isempty(newVertices) ),
            %vertices = Celula de vertices (x,y), 0/1 para s1, 0/1 para s2, ... 0/1 para sn
            positions = zeros(1,nSensors);
            positions(newComb(1)) = 1;
            positions(newComb(2)) = 1;

            tx = mean(newVertices(:,2));
            ty = mean(newVertices(:,3));

            n = size(newVertices,1);
            for i=1:n,
                Vx = newVertices(i,2);
                Vy = newVertices(i,3);
                %newVertices(i,1) = atan((Vy-ty)/Vx-tx);
                %Translation of axes
                newVertices(i,1) = atan2(Vy-ty,Vx-tx);

                if(PLOT),
                    %PLOT VERTICE
                    plot(Vx,Vy,'go',...
                        'LineWidth',2,...
                        'MarkerSize',10,...
                        'MarkerEdgeColor','b',...
                        'MarkerFaceColor',[0.5,0.5,0.5])
                end
            end

            newVertices = sortrows(newVertices,1);

            area = polyArea(newVertices(:,2:3));
            
            vertices{size(vertices,2)+1} = {newVertices, positions, area};

            %TODO: VERIFICAR ESSA CHAMADA
            %vertices = getOverlap(sensors, vertices, currentSensor, overlapLevel+1, epsilon, FOV, theta)
            %rec(n,[combination i]);
            vertices = getOverlap(sensors, vertices, newComb, epsilon, FOV, theta, PLOT, PRINT);
        end
        %end
    elseif(overlapLevel>2),
        
        newVertices = [];
        cnt = 1;
        angle = 0;
                
        for i=1:size(vertices,2),
            %indexes = find(vertices{i}{2}==1 & vertices{1}{2}(currentSensor)==0);
            indexes = find(vertices{i}{2}(combination)==1);
            if(size(indexes,2) == overlapLevel-1),
                nVertices = size(vertices{i}{1},1);
                
                s1 = sensors{newComb(nCombs+1)};
                s1c = struct2cell(sensors{newComb(nCombs+1)});
                
                for j=1:nVertices,

                    v1 = vertices{i}{1}(j,2:3);
                    if(j~=nVertices),
                        v2 = vertices{i}{1}(j+1,2:3);
                    else,
                        v2 = vertices{i}{1}(1,2:3);
                    end

                    insideV1 = isInsideTri(v1(1), v1(2), s1.Ax, s1.Ay, s1.Bx, s1.By, s1.Cx, s1.Cy, FOV, epsilon);
                    insideV2 = isInsideTri(v2(1), v2(2), s1.Ax, s1.Ay, s1.Bx, s1.By, s1.Cx, s1.Cy, FOV, epsilon);
    
                    empty1 = [];
                    empty2 = [];
                    if(~isempty(newVertices)),
                        empty1 = find(newVertices(:,2)==v1(1) & newVertices(:,3)==v1(2));
                        empty2 = find(newVertices(:,2)==v2(1) & newVertices(:,3)==v2(2));
                    end
                    
                    if(insideV1 && insideV2),
                        if(isempty(empty1)),
                            newVertices(cnt,:) = [angle v1(1) v1(2)];
                            cnt = cnt+1;
                        end
                        if(isempty(empty2)),
                            newVertices(cnt,:) = [angle v2(1) v2(2)];
                            cnt = cnt+1;
                        end
                    elseif(~insideV1 && ~insideV2),
                        continue;
                    else
                        %Pega interseção, vê se tá dentro e guarda
                        for Vi=1:3,

                            V1s.x = v1(1);
                            V1s.y = v1(2);
                            V2s.x = v2(1);
                            V2s.y = v2(2);
                            A.x = s1.Ax;
                            A.y = s1.Ay;
                            A.alfa = s1.alfa;
                            B.x = s1.Bx;
                            B.y = s1.By;
                            C.x = s1.Cx;
                            C.y = s1.Cy;
                            
                            [intersect, Vx, Vy] = getIntersectionSegment(V1s, V2s, A,B,C,Vi, theta, epsilon);
                            
                            
                            
                            if(intersect),
                                empty = [];
                                if(~isempty(newVertices)),
                                    empty = find(newVertices(:,2)==Vx & newVertices(:,3)==Vy);
                                end
                                if(isempty(empty)),
                                %Initialize all angles equals ZERO
                                    newVertices(cnt,:) = [angle Vx Vy];
                                    cnt = cnt+1;
                                end
                            end
                        end
                        if(insideV1 && ~insideV2 && isempty(empty1)),
                            newVertices(cnt,:) = [angle v1(1) v1(2)];
                            cnt = cnt+1;                            
                        elseif(~insideV1 && insideV2 && isempty(empty2)),
                            newVertices(cnt,:) = [angle v2(1) v2(2)];
                            cnt = cnt+1;
                        end
                    end
                end
                
                %Verificar se os vertices de s1 estão dentro de todos os
                %triangulos anteriores
                for Vi=1:3,
                    for k=1:nCombs,
                        x = s1c{2*Vi};
                        y = s1c{2*Vi+1};
                        inside = isInsideTriS( sensors, combination, x, y, FOV, epsilon );
                        %Criar uma funcao recursiva para saber se tá tá
                        %dentro de todos os triangulos anteriores
                        %inside = isInsideTri(s2c{2*Vj}, s2c{2*Vj+1}, A.x, A.y, B.x, B.y, C.x, C.y, FOV, epsilon);
                        
                        empty = [];
                        if(~isempty(newVertices)),
                            empty = find(newVertices(:,2)==x & newVertices(:,3)==y);
                        end
                        
                        if(inside && isempty(empty)),
                            %Initialize all angles equals ZERO
                            newVertices(cnt,:) = [angle x y];
                            cnt = cnt+1;
                        end
                    end
                end
            end
        end
        
        if( ~isempty(newVertices) ),
            %vertices = Celula de vertices (x,y), 0/1 para s1, 0/1 para s2, ... 0/1 para sn
            positions = zeros(1,nSensors);
            for k=1:nCombs+1,
                positions(newComb(k)) = 1;
            end

            tx = mean(newVertices(:,2));
            ty = mean(newVertices(:,3));

            n = size(newVertices,1);
            for i=1:n,
                Vx = newVertices(i,2);
                Vy = newVertices(i,3);
                %newVertices(i,1) = atan((Vy-ty)/Vx-tx);
                %Translation of axes
                newVertices(i,1) = atan2(Vy-ty,Vx-tx);

                if(PLOT),
                    %PLOT VERTICE
                    plot(Vx,Vy,'go',...
                        'LineWidth',2,...
                        'MarkerSize',10,...
                        'MarkerEdgeColor','b',...
                        'MarkerFaceColor',[0.5,0.5,0.5])
                end
            end

            newVertices = sortrows(newVertices,1);

            area = polyArea(newVertices(:,2:3));
            
            vertices{size(vertices,2)+1} = {newVertices, positions, area};
            
            vertices = getOverlap(sensors, vertices, newComb, epsilon, FOV, theta, PLOT, PRINT);
        end 
    else,
        error('You are trying to calculate the overlap of less than TWO sensors!');
    end
end

end