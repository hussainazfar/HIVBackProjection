function [Times, StartingCD4, OptimisedParameters]=OptimiseTestingRateToCD4(RealTestingCD4, Pxi )
    % To do a test run on this, call the following code
    % ExampleData; % produces CD4ForOptimisation
    % NumberOfSamples=200;
    % [Px]=LoadBackProjectionParameters(NumberOfSamples);
    % Create a simulation specific value for the parameters
    % Pxi=Px;
    % Pxi.SquareRootAnnualDecline=Px.SquareRootAnnualDeclineVec(1);
    % Pxi.FractionalDeclineToRebound=Px.FractionalDeclineToReboundVec(1);
    % [Times, StartingCD4, OptimisedParameters]=OptimiseTestingRateToCD4(CD4ForOptimisation, Pxi );


    ExpectedOutput=hist(RealTestingCD4, 50:100:1950);
    [~, NumberOfCD4Counts]=size(RealTestingCD4);
    FunctionPointer=@GenerateCD4Count;
    % [ResultsForOPtimisation, OtherOutput]=GenerateCD4Count(TestingRateParameters, FunctionInput);
    % TestingRateParameters(1)= AnnualTestingRate
    % TestingRateParameters(1)= in the equation 
    % OtherOutput= raw CD4 counts
    
    %OptimisationSettings=[];
    OptimisationSettings.OutputPlotFunction=@PlotOptimisationOutput;
    OptimisationSettings.PlotParameters=true;
    
    Pxi.SimulatedPopSize=NumberOfCD4Counts;
    FunctionInput=Pxi;
    
    ParameterBounds=[0, 1; 0, 1];
    
    % Determine a likely testing rate 
    [OptimisedParameters, ~]=StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, ExpectedOutput, OptimisationSettings);

    % Rerun the best testing rate, match CD4 counts with
    Pxi.SimulatedPopSize=10000;
    
    [~, Data]=GenerateCD4Count(OptimisedParameters, Pxi);
    
    ClosestN=Pxi.SimulatedPopSize/100;
    % Choose time values of CD4 counts close to the ones input
    [ReturnValues]=ChooseRandomNearbyValues(RealTestingCD4, Data.CD4, [Data.Time; Data.InitialCD4], ClosestN);

    % Store results
    Times= ReturnValues(1, :);
    StartingCD4= ReturnValues(2, :);



end