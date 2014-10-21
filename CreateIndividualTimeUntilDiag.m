function [Times, StartingCD4, TestingParameter]=CreateIndividualTimeUntilDiag(RealTestingCD4, Px, RandomNumberStream)
% function [Times, StartingCD4, TestingProbVec, IdealPopTimesStore, IdealPopTestingCD4Store ]=CreateIndividualTimeUntilDiag(RealTestingCD4, Px, RandomNumberStream)



% CurrentDistribution - vector of CD4 values in the population (size=1*NumberOfPeople)
% DeclineAssumptions - a structure that includes the decline rates at various points
% Times - a matrix of estimated times since infection (NumberOfPeople, NumberOfTimeSamples)
% StartingCD4 - a matrix of estimated CD4s at infection (NumberOfPeople, NumberOfTimeSamples)
% TestingProbVec - the values of the probability vector associated with this result


[~, NumberOfPeople]=size(RealTestingCD4);
Times=zeros(NumberOfPeople, Px.NoParameterisations);
StartingCD4=zeros(NumberOfPeople, Px.NoParameterisations);

% For each specific vaiable combination
parfor CurrentParamNumber=1:Px.NoParameterisations
% for CurrentParamNumber=1:NumberOfTimeSamples
    % Seed the random number generator
    set(RandomNumberStream,'Substream',CurrentParamNumber);
    
    %Choose the current parameterision
    Pxi=Px;
    Pxi.CD4Decline=Px.CD4DeclineVec(CurrentParamNumber);
    Pxi.SQRCD4Decline=Px.SQRCD4DeclineVec(CurrentParamNumber);
    Pxi.FractionalDeclineToRebound=Px.FractionalDeclineToReboundVec(CurrentParamNumber);
    Pxi.FirstInfectionDate=Pxi.FirstInfectionDateVec(CurrentParamNumber);
        
    
    [TimesForThisSim, StartingCD4ForThisSim, OptimisedParameters]=OptimiseTestingRateToCD4(RealTestingCD4, Pxi );
    
    
    % Store results
    Times(:, CurrentParamNumber)= TimesForThisSim;
    StartingCD4(:, CurrentParamNumber)= StartingCD4ForThisSim;
    TestingParameter(CurrentParamNumber).Result=OptimisedParameters;

end


end
    
 

