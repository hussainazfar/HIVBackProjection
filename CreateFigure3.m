
%% Figure 3a 
disp('Calculating the output for Figure 3');
disp(' ');
YearVectorLabel=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2));

%find the mean and the 95% confidence interval
UCI=prctile(DistributionDiagnosedInfections, 97.5, 1);
LCI=prctile(DistributionDiagnosedInfections, 2.5, 1);
Median=median(DistributionDiagnosedInfections, 1);

figure
hold on
DiagnosesHandle=plot(DiagnosesByYear.Time, DiagnosesByYear.N, 'Color' , [0.3 0.3 0.3], 'LineStyle', '.' ,'MarkerSize',20);

BackProjectedInfectionsHandle=plot(YearVectorLabel, Median, 'Color' , [0.0 0.0 0.0],'LineWidth',2, 'LineStyle', '-');
UncertaintyHandle=plot(YearVectorLabel, UCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
plot(YearVectorLabel, LCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');

xlabel('Year','fontsize', 22);
ylabel('Number of cases','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;

xlim([PlotSettings.YearsToPlot(1) PlotSettings.YearsToPlot(2)])
ylim([0 ceil((max(DiagnosesByYear.N))/500)*500])


h_legend=legend([DiagnosesHandle BackProjectedInfectionsHandle BackProjectedInfectionsHandle UncertaintyHandle], 'Diagnoses', 'Back-projected incidence', 'of diagnosed cases', '95% uncertainty bound',  'Location','NorthEast');
set(h_legend,'FontSize',16);


legend('boxoff')

print('-dpng ','-r300','ResultsPlots/Figure 3.png')

[~, YearIndex]=min(abs(YearVectorLabel-YearOfDiagnosedDataEnd));
InfectionsString=[num2str(round(Median(YearIndex)), '%i') ' (' num2str(round(LCI(YearIndex)), '%i'), '-', num2str(round(UCI(YearIndex)), '%i'), ')'];
fileID = fopen('Results/Figure 3 Observations.txt','w');
fprintf(fileID, 'Figure 3 Depicts Backprojected Infections and Diagnoses:-\r\n\r\n');
fprintf(fileID, 'The number of infections that are placed in 2013: %s\r\n', InfectionsString);
fclose(fileID);

%% Figure 3b

YearVectorLabel=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2));

%add the two variables together to get a final result
DistributionTotal=DistributionDiagnosedInfections+DistributionUndiagnosedInfections;
UCI=prctile(DistributionTotal, 97.5, 1);
LCI=prctile(DistributionTotal, 2.5, 1);
Median=median(DistributionTotal, 1);

figure
hold on
DiagnosesHandle=plot(DiagnosesByYear.Time, DiagnosesByYear.N, 'Color' , [0.3 0.3 0.3], 'LineStyle', '.' ,'MarkerSize',20);

TotalEstimatedInfectionsHandle=plot(YearVectorLabel, Median, 'Color' , [0.0 0.0 0.0],'LineWidth',2, 'LineStyle', '-');
UncertaintyHandle=plot(YearVectorLabel, UCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
plot(YearVectorLabel, LCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');


hold off

xlabel('Year','fontsize', 22);
ylabel('Number of cases','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;

xlim([PlotSettings.YearsToPlot(1) PlotSettings.YearsToPlot(2)])
ylim([0 ceil((max(DiagnosesByYear.N))/500)*500])

%h_legend=legend([DiagnosesHandle BackProjectedInfectionsHandle TotalEstimatedInfectionsHandle], 'Diagnoses                    ', 'Diagnosed infections' , 'All infections', 'Location','NorthEast');
h_legend=legend([DiagnosesHandle TotalEstimatedInfectionsHandle, UncertaintyHandle], 'Diagnoses',  'Estimated incidence', '95% uncertainty bound', 'Location','NorthEast');

set(h_legend,'FontSize',16);

legend('boxoff')

print('-dpng ','-r300','ResultsPlots/Figure 4.png')

%% Create paper sentences
fileID = fopen('Results/Figure 4 Observations.txt','w');
fprintf(fileID, 'Figure 4 Depicts Diagnoses and Total Expected Infectionsin that year:-\r\n\r\n');
fprintf(fileID, 'The number of infections that are placed in 2013: %s\r\n', InfectionsString);
[~, YearIndex]=min(abs(YearVectorLabel-1984));
Infections1984=[num2str(round(Median(YearIndex)), '%i') ' [' num2str(round(LCI(YearIndex)), '%i'), '-', num2str(round(UCI(YearIndex)), '%i'), ']'];
[~, YearIndex]=min(abs(YearVectorLabel-1987));
Diagnoses1987=num2str(round(DiagnosesByYear.N(YearIndex)), '%i');
fprintf(fileID, 'The peak estimated infections (%s) that occurred in 1984 is somewhat lower than the peak diagnoses (%s) in 1987 as there was a back-log of infections that occurred earlier which needed to be cleared\r\n', Infections1984, Diagnoses1987);

[~, YearIndex]=min(abs(YearVectorLabel-1997));
Infections1997=[num2str(round(Median(YearIndex)), '%i') ' (' num2str(round(LCI(YearIndex)), '%i'), '-', num2str(round(UCI(YearIndex)), '%i'), ')'];
fprintf(fileID, 'Following this peak, infections reached a low of %s in 1997\r\n', Infections1997);


[~, YearIndex]=min(abs(YearVectorLabel-YearOfDiagnosedDataEnd));
InfectionsString=[num2str(round(Median(YearIndex)), '%i') ' (' num2str(round(LCI(YearIndex)), '%i'), '-', num2str(round(UCI(YearIndex)), '%i'), ')'];
DiagnosesString=num2str(round(DiagnosesByYear.N(YearIndex)), '%i');
fprintf(fileID, 'There were %s infections in the final year of data, with %s diagnoses in the final year of data\r\n', InfectionsString, DiagnosesString);
fclose(fileID);
disp('------------------------------------------------------------------');
