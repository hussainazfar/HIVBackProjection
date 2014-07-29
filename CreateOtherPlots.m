%% Create a plot of both the real and simulated CD4 at diagnosis plots on one plot
clf;
% HistogramCD4Centres=12.5:25:4987.5;
HistogramCD4Centres=25:50:4987.5;
a=CD4ComparisonLookup;%to minimise code size
RealTestingCD4=[ CD4Comparison(a==2009).RealTestingCD4 CD4Comparison(a==2010).RealTestingCD4 CD4Comparison(a==2011).RealTestingCD4 CD4Comparison(a==2012).RealTestingCD4 CD4Comparison(a==2013).RealTestingCD4];
SimulatedTestingCD4=[ CD4Comparison(a==2009).SimulatedTestingCD4 CD4Comparison(a==2010).SimulatedTestingCD4 CD4Comparison(a==2011).SimulatedTestingCD4 CD4Comparison(a==2012).SimulatedTestingCD4 CD4Comparison(a==2013).SimulatedTestingCD4];

[SimulatedCD4Histogram, X] =hist(reshape(SimulatedTestingCD4, 1, []), HistogramCD4Centres);%Collapse all the simulations into a single variable to get something analoguous to a "mean"
[RealCD4Histogram, X] =hist(RealTestingCD4, HistogramCD4Centres);
hold on;
RealCD4Handle=plot(HistogramCD4Centres, RealCD4Histogram./sum(RealCD4Histogram)*100, 'k.','MarkerSize',15);
SimulatedCD4Handle=plot(HistogramCD4Centres, SimulatedCD4Histogram./sum(SimulatedCD4Histogram)*100, 'Color' , [1.0 0.0 0.0],'LineWidth',2,'LineStyle', '-', 'Marker', '.', 'MarkerSize',15);
hold off;

xlabel('CD4 count (cells/\muL) at diagnosis','fontsize', 22);
ylabel('Proportion diagnosed at this CD4 (%)','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18);
box off;

xlim([0 2000]);

h_legend=legend([RealCD4Handle SimulatedCD4Handle], 'Diagnosis data', 'Simulated diagnoses', 'Location','NorthEast');
set(h_legend,'FontSize',16);


legend('boxoff')

print('-dpng ','-r300','ResultsPlots/Appendix Figure 1 CD4AtDiagnosisComparison2009to2013.png')


%% Output the same figure by tenths of a year
clf;%clear the current figure ready for plotting
    PreciseYearVectorLabel=CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)-StepSize);
    
    %finding the uncertainty in the 0.1 year intervals
    %find the mean and the 95% confidence interval
    UCI=prctile(DistributionDiagnosedInfectionsPrecise, 97.5, 1);
    LCI=prctile(DistributionDiagnosedInfectionsPrecise, 2.5, 1);
    Mean=mean(DistributionDiagnosedInfectionsPrecise, 1);
    hold on;
    BackProjectedInfectionsHandle=plot(PreciseYearVectorLabel, [Mean], 'r');
    plot(PreciseYearVectorLabel, [UCI; LCI], 'r');
    hold off;



    %add the two variables together to get a final result
    DistributionTotalPrecise=DistributionDiagnosedInfectionsPrecise+DistributionUndiagnosedInfectionsPrecise;
    UCI=prctile(DistributionTotalPrecise, 97.5, 1);
    LCI=prctile(DistributionTotalPrecise, 2.5, 1);
    Mean=mean(DistributionTotalPrecise, 1);
    hold on
    TotalEstimatedInfectionsHandle=plot(PreciseYearVectorLabel, [Mean], 'b');
    plot(PreciseYearVectorLabel, [ UCI; LCI], 'b');
    hold off
    
    hold on
    DiagnosesHandle=plot(CD4BackProjectionYears(1):StepSize:CD4BackProjectionYears(2), Diagnoses, 'k.');
    hold off
    
    xlabel('Year','fontsize', 22);
    ylabel('Number of cases','fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;
    
    xlim([PlotSettings.YearsToPlot(1) PlotSettings.YearsToPlot(2)])
    
    
    %legend([DiagnosesHandle BackProjectedInfectionsHandle TotalEstimatedInfectionsHandle], 'Diagnoses                    ', 'Back-projected infections' , 'Total estimated infections', 'Location','NorthEast');
    
    h_legend=legend([DiagnosesHandle BackProjectedInfectionsHandle TotalEstimatedInfectionsHandle], 'Diagnoses                    ', 'Diagnosed infections' , 'All infections', 'Location','NorthEast');
    set(h_legend,'FontSize',16);
    
    
    legend('boxoff')
    
    print('-dpng ','-r300','ResultsPlots/Diagnoses and Infections Fine Detail.png')
    
    
    %% Output the forward projected estimates
 clf;%clear the current figure ready for plotting
    YearVectorLabel=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2)-1);
    
    %find the mean and the 95% confidence interval
    UCI=prctile(DistributionUndiagnosedInfections, 97.5, 1);
    LCI=prctile(DistributionUndiagnosedInfections, 2.5, 1);
    Mean=mean(DistributionUndiagnosedInfections, 1);
    ForwardProjectedInfectionsHandle=plot(YearVectorLabel, Mean, 'Color' , [0.0 0.0 0.0],'LineWidth',2, 'LineStyle', '-');
    hold on;
    plot(YearVectorLabel, UCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
    plot(YearVectorLabel, LCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
    

    
    xlabel('Year','fontsize', 22);
    ylabel('Number of cases','fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;
    
    xlim([PlotSettings.YearsToPlot(1) PlotSettings.YearsToPlot(2)])
    ylim([0 max(DiagnosesByYear)])
    
    %legend([DiagnosesHandle BackProjectedInfectionsHandle ], 'Diagnoses                    ', 'Back-projected infections' ,  'Location','NorthEast')
    
    h_legend=legend([ ForwardProjectedInfectionsHandle], 'Incidence of infections not yet diagnosed' ,  'Location','NorthEast');
    set(h_legend,'FontSize',16);
    
    
    legend('boxoff')
    
    print('-dpng ','-r300','ResultsPlots/Unused figure Forward projected Infections Only.png')


    %% output a distribution of times until diagnosis
clf;%clear the current figure ready for plotting

InfectionTimeToPlot=reshape(InfectionTimeMatrix, 1, []);
MeanTimeDistribution=hist(InfectionTimeToPlot, 0.5:1:MaxYears);
% MeanTimeDistribution=hist(InfectionTimeToPlot, 0.0:StepSize:MaxYears);
    %MeanTimeDistribution=hist(TimeDistributionOfRecentDiagnoses, 0.0:StepSize:MaxYears);
    MeanTimeDistribution=MeanTimeDistribution/sum(MeanTimeDistribution);
%     area(0.0:StepSize:MaxYears, MeanTimeDistribution);%, 'k.','MarkerSize',20);
bar(1:1:MaxYears, MeanTimeDistribution);%, 'k.','MarkerSize',20);
    xlabel({'Time between infection and diagnosis' '(years)'},'fontsize', 22);
    ylabel('Proportion of cases','fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;
    set(gca,'XTick',0.0:MaxYears)
    xlim([0.5 15.5])
    print('-dpng ','-r300','ResultsPlots/Unused Figure Distribution of times until diagnosis.png');%(using fit times only)
    
%% output median CD4 count at diagnosis
clf;%clear the current figure ready for plotting
YearIndex=0;
YearsToPlot=1980:YearOfDiagnosedDataEnd;
for Year=YearsToPlot
    disp(Year)
    YearIndex=YearIndex+1;
    TempCD4=[];
    for P=Patient
        if (P.DateOfDiagnosisContinuous>=Year && P.DateOfDiagnosisContinuous<Year+1)
            TempCD4=[TempCD4  P.CD4CountAtDiagnosis];
        end
    end
    CD4ToGraph(YearIndex)=median(TempCD4);
end
clf;
plot(YearsToPlot, CD4ToGraph, '.','MarkerSize',15);
    xlabel({'Year'},'fontsize', 22);
    ylabel('Median CD4 count (cells/\muL) at diagnosis','fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;


    print('-dpng ','-r300','ResultsPlots/Appendix Figure 2 Median CD4 count at diagnosis.png');%(using fit times only)

    
%% This plotting of example individual stochasticity
% See GenerateTheoreticalPopulation.m
% Hughes, M.D. et al "Within-Subject Variation in CD4..." 1994 JID
% On the loge scale, the relationship between the within-subject SO and the underlying CD4 cell count of mu was given by (sigma = 0.930 - 0.110 loge(mu).

%Testing this result
LogSamples=zeros(1, 10000);
mustore=zeros(1, 10000);
for i=1:10000
    mu=500*rand();
    logmu=log(mu+10);%plus 10 to avoid the problems associated with log zero
    sigma = 0.930 - 0.110*logmu;
    LogSamples(i)=normrnd(logmu,sigma);
    mustore(i)=mu;
end

clf;
plot(mustore, exp(LogSamples), 'r.');

xlabel({'Median CD4 count (cells/\muL)'},'fontsize', 22);
    ylabel({'Modelled single measurement' 'of CD4 count (cells/\muL)'},'fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;


    print('-dpng ','-r300','ResultsPlots/Appendix Figure 3 Stochasticity of the CD4 Count.png');%(using fit times only)
    
    
%% Outputting the total size of the duplicates
[~, NumOfPatientInSim]=size(Patient);
[~, NumberOfDuplicates]=size(DuplicatePatient);
disp(['There were ' str2num(NumberOfDuplicates) ' duplicates and ' str2num(NumOfPatientInSim) ' records included in the final simulation.']);
