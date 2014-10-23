function Figure1New
    NoParameterisations=200;
    [Px]=LoadBackProjectionParameters(NoParameterisations);
    % Create a simulation specific value for the parameters
    Pxi=Px;
    
    
    Pxi.CD4Decline=median(Px.CD4DeclineVec); % select a sample of this parameter
    Pxi.FractionalDeclineToRebound=median(Px.FractionalDeclineToReboundVec); % select a sample of this parameter
    Pxi.SQRCD4Decline=median(Px.SQRCD4DeclineVec);
    Pxi.SimulatedPopSize=10000000;
    
    TestingParameters=[0.1, 0, 0];%low, flat testing rate should not bias towards high starting CD4s

    
    
[CD4CountHistogram, Data]=GenerateCD4Count(TestingParameters, Pxi);

Count=0;
StepSize=0.1;
MeasurementDistance=0.01;
for Time=[0, 0.05, 0.1:StepSize:20]
    Time
    Count=Count+1;
    IndexInStep=Time<=Data.Time & Data.Time<Time+MeasurementDistance;
    
    TestingCD4=Data.CD4(IndexInStep);
     t(Count)=Time;
     CD4Median(Count)=median(TestingCD4);
     CD4U95(Count)=prctile(TestingCD4, 97.5);
     CD4L95(Count)=prctile(TestingCD4, 2.5);
end

clf;
hold on;
plot(t, CD4Median);
plot(t,CD4U95);
plot(t,CD4L95);
hold off;
end