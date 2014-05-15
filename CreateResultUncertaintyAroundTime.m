%Pre-allocating memory
YearIndex=0;
TimeSinceInfectionYearIndex=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2)-1);
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    for SimNumber=1:NumSims
        TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time=-1*ones(1, NumberOfPatients);
    end
end

% for i=1:NumberOfPatients
%     if mod(i, 1000)==0
%         disp(i)
%     end
%     YearIndex=0;
%     for Year=TimeSinceInfectionYearIndex
%         YearIndex=YearIndex+1;
%         if Patient(i).DateOfDiagnosisContinuous>= Year && Patient(i).DateOfDiagnosisContinuous< Year+1
%             for SimNumber=1:NumSims
%                 TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time(i)=Patient(i).TimeFromInfectionToDiagnosis(SimNumber);
%             end
%         end
%     end
% end

for i=1:NumberOfPatients
    if mod(i, 1000)==0
        disp(i)
    end
%     YearIndex=0;
%     for Year=TimeSinceInfectionYearIndex
%         YearIndex=YearIndex+1;
%         if Patient(i).DateOfDiagnosisContinuous>= Year && Patient(i).DateOfDiagnosisContinuous< Year+1
%             for SimNumber=1:NumSims
%                 TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time(i)=Patient(i).TimeFromInfectionToDiagnosis(SimNumber);
%             end
%         end
%     end
    
    YearIndex=Patient(i).DateOfDiagnosisContinuous>= TimeSinceInfectionYearIndex & Patient(i).DateOfDiagnosisContinuous< TimeSinceInfectionYearIndex+1;
    for SimNumber=1:NumSims
        TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time(i)=Patient(i).TimeFromInfectionToDiagnosis(SimNumber);
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

%Find the median, mean, IQR for each sim
YearIndex=0;
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    for SimNumber=1:NumSims
        TimeSinceInfectionMatrix(YearIndex).Mean(SimNumber)=mean(TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time);
        TimeSinceInfectionMatrix(YearIndex).Median(SimNumber)=median(TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time);
        TimeSinceInfectionMatrix(YearIndex).LQR(SimNumber)=prctile(TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time, 25);
        TimeSinceInfectionMatrix(YearIndex).UQR(SimNumber)=prctile(TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time, 75);
    end
    TimeSinceInfectionMatrix(YearIndex).MeanMean=mean(TimeSinceInfectionMatrix(YearIndex).Mean);
    TimeSinceInfectionMatrix(YearIndex).MeanLCI=prctile(TimeSinceInfectionMatrix(YearIndex).Mean, 2.5);
    TimeSinceInfectionMatrix(YearIndex).MeanUCI=prctile(TimeSinceInfectionMatrix(YearIndex).Mean, 97.5);
    
    TimeSinceInfectionMatrix(YearIndex).MedianMean=mean(TimeSinceInfectionMatrix(YearIndex).Median);
    TimeSinceInfectionMatrix(YearIndex).MedianLCI=prctile(TimeSinceInfectionMatrix(YearIndex).Median, 2.5);
    TimeSinceInfectionMatrix(YearIndex).MedianUCI=prctile(TimeSinceInfectionMatrix(YearIndex).Median, 97.5);
end


