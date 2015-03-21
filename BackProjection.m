clear all;
clc;

TimeALL = tic;

%% Load Settings for simulation
LoadSettings;

%% Creating Object Patient 
%Place data from LineDataMatrix into PatientData
disp('Loading saved basic patient class data');
disp(' ');
[Patient] = CreatePatientObject(LineDataMatrix);

%% Remove records to adjust for duplicate diagnoses, assuming previously diagnosed overseas do not have duplicates
if Sx.DeduplicateDiagnoses == true
    disp(' ');
    disp('------------------------------------------------------------------');
    disp('Analyzing and removing Duplication in Data ');
    DuplicateTimer = tic;
    
    [Patient, DuplicatePatient] = RemoveDuplicates(Patient);
    
    disp(' ');
    disp([num2str(length(DuplicatePatient)) ' duplicates expected out of ' num2str(length(DuplicatePatient) + length(Patient)) ' records ']);
    disp(' ');
    
    disp('-Time to Remove Duplicate Copies-');
    toc(DuplicateTimer)
    disp('------------------------------------------------------------------');
end

%% Determine the time between infection and diagnosis
matlabpool('open', str2num(getenv( 'NUMBER_OF_PROCESSORS' ))-1);            %initialising parallel Matlab Sessions
disp('------------------------------------------------------------------');
disp('Determining and Optimising time between Infection and Diagnosis');
disp(' ');
disp('Loading Back Projection Parameters...');

[Px] = LoadBackProjectionParameters(Sx.NoParameterisations, Sx.MaxYears, Sx.StepSize, BackProjectStartSingleYearAnalysis);
Px.ConsiderRecentInfection = Sx.ConsiderRecentInfection;

disp('Back Projection Parameters Loaded Successfully!');
disp(' ');
disp('Running Optimisation Algorithm...');

OptimisationTimer = tic;

[~, NumberInPatientCurrently] = size(Patient);
YearIndex = 0;

for x = 1:Sx.NoParameterisations
    Sim(x).Patient = Patient;
end

for Year = BackProjectStartSingleYearAnalysis:YearOfDiagnosedDataEnd
    SimTimer = tic;
    fprintf(1, '\nRunning Simulation Year %d: \n', Year);
    YearIndex = YearIndex + 1;
    
    % For indivudals diagnosed prior to 1985, process as a group (as we have insufficient data on these individuals anyway)
    if Year == BackProjectStartSingleYearAnalysis
        MinYear = 0;%
        MaxYear = Year+1;
    else
        MinYear = Year;
        MaxYear = Year+1;
    end
      
    CD4ForOptimisation = -1 * ones(1, NumberInPatientCurrently);            %to indicate empty fields
    % Select individuals that are in the year group
    PatientRef = -1 * ones(1, NumberInPatientCurrently);
    CountRef=0;
    
    for x = 1:NumberInPatientCurrently
        % if the year of diagnosis matches
        if (MinYear <= Patient(x).DateOfDiagnosisContinuous) && (Patient(x).DateOfDiagnosisContinuous < MaxYear)
            CountRef = CountRef + 1;
            % record patient ref
            CD4ForOptimisation(CountRef) = Patient(x).CD4CountAtDiagnosis;
            % Extract CD4 at diagnosis
            PatientRef(CountRef) = x;
        end
    end
    % clear empty fields
    CD4ForOptimisation(CD4ForOptimisation<0) = [];
    PatientRef(PatientRef<0) = [];
    
    
    %Perform an optimisation
    Px.CurrentYear = Year;
    [Times, StartingCD4, TestingParameter] = CreateIndividualTimeUntilDiag(CD4ForOptimisation, Px, RandomNumberStream);
    
    OptimisationResults(YearIndex).Year = Year;
    OptimisationResults(YearIndex).TestingParameter = TestingParameter;
    
    %Place values back into the vector
    CountRef = 0;
    for ref = PatientRef
        CountRef = CountRef + 1;
        Patient(ref).TimeFromInfectionToDiagnosis = Times(CountRef, :);
    end
    
    CD4Comparison(YearIndex).RealTestingCD4 = CD4ForOptimisation;
    CD4ComparisonLookup(YearIndex) = Year;
    %Store the appropriate probabilities
    fprintf(1, 'Time to run Simulation: %.2f seconds\n', toc(SimTimer));
end

for x = 1:length(Patient)
    for y = 1:Sx.NoParameterisations
        Sim(y).Patient(x).TimeFromInfectionToDiagnosis = Patient(x).TimeFromInfectionToDiagnosis(y);  
    end
end

disp(' ');
disp('-Time Spent on Optimisation-');
toc(OptimisationTimer)
%disp('------------------------------------------------------------------');
%matlabpool close;
disp('------------------------------------------------------------------');

%% Create dates for the infection based on time between infection and testing, together with testing date
[~, NumberOfPatients] = size(Patient);
for x = 1:NumberOfPatients
    Patient(x) = Patient(x).DetermineInfectionDateDistribution();
end

for x = 1:Sx.NoParameterisations
    for y = 1:NumberOfPatients
        Sim(x).Patient(y) = Patient(x).DetermineInfectionDateDistribution();
    end    
end
    
%% If consideration is given to recent infection data, select data according to avaialable information

if Sx.ConsiderRecentInfection == true
    for SimCount = 1:Sx.NoParameterisations
        for x = 1:NumberInPatientCurrently
            % A clear western blot in close proximity to diagnosis indicates most likely a recent infection
            % Serconversion illness indicates a likely recent infection
            LatestFirstDateEstFromIllness = NaN;
            LatestFirstDateEstFromWesternBlot = NaN;
            % if the time of illness is more than 40 days after diagnosis,
            % it's likely not to be serconversion illness so we ignore
            if (Patient(x).DateIll - Patient(x).DateOfDiagnosisContinuous) < (40 / 365) % if NaN, do nothing
                LatestFirstDateEstFromIllness = Patient(x).DateIll - (40 / 365);
            end
            % if it is more than 40 days after diagnosis, there's probably an issue, so we ignore the western blot result
            if (Patient(x).DateIndetWesternBlot - Patient(x).DateOfDiagnosisContinuous) < (40/365) % if NaN, do nothing
                LatestFirstDateEstFromWesternBlot = Patient(x).DateIndetWesternBlot - (40/365);
            end
            
            
            if (Patient(x).InfectionDateDistribution(SimCount) < Patient(x).DateLastNegative) && (Patient(x).DateLastNegative < Patient(x).DateOfDiagnosisContinuous) % if NaN, do nothing
                LatestFirstDateEstFromLastNegative = Patient(x).DateLastNegative;
            else
                LatestFirstDateEstFromLastNegative = NaN;
            end
            
            % Find the most recent of the above. Randomly chose between
            % LatestFirstDate and the date of diagnosis
            LatestFirstDate=max([LatestFirstDateEstFromWesternBlot, LatestFirstDateEstFromIllness, LatestFirstDateEstFromLastNegative]);
            if ~isnan(LatestFirstDate)
                Patient(x).InfectionDateDistribution(SimCount) = LatestFirstDate + rand*(Patient(x).DateOfDiagnosisContinuous - LatestFirstDate);
                % re-establish the time between infection and diagnosis for the individual
                Patient(x).TimeFromInfectionToDiagnosis = Patient(x).DateOfDiagnosisContinuous - Patient(x).InfectionDateDistribution;
            end
            %else do nothing
        end
    end
end

%% Forward simulate 
ForwardSimulate;

%% Create a diagnosis plot
[FineDiagnoses] = DiagnosesByTime(Patient, CD4BackProjectionYearsWhole(1), Sx.StepSize, CD4BackProjectionYearsWhole(2)+1-Sx.StepSize);

[DiagnosesByYear] = DiagnosesByTime(Patient, CD4BackProjectionYearsWhole(1), 1, CD4BackProjectionYearsWhole(2));

%% Find total undiagnosed at all points in time

fprintf(1,'\nDetermining when Patients were Undiagnosed\n');
UndiagnosedTimer = tic;
    
fprintf(1,'\nAnalyzing Undiagnosed Patients:\n');

[UndiagnosedPatient] = UndiagnosedByTime(Patient, CD4BackProjectionYearsWhole(1), Sx.StepSize, (CD4BackProjectionYearsWhole(2)+1-Sx.StepSize)); %only of those diagnosed at end of last year of data

% UndiagnosedByTime this functino now returns ALL undiagnosed

% UndiagnosedPatient in graphs should be only those undiagnosed at time who
% have been diagnosed prior to the end of data (should not include forwaard
% simulated individuals

% suggested changes
% [TotalUndiagnosedByTime] = UndiagnosedByTime(Patient, CD4BackProjectionYearsWhole(1), Sx.StepSize, (CD4BackProjectionYearsWhole(2)+1-Sx.StepSize)); %only of those diagnosed at end of last year of data

% make a new function, very similar to UndiagnosedByTime, that takes
% another parameter, data cut off time. 
% if Patient(i).DateOfDiagnsosis<DataCutOff -> add to the data

%Add the undiagnosed with time (who have been diagnosed) to the people we know will be diagnosed in the future
TotalUndiagnosedByTime.Time = UndiagnosedPatient.Time ;
TotalUndiagnosedByTime.N = UndiagnosedSummed + UndiagnosedPatient.N ;     %%%%%%%%%%%%%%%%%%%%need to get rid of UndiagnosedSummed%%%%%%%%%%%%%%%%%%

[NumSims, NumStepsInYearDimension] = size(TotalUndiagnosedByTime.N);
for SimCout = 1:NumSims
    EffectiveTestingRate(SimCout, :) = FineDiagnoses.N ./ TotalUndiagnosedByTime.N(SimCout, :);
end

YearCount = 0;
StepsToAverageOver = round(1/Sx.StepSize);
YearlyEffectiveTestingRate = [];
for YearStepCount = 1:10:NumStepsInYearDimension
    YearCount = YearCount + 1;
    YearlyEffectiveTestingRate(:, YearCount) = mean(EffectiveTestingRate(:, YearStepCount:YearStepCount+StepsToAverageOver-1), 2);
    RaisedPower = round(1/Sx.StepSize);
    YearlyEffectiveTestingRate(:, YearCount) = 1 - (1-YearlyEffectiveTestingRate(:, YearCount)).^RaisedPower;%Do a probability transform (0.1 to 1 years)
end

YearCount = 0;
StepsToAverageOver = round(1/Sx.StepSize);

 fprintf(1, '\n\n-Time to Determine Undiagnosed State of Patients-\n');
 toc(UndiagnosedTimer)
 disp('------------------------------------------------------------------');

%% Determine the time until infection for the population with time
[~, NumberOfPatients] = size(Patient);

%Set all year times to zero 
YearIndex = 0;
TimeSinceInfection = [];
TimeSinceInfectionYearIndex = CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2);

for Year = TimeSinceInfectionYearIndex
    YearIndex = YearIndex + 1;
    TimeSinceInfection(YearIndex).v = -ones(1, NumberOfPatients*NumSims);
end

%For all of the years
for x = 1:NumberOfPatients
    YearIndex = 0;
    for Year = CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2)
        YearIndex = YearIndex+1;
        if Patient(x).DateOfDiagnosisContinuous >= Year && Patient(x).DateOfDiagnosisContinuous < Year+1
            TimeSinceInfection(YearIndex).v((x-1)*NumSims+1:x*NumSims) = Patient(x).TimeFromInfectionToDiagnosis;
        end
    end
end
YearIndex = 0;
for Year = TimeSinceInfectionYearIndex
    YearIndex = YearIndex + 1;
    %Remove all of the unfilled values as above
    TimeSinceInfection(YearIndex).v(TimeSinceInfection(YearIndex).v<0) = [];
end

%% Plotting results
CreateFigure1;
CreateFigure2;
CreateFigure3;
CreateFigure4(TotalUndiagnosedByTime, PlotSettings.YearsToPlot, 'Figure 4 TotalUndiagnosedByTime');
CreateFigure5;

%CreateOtherPlots;
%CreateResultUncertaintyAroundTime;
%YearValueVector=CD4BackProjectionYearsWhole(1):Sx.StepSize:(CD4BackProjectionYearsWhole(2)+1-Sx.StepSize);

%% Calculating Total Simulation Time
disp(' ');
disp('------------------------------------------------------------------');
disp('-Total Simulation Time-');
toc(TimeALL)
disp('------------------------------------------------------------------');
%% Sensitivity analysis
%SensitivityAnalysis

%%% Paper sentences
%disp('------------------------------------------------------------------');
%TotalUndiagnosedByTime.Median=median(TotalUndiagnosedByTime.N, 1);
%[MaxMedUndiagnosed, IndexOfMax]= max(TotalUndiagnosedByTime.Median);
%YearMaxMedUndiagnosed=TotalUndiagnosedByTime.Time(IndexOfMax);
%LCI=prctile(TotalUndiagnosedByTime.N(:, IndexOfMax), 2.5);
%UCI=prctile(TotalUndiagnosedByTime.N(:, IndexOfMax), 97.5);
%disp(['The model estimates that the number of people living with undiagnosed HIV peaked in ' num2str(YearMaxMedUndiagnosed) ' at ' num2str(MaxMedUndiagnosed) '(' num2str(LCI) '-' num2str(UCI) ') cases.']);

%LCI=prctile(TotalUndiagnosedByTime.N(:, end), 2.5);
%UCI=prctile(TotalUndiagnosedByTime.N(:, end), 97.5);
%disp(['Final year of undiagnosed ' num2str(TotalUndiagnosedByTime.Median(end)) '(' num2str(LCI) '-' num2str(UCI) ') cases.']);
%
%SubsetUndiagnosed.N=TotalUndiagnosedByTime.N(:, IndexOfMax:end);
%SubsetUndiagnosed.Median=TotalUndiagnosedByTime.Median(IndexOfMax:end);
%SubsetUndiagnosed.Time=TotalUndiagnosedByTime.Time(IndexOfMax:end);
%[MinMedUndiagnosed, IndexOfMin]= min(SubsetUndiagnosed.Median);
%LCI=prctile(SubsetUndiagnosed.N(:, IndexOfMin), 2.5);
%UCI=prctile(SubsetUndiagnosed.N(:, IndexOfMin), 97.5);
%YearMinMedUndiagnosed=SubsetUndiagnosed.Time(IndexOfMin);
%disp(['Min since max occurred in ' num2str(YearMinMedUndiagnosed) ' with ' num2str(MinMedUndiagnosed) '(' num2str(LCI) '-' num2str(UCI) ') cases.']);

%% Return diagnosed overseas to the population
%AllPatients=[Patient PreviouslyDiagnosedOverseasPatient];

%% Saving results 
% use http://www.mathworks.com.au/help/matlab/ref/save.html#inputarg_version
% v7.3 to save files above 2GB
%YearVectorLabel=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2)-1);
%HistYearSlots=(CD4BackProjectionYearsWhole(1):Sx.StepSize:(CD4BackProjectionYearsWhole(2)+1-Sx.StepSize));
%disp('In the following section, data is to be saved to put into a file for reuse later');
%BackProjectedResults.DistributionDiagnosedInfections=DistributionDiagnosedInfections;
%BackProjectedResults.DistributionUndiagnosedInfections=DistributionUndiagnosedInfections;
%BackProjectedResults.DistributionUndiagnosedInfectionsPrecise=DistributionUndiagnosedInfectionsPrecise;
%BackProjectedResults.DistributionDiagnosedInfectionsPrecise=DistributionDiagnosedInfectionsPrecise;
% BackProjectedResults.MeanDeclineSelected=MeanDeclineSelected; 
% BackProjectedResults.AsymptomaticPSelected=AsymptomaticPSelected;
% BackProjectedResults.SymptomaticPSelected=SymptomaticPSelected;
% BackProjectedResults.CurvatureSelected=CurvatureSelected;
%BackProjectedResults.YearVectorLabel=YearVectorLabel;
%BackProjectedResults.YearVectorLabelPrecise=HistYearSlots;
%BackProjectedResults.CD4BackProjectionYearsWhole=CD4BackProjectionYearsWhole;
%BackProjectedResults.TotalUndiagnosedByTime=TotalUndiagnosedByTime;

%BackProjectedResults.OptimisationResults=OptimisationResults;

%save('PatientSaveFiles/BackProjectedResults.mat', 'BackProjectedResults');
%disp('Saving individual patient records, this may take a while');
%Identifier=1;
%SavePatientClass(AllPatients, 'PatientSaveFiles',  Identifier);


% save('PatientSaveFiles/SimulationState.mat');

