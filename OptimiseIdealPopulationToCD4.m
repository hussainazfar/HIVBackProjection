function [IdealPopTimes, IdealPopStartingCD4s, IdealPopTestingCD4, PEstimate]=OptimiseIdealPopulationToCD4(RealTestingCD4, Pxi, SimulatedPopSize)
%This is a linear stochastic opitmisation, so it should be fairly quick to fit

Tolerance=1;%if the median of the distribution +/- 1 the requested distribution, then it is acceptable. 
MaximumLoops=1000;%1000;%the maximum loop
BestError=10^50;% a large number
BestPEstimate=rand();%0.5;
Variability=0.5;
LoopsSinceBetterResult=0;

RealDataMedianCD4Count=median(RealTestingCD4);


[~, NumberOfCD4s]=size(RealTestingCD4);

for LoopNumber=1:MaximumLoops
    LoopsSinceBetterResult=LoopsSinceBetterResult+1;
    CurrentPAttempt=BestPEstimate+Variability*(1-2*rand());%Vary the best estimate a little
    % avoid errors when dealing with testing later on
    while CurrentPAttempt<=0 || CurrentPAttempt>=1
        CurrentPAttempt=BestPEstimate+Variability*(1-2*rand());%Vary the best estimate a little
    end
    
    
    [TimeUntilDiagnosis]=GenerateTimeUntilDiagnosis(SimulatedPopSize, CurrentPAttempt, NumberOfCD4s, Pxi);
    
    [TimeUntilDiagnosis, StartingCD4, SimulatedTestingCD4]=GenerateTheoreticalPopulationCD4s(TimeUntilDiagnosis, Pxi);
    
    % Select the appropriate number of cases
    SelectedSimulatedCD4s = datasample(SimulatedTestingCD4,NumberOfCD4s,'Replace',true);

    %% Determine error of the function
    
    %Simple error
    SimulatedMedianCD4=median(SelectedSimulatedCD4s);
    ThisError=abs(RealDataMedianCD4Count-SimulatedMedianCD4);

    if ThisError<BestError
        BestError=ThisError;
        LoopsSinceBetterResult=0;
        BestPEstimate=CurrentPAttempt;
        IdealPopTimes=TimeUntilDiagnosis;
        IdealPopStartingCD4s=StartingCD4;
        IdealPopTestingCD4=SimulatedTestingCD4;
    end
    if BestError<Tolerance
        break;
    end
    if LoopsSinceBetterResult>10 %cool the temperature if it has been a while since a better error was returned
        Variability=Variability*0.9;
    end
end

% disp(LoopNumber)

%% test this location 100 times, determine the median error
ErrorVec=zeros(1, 100);
for i=1:100
    [TimeUntilDiagnosis]=GenerateTimeUntilDiagnosis(SimulatedPopSize, CurrentPAttempt, NumberOfCD4s, Pxi);
    [TimeUntilDiagnosis, StartingCD4, SimulatedTestingCD4]=GenerateTheoreticalPopulationCD4s(TimeUntilDiagnosis, Pxi);
    SelectedSimulatedCD4s = datasample(SimulatedTestingCD4,NumberOfCD4s,'Replace',true);
    SimulatedMedianCD4=median(SelectedSimulatedCD4s);
    ErrorVec(i)=abs(RealDataMedianCD4Count-SimulatedMedianCD4);
end

MedianErrorAtPoint=median(ErrorVec);
ThisError=10^50;% a large number
while ThisError>MedianErrorAtPoint
    %keep sampling uniformly until you find one simulated P which beats the median
    CurrentPAttempt=rand();
    [TimeUntilDiagnosis]=GenerateTimeUntilDiagnosis(SimulatedPopSize, CurrentPAttempt, NumberOfCD4s, Pxi);
    [TimeUntilDiagnosis, StartingCD4, SimulatedTestingCD4]=GenerateTheoreticalPopulationCD4s(TimeUntilDiagnosis, Pxi);
    SelectedSimulatedCD4s = datasample(SimulatedTestingCD4,NumberOfCD4s,'Replace',true);
    SimulatedMedianCD4=median(SelectedSimulatedCD4s);
    ThisError=abs(RealDataMedianCD4Count-SimulatedMedianCD4);
end
PEstimate=CurrentPAttempt;
IdealPopTimes=TimeUntilDiagnosis;
IdealPopStartingCD4s=StartingCD4;
IdealPopTestingCD4=SimulatedTestingCD4;

end
 