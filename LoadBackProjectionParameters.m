function [ Px ] = LoadBackProjectionParameters( NoParameterisations, MaxYears, StepSize, BackProjectStartSingleYearAnalysis )
%Back Projection Parameters are all calculated in this fuction for
%Optimisation
%   Values this function returns as part of structure Px are:
%% Simulation Settings
Px.NoParameterisations = NoParameterisations;
Px.MaxYears = MaxYears;
Px.StepSize = StepSize;

%% Creating Simulation Start Time
Px.UpperFirstInfectionDate = BackProjectStartSingleYearAnalysis;            %used to filter possible back projected times
Px.LowerFirstInfectionDate = BackProjectStartSingleYearAnalysis - 5;        %used to filter possible back projected times

Px.FirstInfectionDateVec = Px.LowerFirstInfectionDate + (Px.UpperFirstInfectionDate - Px.LowerFirstInfectionDate) * rand(1, Px.NoParameterisations);

%% The below results are from a meta-analysis of studies of healthy CD4 counts, the following studies were used for this purpose
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

%mean healthy CD4 values measured in each study
meanCD4Healthyvec = [760, 950, 840, 710.96, 797.23, 807, 1036, 1017, 896.48, 830, 764.87, 1089, 749.42, 940, 993, 1171.12, 983.59, 704.28, 931.91, 1095];

%Standard Deviation in CD4 count in each study
stdCD4Healthyvec=[290, 225, 240, 197.66, 245.72, 378, 296, 329, 346.71, 288, 249.71, 415, 368.28, 307.65, 319, 414.49, 334.31, 249.69, 291.96, 391];

%Population Size in each study
nCD4Healthy=[402,50, 1000, 289, 275, 61, 266, 2787, 101, 600, 85, 146, 51, 965, 1356, 60, 678, 70, 100, 220];
nCD4Healthy=nCD4Healthy*100;                                                %multiply by 100 to ensure that we get the true mean from this bootstrapped method

%aggregating results to get value to be used for this simulation
varianceCD4Healthy = stdCD4Healthyvec.^2;
mu = log(meanCD4Healthyvec.^2./sqrt(varianceCD4Healthy + meanCD4Healthyvec.^2));
sigma = sqrt(log(varianceCD4Healthy./(meanCD4Healthyvec.^2) + 1)); 

BootStrappedCD4s=[];

for x = 1:length(mu)                                                        %Create numbers at random which would fall into the distribution
    SamplesToAdd = lognrnd(mu(x),sigma(x), 1, nCD4Healthy(x));
    BootStrappedCD4s = [BootStrappedCD4s SamplesToAdd];
end

MedianHealthyCD4 = median(BootStrappedCD4s);

LogBootStrappedCD4s = log(BootStrappedCD4s);
MedianLogBootStrappedCD4s = median(LogBootStrappedCD4s);
StdLogBootStrappedCD4s = std(LogBootStrappedCD4s);

Px.MedianLogHealthyCD4 = MedianLogBootStrappedCD4s;
Px.StdLogHealthyCD4 = StdLogBootStrappedCD4s;

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

Px.FractionalDeclineToTrough = 418/MedianHealthyCD4; %
Px.TimeUntilTrough = 17/365.25;
Px.TimeUntilRebound = 40/365.25;

% 1. Lang et al 1989 Patterns of T Lymphocyte Changes with Human Immunodeficiency Virus Infection: From Seroconversion to the Development of AIDS
% 2. Kaufmann et al. 1999
% 3. 2012 surveillance data of Australian recent infections
% To compensate for the high levels of disagreement in above studies we will choose the
% CD4 intercept (median, confidence intervals) to be 636 (586 - 686)

Px.BaselineCD4Median = 636;
Px.BaselineCD4LCI = 586;
Px.BaselineCD4UCI = 686;

Px.BaselineCD4Stdev = ((Px.BaselineCD4UCI - Px.BaselineCD4LCI) / 2) / 1.96;

% Create the distribution average CD4 count declines
m = Px.BaselineCD4Median;
v = (Px.BaselineCD4Stdev)^2;
mu = log((m^2)/sqrt(v+m^2));
sigma = sqrt(log(v/(m^2)+1));

Px.BaselineCD4MedianVec = lognrnd(mu, sigma, 1, NoParameterisations);

Px.FractionalDeclineToReboundVec = Px.BaselineCD4MedianVec / MedianHealthyCD4;
%% Assessing the literature on decline rates
% This section is dealing with a linear model of CD4 decline, the following
% studies were used for this section:
% 1.Lee(1989) 2.Veuglers(1997) 3.Sydney 4.Amsterdam 5.San Francisco GeneralHospital
% 6.San Francisco Men's Health 7.Prins (1999)European Secroconvert Study 
% 8.Deeks (2004), San Francisco, USA 9.% Mellors (MACS, USA) 10.Drylewicz(2008) France 
%11.Muller(2009) Switzerland 12.Wolbers(2010) CASCADE 13.Lewden(2010) France

N_CD4Decline = [112 129 79 140 19 46 221+443 68 1640 98+320 463 2820 373];
StudyDeclineRate = [68 59.87 36.42 54.1 43.45 55.42 60 96 64 49 52.5 61 63];

StudyCD4WeightedVector = [];
    
for x = 1:length(N_CD4Decline)
    StudyCD4WeightedVector = [StudyCD4WeightedVector StudyDeclineRate(x)*ones(1, N_CD4Decline(x))];
end

Px.MeanCD4Decline = mean(StudyCD4WeightedVector);
Px.SDCD4Decline = std(StudyCD4WeightedVector);                              %The systematic variation in the study's results

% Determine individual variablity in linear decline
IndividualDeclineIQR = 35; 
%-81 to –46, figure give in Cascade 
%The annual decline in CD4 per year, Wolbers, 2010, Pretreatment CD4 Cell Slope and Progression to AIDS or Death in HIV-Infected Patients Initiating Antiretroviral Therapy
Px.IndividualDeclineSD = (IndividualDeclineIQR / 2) / 0.674490;

%% Create the distribution average CD4 count declines
m = Px.MeanCD4Decline;
v = (Px.SDCD4Decline)^2;
mu = log((m^2) / sqrt(v + m^2));
sigma = sqrt(log(v / (m^2) + 1));

Px.CD4DeclineVec = lognrnd(mu, sigma, 1, NoParameterisations);
    % In this section, the decline must not be less than 10% of the average decline across simulations
    % Although this is very unlikely (given the above parameters) it needs to
    % be assumed that it is possible that declines of 10% could occur because
    % they are explicitly filtered in GenerateCD4Count
    
Px.CD4DeclineVec(Px.CD4DeclineVec <0.1*Px.MeanCD4Decline) = [];             %dispose of declines that are less than 10% of the estimate due to explicit filtering in GenerateCD4Count
NumberRemaining = length(Px.CD4DeclineVec);

if NumberRemaining < 1
    error('The CD4Decline function resulted in too few samples to resample from. This may be due to a decline rate that is too shallow');
end

%Resample to produce the required number of samples
ResampledDecline = randsample(Px.CD4DeclineVec, NoParameterisations - NumberRemaining,'true'); % with replacement
Px.CD4DeclineVec = [Px.CD4DeclineVec ResampledDecline];

%% Square root decline model
% The weighted mean of the decline is 61 cells per year 
% assuming a  mean of 400 cells in the study, and a loss of 61 cells in the
% year following, meaning a fall to 339. The square root of these values
% are 20.00 and 18.41 respectively. This represents an annual decline in
% square root CD4 counts of 1.588 per year.

% To choose an appropriate level of decline, we selected a mean square root
% decline of 1.6, and a 95% confidence interval of 1.4 to 1.8 using studies
% by Cascade 2003, Lodi 2010, Lodi 2011, Pillay non-TDR 1.7(95% CI,
% 0.8–2.6), Keller 2010 : 1.67 (Canada)

Px.MeanSquareRootAnnualDecline = 1.6;
Px.SquareRootAnnualDeclineStdev = ((1.8 - 1.4) / 2) / 1.96;

% Create the distribution average CD4 count declines
m = Px.MeanSquareRootAnnualDecline;
v = (Px.SquareRootAnnualDeclineStdev)^2;
mu = log((m^2) / sqrt(v + m^2));
sigma = sqrt(log(v / (m^2) + 1));

Px.SQRCD4DeclineVec = lognrnd(mu, sigma, 1, NoParameterisations);

Px.SQRCD4DeclineVec(Px.SQRCD4DeclineVec<0.1*Px.MeanSquareRootAnnualDecline)=[]; %dispose of declines that are less than 10% of the estimate due to explicit filtering in GenerateCD4Count
NumberRemaining = length(Px.SQRCD4DeclineVec);

if NumberRemaining < 1
    error('The SQRDecline function resulted in too few samples to resample from. This may be due to a decline rate that is too shallow');
end

%Resample to produce the required number of samples
ResampledSQRDecline = randsample(Px.SQRCD4DeclineVec, NoParameterisations - NumberRemaining, 'true'); % with replacement
Px.SQRCD4DeclineVec = [Px.SQRCD4DeclineVec ResampledSQRDecline];

%% Individual vaiablility in decline
%The following represents the individual variability of CD4 declines from 
%Wolbers et al. Plos 2010 (table 1) to generate an interquartile range
%For example, people at the 25th percentile may have a decline of 46 cells 
%per year, and at the 75th percentile may have a decline of 81.
%It is well established that high CD4s have higher CD4 declines, therefore,
%compare the upper quartile reading of decline to the upper quartile reading of current CD4
% and look for ranges of uncertainty.

CD4cellcountatcARTinitiation = [289];                                       %[206 398];
EstimatedprecARTCD4slope=[61 46 81];                                        %[median LQR UQR]
CD4cellcount1yearbeforecARTinitiation = CD4cellcountatcARTinitiation + EstimatedprecARTCD4slope;
sqrCD4_1 = sqrt(CD4cellcount1yearbeforecARTinitiation);
sqrCD4_2 = sqrt(CD4cellcountatcARTinitiation);
sqrdecline = sqrCD4_1 - sqrCD4_2;                                           %+ve, [median LQR UQR]

%now to find a rough stddev for square decline rates
MedianToUQR = (sqrdecline(3) - sqrdecline(1));                              %0.5271
MedianToLQR = (sqrdecline(1) - sqrdecline(2));                              %0.4053
MeanDistance = (MedianToUQR + MedianToLQR) / 2;                             %0.4662

%Range in which we believe INDIVIDUAL variability to be contained
Px.SDSQRDeclineIndividual = MeanDistance/0.67;                               %0.67 is the one tail value for the normal distribution 25th percentile

%% Linear decline following square root decline
% Although square root decline has the nice property of giving faster
% declines for higher CD4 counts, there is a point at which the CD4 decline
% becomes very shallow. Using the median starting CD4 count, we determine 
% the time until median decline is 60 cell/mL/year.

Px.TimeAtLinearDecline = (-Px.MeanCD4Decline/(-2*Px.MeanSquareRootAnnualDecline) - sqrt(Px.BaselineCD4Median))/(-Px.MeanSquareRootAnnualDecline);

% Add the time in the fast fall and recovery
Px.TimeAtLinearDecline = Px.TimeAtLinearDecline + Px.TimeUntilRebound;

% Note that from TimeAtLinearDecline onwards, the decline is based on the
% sqrCD4decline at that point in time. That means that the decline is, on
% average, not allowed to be lower than 60.8cells/muL/year.

end

