%% Output plot of progression

% PopulationSizeToSimulate=1000000;%1000000;

% Ax=Px;
% Ax.SquareRootAnnualDecline=median(Ax.SquareRootAnnualDeclineVec);
% Ax.FractionalDeclineToRebound=median(Px.FractionalDeclineToReboundVec);
% [TimeUntilDiagnosis, ~, TestingCD4]=GenerateTheoreticalPopulationCD4s(20*rand(1, PopulationSizeToSimulate), Ax);

disp('Calculating the output for plot 1');

Pxi = Px;

Pxi.FractionalDeclineToRebound = median(Px.FractionalDeclineToReboundVec);  % select a sample of this parameter
Pxi.SQRCD4Decline = median(Px.SQRCD4DeclineVec);
Pxi.SimulatedPopSize = 1000000;

TestingParameters = [0.1, 0, 0];                                            %low, flat testing rate should not bias towards high starting CD4s

[CD4CountHistogram, Data] = GenerateCD4Count(TestingParameters, Pxi);

TimeUntilDiagnosis = Data.Time;
testCD4 = Data.CD4;
Count = 0;
clear     MedianVec UCIVec LCIVec UQRVec LQRVec;

% for t=0:0.1:20
Granularity = 0.1;
MeasurementDistance = 0.01;
EndYear = 10;
t = [0.05 0.1:Granularity:EndYear];

for tval = t
    Count = Count + 1;
    ttindex = (TimeUntilDiagnosis >= tval) & (TimeUntilDiagnosis < tval + MeasurementDistance);
    CD4AtTime = testCD4(ttindex);
    MedianVec(Count) = median(CD4AtTime);
    UCIVec(Count) = prctile(CD4AtTime, 2.5);
    LCIVec(Count) = prctile(CD4AtTime, 97.5);
    UQRVec(Count) = prctile(CD4AtTime, 25);
    LQRVec(Count) = prctile(CD4AtTime, 75);
end

t = t + MeasurementDistance / 2;                                            %the above values are for the centre point
t = [0 t];
LogInitialCD4Vector = normrnd(Px.MedianLogHealthyCD4, Px.StdLogHealthyCD4, [1 Pxi.SimulatedPopSize]);
InitialCD4Vector = exp(LogInitialCD4Vector);
    MedianVec = [median(InitialCD4Vector) MedianVec];
    UCIVec = [prctile(InitialCD4Vector, 2.5) UCIVec];
    LCIVec = [prctile(InitialCD4Vector, 97.5) LCIVec];
    UQRVec = [prctile(InitialCD4Vector, 25) UQRVec];
    LQRVec = [prctile(InitialCD4Vector, 75) LQRVec];

clf;%clear the current figure ready for plotting
subplot(1, 5, [2 3 4 5])

hold on;
hIQR = plot(t, UQRVec, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '-');
plot(t, LQRVec, 'Color' , [0.5 0.5 0.5],'LineWidth',2, 'LineStyle', '-');    
h95 = plot(t, UCIVec, 'Color' , [0.5 0.5 0.5],'LineWidth',1, 'LineStyle', '--');
plot(t, LCIVec, 'Color' , [0.5 0.5 0.5],'LineWidth',1, 'LineStyle', '--');    
hmed = plot(t, MedianVec, 'Color' , [0.0 0.0 0.0],'LineWidth',3);
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

h_legend = legend([ hmed hIQR h95], {'Median', '25th & 75th percentile', '2.5 & 97.5 percentile'} ,  'Location','NorthEast');
set(h_legend,'FontSize',16);
    

% Create plot for side of graph
[X, Centres] = hist(InitialCD4Vector, 10:20:2010);
subplot(1, 5, 1);
maxXValue = max(X);
X = 1.1 * maxXValue - X;
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
HealthyCD4VecTest = exp(normrnd(Px.MedianLogHealthyCD4, Px.StdLogHealthyCD4, [1 100000]));
HealthyCD4LQR = prctile(HealthyCD4VecTest, 25);
HealthyCD4UQR = prctile(HealthyCD4VecTest, 75);
disp(['The healthy CD4 count distribution had an interquartile range of (' num2str(HealthyCD4LQR, '%.0f') '-' num2str(HealthyCD4UQR, '%.0f') ')' ]);

%% Create uncertainty in time between infection and diagnosis

PopulationSizeToSimulate = 1000000;                                           %makesure there are at least 50000 samples per point
Median500 = [];
Median350 = [];
Median200 = [];
CurrentMedianStore = zeros(Sx.NoParameterisations, 200);
UncertaintyTimer = tic;
for CurrentParamNumber = 1:Sx.NoParameterisations
    disp(['Figure 1 appendices sim' num2str(CurrentParamNumber)]);
    if (CurrentParamNumber>1)
        UncertaintyTimerCurrentTime = toc(UncertaintyTimer);
        UncertaintySimsComplete = CurrentParamNumber - 1;
        TimePerSim = UncertaintyTimerCurrentTime / UncertaintySimsComplete;
        UncertaintySimsRemaining = Sx.NoParameterisations - UncertaintySimsComplete;
        UncertaintyTimeRemaining = (TimePerSim * UncertaintySimsRemaining)/3600;
        disp(['Hours remaining: ' num2str(UncertaintyTimeRemaining)]);
    end
    
    Pxi = Px;
    
    Pxi.FractionalDeclineToRebound = Px.FractionalDeclineToReboundVec(CurrentParamNumber); % select a sample of this parameter
    Pxi.SQRCD4Decline = Px.SQRCD4DeclineVec(CurrentParamNumber);
    Pxi.SimulatedPopSize = PopulationSizeToSimulate;
    TestingParameters = [0.1, 0, 0];%low, flat testing rate should not bias towards high starting CD4s
    [CD4CountHistogram, Data] = GenerateCD4Count(TestingParameters, Pxi);
    
    TimeUntilDiagnosis = Data.Time;
    TestingCD4 = Data.CD4;

    
    % search for elements with approximately the right CD4 count
%     Year=0.4;%to avoid the problem of the rapid decline
    
    CD4200Found = false;
    CD4350Found = false;
    CD4500Found = false;
    
    Year = 0;
    YearStep = 0;
    while (Year < 20)
        YearStep = YearStep + 1;
        CurrentMedian = median(TestingCD4(Year<=TimeUntilDiagnosis & TimeUntilDiagnosis<Year+0.1));
        CurrentMedianStore(CurrentParamNumber, YearStep) = CurrentMedian;
        if CurrentMedian<500 && CD4500Found==false
            Median500(CurrentParamNumber) = Year;
            CD4500Found = true;
        end
        if CurrentMedian<350 && CD4350Found==false
            Median350(CurrentParamNumber) = Year;
            CD4350Found=true;
        end
        if CurrentMedian<200 && CD4200Found==false
            Median200(CurrentParamNumber) = Year;
            CD4200Found = true;
        end
        Year = Year + Sx.StepSize;
    end
end


MedianMedian500 = median(Median500);
LCIMedian500 = prctile(Median500, 2.5);
UCIMedian500 = prctile(Median500, 97.5);
MedianMedian350 = median(Median350);
LCIMedian350 = prctile(Median350, 2.5);
UCIMedian350 = prctile(Median350, 97.5);
MedianMedian200 = median(Median200);
LCIMedian200 = prctile(Median200, 2.5);
UCIMedian200 = prctile(Median200, 97.5);


disp(['The time it takes for the median CD4 count to reach 500 is '  num2str(MedianMedian500) '(' num2str(LCIMedian500) '-' num2str(UCIMedian500) ') years.'])
disp(['The time it takes for the median CD4 count to reach 350 is '  num2str(MedianMedian350) '(' num2str(LCIMedian350) '-' num2str(UCIMedian350) ') years.'])
disp(['The time it takes for the median CD4 count to reach 200 is '  num2str(MedianMedian200) '(' num2str(LCIMedian200) '-' num2str(UCIMedian200) ') years.'])

MedianCD4WithTime = CurrentMedianStore(:, 10:10:100);                       %select yearly data
MedianCD4WithTimeMedian = median(MedianCD4WithTime,1);
MedianCD4WithTimeMedianLCI = prctile(MedianCD4WithTime, 2.5,1);
MedianCD4WithTimeMedianUCI = prctile(MedianCD4WithTime, 97.5,1);
TimeForPlot = 1:10;

clf;
CreateUncertaintyPlot(TimeForPlot, MedianCD4WithTimeMedian', MedianCD4WithTimeMedianUCI', MedianCD4WithTimeMedianLCI', 'r');
xlabel('Time since infection (years)','fontsize', 22);
ylabel({'Median CD4 count', '(95% uncertainty bound of the median)'},'fontsize', 22);
set(gca,'XTick', 1:10);
set(gca,'YTick', 0:100:800);
xlim([0 11]);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);                                             %makes the grey border white
set(gca, 'fontsize', 18)
box off;
print('-dpng ','-r300','ResultsPlots/Appendix uncertainty of median CD4 between simulations with time.png');

clf;
hold on;
for x = 1:Sx.NoParameterisations
    %plot(0.05:0.1:10.1, CurrentMedianStore(1:min([Sx.NoParameterisations, 10]), 1:101)')
    plot(0.05:0.1:10.1, CurrentMedianStore(x, 1:101)','LineWidth',0.5)
end
xlabel('Time since infection (years)','fontsize', 22);
ylabel({'Median CD4 count'},'fontsize', 22);
set(gca,'XTick', 1:10);
set(gca,'YTick', 0:100:800);
xlim([0 11]);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
print('-dpng ','-r1200','ResultsPlots/Other Individual simulations of median CD4.png');
