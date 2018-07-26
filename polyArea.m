function [ area ] = polyArea( vertices )
%[ area ] = polyArea( vertices )
%
%   polyArea Calculates the area of a polygon.
%   vertices(i,1) = coordinate x.
%   vertices(i,2) = coordinate y.

n = size(vertices,1);

area = 0;

if(n <=2),
    error('Insufficient number of vertices.');
else,
   for i=1:n,
       if(i == n),
           area = area + vertices(i,1)*vertices(1,2) - vertices(1,1)*vertices(i,2);
       else,
           area = area + vertices(i,1)*vertices(i+1,2) - vertices(i+1,1)*vertices(i,2);
       end
   end
   
   area = abs(area)/2;
end

end

