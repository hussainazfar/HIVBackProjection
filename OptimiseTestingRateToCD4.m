function [ChosenCD4Count, PEstimate]=OptimiseTestingRateToCD4(RealTestingCD4, Pxi )

    ExpectedOutput=hist(RealTestingCD4, 50:100:1950);
    NumberOfCD4Counts=size(1, RealTestingCD4);
    FunctionPointer=@GenerateCD4Count;
    % [ResultsForOPtimisation, OtherOutput]=GenerateCD4Count(TestingRateParameters, FunctionInput);
    % TestingRateParameters(1)= AnnualTestingRate
    % TestingRateParameters(1)= in the equation 
    % OtherOutput= raw CD4 counts
    
    OptimisationSettings.ErrorFunction=true;
    
    
    
    % Determine a likely testing rate 
    StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, ExpectedOutput, OptimisationSettings)

    % Rerun the best testing rate, match CD4 counts with
    SimulatedPopSize=10000;
    
    []=GenerateCD4Count();
    
    % Choose nearest neighbours
    NumberOfPeople=0;
    for ThisCD4=RealTestingCD4
        NumberOfPeople=NumberOfPeople+1;
        
    end
    
    % Return result

end