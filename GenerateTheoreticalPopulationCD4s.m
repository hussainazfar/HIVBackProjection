function [TimeUntilDiagnosis, InitialCD4Vector, TestingCD4]=GenerateTheoreticalPopulationCD4s(TimeUntilDiagnosis, Pxi)
% This function takes a healthy population and simulates the CD4 decline
% according to assumptions contained in in Pxi and the TestingP. In doing
% so, it creates the number of people expected in the correct proportions
% by CD4. 

[~, SimulatedPopSize]=size(TimeUntilDiagnosis);


NumericalIndices=1:SimulatedPopSize;
TestingCD4=zeros(1, SimulatedPopSize);

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
m=Pxi.SquareRootAnnualDeclineChosen;
v=(Pxi.SDSQRDeclineIndividual)^2;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));
SQRDecline = lognrnd(mu,sigma,1,NumberThatReachSlowDecline);
SQRDecline(SQRDecline<0.1*Pxi.SquareRootAnnualDeclineChosen)=0.1*Pxi.SquareRootAnnualDeclineChosen;%This is to avoid negative declines and divide by zero errors. Note that it is expected that around 0.9% of the population would have this level according to these calculations


TimeSpentInSQRTDecline=TimeUntilDiagnosis(IndexSlowDeclineNum)-Pxi.TimeUntilRebound;
sqrtCalculatedCD4SQRTDecline=sqrtCD4AtRebound-SQRDecline.*TimeSpentInSQRTDecline;
CalculatedCD4SQRTDecline=sqrtCalculatedCD4SQRTDecline.^2;
% add them to the matrix
TestingCD4(IndexSlowDecline)=CalculatedCD4SQRTDecline;


%% Forcing linear decline from this point
LinearDecline=false;
if LinearDecline
    sqrt200=sqrt(200);

    % Generate a squareroot decline for these individuals
    m=Pxi.SquareRootAnnualDeclineChosen;
    v=(Pxi.SDSQRDeclineIndividual)^2;
    mu = log((m^2)/sqrt(v+m^2));
    sigma = sqrt(log(v/(m^2)+1));
    SQRDecline = lognrnd(mu,sigma,1,NumberThatReachSlowDecline);
    SQRDecline(SQRDecline<0.1*Pxi.SquareRootAnnualDeclineChosen)=0.1*Pxi.SquareRootAnnualDeclineChosen;%This is to avoid negative declines and divide by zero errors. Note that it is expected that around 0.9% of the population would have this level according to these calculations


    % Determine time until the individual reaches 200 according to squareroot decline methodology
    TimeUntil200=(sqrtCD4AtRebound-sqrt200)./SQRDecline;

    %Determine which individuals are tested before they reach 200
    IndexSQRDecline=(Pxi.TimeUntilRebound+TimeUntil200>TimeUntilDiagnosis(IndexSlowDecline));%note this index is the index of the those in the "slow decline"
    IndexSQRDeclineNum=IndexSlowDeclineNum(IndexSQRDecline);%this numerical index in the original vector

    % for all individuals whose testing time is before reaching 200
    %determine the CD4 at testing


    TimeSpentInSQRTDecline=TimeUntilDiagnosis(IndexSQRDeclineNum)-Pxi.TimeUntilRebound;


    sqrtCalculatedCD4SQRTDecline=sqrtCD4AtRebound(IndexSQRDecline)-SQRDecline(IndexSQRDecline).*TimeSpentInSQRTDecline;

    CalculatedCD4SQRTDecline=sqrtCalculatedCD4SQRTDecline.^2;
    % add them to the matrix
    TestingCD4(IndexSQRDeclineNum)=CalculatedCD4SQRTDecline;


    % for those who get below 200
    % Note we use linear decline from here because the decline becomes too slow if we use square root
    IndexLinearDecline=~IndexSQRDecline;
    IndexLinearDeclineNum=IndexSlowDeclineNum(IndexLinearDecline);

    TimeAt200=Pxi.TimeUntilRebound +TimeUntil200(IndexLinearDecline);

    % determine the linear decline for this individual at 200
    % by finding the equation of the sqrt decline at 200 and differentiating
    % it, we can find the gradient at 200 and use it to form a linear decline
    % from that point onwards
    % dc/dt=f2(t)
    % f(t)=sqrt(200)-IndividualSQRDecline*t
    % dc/dt=2*f(t)*f'(t)
    % dc/dt=2*(sqrt(200)-IndividualSQRDecline*t)*(-IndividualSQRDecline)
    % but t=0 at c=200
    % dc/dt=-2*sqrt(200)*IndividualSQRDecline
    % the following should give an average decline of about 50 cells/muL/year
    LinearDeclineRate=-2*sqrt(200)*SQRDecline(IndexLinearDecline);

    DurationOfLinearDecline=TimeUntilDiagnosis(IndexLinearDeclineNum)-TimeAt200;

    CD4AtTesting=200+DurationOfLinearDecline.*LinearDeclineRate;%Note LinearDeclineRate should be negative here
    TimeUntil0=200./(-LinearDeclineRate);
    %For those who have a CD4 at testing >= 0, store CD4 
    IndexTestAbove0=DurationOfLinearDecline<=TimeUntil0;
    TestingCD4(IndexLinearDeclineNum(IndexTestAbove0))=CD4AtTesting(IndexTestAbove0);%Store those who have CD4 between 0 and 200
    IndexTestBelow0=DurationOfLinearDecline>TimeUntil0;
    TestingCD4(IndexLinearDeclineNum(IndexTestBelow0))=0;%Store those who have 0 cd4 at testing 
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Delete bouncing along zero (depreciated)
DeletePeopleBouncing=false;
if DeletePeopleBouncing
    %for those who have a CD4 at testing <0, determine if it has been less than a year since they hit zero
    % if it is < 1 year, then store the CD4 as zero
    TimeAllowedBouncingAlongAtZeroCD4=2;%years
    IndexExceedTime=DurationOfLinearDecline>TimeUntil0+TimeAllowedBouncingAlongAtZeroCD4;

    TotalExcluded=sum(IndexExceedTime);
    TotalRemaining=SimulatedPopSize-TotalExcluded;

    if TotalExcluded==0
        %don't do anything
    elseif TotalRemaining==0
        error('Possible problem: zero people avoided being at 0 CD4 for more than the maximum time');
    else
        % Delete the individuals who test more than 1 year after reaching 0 CD4
        TestingCD4(IndexLinearDeclineNum(IndexExceedTime))=[];
        TimeUntilDiagnosis(IndexLinearDeclineNum(IndexExceedTime))=[];
        InitialCD4Vector(IndexLinearDeclineNum(IndexExceedTime))=[];
        %resample replacement from existing measurements to generate the IdealPopSize
        % create indices to resample from
        IndiciesForResample=randsample(TotalRemaining, TotalExcluded, 1);
        % add the relevant values on to the end of the vector
        TestingCD4=[TestingCD4 TestingCD4(IndiciesForResample)];
        TimeUntilDiagnosis=[TimeUntilDiagnosis TimeUntilDiagnosis(IndiciesForResample)];
        InitialCD4Vector=[InitialCD4Vector InitialCD4Vector(IndiciesForResample)];
    end
end



%% Add stochasticity to all TestingCD4
% Hughes, M.D. et al "Within-Subject Variation in CD4..." 1994 JID
% On the loge scale, the relationship between the within-subject SO and the underlying CD4 cell count of mu was given by (sigma = 0.930 - 0.110 loge(mu).

mu=TestingCD4;
% mu=1200*rand(1, 1000);
logmu=log(mu+10);%plus 10 to avoid the problems associated with log zero
sigma = 0.930 - 0.110*logmu;
LogSamples=normrnd(logmu,sigma);
TestingCD4=exp(LogSamples);
% plot(mu, exp(LogSamples), 'b.');

% Old variability system:
% +/- add half the variablity to the reading
% m=Pxi.MeanCD4PercentVariability;
% v=(Pxi.SDCD4PercentVariability)^2;
% mu = log((m^2)/sqrt(v+m^2));
% sigma = sqrt(log(v/(m^2)+1));
% CD4StochasticityWeighting = lognrnd(mu,sigma,1,SimulatedPopSize);%This is the amount you multiply the random number by
% CD4StochasticityVector=(0.5-rand(1,SimulatedPopSize)).*CD4StochasticityWeighting/2;
% TestingCD4=TestingCD4.*(1+CD4StochasticityVector);


%% To test:
%plot(TimeUntilDiagnosis, TestingCD4, '.')
% this should give roughly an outline of the average persons decline (note it will be quite noisy)
% to avoid the noisyness, you can instead sort into buckets according to
% testing time, then take the avearge CD4 of those in the buckets
% i=0;
% for timei=0:0.1:20
%     i=i+1;
%     IndexToGraph=timei< TimeUntilDiagnosis& TimeUntilDiagnosis<timei+0.1;
%     y(i)=median(TestingCD4(IndexToGraph));
%     x(i)=timei;
% end
% plot(x, y);

end