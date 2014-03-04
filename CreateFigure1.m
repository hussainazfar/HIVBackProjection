%% Output plot of progression

Ax=Px;
Ax.SquareRootAnnualDeclineChosen=mean(Ax.SquareRootAnnualDeclineVec);
[TimeUntilDiagnosis, ~, TestingCD4]=GenerateTheoreticalPopulationCD4s(20*rand(1, 1000000), Ax);
testtime=TimeUntilDiagnosis;
testCD4=TestingCD4;
Count=0;
clear     MedianVec UCIVec LCIVec UQRVec LQRVec;
% for t=0:0.1:20
Granularity=0.05;
EndYear=10;
for t=0:Granularity:EndYear
    Count=Count+1;
    ttindex=testtime>=t & testtime<t+Granularity;
    CD4AtTime=testCD4(ttindex);
    MedianVec(Count)=median(CD4AtTime);
    UCIVec(Count)=prctile(CD4AtTime, 2.5);
    LCIVec(Count)=prctile(CD4AtTime, 97.5);
    UQRVec(Count)=prctile(CD4AtTime, 25);
    LQRVec(Count)=prctile(CD4AtTime, 75);
end
t=(0:Granularity:EndYear)+Granularity/2; %the above values are for the centre point
t=[0 t];
LogInitialCD4Vector = normrnd(Px.MedianLogHealthyCD4, Px.StdLogHealthyCD4, [1 1000000]);
InitialCD4Vector=exp(LogInitialCD4Vector);
    MedianVec=[median(InitialCD4Vector) MedianVec];
    UCIVec=[prctile(InitialCD4Vector, 2.5) UCIVec];
    LCIVec=[prctile(InitialCD4Vector, 97.5) LCIVec];
    UQRVec=[prctile(InitialCD4Vector, 25) UQRVec];
    LQRVec=[prctile(InitialCD4Vector, 75) LQRVec];

clf;%clear the current figure ready for plotting
subplot(1, 5, [2 3 4 5])

hold on;
hIQR=plot(t, UQRVec, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '-');
plot(t, LQRVec, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '-');    
h95=plot(t, UCIVec, 'Color' , [0.5 0.5 0.5],'LineWidth',1, 'LineStyle', '--');
plot(t, LCIVec, 'Color' , [0.5 0.5 0.5],'LineWidth',1, 'LineStyle', '--');    
hmed=plot(t, MedianVec, 'Color' , [0.0 0.0 0.0],'LineWidth',3);
hold off;
xlim([-0.01 EndYear]);
set(gca,'XTick',0:EndYear)
ylim([0 1800]);
xlabel('Time since infection (years)','fontsize', 22);
ylabel('CD4 count (cells/\muL)','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;

h_legend=legend([ hmed hIQR h95], {'Median', '25th & 75th percentile', '2.5 & 97.5 percentile'} ,  'Location','NorthEast');
set(h_legend,'FontSize',16);
    

% Create plot for side of graph
[X, Centres]=hist(InitialCD4Vector, 10:20:2010);
subplot(1, 5, 1);
maxXValue=max(X);
X=1.1*maxXValue-X;
plot(X, Centres, 'Color' , [0.0 0.0 0.0]);
hold on;
plot([1.1*maxXValue 1.1*maxXValue], [0 1800], 'Color' , [0.0 0.0 0.0]);
ylim([0 1800]);
xlabel('PDF','fontsize', 22);
ylabel('CD4 count (cells/\muL)','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;

print('-dpng ','-r300','ResultsPlots/Figure 1 Trend of CD4 decay.png')

%% Output paper sentences
disp('Figure 1')
disp(['The healthy CD4 count distribution had a median of ' num2str(exp(Px.MedianLogHealthyCD4), '%.0f') ' and standard deviation of ' num2str(Px.StdLogHealthyCD4, '%.3f')]);
disp('')
%disp(['The time it takes for the median CD4 count to reach 500 is '  num2str(1.7)  ' years.'])
%disp(['The time it takes for the median CD4 count to reach 200 is '  num2str(6.2)  ' years.'])