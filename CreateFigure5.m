



%% Output undiagnosed testing probabilities
    
    clf;%clear the current figure ready for plotting
    YearVectorLabel=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2));
    
    %find the mean and the 95% confidence interval
    UCI=prctile(YearlyEffectiveTestingRate, 97.5, 1);
    LCI=prctile(YearlyEffectiveTestingRate, 2.5, 1);
    Median=median(YearlyEffectiveTestingRate, 1);
    
    hold on;
    hquart=plot(YearVectorLabel, UCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
    plot(YearVectorLabel, LCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
    hmed=plot(YearVectorLabel, Median, 'Color' , [0.0 0.0 0.0],'LineWidth',2);

    
    xlabel('Year','fontsize', 22);
    ylabel({'Annual probability of testing' 'among people with undiagnosed HIV'},'fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;
    
    xlim([1980 2013])
    h_legend=legend([hmed hquart], {'Median', '95% uncertainty bound'},  'Location','SouthEast');
    set(h_legend,'FontSize',16);
    legend('boxoff');
    print('-dpng ','-r300','ResultsPlots/Figure 5a ProbabilityOfTestingByYear.png')

%% Output paper sentence
disp('Figure 5a')
[~, YearIndex]=min(abs(YearVectorLabel-1999));
String1999TestingProbability=[num2str(Median(YearIndex), '%.2f') ' [' num2str(LCI(YearIndex), '%.2f'), '-', num2str(UCI(YearIndex), '%.2f'), ']'];
[~, YearIndex]=min(abs(YearVectorLabel-YearOfDiagnosedDataEnd));
StringFinalTestingProbability=[num2str(Median(YearIndex), '%.2f') ' (' num2str(LCI(YearIndex), '%.2f'), '-', num2str(UCI(YearIndex), '%.2f'), ')'];


disp(['The model estimates that the annual testing probabilty fell to the lowest point (p=' String1999TestingProbability ') in 1999, the year which coincides with the lowest number of diagnoses. ' ...
    'Testing probailities are calculated to have increased since then, with the annual testing probability in the final year of data at p=' StringFinalTestingProbability '. ']);


%% Output time until diagnosis by year
    
%determine median and interquartile ranges

StartYearForTimeUntilDiagnosisPlot=1982;

YearIndex=0;
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    %Remove all of the unfilled values as above
%     TimeSinceInfection(YearIndex).v(TimeSinceInfection(YearIndex).v<0)=[];
    
    TimeSinceInfectionMedian(YearIndex)=median(TimeSinceInfection(YearIndex).v);
    TimeSinceInfectionLQR(YearIndex)=prctile(TimeSinceInfection(YearIndex).v, 25);
    TimeSinceInfectionUQR(YearIndex)=prctile(TimeSinceInfection(YearIndex).v, 75);
    
    TimeSinceInfectionMean(YearIndex)=mean(TimeSinceInfection(YearIndex).v);

end

clf;%clear the current figure ready for plotting
    YearVectorLabel=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2));  

    PlotIndex=TimeSinceInfectionYearIndex>StartYearForTimeUntilDiagnosisPlot-0.5;
    
    
    hold on;
    hquart=plot(YearVectorLabel(PlotIndex), TimeSinceInfectionLQR(PlotIndex), 'Color' , [0.5 0.5 0.5],'LineWidth',2);
    plot(YearVectorLabel(PlotIndex), TimeSinceInfectionUQR(PlotIndex), 'Color' , [0.5 0.5 0.5],'LineWidth',2);
    hmed=plot(YearVectorLabel(PlotIndex), TimeSinceInfectionMedian(PlotIndex), 'Color' , [0.0 0.0 0.0],'LineWidth',2);

    
    xlabel('Year of diagnosis','fontsize', 22);
    ylabel({'Estimated time between' 'infection and diagnosis (years)'},'fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;
    
    xlim([1980 2013])

    h_legend=legend([hmed hquart], {'Median', 'Quartiles'},  'Location','NorthEast');
    set(h_legend,'FontSize',16);
    legend('boxoff');
    print('-dpng ','-r300','ResultsPlots/Figure 5b MedianAndIQROfTimeUntilDiagnosisByYear.png')
    
%% Output paper sentence
disp('Figure 5b')
[~, YearIndex]=min(abs(YearVectorLabel-CD4BackProjectionYearsWhole(2)));
StringFinalYearTime=[num2str(TimeSinceInfectionMedian(YearIndex), '%.1f') ' (IQR: ' num2str(TimeSinceInfectionLQR(YearIndex), '%.1f'), '-', num2str(TimeSinceInfectionUQR(YearIndex), '%.1f'), ')'];
disp([' The median time between infection and diagnosis for people diagnosed in the last year of data was estimated at ' StringFinalYearTime ' years.']);
disp(['Mean time between infection and diagnosis in the final year of data was ' num2str(TimeSinceInfectionMean(YearIndex)) ' years']);

[~, YearIndex]=min(abs(YearVectorLabel-1985));
String1985Time=[num2str(TimeSinceInfectionMedian(YearIndex), '%.1f') ' (IQR: ' num2str(TimeSinceInfectionLQR(YearIndex), '%.1f'), '-', num2str(TimeSinceInfectionUQR(YearIndex), '%.1f'), ')'];
disp([' This is a substantial reduction from 1985, where median time until diagnosis was estimated to be ' String1985Time ' years.']);
disp(['Mean time between infection and diagnosis in 1985 was ' num2str(TimeSinceInfectionMean(YearIndex)) ' years']);


%% Looking at results in the final year
MSMTimeUntilDiagIndexFinalYear=false(size(Patient));
NonMSMTimeUntilDiagIndexFinalYear=false(size(Patient));

for i=1:NumberOfPatients
    if 2013<=Patient(i).DateOfDiagnosisContinuous && Patient(i).DateOfDiagnosisContinuous<2014
        if Patient(i).ExposureRoute<=4
            MSMTimeUntilDiagIndexFinalYear(i)=true;
        else
            NonMSMTimeUntilDiagIndexFinalYear(i)=true;
        end
    end
end

%%  MSM
MSMTimeUntilDiagFinalYear=Patient(MSMTimeUntilDiagIndexFinalYear);
[~, NumMSMDiagFinalYear]=size(MSMTimeUntilDiagFinalYear);
MSMTimeUntilDiagnosisFinalYear=zeros(NoParameterisations, NumMSMDiagFinalYear);
for i=1:NumMSMDiagFinalYear
    MSMTimeUntilDiagnosisFinalYear(:, i)=MSMTimeUntilDiagFinalYear(i).TimeFromInfectionToDiagnosis;
end

MeanVectorMSMTime=mean(MSMTimeUntilDiagnosisFinalYear, 2);
MeanMeanMSM=median(MeanVectorMSMTime, 1);
MeanMeanMSMLLCI=prctile(MeanVectorMSMTime, 2.5, 1);
MeanMeanMSMLUCI=prctile(MeanVectorMSMTime, 97.5, 1);
disp('Median time to diagnosis in final year, -MSM (figure 5)');
disp([num2str(MeanMeanMSM),' ',  num2str(MeanMeanMSMLLCI),'-', num2str(MeanMeanMSMLUCI)]);


%% Non MSM
NonMSMTimeUntilDiagFinalYear=Patient(NonMSMTimeUntilDiagIndexFinalYear);
[~, NumNonMSMDiagFinalYear]=size(NonMSMTimeUntilDiagFinalYear);
NonMSMTimeUntilDiagnosisFinalYear=zeros(NoParameterisations, NumNonMSMDiagFinalYear);
for i=1:NumNonMSMDiagFinalYear
    NonMSMTimeUntilDiagnosisFinalYear(:, i)=NonMSMTimeUntilDiagFinalYear(i).TimeFromInfectionToDiagnosis;
end

MeanVectorNonMSMTime=mean(NonMSMTimeUntilDiagnosisFinalYear, 2);
MeanMeanNonMSM=median(MeanVectorNonMSMTime, 1);
MeanMeanNonMSMLLCI=prctile(MeanVectorNonMSMTime, 2.5, 1);
MeanMeanNonMSMLUCI=prctile(MeanVectorNonMSMTime, 97.5, 1);
disp('Median time to diagnosis in final year, non-MSM (figure 5)');
disp([num2str(MeanMeanNonMSM),' ',  num2str(MeanMeanNonMSMLLCI),'-', num2str(MeanMeanNonMSMLUCI)]);
