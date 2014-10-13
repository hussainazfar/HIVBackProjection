function [ChosenCD4Count, PEstimate]=OptimiseTestingRateToCD4(RealTestingCD4, Pxi )

    ExpectedOutput=hist(RealTestingCD4, 50:100:1950);
    [~, NumberOfCD4Counts]=size(1, RealTestingCD4);
    FunctionPointer=@GenerateCD4Count;
    % [ResultsForOPtimisation, OtherOutput]=GenerateCD4Count(TestingRateParameters, FunctionInput);
    % TestingRateParameters(1)= AnnualTestingRate
    % TestingRateParameters(1)= in the equation 
    % OtherOutput= raw CD4 counts
    
    OptimisationSettings=[];
    
    Pxi.SimulatedPopSize=NumberOfCD4Counts;
    FunctionInput=Pxi;
    
    ParameterBounds=[0, 1; 0, 1];
    
    % Determine a likely testing rate 
    [OptimisedParameters, ~]=StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, ExpectedOutput, OptimisationSettings)

    % Rerun the best testing rate, match CD4 counts with
    Pxi.SimulatedPopSize=10000;
    
    [~, Data]=GenerateCD4Count(OptimisedParameters, Pxi);
    
    % Choose nearest neighbours
    NumberOfPeople=0;
    for ThisCD4=RealTestingCD4
        NumberOfPeople=NumberOfPeople+1;
        %Find CD4 counts that are within 
        Data.CD4
        
    end
    
    % Return result

end