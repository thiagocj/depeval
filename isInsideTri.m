function [ inside ] = isInsideTri( x, y, Ax, Ay, Bx, By, Cx, Cy, FOV, epsilon )
%[inside] = isInside(x, y, Ax, Ay, Bx, By, Cx, Cy, FOV, epsilon)
%
%   isInside verifies if the point (x,y) is inside of the triangle ABC.
%   If the point (x,y) is inside of ABC, then contains = 1. Otherwise,
%   contains = 0. The error epsilon is considered on calculations.

inside = 0;

APB = abs(Ax*(By-y) + Bx*(y-Ay) + x*(Ay-By))/2;
APC = abs(Ax*(y-Cy) + x*(Cy-Ay) + Cx*(Ay-y))/2;
BPC = abs(x*(By-Cy) + Bx*(Cy-y) + Cx*(y-By))/2;

%vertices = [Ax, Ay; Bx, By; Cx, Cy];
%auxFOV = polyArea(vertices)
%FOV-auxFOV

auxFOV = APB+APC+BPC;

%if( abs(FOV-(APB+APC+BPC))<= epsilon ),
if( abs(FOV-auxFOV)<= epsilon ),
    inside = 1;
end
    
end

