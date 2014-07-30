

TimeALL=tic;

%% Seed the random variables
RandomNumberStream = RandStream('mlfg6331_64','Seed',1385646);
RandStream.setGlobalStream(RandomNumberStream);

%Use the below code in any parfor loop to use appropriate substreams for the rand generator (i is the loop number)
%set(stream,'Substream',i);


%% Load settings for the simualtion
% LoadSettings
LoadSettings


if InitialisePCToSRThisSim==false
    load([ParameterLocalStorageLocation 'PC2SR.mat']);%If PC2SR file cannot be found, it may need to be generated
else
    % Initialise postcode to statistical region coder
    disp('Initialising PCToSR system');
    [PC2SR]=InitialisePCToSR();
end


%% Load the patient data into a large matrix and create objects to store patient data
disp('Loading saved basic patient class data');

%open file format, return separately the postcodes and other subsections of the data 
[LineDataMatrix, LocationDataMatrix]=LoadNotificationFile(HIVFile, SheetName, PerformGeographicCalculations);

%Place data from LineDataMatrix into PatientData
[Patient]=CreatePatientObject(LineDataMatrix);

if PerformGeographicCalculations ==true
    %Place data from LocationDataMatrix into PatientData
    Patient=GeoAddLocationData(Patient, LocationDataMatrix, PC2SR);
end


%% Sort Patients into those who have a previous overseas diagnosis, and those who have not. 

disp('Removing overseas diagnosed cases to be utilised later');
PatientSplitTimer=tic;
OverseasDiagID=[];
[~, NumberInPatientCurrently]=size(Patient);
for i=1:NumberInPatientCurrently
    if Patient(i).PreviouslyDiagnosedOverseas==1
        OverseasDiagID=[OverseasDiagID i];
    end
end
PreviouslyDiagnosedOverseasPatient=Patient(OverseasDiagID);
Patient(OverseasDiagID)=[];
toc(PatientSplitTimer)

%% Remove records to adjust for duplicate diagnoses
[Patient, DuplicatePatient]=RemoveDuplicates(Patient);


%% Sort Patients into those who have an infection known to be in the last 12 months, and those who have not. 
if ConsiderRecentInfection==true
    disp('Removing Recent cases to be utilised later');
    PatientSplitTimer=tic;
    RecentPatientID=[];
    [~, NumberInPatientCurrently]=size(Patient);
    for i=1:NumberInPatientCurrently
        if Patient(i).RecentInfection==1
            RecentPatientID=[RecentPatientID i];
        end
    end
    RecentPatient=Patient(RecentPatientID);
    Patient(RecentPatientID)=[];
    toc(PatientSplitTimer)
    
    %Determine the proportion of people in each year with evidence of recent infection
    NotRecentDiagnosisDates=zeros(size(Patient));
    PCount=0;
    for P=Patient
        PCount=PCount+1;
        NotRecentDiagnosisDates(PCount)=P.DateOfDiagnosisContinuous;%Note that in this system all records without recent diagnosis data have an entris of year zero. This means that you can fileter it out when trying to determine the total number recently infected below.
    end
    
    RecentDiagnosisDates=zeros(size(RecentPatient));
    PCount=0;
    for RP=RecentPatient
        PCount=PCount+1;
        RecentDiagnosisDates(PCount)=RP.DateOfDiagnosisContinuous;
    end
    
 end



%% Determine the time between infection and diagnosis
disp('Determining the time between infection and diagnosis');
TicOptimisation=tic;
NumberOfSamples=200;

disp( 'Starting parallel Matlab...');
matlabpool(str2num(getenv( 'NUMBER_OF_PROCESSORS' ))-2);%this may not work in all processors

[Px]=LoadBackProjectionParameters(NumberOfSamples);
Px.ConsiderRecentInfection=ConsiderRecentInfection;

% Sort individuals by year of diagnosis
BackProjectStartSingleYearAnalysis=1984;

[~, NumberInPatientCurrently]=size(Patient);
YearIndex=0;
for Year=BackProjectStartSingleYearAnalysis:YearOfDiagnosedDataEnd-1
    YearIndex=YearIndex+1;
    disp(Year)
    % For indivudals diagnosed prior to 1985, process as a group (as we have insufficient data on these individuals anyway)
    if Year==BackProjectStartSingleYearAnalysis
        MinYear=0;%
        MaxYear=Year+1;
    else
        MinYear=Year;
        MaxYear=Year+1;
    end
    
    if Px.ConsiderRecentInfection
        RecentDataTotal=sum(MinYear<=RecentDiagnosisDates & RecentDiagnosisDates<MaxYear);
        NoRecentDataTotal=sum(MinYear<=NotRecentDiagnosisDates & NotRecentDiagnosisDates<MaxYear);
        Px.PropWithRecentDiagDataPresentThisYear=RecentDataTotal/(RecentDataTotal+NoRecentDataTotal);
        
    end
    
    CD4ForOptimisation=-1*ones(1, NumberInPatientCurrently);
    % Select individuals that are in the year group
    PatientRef=-1*ones(1, NumberInPatientCurrently);
    CountRef=0;
    for i=1:NumberInPatientCurrently
        % if the year of diagnosis matches
        if MinYear<=Patient(i).DateOfDiagnosisContinuous && Patient(i).DateOfDiagnosisContinuous<MaxYear
            CountRef=CountRef+1;
            % record patient ref
            CD4ForOptimisation(CountRef)=Patient(i).CD4CountAtDiagnosis;
            % Extract CD4 at diagnosis
            PatientRef(CountRef)=i;
        end
    end
    % clear empty fields
    CD4ForOptimisation(CD4ForOptimisation<0)=[];
    PatientRef(PatientRef<0)=[];
    
    %Perform an optimisation
    [Times, StartingCD4, TestingProbVec, IdealPopTimesStore, IdealPopTestingCD4 ]=CreateIndividualTimeUntilDiag(CD4ForOptimisation, Px, NumberOfSamples, RandomNumberStream);
    
    OptimisationResults(YearIndex).Year=Year;
    OptimisationResults(YearIndex).TestingProbVec=TestingProbVec;
    
    %Place values back into the vector
    CountRef=0;
    for ref=PatientRef
        CountRef=CountRef+1;
        Patient(ref).TimeFromInfectionToDiagnosis=Times(CountRef, :);
    end
    
    CD4Comparison(YearIndex).RealTestingCD4=CD4ForOptimisation;
    CD4Comparison(YearIndex).SimulatedTestingCD4=IdealPopTestingCD4;
    CD4ComparisonLookup(YearIndex)=Year;
    %Store the appropriate probabilities
    
end
matlabpool close;
TimeSpentOptimising=toc(TicOptimisation);
toc(TicOptimisation)




%% Old system
% Determine the assumed testing rate in the population
%The following uses a distributed computing genetic algorithm to
%optimise the parameters we believe to be correct for the population
% % % % % [AsymptomaticPSelected, SymptomaticPSelected, CurvatureSelected, MeanDeclineSelected,  CD4sUsedForFitting, SimulatedTestingCD4, SimulatedTimeUntilDiagnosis]=FindDataAndOptimise(Patient, RangeOfCD4Averages, Sx);
% % % % % 
% % % % % CombinedCD4Vector=SimulatedTestingCD4;
% % % % % CombinedTimeVector=SimulatedTimeUntilDiagnosis;

% Create a distribution of time between infection and diagnosis for all individuals
% % % % % CreateDatesOfInfection



    
    
    
% Set the number of samples in the distribution of times until diagnosis to the number of optimised points found
% Here we set the number of samples per person to the number of found optimised points
% % % % % NumberOfSamples=NoOptimisedPoints;
NumberOfSamples=NumberOfSamples;
 
    
    
%% If consideration is given to recent infection data, recombine the non-Recent patients back into the patient variable
if ConsiderRecentInfection==true
    % assign infection distributions of those who are known to have been infected in the last 12 months

    [~, NumberOfRecentInfections]=size(RecentPatient);

    for i=1:NumberOfRecentInfections
        RecentPatient(i).TimeFromInfectionToDiagnosis= rand(1,NumberOfSamples);
        %Alternate distribution: People have testing rates of between once every 3 months and 1 year = (1-rand(1, NumberOfSamples)*0.75).*rand(1, NumberOfSamples)
    end

    %recombine the recent and non-recent infections
    Patient=[Patient RecentPatient];
end



%% Create dates for the infection based on time between infection and testing, together with testing date
[~, NumberOfPatients]=size(Patient);
for i=1:NumberOfPatients
    Patient(i)=Patient(i).DetermineInfectionDateDistribution();
end
    















%% This section is where all of the information is collected up to make a population wide calculation of the incidence
clear DistributionUndiagnosedInfectionsPrecise;
clear DistributionDiagnosedInfectionsPrecise;
clear DistributionDiagnosedInfections;
clear DistributionUndiagnosedInfections;


%Create a summing vector that contains the infection dates for the
%diagnoses (regardless of the date of diagnosis)

tic
DateMatrix=zeros(NumberOfSamples, NumberOfPatients);
InfectionTimeMatrix=zeros(NumberOfSamples, NumberOfPatients);

NoPatientInRange=0;
TimeDistributionOfRecentDiagnoses=[];
CD4DistributionOfRecentDiagnoses=[];
for i=1:NumberOfPatients

        TimeDistributionOfRecentDiagnoses((i-1)*NumberOfSamples+1:i*NumberOfSamples)=Patient(i).TimeFromInfectionToDiagnosis;
        CD4DistributionOfRecentDiagnoses((i-1)*NumberOfSamples+1:i*NumberOfSamples)=Patient(i).CD4CountAtDiagnosis;
        DateMatrix(:, i)=Patient(i).InfectionDateDistribution;
        if Patient(i).DateOfDiagnosisContinuous>= RangeOfCD4Averages(1) && Patient(i).DateOfDiagnosisContinuous< RangeOfCD4Averages(2)
            NoPatientInRange=NoPatientInRange+1;
            InfectionTimeMatrix(:, NoPatientInRange)=Patient(i).TimeFromInfectionToDiagnosis;
            %ExpectedTimesVector=[ExpectedTimesVector Patient(i).TimeFromInfectionToDiagnosis];
        end
end
%remove all those elements that are not used
InfectionTimeMatrix(:, NoPatientInRange+1:NumberOfPatients)=[];
timevalue=toc;


HistYearSlots=(CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize));

for SimNumber=1:NumberOfSamples
    disp(['Finding undiagnosed ' num2str(SimNumber) ' of ' num2str(NumberOfSamples)]);
    
    ExpectedTimesVector=InfectionTimeMatrix(SimNumber, :);%(for this Sim)
    InfectionsByYearDiagnosed=hist(DateMatrix(SimNumber, :), HistYearSlots);% 0.5*StepSize used to centralise the bar plots in the the hist function
    [~, TotalInTimeVector]=size(ExpectedTimesVector);
    
        ProportionOfExpectedTimesVectorExpectedPerStep=StepSize/(RangeOfCD4Averages(2)-RangeOfCD4Averages(1));
        TotalInStepResample=round(TotalInTimeVector*ProportionOfExpectedTimesVectorExpectedPerStep);%this parameter is not acually used in any meaningful way in this code
        
        % Find an estimate for the number of infections which are undiagnosed
        [~, LastPositionInArray]=size(HistYearSlots);
        YearIndex=0;
        for YearStep=HistYearSlots
            YearIndex=YearIndex+1;
            n=LastPositionInArray-YearIndex+1;
            if n>MaxYears/StepSize %i.e if year step is greater than 20 years
                DistributionForThisSimulationUndiagnosedInfectionsPrecise(YearIndex)=0;
            else
                if TotalInStepResample<0
                    DistributionForThisSimulationUndiagnosedInfectionsPrecise(YearIndex)=0;
                else
                    AdjustmentFactor=2*n/(2*n-1);
                    %Adjust for the fact that we are cutting across triangle in determining the future cases i.e.:
                    %|\
                    %|\|\
                    %|\|\|\
                    %2.5, 1.5, 0.5
                    TotalDiagnosedInBackprojectionEstimate=InfectionsByYearDiagnosed(YearIndex)*AdjustmentFactor;
                    replacement=true;
                    RandomisedExpectedTimesVector=randsample(ExpectedTimesVector, TotalInTimeVector, replacement);%create a really big vector to sample from. This should be about 50 times bigger than what's needed.
                    
                    NumberFoundDiagnosed=0;
                    NumberOfUnidagnosedInfectionsThisStep=0;
                    CountSamples=0;
                    while NumberFoundDiagnosed<TotalDiagnosedInBackprojectionEstimate

                        CountSamples=CountSamples+1;
                        
                        NewTimeToAdd=RandomisedExpectedTimesVector(CountSamples);
                        TimeToFind=(CD4BackProjectionYearsWhole(2)+1-YearStep);

                        if NewTimeToAdd<TimeToFind+StepSize/2%The StepSize/2 is because of an error being created by the random addition of small amounts to the expected times vector
                            NumberFoundDiagnosed=NumberFoundDiagnosed+1;
                        else
                            NumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep+1;
                        end
                        
                    end

                    DistributionForThisSimulationUndiagnosedInfectionsPrecise(YearIndex)=NumberOfUnidagnosedInfectionsThisStep;

                end
            end
        end

    %Create a matrix of all simulations
    DistributionUndiagnosedInfectionsPrecise(SimNumber, :)=DistributionForThisSimulationUndiagnosedInfectionsPrecise;
    DistributionDiagnosedInfectionsPrecise(SimNumber, :)=InfectionsByYearDiagnosed;
    
    %Sum up the results for the undiagnosed infections into year blocks
    YearIndex=0;
    StepIndex=0;
    DistributionForThisSimulationUndiagnosedInfections=zeros(1, (CD4BackProjectionYearsWhole(2)-CD4BackProjectionYearsWhole(1)));
    for Year=CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2)
        YearIndex=YearIndex+1;
        for TenSteps=1:10
            StepIndex=StepIndex+1;
            DistributionForThisSimulationUndiagnosedInfections(YearIndex)=DistributionForThisSimulationUndiagnosedInfections(YearIndex)+DistributionForThisSimulationUndiagnosedInfectionsPrecise(StepIndex);
        end        
    end
    
    %State the histogram year centres
    YearCentres=(CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2))+0.5;
    %Find the infections that have already been diagnosed
    DistributionForThisSimulationDiagnosedInfections=hist(DateMatrix(SimNumber, :), YearCentres);
   
    DistributionDiagnosedInfections(SimNumber, :)=DistributionForThisSimulationDiagnosedInfections;
    DistributionUndiagnosedInfections(SimNumber, :)=DistributionForThisSimulationUndiagnosedInfections;
    
end

%% Create a diagnosis plot
SizeOfDiagnosisVector=ceil((CD4BackProjectionYears(2)-CD4BackProjectionYears(1))/StepSize);

Diagnoses=zeros(1, SizeOfDiagnosisVector);
DiagnosesByYear=zeros(1, (CD4BackProjectionYearsWhole(2)-CD4BackProjectionYearsWhole(1)+1));

[~, NumberOfPatients]=size(Patient);

for i=1:NumberOfPatients

    %add diagnosis date to appropriate position for a fine level reporting
    Ref=ceil((Patient(i).DateOfDiagnosisContinuous-CD4BackProjectionYears(1))/StepSize);
    Diagnoses(Ref)=Diagnoses(Ref)+1;
    
    %Determine which year the diagnosis occurred
    RefYear=ceil((Patient(i).DateOfDiagnosisContinuous-CD4BackProjectionYearsWhole(1)));

    DiagnosesByYear(RefYear)=DiagnosesByYear(RefYear)+1;
end

%% Find total undiagnosed at all points in time
[~, NumberOfYearSlots]=size(HistYearSlots);
UndiagnosedMatrix=zeros(NumberOfSamples, NumberOfYearSlots );
for i=1:NumberOfPatients
    %exclude those who were diagnosed overseas
    if mod(i, 100)==0
        disp(['Finding when patient ' num2str(i) ' is undiagnosed']);
    end
    if Patient(i).PreviouslyDiagnosedOverseas==0
        YearSlotCount=0;
        for YearStep=HistYearSlots
            YearSlotCount=YearSlotCount+1;
            UndiagnosedAddtionVector=Patient(i).InfectionDateDistribution<YearStep & Patient(i).DateOfDiagnosisContinuous >YearStep;
            %Add this value to the matrix across the no. simulations dimension
            UndiagnosedMatrix(:, YearSlotCount)=UndiagnosedMatrix(:, YearSlotCount)+UndiagnosedAddtionVector';
        end
    end
end

%Find the total currently undiagnosed
% Note that all the diagnoses in the DistributionUndiagnosedInfectionsPrecise are undiagnosed.  
UndiagnosedSummed=[];
for IndexCount=1:NumberOfYearSlots
    % Find sum of all currently undiagnosed
    if IndexCount==1
        UndiagnosedSummed(:, IndexCount)=DistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    else
        UndiagnosedSummed(:, IndexCount)=UndiagnosedSummed(:, IndexCount-1)+DistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    end
end
%Add the undiagnosed with time (who have been diagnosed) to the people we know will be diagnosed in the future
TotalUndiagnosedByTime=UndiagnosedSummed+UndiagnosedMatrix ;

[NumSims, NumStepsInYearDimension]=size(TotalUndiagnosedByTime);
for SimCout=1:NumSims
    EffectiveTestingRate(SimCout, :)=Diagnoses./TotalUndiagnosedByTime(SimCout, :);
end

YearCount=0;
StepsToAverageOver=round(1/StepSize);
YearlyEffectiveTestingRate=[];
for YearStepCount=1:10:NumStepsInYearDimension
    YearCount=YearCount+1;
    YearlyEffectiveTestingRate(:, YearCount)=mean(EffectiveTestingRate(:, YearStepCount:YearStepCount+StepsToAverageOver-1), 2);
    RaisedPower=round(1/StepSize);
    YearlyEffectiveTestingRate(:, YearCount)=1-(1-YearlyEffectiveTestingRate(:, YearCount)).^RaisedPower;%Do a probability transform (0.1 to 1 years)
end

%% Determine the time until infection for the population with time
[~, NumberOfPatients]=size(Patient);
%Set all year times to zero 
YearIndex=0;
TimeSinceInfection=[];
TimeSinceInfectionYearIndex=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2)-1);
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    TimeSinceInfection(YearIndex).v=-ones(1, NumberOfPatients*NumSims);
end
%For all of the years
for i=1:NumberOfPatients
    YearIndex=0;
    for Year=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2)-1)
        YearIndex=YearIndex+1;
        if Patient(i).DateOfDiagnosisContinuous>= Year && Patient(i).DateOfDiagnosisContinuous< Year+1
            TimeSinceInfection(YearIndex).v((i-1)*NumSims+1:i*NumSims)=Patient(i).TimeFromInfectionToDiagnosis;
        end
    end
end
YearIndex=0;
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    %Remove all of the unfilled values as above
    TimeSinceInfection(YearIndex).v(TimeSinceInfection(YearIndex).v<0)=[];
end

%% Plotting results
CreateFigure1
CreateFigure2
CreateFigure3
CreateFigure4
CreateFigure5
CreateOtherPlots
CreateResultUncertaintyAroundTime
%OutputPlots %old plots output
toc(TimeALL)

%% Return diagnosed overseas to the population
AllPatients=[Patient PreviouslyDiagnosedOverseasPatient];

%% Saving results 
% use http://www.mathworks.com.au/help/matlab/ref/save.html#inputarg_version
% v7.3 to save files above 2GB
YearVectorLabel=CD4BackProjectionYearsWhole(1):(CD4BackProjectionYearsWhole(2)-1);
HistYearSlots=(CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize));
disp('In the following section, data is to be saved to put into a file for reuse later');
BackProjectedResults.DistributionDiagnosedInfections=DistributionDiagnosedInfections;
BackProjectedResults.DistributionUndiagnosedInfections=DistributionUndiagnosedInfections;
BackProjectedResults.DistributionUndiagnosedInfectionsPrecise=DistributionUndiagnosedInfectionsPrecise;
BackProjectedResults.DistributionDiagnosedInfectionsPrecise=DistributionDiagnosedInfectionsPrecise;
% BackProjectedResults.MeanDeclineSelected=MeanDeclineSelected; 
% BackProjectedResults.AsymptomaticPSelected=AsymptomaticPSelected;
% BackProjectedResults.SymptomaticPSelected=SymptomaticPSelected;
% BackProjectedResults.CurvatureSelected=CurvatureSelected;
BackProjectedResults.YearVectorLabel=YearVectorLabel;
BackProjectedResults.YearVectorLabelPrecise=HistYearSlots;
BackProjectedResults.CD4BackProjectionYearsWhole=CD4BackProjectionYearsWhole;
BackProjectedResults.TotalUndiagnosedByTime=TotalUndiagnosedByTime;

BackProjectedResults.OptimisationResults=OptimisationResults;

save('PatientSaveFiles/BackProjectedResults.mat', 'BackProjectedResults');
disp('Saving individual patient records, this may take a while');
Identifier=1;
SavePatientClass(AllPatients, 'PatientSaveFiles',  Identifier);

% clear Patient;
% clear RecentPatient;
% clear LineDataMatrix;
% clear LocationDataMatrix;
% clear OldCombinedCD4Vector;
% clear OldCombinedTimeVector;
% clear OtherOutput;
% save('PatientSaveFiles/SimulationState.mat');
toc(TimeALL)

%publication commit message
% Publication commit BP002