function [intersect, Vx, Vy] = getIntersection(A,B,C,vertex1, D,E,F,vertex2, theta, epsilon)
%[intersect, Vx, Vy] = getIntersection(A,B,C,vertex1, D,E,F,vertex2)
%
%   getIntersection Summary of this function goes here
%   Detailed explanation goes here

intersect = 0;

syms Vx Vy;

switch vertex1,
    case 1, %AB(1)
        eqn1 = Vy - A.y == (Vx - A.x)*tan(A.alfa);
    case 2, %AC(2)
        eqn1 = Vy - A.y == (Vx - A.x)*tan(mod(A.alfa+theta, 2*pi));
    case 3, %BC(3)
        eqn1 = Vy - B.y == ((C.y - B.y)/(C.x - B.x))*(Vx-B.x);
end

switch vertex2,
    case 1, %DE(1)
        eqn2 = Vy - D.y == (Vx - D.x)*tan(D.alfa);
    case 2, %DF(2)
        eqn2 = Vy - D.y == (Vx - D.x)*tan(mod(D.alfa+theta, 2*pi));
    case 3, %EF(3)
        eqn2 = Vy - E.y == ((F.y - E.y)/(F.x - E.x))*(Vx-E.x);
end

solx = solve(eqn1, eqn2, Vx, Vy);

Vx = eval(solx.Vx);
Vy = eval(solx.Vy);

if( isempty(Vx) || isempty(Vy))
	return;
else,
    switch vertex1,
        case 1, %AB(1)
            contains1 = inVertex(Vx, Vy, A.x, A.y, B.x, B.y, epsilon);
        case 2, %AC(2)
            contains1 = inVertex(Vx, Vy, A.x, A.y, C.x, C.y, epsilon);
        case 3, %BC(3)
            contains1 = inVertex(Vx, Vy, B.x, B.y, C.x, C.y, epsilon);
    end

    switch vertex2,
        case 1, %DE(1)
            contains2 = inVertex(Vx, Vy, D.x, D.y, E.x, E.y, epsilon);
        case 2, %DF(2)
            contains2 = inVertex(Vx, Vy, D.x, D.y, F.x, F.y, epsilon);
        case 3, %EF(3)
            contains2 = inVertex(Vx, Vy, E.x, E.y, F.x, F.y, epsilon);
    end
    
    if(contains1 && contains2),
        intersect = 1;
    end
end

end

