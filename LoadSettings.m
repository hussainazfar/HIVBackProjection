%% Optimisation settings
Sx.HistogramCentres=25:50:4975;

%% Simulation settings
MaxYears=20;%Max years is the maximum number of years a person can spend without being diagnosed with HIV. Although longer times are possible in real life, so few would occur that we can successfully ignore it in the name of simplicity and approximation
Sx.MaxYears=MaxYears;    
StepSize=0.1;
Sx.StepSize=StepSize;

%% Data settings
YearOfDiagnosedDataEnd=2013;% for data that doesn't go beyond 2013
CD4BackProjectionYears=[1965.0 YearOfDiagnosedDataEnd-StepSize];
CD4BackProjectionYearsWhole=[1965 YearOfDiagnosedDataEnd];

ConsiderRecentInfection=true;

%% Program settings
RunID='BackProject';

BackProjectStartSingleYearAnalysis=1984;

%change the 2 following variables to false if geographic calculations unnecessary or
%outside of the Australian region
PerformGeographicCalculations=true;%do movement calculations and break up according to location
InitialisePCToSRThisSim=true;%re-perform this function. Only relevant if geographic calculations take place. 

UseGeneticAlgorithmOptimisation=true;




NumberOfSamples=500;%Used in the old optmisation algorithm
Sx.NumberOfSamples=NumberOfSamples;
RangeOfCD4Averages=[(YearOfDiagnosedDataEnd-5) YearOfDiagnosedDataEnd];%YearOfDiagnosedDataEnd not inclusive
RangeOfCD4AveragesForForwardProjection=[(YearOfDiagnosedDataEnd-5) YearOfDiagnosedDataEnd];


TotalTime=tic;

ParameterLocalStorageLocation='Parameters/';

% HIVFile='Imputation\HIVAug2013Imputation.xls';
HIVFile='Imputation\Data\notifications2014imputationformatted.xls';

SheetName='Dataset_1';


PlotSettings.ListOfCD4sToPlot=[200 350 500];
PlotSettings.YearsToPlot=[1970 CD4BackProjectionYearsWhole(2)];
PlotSettings.YearsToPlotForCD4AtDiagnosis=[1985 CD4BackProjectionYearsWhole(2)];







%%





% % % % % % % 
% % % % % % % %% The below results are from a meta-analysis of known studies of healthy CD4 counts 
% % % % % % % % MeanHealthyCD4=903;
% % % % % % % % Sx.MeanHealthyCD4=MeanHealthyCD4;
% % % % % % % % SDHealthyCD4=305;
% % % % % % % % Sx.SDHealthyCD4=SDHealthyCD4;
% % % % % % % 
% % % % % % % % Tindall (1988)
% % % % % % % % Bodsworth (1992) A
% % % % % % % % Bodsworth (1992) B
% % % % % % % % Bryant (1996)  Male
% % % % % % % % Bryant (1996)  Female
% % % % % % % % Vuillier (1988)
% % % % % % % % Tollerud (1989)
% % % % % % % % Giorgi (1990)
% % % % % % % % Hannet (1992)
% % % % % % % % Bofill (1992)
% % % % % % % % Hulstaert (1994)
% % % % % % % % Howard (1996)
% % % % % % % % Comans-Bitter (1997)
% % % % % % % % Santagostino (1999)
% % % % % % % % Tsegaye (1999)
% % % % % % % % Messele (1999)
% % % % % % % % Kassu (2001)
% % % % % % % % Bisset (2004)
% % % % % % % % Ullrich (2005)
% % % % % % % % Yaman (2005)
% % % % % % % 
% % % % % % % meanCD4Healthyvec=[760, 950, 840, 710.96, 797.23, 807, 1036, 1017, 896.48, 830, 764.87, 1089, 749.42, 940, 993, 1171.12, 983.59, 704.28, 931.91, 1095];
% % % % % % % 
% % % % % % % stdCD4Healthyvec=[290, 225, 240, 197.66, 245.72, 378, 296, 329, 346.71, 288, 249.71, 415, 368.28, 307.65, 319, 414.49, 334.31, 249.69, 291.96, 391];
% % % % % % % 
% % % % % % % nCD4Healthy=[402,50, 1000, 289, 275, 61, 266, 2787, 101, 600, 85, 146, 51, 965, 1356, 60, 678, 70, 100, 220];
% % % % % % % nCD4Healthy=nCD4Healthy*100;%multiply by 100 to ensure that we get the true mean from this bootstrapped method
% % % % % % % 
% % % % % % % varianceCD4Healthy=stdCD4Healthyvec.^2;
% % % % % % % mu=log(meanCD4Healthyvec.^2./sqrt(varianceCD4Healthy+meanCD4Healthyvec.^2));
% % % % % % % sigma=sqrt(log(varianceCD4Healthy./(meanCD4Healthyvec.^2)+1));
% % % % % % % 
% % % % % % % 
% % % % % % % BootStrappedCD4s=[];
% % % % % % % i=0;
% % % % % % % for Dummy=mu
% % % % % % %     i=i+1;
% % % % % % %     %Create numbers at random which would fall into the distribution
% % % % % % %     SamplesToAdd=lognrnd(mu(i),sigma(i), 1, nCD4Healthy(i));
% % % % % % %     BootStrappedCD4s=[BootStrappedCD4s SamplesToAdd];
% % % % % % % end
% % % % % % % MedianHealthyCD4 = median(BootStrappedCD4s);
% % % % % % % 
% % % % % % % LogBootStrappedCD4s=log(BootStrappedCD4s);
% % % % % % % MedianLogBootStrappedCD4s=median(LogBootStrappedCD4s);
% % % % % % % StdLogBootStrappedCD4s=std(LogBootStrappedCD4s);
% % % % % % % 
% % % % % % % Sx.MedianLogHealthyCD4=MedianLogBootStrappedCD4s;
% % % % % % % Sx.StdLogHealthyCD4=StdLogBootStrappedCD4s;
% % % % % % % % To show how you regenerate the distribution
% % % % % % % % [~, TotalBootStrappedCD4s]=size(BootStrappedCD4s);
% % % % % % % % R = normrnd(MedianLogBootStrappedCD4s,StdLogBootStrappedCD4s, [1 TotalBootStrappedCD4s]);
% % % % % % % % NewCD4s=exp(R);
% % % % % % % % [BSCD4s]=hist(BootStrappedCD4s, 0.25:50:3975);
% % % % % % % % [NCD4s]=hist(NewCD4s, 0.25:50:3975);
% % % % % % % % plot( 0.25:50:3975, [BSCD4s; NCD4s]);
% % % % % % % 
% % % % % % % 
% % % % % % % 
% % % % % % % 
% % % % % % %  
% % % % % % % 
% % % % % % % 
% % % % % % % %% determine the initial fall and rebound of individuals 
% % % % % % % % Acute infection takes 2-4 weeks
% % % % % % % % The text says nadir 17 days after symptoms of 418, followed by 756 at day 40. I'm going to suggest that the first 1/10th of a year of testing CD4 to be set at a percentage decline of initial CD4, 418/950=44%, followed by a rebound to 756/950=79.5%. This adds in a couple of weeks for the infection to take hold. 
% % % % % % % % Kaufmann 1999 
% % % % % % % % Kaufmann GR, Cunningham P, Zaunders J, Law M, Vizzard J, Carr A, et al. Impact of Early HIV-1 RNA and T-Lymphocyte Dynamics During Primary HIV-1 Infection on the Subsequent Course of HIV-1 RNA Levels and CD4+ T-Lymphocyte Counts in the First Year of HIV-1 Infection. JAIDS Journal of Acquired Immune Deficiency Syndromes 1999,22:437-444.
% % % % % % % % says nadir 17 days after symptoms of 418 (mdeian), followed by a maximum median of 756 at day 40.
% % % % % % % 
% % % % % % % 
% % % % % % % %WARNING 
% % % % % % % % this is not where the decline assumptions are loaded from
% % % % % % % 
% % % % % % % 
% % % % % % % 
% % % % % % % Sx.FractionalDeclineToTrough=418/MedianHealthyCD4; %fractional decline after 1/10th of a year
% % % % % % % Sx.FractionalDeclineToRebound=756/MedianHealthyCD4;  %fractional decline after 2/10th of a year from HEALTHY CD4 to top of rebound peak
% % % % % % % %(1) MedianHealthyCD4
% % % % % % % %(2) Sx.FractionalDeclineToTrough
% % % % % % % %(3) Sx.FractionalDeclineToRebound
% % % % % % % %     (1)
% % % % % % % %     |\
% % % % % % % %     | \
% % % % % % % %     |  \       __ (3)
% % % % % % % %     |   \     /  \
% % % % % % % % CD4 |    \   /    \  
% % % % % % % %     |     \_/      \   
% % % % % % % %     |      (2)      \      
% % % % % % % %     |                \             
% % % % % % % %     |                 \               
% % % % % % % %     |____________________________ time
% % % % % % % 
% % % % % % % 
% % % % % % % 
% % % % % % % %% Chose the decline model to be used
% % % % % % % Sx.DeclineModel=1;
% % % % % % % %Sx.DeclineModel=1 : square root decline model
% % % % % % % %Sx.DeclineModel=2 : linear decline model
% % % % % % % if Sx.DeclineModel==1
% % % % % % %     % Square root decline model 
% % % % % % % 
% % % % % % %     % Lodi S, Phillips A, Touloumi G, Pantazis N, Bucher HC, et al. (2010) CD4 decline in seroconverter and seroprevalent individuals in the precombination of antiretroviral therapy era. AIDS 24: 2697-2704
% % % % % % %     % A linear decline model is ==2
% % % % % % %     Sx.SquareRootAnnualDecline=1.754;
% % % % % % %     %The following indicates the range in which we believe the population parameter to be with 95% confidence
% % % % % % %     Sx.SquareRootAnnualDeclineStdev=(1.820-1.688)/2/1.96;
% % % % % % %     
% % % % % % %     %The following represents the individual variability of people within
% % % % % % %     %each estimate. For example, people at the 25th percentile may have a
% % % % % % %     %decline of 46 cells per year, and at the 75th percentile may have a
% % % % % % %     %decline of 81. 
% % % % % % %     %Using the results from Wolbers et al. Plos 2010 (table 1) to generate an interquartile range
% % % % % % %     CD4cellcountatcARTinitiation=[289 289 289];
% % % % % % %     EstimatedprecARTCD4slope=[61 46 81]; %[median LQR UQR]
% % % % % % %     CD4cellcount1yearbeforecARTinitiation=CD4cellcountatcARTinitiation+EstimatedprecARTCD4slope;
% % % % % % %     sqrCD4_1=sqrt(CD4cellcount1yearbeforecARTinitiation);
% % % % % % %     sqrCD4_2=sqrt(CD4cellcountatcARTinitiation);
% % % % % % %     sqrdecline=sqrCD4_1-sqrCD4_2;%+ve, [median LQR UQR]
% % % % % % %     %now to find a rough stddev
% % % % % % %     MedianToUQR=(sqrdecline(3)-sqrdecline(1));%0.4053
% % % % % % %     MedianToLQR=(sqrdecline(1)-sqrdecline(2));%0.5271
% % % % % % %     MeanDistance=(MedianToUQR+MedianToLQR)/2;%0.4662
% % % % % % %     %The following indicates the range in which we believe INDIVIDUAL variability to be contained
% % % % % % %     Sx.SquareRootAnnualDeclineIndividualSD= MeanDistance/0.67;%0.67 is the one tail value for the normal distrbution 25th percentile
% % % % % % %     
% % % % % % %     
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     %Calculation
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     %Sx.SquareRootAnnualDecline=(EndCD4^0.5-StartCD4^0.5)/TimePeriod
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     %EndCD4=(StartCD4.^0.5+Sx.SquareRootAnnualDecline.*TimePeriod).^2;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % The paper below is older and less predictive
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Fidler, S., et al., Slower CD4 cell decline following cessation of a 3 month course of HAART in primary HIV infection: findings from an observational cohort. AIDS, 2007. 21(10): p. 1283-91.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     %  Year       Decline Rate    Median CD4 Count
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % 1 year	-96 (-76, -115)     502
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % 2 year	-86 (-70, -102)     411
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % 3 year	-77 (-65, -89)      329
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Square root scale	-2.14 (-1.69, -2.59) 0.45
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Censoring adjusted square root scale	-2.66 (-2.23, -3.10)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Sx.DeclineModel=1;%1 here stands for the square root model
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Sx.SquareRootAnnualDecline=-2.14;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Sx.SquareRootAnnualDeclineStdev=(2.14-1.69)/1.96;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Note that although the study above is older and less predictive, it
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % shows the folly in assuming the the rate in Lodi et al. is correct.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % Hence we will set the uncertainty for the annual average decline to
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % make the result of Fidler et al. at the edge of the 95% CI for the
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     % annual decline in Lodi
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     Sx.SquareRootAnnualDeclineStudyResultUncertainty=(2.14-Sx.SquareRootAnnualDecline)/1.96;
% % % % % % %     
% % % % % % %     
% % % % % % %     
% % % % % % %     
% % % % % % %     
% % % % % % % elseif Sx.DeclineModel==2
% % % % % % %     % Linear decline model 
% % % % % % %     %This section deals with the systematic uncertainity in estimates for CD4 decline mean
% % % % % % % 
% % % % % % %     %Lee (1989)
% % % % % % %     N_CD4Decline(1)=112;
% % % % % % %     StudyDeclineRate(1)=68;
% % % % % % %     % Veuglers (1997)
% % % % % % %     % Vancouver
% % % % % % %     N_CD4Decline(2)=129;
% % % % % % %     StudyDeclineRate(2)=59.87;
% % % % % % %     % Sydney
% % % % % % %     N_CD4Decline(3)=79;
% % % % % % %     StudyDeclineRate(3)=36.42;
% % % % % % %     % Amsterdam
% % % % % % %     N_CD4Decline(4)=140;
% % % % % % %     StudyDeclineRate(4)=54.1;
% % % % % % %     % San Francisco GeneralHospital
% % % % % % %     N_CD4Decline(5)=19;
% % % % % % %     StudyDeclineRate(5)=43.45;
% % % % % % %     % San Francisco Men's Health
% % % % % % %     N_CD4Decline(6)=46;
% % % % % % %     StudyDeclineRate(6)=55.42;
% % % % % % %     % Prins (1999)European Secroconvert Study
% % % % % % %     N_CD4Decline(7)=221+443;
% % % % % % %     StudyDeclineRate(7)=60;
% % % % % % %     % Deeks (2004), San Francisco, USA
% % % % % % %     N_CD4Decline(8)=68;
% % % % % % %     StudyDeclineRate(8)=96;
% % % % % % %     % Fidler (2007)Exluded because of overlap with other CASCADE STUDY
% % % % % % %     %N_CD4Decline(9)=179;
% % % % % % %     %StudyDeclineRate(9)=77;
% % % % % % %     % Mellors (MACS, USA)
% % % % % % %     N_CD4Decline(9)=1640;
% % % % % % %     StudyDeclineRate(9)=64;
% % % % % % %     % Drylewicz (2008) France
% % % % % % %     N_CD4Decline(10)=98+320;
% % % % % % %     StudyDeclineRate(10)=49;
% % % % % % %     % Muller (2009) Switzerland
% % % % % % %     N_CD4Decline(11)=463;
% % % % % % %     StudyDeclineRate(11)=52.5;
% % % % % % %     % Wolbers (2010) CASCADE
% % % % % % %     N_CD4Decline(12)=2820;
% % % % % % %     StudyDeclineRate(12)=61;
% % % % % % %     % Lewden (2010) France
% % % % % % %     N_CD4Decline(13)=373;
% % % % % % %     StudyDeclineRate(13)=63;
% % % % % % % 
% % % % % % %     StudyCD4WeightedVector=[];
% % % % % % %     for i=1:13
% % % % % % %         StudyCD4WeightedVector=[StudyCD4WeightedVector StudyDeclineRate(i)*ones(1, N_CD4Decline(i))];
% % % % % % %     end
% % % % % % % 
% % % % % % %     Decline=mean(StudyCD4WeightedVector);
% % % % % % %     Sx.Decline=Decline;
% % % % % % %     DeclineStudySD=std(StudyCD4WeightedVector);%The systematic variation in the study's results
% % % % % % %     Sx.DeclineStudySD=DeclineStudySD;
% % % % % % % 
% % % % % % %     DeclineIQR=35; % -81 to –46, figure give in Cascade %The annual decline in CD4 per year, Wolbers, 2010, Pretreatment CD4 Cell Slope and Progression to AIDS or Death in HIV-Infected Patients Initiating Antiretroviral Therapy
% % % % % % %     DeclineSD=DeclineIQR/2/0.674490;
% % % % % % %     Sx.DeclineSD=DeclineSD;
% % % % % % % 
% % % % % % % 
% % % % % % %     NDeclineStudy=2820;
% % % % % % %     DeclineLCI=Decline-1.96*DeclineSD/sqrt(NDeclineStudy);%These values aren't used for anything, just interest's sake
% % % % % % %     DeclineUCI=Decline+1.96*DeclineSD/sqrt(NDeclineStudy);%These values aren't used for anything, just interest's sake
% % % % % % % 
% % % % % % % end
% % % % % % % %% This section deals with the stochasticity of the CD4 levels with time.
% % % % % % % % See Malone, J.L. et al "Sources of variability in repeated T-helper Lymphocyte counts..." 1990 JAIDS 
% % % % % % % 
% % % % % % % % Although CD4 counts vary in predictable ways over a long period, there is
% % % % % % % % a certain amount of daily variability in CD4 reading. Using table 1:
% % % % % % % % WR Stage 1/2; No=7; Mean CD4 = 464
% % % % % % % % WR stage 3-5; No=5; Mean CD4 = 333
% % % % % % % % Overall mean CD4:
% % % % % % % MeanCD4OfVariabilityStudy=(464*7+333*5)/12;
% % % % % % % 
% % % % % % % % Looking at Table 2, and using the maximal uncertainty, the mean daily
% % % % % % % % rythmical variability is 62.3 cells/day (SD 30.5)
% % % % % % % % Hence the percentage change for these values should be 
% % % % % % % 
% % % % % % % MeanCD4PercentVariability=62.3/MeanCD4OfVariabilityStudy;
% % % % % % % SDCD4PercentVariability=30.5/MeanCD4OfVariabilityStudy;
% % % % % % % 
% % % % % % % % Since this is a rythmical variability, we need to sample over a
% % % % % % % % oscillatory function. We will create a sine function with a period of
% % % % % % % % exactly 1. The mean value of the function will be 1, the maximum value
% % % % % % % % will be the half the % variation from the overall mean, and likewise for
% % % % % % % % the minimum value. That is:
% % % % % % % % StocasticVariation=1+sin(r*(2*PI))*(IndividualDailyVariation/2);
% % % % % % % % Note that the IndividualDailyVariation will differ by person based on the SDCD4PercentVariability
% % % % % % % 
% % % % % % % TotalSchocasticDeclinesToUse=1000;
% % % % % % % IndividualDailyVariationVector=normrnd(MeanCD4PercentVariability, SDCD4PercentVariability, TotalSchocasticDeclinesToUse, 1);
% % % % % % % MaxNumberOfSteps=MaxYears/StepSize;
% % % % % % % 
% % % % % % % %Make sure to zero out any negative values
% % % % % % % IndividualDailyVariationVector(IndividualDailyVariationVector<0)=0;
% % % % % % % IndividualDailyVariation=repmat(IndividualDailyVariationVector, 1, MaxNumberOfSteps);
% % % % % % % StochasticCD4Matrix=1+sin(rand(TotalSchocasticDeclinesToUse, MaxNumberOfSteps)*2*pi).*(IndividualDailyVariation/2);
% % % % % % % 
% % % % % % % % Make sure to zero out any negative values
% % % % % % % StochasticCD4Matrix(StochasticCD4Matrix<0)=0;
% % % % % % % Sx.StochasticCD4Matrix=StochasticCD4Matrix;
% % % % % % % 
% % % % % % % %to look at the variability, use the following command
% % % % % % % % plot(1:200, StochasticCD4Matrix(1,:), '.')




