function [Px]=LoadBackProjectionParameters(ParameterisationSpaceSize, MajorityOlderThan30)

%% Simulation settings
MaxYears=20;%Max years is the maximum number of years a person can spend without being diagnosed with HIV. Although longer times are possible in real life, so few would occur that we can successfully ignore it in the name of simplicity and approximation
Px.MaxYears=MaxYears;    
StepSize=0.1;
Px.StepSize=StepSize;

%% The below results are from a meta-analysis of known studies of healthy CD4 counts 
% MeanHealthyCD4=903;
% Px.MeanHealthyCD4=MeanHealthyCD4;
% SDHealthyCD4=305;
% Px.SDHealthyCD4=SDHealthyCD4;

% Tindall (1988)
% Bodsworth (1992) A
% Bodsworth (1992) B
% Bryant (1996)  Male
% Bryant (1996)  Female
% Vuillier (1988)
% Tollerud (1989)
% Giorgi (1990)
% Hannet (1992)
% Bofill (1992)
% Hulstaert (1994)
% Howard (1996)
% Comans-Bitter (1997)
% Santagostino (1999)
% Tsegaye (1999)
% Messele (1999)
% Kassu (2001)
% Bisset (2004)
% Ullrich (2005)
% Yaman (2005)

meanCD4Healthyvec=[760, 950, 840, 710.96, 797.23, 807, 1036, 1017, 896.48, 830, 764.87, 1089, 749.42, 940, 993, 1171.12, 983.59, 704.28, 931.91, 1095];

stdCD4Healthyvec=[290, 225, 240, 197.66, 245.72, 378, 296, 329, 346.71, 288, 249.71, 415, 368.28, 307.65, 319, 414.49, 334.31, 249.69, 291.96, 391];

nCD4Healthy=[402,50, 1000, 289, 275, 61, 266, 2787, 101, 600, 85, 146, 51, 965, 1356, 60, 678, 70, 100, 220];
nCD4Healthy=nCD4Healthy*100;%multiply by 100 to ensure that we get the true mean from this bootstrapped method

varianceCD4Healthy=stdCD4Healthyvec.^2;
mu=log(meanCD4Healthyvec.^2./sqrt(varianceCD4Healthy+meanCD4Healthyvec.^2));
sigma=sqrt(log(varianceCD4Healthy./(meanCD4Healthyvec.^2)+1));


BootStrappedCD4s=[];
i=0;
for Dummy=mu
    i=i+1;
    %Create numbers at random which would fall into the distribution
    SamplesToAdd=lognrnd(mu(i),sigma(i), 1, nCD4Healthy(i));
    BootStrappedCD4s=[BootStrappedCD4s SamplesToAdd];
end
MedianHealthyCD4 = median(BootStrappedCD4s);

LogBootStrappedCD4s=log(BootStrappedCD4s);
MedianLogBootStrappedCD4s=median(LogBootStrappedCD4s);
StdLogBootStrappedCD4s=std(LogBootStrappedCD4s);

Px.MedianLogHealthyCD4=MedianLogBootStrappedCD4s;
Px.StdLogHealthyCD4=StdLogBootStrappedCD4s;
% To show how you regenerate the distribution
% [~, TotalBootStrappedCD4s]=size(BootStrappedCD4s);
% R = normrnd(MedianLogBootStrappedCD4s,StdLogBootStrappedCD4s, [1 TotalBootStrappedCD4s]);
% NewCD4s=exp(R);
% [BSCD4s]=hist(BootStrappedCD4s, 0.25:50:3975);
% [NCD4s]=hist(NewCD4s, 0.25:50:3975);
% plot( 0.25:50:3975, [BSCD4s; NCD4s]);




 


%% determine the initial fall and rebound of individuals 

%(1) MedianHealthyCD4
%(2) Px.FractionalDeclineToTrough
%(3) Px.FractionalDeclineToRebound
%(4) Px.FractionalDeclineTo1Year/Px.CD4At1Year (Not currently used)
%     (1)
%     |\
%     | \
%     |  \       __ (3)
%     |   \     /  \
% CD4 |    \   /    \  
%     |     \_/      \(4)   
%     |      (2)      \      
%     |                \             
%     |                 \               
%     |____________________________ time

% Kaufmann 1999 
% The text says nadir 17 days after symptoms of 418, followed by 756 at day 40. I'm going to suggest that the first 1/10th of a year of testing CD4 to be set at a percentage decline of initial CD4, 418/950=44%, followed by a rebound to 756/950=79.5%. This adds in a couple of weeks for the infection to take hold. 
% median CD4 count at 12 months was 470

% Kaufmann GR, Cunningham P, Zaunders J, Law M, Vizzard J, Carr A, et al. Impact of Early HIV-1 RNA and T-Lymphocyte Dynamics During Primary HIV-1 Infection on the Subsequent Course of HIV-1 RNA Levels and CD4+ T-Lymphocyte Counts in the First Year of HIV-1 Infection. JAIDS Journal of Acquired Immune Deficiency Syndromes 1999,22:437-444.
% says nadir 17 days after symptoms of 418 (mdeian), followed by a maximum median of 756 at day 40.
Px.FractionalDeclineToTrough=418/MedianHealthyCD4; %
Px.TimeUntilTrough=17/365.25;
Px.TimeUntilRebound=40/365.25; % From Kaufmann 1999
Px.FractionalDeclineToRebound=756/MedianHealthyCD4;
% Px.FractionalDeclineTo1Year=470/MedianHealthyCD4;
% Px.AssumedPostSeroconversionMedianCD4=756;


% Post-primary infection CD4
% Pillay 2006 AIDS (Cascade) estimate is 604 at seroconversion
% Kaufmann 1999 is 756 at seroconversion
% Lodi 2011 is 24.167^2=584 (>35 years 23.223^2=539.3) at seroconversion
% Lodi 2010 is 24.982^2=624 (>35 years 24.067^2=579.2) at seroconversion
% In 2011, the median CD4 at diagnosis of those with recent HIV infection
% was 512. If it is assumed that the average time until diagnosis of those
% with evidence of a recent infection is 0.5 years, then the CD4 after
% primary infection should be above 512, likely approximately +30 CD4, or
% 542. 
% (Newly acquired HIV infection was defined as newly diagnosed infection
% with a negative or indeterminate HIV antibody test result, or a diagnosis 
% of primary HIV infection, within 12 months of HIV diagnosis.)

%We chose Lodi 2011 result because it is close to what we would expect for
%Australia and is a recent result. 
% if MajorityOlderThan30==1
%     AgeFactor=-0.646;
% else
%     AgeFactor=0;
% end
% Px.FractionalDeclineToRebound=((24.167+AgeFactor)^2)/MedianHealthyCD4;  %fractional decline after 40 days from HEALTHY CD4 to top of rebound peak
% Px.FractionalDeclineToReboundStdev=((24.433^2-23.901^2)/MedianHealthyCD4)/2/1.96;
%The following value is stored because if the median CD4 at diagnosis of
%the population we are simulating is higher than the value as provided in
%this study, then the algorithm will find it very hard to optimise.
%Essentially, the testing rate will be so high as to make the time until
%testing near instantaneous. This value is used to give the user a warning
%about the state of the popuation, so that they know optimisation is not
%occurring properly
% Px.AssumedPostSeroconversionMedianCD4=(24.167+AgeFactor)^2;

% Create the distribution that that simulations will be working under
% m=Px.FractionalDeclineToRebound;
% v=(Px.FractionalDeclineToReboundStdev)^2;
% mu = log((m^2)/sqrt(v+m^2));
% sigma = sqrt(log(v/(m^2)+1));

% Px.FractionalDeclineToReboundVec = lognrnd(mu,sigma,1,ParameterisationSpaceSize);

% Px.FractionalDeclineTo1Year=470/MedianHealthyCD4;
%Fidler (2007) AIDS 502 (471–535)
% The age range of CASCADE results from Fidler et al (32.9 (27.9–38.5)) compare favourably
% with the Australian ranges 36.0 (28.3-42.2)
% % Px.FractionalDeclineTo1Year=502/MedianHealthyCD4;


%




%% Square root decline model 

% % Lodi S, Phillips A, Touloumi G, Pantazis N, Bucher HC, et al. (2010) CD4 decline in seroconverter and seroprevalent individuals in the precombination of antiretroviral therapy era. AIDS 24: 2697-2704
% %CASCADE
if MajorityOlderThan30==1
    AgeFactor=0.15;
else
    AgeFactor=0;
end
Px.SquareRootAnnualDecline=1.754+AgeFactor;
%The following indicates the range in which we believe the population parameter to be with 95% confidence
Px.SquareRootAnnualDeclineStdev=(1.820-1.688)/2/1.96;

% Create the distribution that that simulations will be working under
m=Px.SquareRootAnnualDecline;
v=(Px.SquareRootAnnualDeclineStdev)^2;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));

Px.SquareRootAnnualDeclineVec = lognrnd(mu,sigma,1,ParameterisationSpaceSize);

% Individual vaiablility in decline
% The following represents the individual variability of CD4 declines. 
% Wolbers et al. Plos 2010 (table 1) to generate an interquartile range
%For example, people at the 25th percentile may have a
%decline of 46 cells per year, and at the 75th percentile may have a
%decline of 81. 
%Using the results from 
% Note: this method does not fully account for the range of possible
% declines in CD4 count of PLHIV. However, it accounts for some of it,
% which is better than asserting that all the variation in the population's
% annual CD4 decline is completely independent of current CD4. It is well
% established that high CD4s have higher CD4 declines, and since this is
% one of the main explanatory factors, it is better to compare the upper
% quartile reading of decline to the upper quartile reading of current CD4
% and look for ranges of uncertainty this way. 
CD4cellcountatcARTinitiation=[289 206 398];
EstimatedprecARTCD4slope=[61 46 81]; %[median LQR UQR]
CD4cellcount1yearbeforecARTinitiation=CD4cellcountatcARTinitiation+EstimatedprecARTCD4slope;
sqrCD4_1=sqrt(CD4cellcount1yearbeforecARTinitiation);
sqrCD4_2=sqrt(CD4cellcountatcARTinitiation);
sqrdecline=sqrCD4_1-sqrCD4_2;%+ve, [median LQR UQR]
%now to find a rough stddev
MedianToUQR=(sqrdecline(3)-sqrdecline(1));%0.4053
MedianToLQR=(sqrdecline(1)-sqrdecline(2));%0.5271
MeanDistance=(MedianToUQR+MedianToLQR)/2;%0.4662
%The following indicates the range in which we believe INDIVIDUAL variability to be contained
Px.SDSQRDeclineIndividual= MeanDistance/0.67;%0.67 is the one tail value for the normal distrbution 25th percentile
    
%Other studies
% Lodi 2011 CASCADE
% if MajorityOlderThan30==1
%     AgeFactor=0.064;
% else
%     AgeFactor=0;
% end
% Px.SquareRootAnnualDecline=1.159+AgeFactor;
% %The following indicates the range in which we believe the population parameter to be with 95% confidence
% Px.SquareRootAnnualDeclineStdev=(1.243-1.075)/2/1.96;

% Xiaojie Huang (2013) Rate of CD4 Decline and HIV-RNA Change Following
% HIV Seroconversion in Men Who Have Sex With Men:
% A Comparison Between the Beijing PRIMO and
% CASCADE Cohorts
%Provides a much higher rate of decline than Lodi 2011 by using a cubic
%model


% Fidler 2.14( 1.69-2.59) untreated CASCADE individuals
% Px.SquareRootAnnualDecline=2.14;
% %The following indicates the range in which we believe the population parameter to be with 95% confidence
% Px.SquareRootAnnualDeclineStdev=(2.59-1.69)/2/1.96;

%Pillay non-TDR 1.7 (95% CI, 0.8–2.6) Cascade

%Keller 2010 : 1.67 (Canada)

% Lodi 2011 makes predictions about the time to various CD4 levels.
% However, they take the CD4 count at conversion and the CD4 decline
% independently, and do not consider that CD4 counts rebound after initial
% HIV infection. 


%% This section deals with the stochasticity of the CD4 levels with time.
% This section has been depreciated in favour of in function calculation.
% See GenerateTheoreticalPopulation.m
% Hughes, M.D. et al "Within-Subject Variation in CD4..." 1994 JID
% On the loge scale, the relationship between the within-subject SO and the underlying CD4 cell count of mu was given by (sigma = 0.930 - 0.110 loge(mu).

%Testing this result
% LogSamples=zeros(1, 10000);
% mustore=zeros(1, 10000);
% for i=1:10000
%     mu=500*rand();
%     logmu=log(mu+10);%plus 10 to avoid the problems associated with log zero
%     sigma = 0.930 - 0.110*logmu;
%     LogSamples(i)=normrnd(logmu,sigma);
%     mustore(i)=mu;
% end
% plot(mustore, exp(LogSamples), 'r.');




%Other studies 
% Malone, J.L. et al "Sources of variability in repeated T-helper Lymphocyte counts..." 1990 JAIDS 

% Although CD4 counts vary in predictable ways over a long period, there is
% a certain amount of daily variability in CD4 reading. Using table 1:
% WR Stage 1/2; No=7; Mean CD4 = 464
% WR stage 3-5; No=5; Mean CD4 = 333
% % Overall mean CD4:
% MeanCD4OfVariabilityStudy=(464*7+333*5)/12;
% 
% % Looking at Table 2, and using the maximal uncertainty, the mean daily
% % rythmical variability is 62.3 cells/day (SD 30.5)
% % Hence the percentage change for these values should be 
% 
% Px.MeanCD4PercentVariability=62.3/MeanCD4OfVariabilityStudy;
% Px.SDCD4PercentVariability=30.5/MeanCD4OfVariabilityStudy;


% Malone et al "Abnormalities of morning serum cortisol levels..." 1992  JID
% Mientjes et al "Large Diurnal variation in CD4 cell..." 1992 AIDS
% Raboud et al "Variation in Plasma RNA Levels, CD4 Cell Counts" 1996 JID
    %CD4 variaton <400 12.8% 
    %CD4 variaton >400 13.7% 
%% This section is dealing with a linear model which we have chosen not to persue at all

% % %     % Linear decline model 
% % %     %This section deals with the systematic uncertainity in estimates for CD4 decline mean
% % % 
% % %     %Lee (1989)
% % %     N_CD4Decline(1)=112;
% % %     StudyDeclineRate(1)=68;
% % %     % Veuglers (1997)
% % %     % Vancouver
% % %     N_CD4Decline(2)=129;
% % %     StudyDeclineRate(2)=59.87;
% % %     % Sydney
% % %     N_CD4Decline(3)=79;
% % %     StudyDeclineRate(3)=36.42;
% % %     % Amsterdam
% % %     N_CD4Decline(4)=140;
% % %     StudyDeclineRate(4)=54.1;
% % %     % San Francisco GeneralHospital
% % %     N_CD4Decline(5)=19;
% % %     StudyDeclineRate(5)=43.45;
% % %     % San Francisco Men's Health
% % %     N_CD4Decline(6)=46;
% % %     StudyDeclineRate(6)=55.42;
% % %     % Prins (1999)European Secroconvert Study
% % %     N_CD4Decline(7)=221+443;
% % %     StudyDeclineRate(7)=60;
% % %     % Deeks (2004), San Francisco, USA
% % %     N_CD4Decline(8)=68;
% % %     StudyDeclineRate(8)=96;
% % %     % Fidler (2007)Exluded because of overlap with other CASCADE STUDY
% % %     %N_CD4Decline(9)=179;
% % %     %StudyDeclineRate(9)=77;
% % %     % Mellors (MACS, USA)
% % %     N_CD4Decline(9)=1640;
% % %     StudyDeclineRate(9)=64;
% % %     % Drylewicz (2008) France
% % %     N_CD4Decline(10)=98+320;
% % %     StudyDeclineRate(10)=49;
% % %     % Muller (2009) Switzerland
% % %     N_CD4Decline(11)=463;
% % %     StudyDeclineRate(11)=52.5;
% % %     % Wolbers (2010) CASCADE
% % %     N_CD4Decline(12)=2820;
% % %     StudyDeclineRate(12)=61;
% % %     % Lewden (2010) France
% % %     N_CD4Decline(13)=373;
% % %     StudyDeclineRate(13)=63;
% % % 
% % %     StudyCD4WeightedVector=[];
% % %     for i=1:13
% % %         StudyCD4WeightedVector=[StudyCD4WeightedVector StudyDeclineRate(i)*ones(1, N_CD4Decline(i))];
% % %     end
% % % 
% % %     Decline=mean(StudyCD4WeightedVector);
% % %     Sx.Decline=Decline;
% % %     DeclineStudySD=std(StudyCD4WeightedVector);%The systematic variation in the study's results
% % %     Sx.DeclineStudySD=DeclineStudySD;
% % % 
% % %     DeclineIQR=35; % -81 to –46, figure give in Cascade %The annual decline in CD4 per year, Wolbers, 2010, Pretreatment CD4 Cell Slope and Progression to AIDS or Death in HIV-Infected Patients Initiating Antiretroviral Therapy
% % %     DeclineSD=DeclineIQR/2/0.674490;
% % %     Sx.DeclineSD=DeclineSD;
% % % 
% % % 
% % %     NDeclineStudy=2820;
% % %     DeclineLCI=Decline-1.96*DeclineSD/sqrt(NDeclineStudy);%These values aren't used for anything, just interest's sake
% % %     DeclineUCI=Decline+1.96*DeclineSD/sqrt(NDeclineStudy);%These values aren't used for anything, just interest's sake




