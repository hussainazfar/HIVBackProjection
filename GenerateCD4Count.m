function [CD4CountHistogram, Data]=GenerateCD4Count(TestingParameters, Pxi)
% This function takes a healthy population and simulates the CD4 decline
% according to assumptions contained in in Pxi and the TestingP. In doing
% so, it creates the number of people expected in the correct proportions
% by CD4. 

SymptomaticTestingRate=exp(log(Curvature)*CD4Count);
% Curvature [0, 1]

%Start with 
SimulatedPopSize=Pxi.SimulatedPopSize;

% Generate an intital distribution
LogInitialCD4Vector = normrnd(Pxi.MedianLogHealthyCD4, Pxi.StdLogHealthyCD4, [1 SimulatedPopSize]);
InitialCD4Vector=exp(LogInitialCD4Vector);


% Kaufmann 1999 
% Kaufmann GR, Cunningham P, Zaunders J, Law M, Vizzard J, Carr A, et al. Impact of Early HIV-1 RNA and T-Lymphocyte Dynamics During Primary HIV-1 Infection on the Subsequent Course of HIV-1 RNA Levels and CD4+ T-Lymphocyte Counts in the First Year of HIV-1 Infection. JAIDS Journal of Acquired Immune Deficiency Syndromes 1999,22:437-444.
% nadir 17 days after symptoms of 418, followed by 756 at day 40.        

% if the time is less than time to the bottom of the rapid decline
IndexSharpDecline=TimeUntilDiagnosis<Pxi.TimeUntilTrough;
CD4AtStart=InitialCD4Vector(IndexSharpDecline);
CD4AtTrough=Pxi.FractionalDeclineToTrough*CD4AtStart;
FractionOfTimeAlongTheDecline=1-(Pxi.TimeUntilTrough-TimeUntilDiagnosis(IndexSharpDecline))/Pxi.TimeUntilTrough;
CalculatedCD4Decline=CD4AtStart-(CD4AtStart-CD4AtTrough).*FractionOfTimeAlongTheDecline;
TestingCD4(IndexSharpDecline)=CalculatedCD4Decline;


% if the time is within the rebound period
IndexSharpRebound=TimeUntilDiagnosis>=Pxi.TimeUntilTrough & TimeUntilDiagnosis<Pxi.TimeUntilRebound;
CD4AtStart=InitialCD4Vector(IndexSharpRebound);
CD4AtTrough=Pxi.FractionalDeclineToTrough*CD4AtStart;
CD4AtRebound=Pxi.FractionalDeclineToRebound*CD4AtStart;
FractionOfTimeAlongTheRebound=1-(Pxi.TimeUntilRebound-TimeUntilDiagnosis(IndexSharpRebound))./(Pxi.TimeUntilRebound-Pxi.TimeUntilTrough);
CalculatedCD4Rebound=CD4AtTrough+(CD4AtRebound-CD4AtTrough).*FractionOfTimeAlongTheRebound;
TestingCD4(IndexSharpRebound)=CalculatedCD4Rebound;

% This section deals with all people who have not been tested during the
% primary infection. Note that they have been appropriately filtered out
% if the time is after the rebound period
IndexSlowDecline=TimeUntilDiagnosis>Pxi.TimeUntilRebound;
IndexSlowDeclineNum=NumericalIndices(IndexSlowDecline);
NumberThatReachSlowDecline=sum(IndexSlowDecline);
CD4AtStart=InitialCD4Vector(IndexSlowDecline);
CD4AtReboundSlow=Pxi.FractionalDeclineToRebound*CD4AtStart;
sqrtCD4AtRebound=sqrt(CD4AtReboundSlow);

% Generate a squareroot decline for these individuals
m=Pxi.SquareRootAnnualDecline;
v=(Pxi.SDSQRDeclineIndividual)^2;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));
SQRDecline = lognrnd(mu,sigma,1,NumberThatReachSlowDecline);
SQRDecline(SQRDecline<0.1*Pxi.SquareRootAnnualDecline)=0.1*Pxi.SquareRootAnnualDecline;%This is to avoid negative declines and divide by zero errors. Note that it is expected that around 0.9% of the population would have this level according to these calculations

TimeSpentInSQRTDecline=TimeUntilDiagnosis(IndexSlowDeclineNum)-Pxi.TimeUntilRebound;
sqrtCalculatedCD4WithSQRTDecline=sqrtCD4AtRebound-SQRDecline.*TimeSpentInSQRTDecline;
sqrtCalculatedCD4WithSQRTDecline(sqrtCalculatedCD4WithSQRTDecline<0)=0;
CalculatedCD4WithSQRTDecline=sqrtCalculatedCD4WithSQRTDecline.^2;
% add them to the matrix
TestingCD4(IndexSlowDecline)=CalculatedCD4WithSQRTDecline;




%% Delete bouncing along zero 
    %for those who have a CD4 at testing <0, determine if it has been less than a year since they hit zero
    % if it is < 1 year, then store the CD4 as zero
    TimeAllowedBouncingAlongAtZeroCD4=1;%years
    
    TimeWhenReachingZero=sqrtCD4AtRebound./SQRDecline;

    DurationAtOrBelowZeroCD4=TimeSpentInSQRTDecline-TimeWhenReachingZero;
    
    IndexExceedTimeBinary=DurationAtOrBelowZeroCD4>TimeAllowedBouncingAlongAtZeroCD4;%this is the index of those who reach the sqrt decline
    TotalExcluded=sum(IndexExceedTimeBinary);
    TotalRemaining=SimulatedPopSize-TotalExcluded;

    if TotalExcluded==0
        %don't do anything
    elseif TotalRemaining==0
        %disp('Possible warning: zero people avoided being at 0 CD4 for more than the maximum time. This point should be avoided automatically by optimisation, however this could be an issue if the optimisation gets stuck.');
    else
        IndexExceedTimeNum=IndexSlowDeclineNum(IndexExceedTimeBinary);%this is indexed according to all people in the simulation
        
        % Delete the individuals who test more than 1 year after reaching 0 CD4
        TestingCD4(IndexExceedTimeNum)=[];
        TimeUntilDiagnosis(IndexExceedTimeNum)=[];
        InitialCD4Vector(IndexExceedTimeNum)=[];
        %resample replacement from existing measurements to generate the IdealPopSize
        % create indices to resample from
        
        IndiciesForResample=randsample(TotalRemaining, TotalExcluded, 1);
        IndiciesForResample=IndiciesForResample';%this is to avoid errors where there is only one remaining individual to be sampled from and it cause a column vector to be made instead of a row vector

        
        % add the relevant values on to the end of the vector
        TestingCD4=[TestingCD4 TestingCD4(IndiciesForResample)];
        TimeUntilDiagnosis=[TimeUntilDiagnosis TimeUntilDiagnosis(IndiciesForResample)];
        InitialCD4Vector=[InitialCD4Vector InitialCD4Vector(IndiciesForResample)];
    end




%% Add stochasticity to all TestingCD4
% Hughes, M.D. et al "Within-Subject Variation in CD4..." 1994 JID
% On the loge scale, the relationship between the within-subject SO and the underlying CD4 cell count of mu was given by (sigma = 0.930 - 0.110 loge(mu).

mu=TestingCD4;
logmu=log(mu+10);%plus 10 to avoid the problems associated with log zero
sigma = 0.930 - 0.110*logmu;
LogSamples=normrnd(logmu,sigma);
TestingCD4=exp(LogSamples);



end