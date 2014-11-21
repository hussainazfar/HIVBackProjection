function CreateFigure4(TotalUndiagnosedByTime, YearsToPlot, FileName)
%% Output total undiagnosed with time
    
clf;%clear the current figure ready for plotting


%find the median and the 95% confidence interval
UCI=prctile(TotalUndiagnosedByTime.N, 97.5, 1);
LCI=prctile(TotalUndiagnosedByTime.N, 2.5, 1);
Median=median(TotalUndiagnosedByTime.N, 1);

hold on;
h95=plot(TotalUndiagnosedByTime.Time, UCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
plot(TotalUndiagnosedByTime.Time, LCI, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '--');
hmed=plot(TotalUndiagnosedByTime.Time, Median, 'Color' , [0.0 0.0 0.0],'LineWidth',2);


xlabel('Year','fontsize', 22);
ylabel('Estimated total of undiagnosed HIV','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
xlim(YearsToPlot)

h_legend=legend([hmed h95], {'Median', '95% uncertainty bound'},  'Location','NorthEast');
set(h_legend,'FontSize',16);
legend('boxoff');

print('-dpng ','-r300',['ResultsPlots/' FileName '.png']) 