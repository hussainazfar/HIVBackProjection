function [Times, StartingCD4, TestingProbVec, IdealPopTimesStore, IdealPopTestingCD4Store ]=CreateIndividualTimeUntilDiag(RealTestingCD4, Px, RandomNumberStream)
% CurrentDistribution - vector of CD4 values in the population (size=1*NumberOfPeople)
% DeclineAssumptions - a structure that includes the decline rates at various points
% Times - a matrix of estimated times since infection (NumberOfPeople, NumberOfTimeSamples)
% StartingCD4 - a matrix of estimated CD4s at infection (NumberOfPeople, NumberOfTimeSamples)
% TestingProbVec - the values of the probability vector associated with this result


SimulatedPopSize=10000;
ClosestN=SimulatedPopSize/100;%This should sample from the 1% of simulations that are closest

[~, NumberOfPeople]=size(RealTestingCD4);
Times=zeros(NumberOfPeople, NumberOfParameterisations);
StartingCD4=zeros(NumberOfPeople, NumberOfParameterisations);
TestingProbVec=zeros(1, NumberOfParameterisations);

IdealPopTimesStore=zeros(SimulatedPopSize, NumberOfParameterisations);

% For each specific vaiable combination
parfor CurrentParamNumber=1:Px.NumberOfSamples
% for CurrentParamNumber=1:NumberOfTimeSamples
    % Seed the random number generator
    set(RandomNumberStream,'Substream',CurrentParamNumber);
    
    %Choose the current parameterision
    Pxi=Px;
    Pxi.SquareRootAnnualDecline=Px.SquareRootAnnualDeclineVec(CurrentParamNumber);
    Pxi.FractionalDeclineToRebound=Px.FractionalDeclineToReboundVec(CurrentParamNumber);
    
    [IdealPopTimes, IdealPopStartingCD4s, IdealPopTestingCD4, BestPEstimate]=OptimiseIdealPopulationToCD4(RealTestingCD4, Pxi, SimulatedPopSize);
    
    % Choose time values of CD4 counts close to the ones input
    [ReturnValues]=ChooseRandomNearbyValues(RealTestingCD4, IdealPopTestingCD4, [IdealPopTimes; IdealPopStartingCD4s], ClosestN);

    

    
    
    % Store results
    Times(:, CurrentParamNumber)= ReturnValues(1, :);
    StartingCD4(:, CurrentParamNumber)= ReturnValues(2, :);
    TestingProbVec(CurrentParamNumber)=BestPEstimate;
    IdealPopTimesStore(:, CurrentParamNumber)=IdealPopTimes;
    IdealPopTestingCD4Store(:, CurrentParamNumber)=IdealPopTestingCD4;
end


end
    
 

