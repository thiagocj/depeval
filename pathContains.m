function [ contains ] = pathContains(path, element)
%pathContains Verifies if 'path' contais 'element'.
%   If 'path' contais 'element', then contains = 1. Otherwise, contains =0.
%   'path' is a cell and 'element' is a string.
    
    contains = 0;
    
    for i=1:max(size(path)),
        if(strcmp(path{i},element)),
            contains = 1;
            break;
        end
    end

end

