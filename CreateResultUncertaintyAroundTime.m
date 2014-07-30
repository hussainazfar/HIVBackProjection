%Pre-allocating memory
YearIndex=0;
TimeSinceInfectionYearIndex=CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2);
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    for SimNumber=1:NumSims
        TimeSinceInfectionMatrix(YearIndex).Sim(SimNumber).Time=-1*ones(1, NumberOfPatients);
    end
end


for i=1:NumberOfPatients

    
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
hold on;
MeanHandle=CreateUncertaintyPlot(TimeSinceInfectionYearIndex-0.1, TimeSinceInfectionMeanMean, TimeSinceInfectionMeanUCI, TimeSinceInfectionMeanLCI, 'r');
hold on;
MedianHandle=CreateUncertaintyPlot(TimeSinceInfectionYearIndex+0.1, TimeSinceInfectionMedianMean, TimeSinceInfectionMedianUCI, TimeSinceInfectionMedianLCI, 'b');
xlim([1982.5 CD4BackProjectionYearsWhole(2)+1])
ylim([0 15])
xlabel('Year of diagnosis','fontsize', 22);
ylabel({'Time between infection and diagnosis', '(95% uncertainty bound)'},'fontsize', 22);
set(gca,'YTick',0:1:15)
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
h_legend=legend([ MeanHandle MedianHandle], {'Mean', 'Median'} ,  'Location','NorthEast');



print('-dpng ','-r300','ResultsPlots/Appendix Uncertainty in time until diagnosis.png')

disp('Note that this section calculates the uncertainty in the mean and median estimate, and does not represent the distribution of individuals within a particular simulation');
disp(['The mean time between infection and diagnosis in the final year of simulation is etimated to be ' num2str( TimeSinceInfectionMeanMean(end)) '(' num2str( TimeSinceInfectionMeanLCI(end)) '-' num2str( TimeSinceInfectionMeanUCI(end)) ') years.']);
disp(['The median time between infection and diagnosis in the final year of simulation is etimated to be ' num2str( TimeSinceInfectionMedianMean(end)) '(' num2str( TimeSinceInfectionMedianLCI(end)) '-' num2str( TimeSinceInfectionMedianUCI(end)) ') years.']);
