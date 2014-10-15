function [Times, StartingCD4, OptimisedParameters]=OptimiseTestingRateToCD4(RealTestingCD4, Pxi )
    % To do a test run on this, call the following code
%     ExampleData; % produces CD4ForOptimisation
%     NoParameterisations=200;
%     [Px]=LoadBackProjectionParameters(NoParameterisations);
%     % Create a simulation specific value for the parameters
%     Pxi=Px;
%     Pxi.ShowCD4Optimisation=true; % to show the plots of the output of the function. Turn on for testing, but turn off for increased speed
%     Pxi.SquareRootAnnualDecline=Px.SquareRootAnnualDeclineVec(1); % select a sample of this parameter
%     Pxi.FractionalDeclineToRebound=Px.FractionalDeclineToReboundVec(1); % select a sample of this parameter
%     [Times, StartingCD4, OptimisedParameters]=OptimiseTestingRateToCD4(CD4ForOptimisation, Pxi );
    
    
    try 
        TempShowCD4Optimisation=Pxi.ShowCD4Optimisation;
    catch 
        TempShowCD4Optimisation=false;
    end
    Pxi.ShowCD4Optimisation=TempShowCD4Optimisation;
        

    ExpectedOutput=hist(RealTestingCD4, 50:100:1450);
    [~, NumberOfCD4Counts]=size(RealTestingCD4);
    FunctionPointer=@GenerateCD4Count;
    % [CD4CountHistogram, Data]=GenerateCD4Count(TestingRateParameters, FunctionInput);
    % TestingRateParameters(1)= AnnualTestingRate
    % TestingRateParameters(1)= in the equation 
    % OtherOutput= raw CD4 counts
    
    if Pxi.ShowCD4Optimisation
        OptimisationSettings.OutputPlotFunction=@PlotOptimisationOutput;
        OptimisationSettings.PlotParameters=true;
        OptimisationSettings.DisplayTimer=true;
    end
    
    OptimisationSettings.SamplesPerRound=64;
    OptimisationSettings.NumberOfRounds=50;

    Pxi.SimulatedPopSize=NumberOfCD4Counts;
    FunctionInput=Pxi;
    
    % there are three parameters that describe the shape of the testing function
    ParameterBounds=[0, 1; 0, 1; 0, 1];
    
    % Determine a likely testing rate 
    [OptimisedParameters, DistributionOfOptimisedParameters]=StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, ExpectedOutput, OptimisationSettings);

%     clf;
%     plot([1 2 3], DistributionOfOptimisedParameters);
    
    % Rerun the best testing rate, match CD4 counts with
    Pxi.SimulatedPopSize=10000;
    
    [~, Data]=GenerateCD4Count(OptimisedParameters, Pxi);
    
    ClosestN=Pxi.SimulatedPopSize/100;
    % Choose time values of CD4 counts close to the ones input
    [ReturnValues]=ChooseRandomNearbyValues(RealTestingCD4, Data.CD4, [Data.Time; Data.InitialCD4], ClosestN);

    % Store results
    Times= ReturnValues(1, :);
    StartingCD4= ReturnValues(2, :);
    
%         
%     b=hist(Data.CD4, 50:100:1450);
%     plot(50:100:1450, b*NumberOfCD4Counts/10000, 'k.'); 


end