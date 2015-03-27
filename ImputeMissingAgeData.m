function [ Age ] = ImputeMissingAgeData( Year, Age )
    % A rough boot strap methodology to replace missing data using nearest (100) neighbours 
    %Extract individuals with all data
    ExtractIndex =~ isnan(Age);
    SampleYear = Year(ExtractIndex);
    SampleAge = Age(ExtractIndex);


    SampleSize = sum(ExtractIndex);
    TopCount = min([100, round(SampleSize*0.1)]);                           %the lowest of top 100 or top 10%
    
    Obs=length(Age);
    
    for c = 1:Obs                                                           %each individual
        if (isnan(Age(c)))
            % Calculate distance of individual from group 
            Distance = abs(Year(c) - SampleYear);
           
            % Order the data by 
            [SortedDistance, DistanceIndex] = sort(Distance);
            
            % Find the values that are at the TopCount point
            ValToMatch = SortedDistance(TopCount);
            
            % Choose top 10% 
            BestIndex = DistanceIndex(SortedDistance <= ValToMatch);

            % Choose a data value at random
            ChosenIndex = randsample(BestIndex, 1);

            % Put data back into the array
            Age(c) = SampleAge(ChosenIndex);
        end
    end

end