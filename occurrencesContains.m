function [contains, index] = occurrencesContains(occurrences, element)
%occurrencesContains Verifies if 'occurrences' contais 'element'.
%   If 'occurrences' contais 'element', then contains = 1. Otherwise, contains =0.
%   'occurrences' is a cell and 'element' is a string.
    
    contains = 0;
    index = 0;
    for i=1:size(occurrences,1),
        if(strcmp(occurrences{i},element)),
            contains = 1;
            index = i;
            break;
        end
    end

end