function [ inside ] = isInsideTriS( sensors, combination, x, y, FOV, epsilon )
%[inside] = isInsideTriS( sensors, combination, x, y, FOV, epsilon )
%
%   isInside verifies if the point (x,y) is inside of the triangle ABC.
%   If the point (x,y) is inside of ABC, then contains = 1. Otherwise,
%   contains = 0. The error epsilon is considered on calculations.

inside = 0;

nCombs = size(combination,2);

if(isempty(combination)),
    inside = 1;
    return;
end

s1 = sensors{combination(1)};

combination = combination(2:nCombs);


APB = abs(s1.Ax*(s1.By-y) + s1.Bx*(y-s1.Ay) + x*(s1.Ay-s1.By))/2;
APC = abs(s1.Ax*(y-s1.Cy) + x*(s1.Cy-s1.Ay) + s1.Cx*(s1.Ay-y))/2;
BPC = abs(x*(s1.By-s1.Cy) + s1.Bx*(s1.Cy-y) + s1.Cx*(y-s1.By))/2;

%vertices = [Ax, Ay; Bx, By; Cx, Cy];
%auxFOV = polyArea(vertices)
%FOV-auxFOV

auxFOV = APB+APC+BPC;

%if( abs(FOV-(APB+APC+BPC))<= epsilon ),
if( abs(FOV-auxFOV)<= epsilon ),
    inside = isInsideTriS( sensors, combination, x, y, FOV, epsilon );
end
    
end

