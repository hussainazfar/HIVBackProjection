ExampleData
RealTestingCD4=CD4ForOptimisation;
NoParameterisations=1;

[Px]=LoadBackProjectionParameters(NoParameterisations);

CurrentParamNumber=1;
 
Pxi=Px;
    Pxi.CD4Decline=Px.CD4DeclineVec(CurrentParamNumber);
    Pxi.SQRCD4Decline=Px.SQRCD4DeclineVec(CurrentParamNumber);
    Pxi.FractionalDeclineToRebound=Px.FractionalDeclineToReboundVec(CurrentParamNumber);
    Pxi.FirstInfectionDate=Pxi.FirstInfectionDateVec(CurrentParamNumber);
    
    [TimesForThisSim, StartingCD4ForThisSim, OptimisedParameters]=OptimiseTestingRateToCD4(RealTestingCD4, Pxi );