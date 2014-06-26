%% Output plot of progression

PopulationSizeToSimulate=1000000;%1000000;

Ax=Px;
Ax.SquareRootAnnualDecline=median(Ax.SquareRootAnnualDeclineVec);
Ax.FractionalDeclineToRebound=median(Px.FractionalDeclineToReboundVec);
[TimeUntilDiagnosis, ~, TestingCD4]=GenerateTheoreticalPopulationCD4s(20*rand(1, PopulationSizeToSimulate), Ax);

testCD4=TestingCD4;
Count=0;
clear     MedianVec UCIVec LCIVec UQRVec LQRVec;
% for t=0:0.1:20
Granularity=0.1;
EndYear=10;
for t=0:Granularity:EndYear
    Count=Count+1;
    ttindex=TimeUntilDiagnosis>=t & TimeUntilDiagnosis<t+Granularity;
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
ylim([0 1500]);
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
ylim([0 1500]);
xlabel('PDF','fontsize', 22);
ylabel('CD4 count (cells/\muL)','fontsize', 22);
set(gca,'YTick',0:100:1500)
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;

print('-dpng ','-r300','ResultsPlots/Figure 1 Trend of CD4 decay.png')

%% Output paper sentences
disp('Figure 1')
disp(['The healthy CD4 count distribution had a median of ' num2str(exp(Px.MedianLogHealthyCD4), '%.0f') ' and standard deviation of ' num2str(Px.StdLogHealthyCD4, '%.3f')]);
HealthyCD4VecTest=exp(normrnd(Px.MedianLogHealthyCD4, Px.StdLogHealthyCD4, [1 100000]));
HealthyCD4LQR=prctile(HealthyCD4VecTest, 25);
HealthyCD4UQR=prctile(HealthyCD4VecTest, 75);
disp(['The healthy CD4 count distribution had an interquartile range of (' num2str(HealthyCD4LQR, '%.0f') '-' num2str(HealthyCD4UQR, '%.0f') ')' ]);





% disp(['The time it takes for the median CD4 count to reach 500 is '  num2str(MedianMedian500) '(' num2str(LCIMedian500) '-' num2str(UCIMedian500) ') years.'])
% disp(['The time it takes for the median CD4 count to reach 350 is '  num2str(MedianMedian350) '(' num2str(LCIMedian350) '-' num2str(UCIMedian350) ') years.'])
% disp(['The time it takes for the median CD4 count to reach 200 is '  num2str(MedianMedian200) '(' num2str(LCIMedian200) '-' num2str(UCIMedian200) ') years.'])












PopulationSizeToSimulate=10000;
Median500=[];
Median350=[];
Median200=[];
CurrentMedianStore=zeros(NumberOfSamples, 200);
for CurrentParamNumber=1:NumberOfSamples
    CurrentParamNumber
    Pxi=Px;
    Pxi.SquareRootAnnualDecline=Px.SquareRootAnnualDeclineVec(CurrentParamNumber);
    Pxi.FractionalDeclineToRebound=Px.FractionalDeclineToReboundVec(CurrentParamNumber);
    [TimeUntilDiagnosis, ~, TestingCD4]=GenerateTheoreticalPopulationCD4s(20*rand(1, PopulationSizeToSimulate), Pxi);
    
    % search for elements with approximately the right CD4 count
%     Year=0.4;%to avoid the problem of the rapid decline
    
    CD4200Found=false;
    CD4350Found=false;
    CD4500Found=false;
    
    Year=0;
    YearStep=0;
    while (Year<20)
        YearStep=YearStep+1;
        CurrentMedian= median(TestingCD4(Year<=TimeUntilDiagnosis & TimeUntilDiagnosis<Year+0.1));
        CurrentMedianStore(CurrentParamNumber,YearStep)=CurrentMedian;
%         if CurrentMedian<500 && CD4500Found==false
%             Median500(CurrentParamNumber)=Year;
%             CD4500Found=true;
%         end
%         if CurrentMedian<350 && CD4350Found==false
%             Median350(CurrentParamNumber)=Year;
%             CD4350Found=true;
%         end
%         if CurrentMedian<200 && CD4200Found==false
%             Median200(CurrentParamNumber)=Year;
%             CD4200Found=true;
%         end
        Year=Year+0.1;
    end
end


%Go through the CurrentMedianStore
%start at 0.05
for CurrentParamNumber=1:NumberOfSamples
    YearStep=0;
    for j=0.05:0.1:19.5
        YearStep=YearStep+1;
    end
end
MedianMedian500=median(Median500);
LCIMedian500=prctile(Median500, 2.5);
UCIMedian500=prctile(Median500, 97.5);
MedianMedian350=median(Median350);
LCIMedian350=prctile(Median350, 2.5);
UCIMedian350=prctile(Median350, 97.5);
MedianMedian200=median(Median200);
LCIMedian200=prctile(Median200, 2.5);
UCIMedian200=prctile(Median200, 97.5);


disp(['The time it takes for the median CD4 count to reach 500 is '  num2str(MedianMedian500) '(' num2str(LCIMedian500) '-' num2str(UCIMedian500) ') years.'])
disp(['The time it takes for the median CD4 count to reach 350 is '  num2str(MedianMedian350) '(' num2str(LCIMedian350) '-' num2str(UCIMedian350) ') years.'])
disp(['The time it takes for the median CD4 count to reach 200 is '  num2str(MedianMedian200) '(' num2str(LCIMedian200) '-' num2str(UCIMedian200) ') years.'])

% clf
% MedianMedianByYear=squeeze(median(CurrentMedianStore, 1));
% plot(CurrentMedianStore')
