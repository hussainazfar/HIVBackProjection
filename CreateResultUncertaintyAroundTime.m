YearIndex=0;
TimeSinceInfectionYearIndex=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2)-1);
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    for SimNumber=1:NumSims
        TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time=-1*ones(1, NumberOfPatients);
    end
end

for i=1:NumberOfPatients
    disp(i)
    YearIndex=0;
    for Year=TimeSinceInfectionYearIndex
        YearIndex=YearIndex+1;
        if Patient(i).DateOfDiagnosisContinuous>= Year && Patient(i).DateOfDiagnosisContinuous< Year+1
            for SimNumber=1:NumSims
                TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time=Patient(i).TimeFromInfectionToDiagnosis(SimNumber);
            end
        end
    end
end

%delete empty spots
YearIndex=0;
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    for SimNumber=1:NumSims
        IndexToClear=TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time<-0.5;
        TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time(IndexToClear)=[];
    end
end