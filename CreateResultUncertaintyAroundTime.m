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
    TimeSinceInfectionMeanMean(YearIndex)=mean(TimeSinceInfectionMatrix(YearIndex).Mean);
    TimeSinceInfectionMeanLCI(YearIndex)=prctile(TimeSinceInfectionMatrix(YearIndex).Mean, 2.5);
    TimeSinceInfectionMeanUCI(YearIndex)=prctile(TimeSinceInfectionMatrix(YearIndex).Mean, 97.5);
    
    TimeSinceInfectionMedianMean(YearIndex)=mean(TimeSinceInfectionMatrix(YearIndex).Median);
    TimeSinceInfectionMedianLCI(YearIndex)=prctile(TimeSinceInfectionMatrix(YearIndex).Median, 2.5);
    TimeSinceInfectionMedianUCI(YearIndex)=prctile(TimeSinceInfectionMatrix(YearIndex).Median, 97.5);
end

clf;

plot(TimeSinceInfectionYearIndex, TimeSinceInfectionMeanMean, 'b-');
hold on;
plot(TimeSinceInfectionYearIndex, TimeSinceInfectionMeanLCI, 'b--');
plot(TimeSinceInfectionYearIndex, TimeSinceInfectionMeanUCI, 'b--');

plot(TimeSinceInfectionYearIndex, TimeSinceInfectionMedianMean, 'r-');
plot(TimeSinceInfectionYearIndex, TimeSinceInfectionMedianLCI, 'r--');
plot(TimeSinceInfectionYearIndex, TimeSinceInfectionMedianUCI, 'r--');
hold off;

print('-dpng ','-r300','ResultsPlots/Appendix Uncertainty in time until diagnosis.png')

disp(['The mean time between infection and diagnosis in the final year of simulation is etimated to be ' num2str( TimeSinceInfectionMeanMean(end)) '(' num2str( TimeSinceInfectionMeanLCI(end)) '-' num2str( TimeSinceInfectionMeanUCI(end)) ') years.']);
disp(['The median time between infection and diagnosis in the final year of simulation is etimated to be ' num2str( TimeSinceInfectionMedianMean(end)) '(' num2str( TimeSinceInfectionMedianLCI(end)) '-' num2str( TimeSinceInfectionMedianUCI(end)) ') years.']);
