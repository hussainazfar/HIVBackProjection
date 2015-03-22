function [ CD4 ] = ImputeMissingCD4Data( Year, Age, CD4 )
    % A rough boot strap methodology to replace missing data using nearest (100) neighbours
        
    %Extract individuals with all data
    ExtractIndex =~ isnan(CD4);
    SampleYear = Year(ExtractIndex);
    SampleAge = Age(ExtractIndex);
    SampleCD4 = CD4(ExtractIndex);

    SampleSize = sum(ExtractIndex);
    TopCount = min([100, round(SampleSize*0.1)]);                           %the lowest of top 100 or top 10%
        
    Obs=length(CD4);
    
    for c = 1:Obs                                                           %each individual
        if (isnan(CD4(c)))
            % Calculate distance of individual from group 
            Distance= 4*abs(Year(c)-SampleYear)+abs(Age(c)-SampleAge);
            % here we are weight the difference in Year as being more
            % important than age. A 20 year age difference is worth a 5 year
            % year of diagnosis difference
            
            % Order the data by 
            
            [SortedDistance, DistanceIndex] = sort(Distance);
            
            % Find the values that are at the TopCount point
            ValToMatch = SortedDistance(TopCount);
            
            % Choose top 10% 
            BestIndex = DistanceIndex(SortedDistance <= ValToMatch);
            
            % Choose a data value at random
            ChosenIndex=randsample(BestIndex, 1);

            % Put data back into the array
            CD4(c) = SampleCD4(ChosenIndex);
        end
    end

end