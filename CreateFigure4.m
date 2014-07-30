%% Output total undiagnosed with time
    
clf;%clear the current figure ready for plotting
YearVectorLabel=CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize);

%find the median and the 95% confidence interval
UCI=prctile(TotalUndiagnosedByTime, 97.5, 1);
LCI=prctile(TotalUndiagnosedByTime, 2.5, 1);
Median=median(TotalUndiagnosedByTime, 1);

hold on;
h95=plot(YearVectorLabel, UCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
plot(YearVectorLabel, LCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
hmed=plot(YearVectorLabel, Median, 'Color' , [0.0 0.0 0.0],'LineWidth',2);


xlabel('Year','fontsize', 22);
ylabel('Estimated total of undiagnosed HIV','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
xlim([PlotSettings.YearsToPlot(1) PlotSettings.YearsToPlot(2)])

h_legend=legend([hmed h95], {'Median', '95% uncertainty bound'},  'Location','NorthEast');
set(h_legend,'FontSize',16);
legend('boxoff');
print('-dpng ','-r300','ResultsPlots/Figure 4 TotalUndiagnosedByTime.png')

%% Paper sentences
[~, YearIndex]=min(abs(YearVectorLabel-1985));
String1985max=[num2str(round(Median(YearIndex)), '%i') ' (' num2str(round(LCI(YearIndex)), '%i'), '-', num2str(round(UCI(YearIndex)), '%i'), ')'];
[~, YearIndex]=min(abs(YearVectorLabel-1998.6));
String1998min=[num2str(round(Median(YearIndex)), '%i') ' (' num2str(round(LCI(YearIndex)), '%i'), '-', num2str(round(UCI(YearIndex)), '%i'), ')'];
[~, YearIndex]=min(abs(YearVectorLabel-(YearOfDiagnosedDataEnd-0.1)));
StringLastYearData=[num2str(round(Median(YearIndex)), '%i') ' (' num2str(round(LCI(YearIndex)), '%i'), '-', num2str(round(UCI(YearIndex)), '%i'), ')'];
disp(['The model estimates that the number of people living with undiagnosed HIV peaked in 1985 at ' String1985max ', before falling to a low of ' String1998min ' people in 1998.' ...
    ' It is estimated that at the end of the last year of data, ' StringLastYearData ' people were living with undiagnosed HIV.']);
