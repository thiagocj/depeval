function [ contains ] = inVertex( x, y, Ax, Ay, Bx, By, epsilon )
%[contains] = inVertex(x, y, Ax, Ay, Bx, By, epsilon);
%
%   inVertex verifies if the point (x,y) belongs to vertex AB, considering
%   the error epsilon. If AB contais the point (x,y), then contains = 1.
%   Otherwise, contains = 0.

contains = 0;

xMin = min(Ax, Bx)-epsilon;
xMax = max(Ax, Bx)+epsilon;
yMin = min(Ay, By)-epsilon;
yMax = max(Ay, By)+epsilon;

if( (x<xMin) || (x>xMax) || (y<yMin) || (y>yMax) ),
    return;
else,
    
    %y = mx + n

    m = (Ay - By)/(Ax - Bx);
    n = Ay-m*Ax;

    error = y - (m*x + n);

    if( (abs(error) <= epsilon) ),
        contains = 1;
    end

    %y = mx + n
    %Aq = b

    %syms m n q;
    %q = [m; n];
    %b = [Ay; By];
    %A = [Ax 1; Bx 1]
    %%Ay = m*Ax + n;
    %%By = m*Bx + n;

end

end

