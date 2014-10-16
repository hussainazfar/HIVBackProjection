% function Figure1New
    NoParameterisations=200;
    [Px]=LoadBackProjectionParameters(NoParameterisations);
    % Create a simulation specific value for the parameters
    Pxi=Px;
    
    
    Pxi.CD4Decline=mean(Px.CD4DeclineVec); % select a sample of this parameter
    Pxi.FractionalDeclineToRebound=mean(Px.FractionalDeclineToReboundVec); % select a sample of this parameter
    Pxi.SimulatedPopSize=1000000;
    
    TestingParameters=[0.1, 0, 0];%low, flat testing rate

[CD4CountHistogram, Data]=GenerateCD4Count(TestingParameters, Pxi);


for Time=0:0.1:20
    Data.Time
    
    Data.CD4
    
end