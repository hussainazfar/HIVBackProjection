NoParameterisations=21; % the number of parameterisations used to generate uncertainty. Should be set to 200
IncludePreviouslyDiagnosedOverseas=false;
DeduplicateDiagnoses=true;

TimeALL=tic;

%% Seed the random variables
RandomNumberStream = RandStream('mlfg6331_64','Seed',1385646);
RandStream.setGlobalStream(RandomNumberStream);

%Use the below code in any parfor loop to use appropriate substreams for the rand generator (i is the loop number)
%set(stream,'Substream',i);


%% Load settings for the simualtion
% LoadSettings
LoadSettings


%if InitialisePCToSRThisSim==false
%    load([ParameterLocalStorageLocation 'PC2SR.mat']);%If PC2SR file cannot be found, it may need to be generated
%else
    % Initialise postcode to statistical region coder
%    disp('Initialising PCToSR system');
%    [PC2SR]=InitialisePCToSR();
%end


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

%% Adjust category 12 exposures for MSM
% it is likely that many in this category will be MSM. Based on approximately 8% females, and assuming therefore 8% heterosexual males, 84% of people in this category may be MSM
[~, NoPatient]=size(Patient);
% Count females
TotalFemalesNotSpecified=0;
TotalNotSpecified=0;
for i=1:NoPatient
    if Patient(i).ExposureRoute==12 %not specified
        TotalNotSpecified=TotalNotSpecified+1;
        if Patient(i).Sex==2
            TotalFemalesNotSpecified=TotalFemalesNotSpecified+1;
        end
    end
end
TotalMalesNotSpecified=TotalNotSpecified-TotalFemalesNotSpecified;
ProbabilityMaleMSM=(TotalMalesNotSpecified-TotalFemalesNotSpecified)/TotalMalesNotSpecified;
for i=1:NoPatient
    if Patient(i).ExposureRoute==12 && Patient(i).Sex==1%not specified
        Patient(i).ExposureRoute=1;
    end
end
%% Sort Patients into those who have a previous overseas diagnosis, and those who have not. 
PreviouslyDiagnosedOverseasPatient=[];
if (IncludePreviouslyDiagnosedOverseas==false)
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
end

%% Remove records to adjust for duplicate diagnoses, assuming previously diagnosed overseas do not have duplicates
if DeduplicateDiagnoses
    [Patient, DuplicatePatient]=RemoveDuplicates(Patient);
end




%% Sort Patients into those who have an infection known to be in the last 12 months, and those who have not. 
% if ConsiderRecentInfection==true
% %     disp('Removing Recent cases to be utilised later');
%     PatientSplitTimer=tic;
%     RecentPatientID=[];
%     [~, NumberInPatientCurrently]=size(Patient);
%     for i=1:NumberInPatientCurrently
%         if Patient(i).RecentInfection==1
%             RecentPatientID=[RecentPatientID i];
%         end
%     end
%     RecentPatient=Patient(RecentPatientID);
%     Patient(RecentPatientID)=[];
%     toc(PatientSplitTimer)
%     
%     %Determine the proportion of people in each year with evidence of recent infection
%     NotRecentDiagnosisDates=zeros(size(Patient));
%     PCount=0;
%     for P=Patient
%         PCount=PCount+1;
%         NotRecentDiagnosisDates(PCount)=P.DateOfDiagnosisContinuous;%Note that in this system all records without recent diagnosis data have an entris of year zero. This means that you can fileter it out when trying to determine the total number recently infected below.
%     end
%     
%     RecentDiagnosisDates=zeros(size(RecentPatient));
%     PCount=0;
%     for RP=RecentPatient
%         PCount=PCount+1;
%         RecentDiagnosisDates(PCount)=RP.DateOfDiagnosisContinuous;
%     end
%     
%  end



%% Determine the time between infection and diagnosis
disp('Determining the time between infection and diagnosis');
TicOptimisation=tic;


disp( 'Starting parallel Matlab...');
matlabpool('open', str2num(getenv( 'NUMBER_OF_PROCESSORS' ))-1);%this may not work in all processors

[Px]=LoadBackProjectionParameters(NoParameterisations);
Px.ConsiderRecentInfection=ConsiderRecentInfection;

% Sort individuals by year of diagnosis
BackProjectStartSingleYearAnalysis=1984;

[~, NumberInPatientCurrently]=size(Patient);
YearIndex=0;

rand_time = [];                     %%Only for testing purposes - Azfar

for Year=BackProjectStartSingleYearAnalysis:YearOfDiagnosedDataEnd-1
    YearIndex=YearIndex+1;
    test = tic                     %%Only for testing purposes - Azfar
    disp(Year)
    % For indivudals diagnosed prior to 1985, process as a group (as we have insufficient data on these individuals anyway)
    if Year==BackProjectStartSingleYearAnalysis
        MinYear=0;%
        MaxYear=Year+1;
    else
        MinYear=Year;
        MaxYear=Year+1;
    end
    
    %This section is no longer used in the current methodology
%     if Px.ConsiderRecentInfection
%         RecentDataTotal=sum(MinYear<=RecentDiagnosisDates & RecentDiagnosisDates<MaxYear);
%         NoRecentDataTotal=sum(MinYear<=NotRecentDiagnosisDates & NotRecentDiagnosisDates<MaxYear);
%         Px.PropWithRecentDiagDataPresentThisYear=RecentDataTotal/(RecentDataTotal+NoRecentDataTotal);
%     end
    
    CD4ForOptimisation=-1*ones(1, NumberInPatientCurrently);%to indicate empty fields
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
    Px.CurrentYear=Year;
    [Times, StartingCD4, TestingParameter]=CreateIndividualTimeUntilDiag(CD4ForOptimisation, Px, RandomNumberStream);
    
    OptimisationResults(YearIndex).Year=Year;
    OptimisationResults(YearIndex).TestingParameter=TestingParameter;
    
    %Place values back into the vector
    CountRef=0;
    for ref=PatientRef
        CountRef=CountRef+1;
        Patient(ref).TimeFromInfectionToDiagnosis=Times(CountRef, :);
    end
    
    CD4Comparison(YearIndex).RealTestingCD4=CD4ForOptimisation;
    CD4ComparisonLookup(YearIndex)=Year;
    %Store the appropriate probabilities
    rand_time(YearIndex) = toc(test);                     %%Only for testing purposes - Azfar
end
matlabpool close;
TimeSpentOptimising=toc(TicOptimisation);
toc(TicOptimisation)







    
    
% %% If consideration is given to recent infection data, recombine the non-Recent patients back into the patient variable
% if ConsiderRecentInfection==true
%     % assign infection distributions of those who are known to have been infected in the last 12 months
% 
%     %[~, NumberOfRecentInfections]=size(RecentPatient);
% 
%     for i=1:NumberInPatientCurrently
%         
%         if Patient(i).RecentInfection==1
%             Patient(i).TimeFromInfectionToDiagnosis= rand(1,NoParameterisations);
%             %Alternate distribution: People have testing rates of between once every 3 months and 1 year = (1-rand(1, NoParameterisations)*0.75).*rand(1, NoParameterisations)
%         end
%     end
% 
%     %recombine the recent and non-recent infections
%     %Patient=[Patient RecentPatient];
% end







%% Create dates for the infection based on time between infection and testing, together with testing date
[~, NumberOfPatients]=size(Patient);
for i=1:NumberOfPatients
    Patient(i)=Patient(i).DetermineInfectionDateDistribution();
end
    

%% If consideration is given to recent infection data, select data according to avaialable information
% There are three items to consider when dealing with a




if ConsiderRecentInfection==true
    for SimCount=1:NoParameterisations
        for i=1:NumberInPatientCurrently
            % A clear western blot in close proximity to diagnosis indicates most likely a recent infection
            % Serconversion illness indicates a likely recent infection
            LatestFirstDateEstFromIllness=NaN;
            LatestFirstDateEstFromWesternBlot=NaN;
            % if the time of illness is more than 40 days after diagnosis,
            % it's likely not to be serconversion illness so we ignore
            if (Patient(i).DateIll-Patient(i).DateOfDiagnosisContinuous)<40/365 % if NaN, do nothing
                LatestFirstDateEstFromIllness=Patient(i).DateIll-40/365;
            end
            % if it is more than 40 days after diagnosis, there's probably an issue, so we ignore the western blot result
            if (Patient(i).DateIndetWesternBlot-Patient(i).DateOfDiagnosisContinuous)<40/365 % if NaN, do nothing
                LatestFirstDateEstFromWesternBlot=Patient(i).DateIndetWesternBlot-40/365;
            end
            
            
            if Patient(i).InfectionDateDistribution(SimCount)<Patient(i).DateLastNegative && Patient(i).DateLastNegative<Patient(i).DateOfDiagnosisContinuous % if NaN, do nothing
                LatestFirstDateEstFromLastNegative=Patient(i).DateLastNegative;
            else
                LatestFirstDateEstFromLastNegative=NaN;
            end
            
            % Find the most recent of the above. Randomly chose between
            % LatestFirstDate and the date of diagnosis
            LatestFirstDate=max([LatestFirstDateEstFromWesternBlot, LatestFirstDateEstFromIllness, LatestFirstDateEstFromLastNegative]);
            if ~isnan(LatestFirstDate)
                Patient(i).InfectionDateDistribution(SimCount)=LatestFirstDate+rand*(Patient(i).DateOfDiagnosisContinuous-LatestFirstDate);
                % re-establish the time between infection and diagnosis for the individual
                Patient(i).TimeFromInfectionToDiagnosis=Patient(i).DateOfDiagnosisContinuous-Patient(i).InfectionDateDistribution;
            end
            %else do nothing
        end
    end
end











%% This section is where all of the information is collected up to make a population wide calculation of the incidence
% clear DistributionUndiagnosedInfectionsPrecise;
% clear DistributionDiagnosedInfectionsPrecise;
% clear DistributionDiagnosedInfections;
% clear DistributionUndiagnosedInfections;
% 
% 
% %Create a summing vector that contains the infection dates for the
% %diagnoses (regardless of the date of diagnosis)
% 
% tic
% DateMatrix=zeros(NoParameterisations, NumberOfPatients);
% InfectionTimeMatrix=zeros(NoParameterisations, NumberOfPatients);
% MSMCaseIndicator=zeros(1, NumberOfPatients);
% 
% 
% 
% NoPatientInRange=0;
% TimeDistributionOfRecentDiagnoses=[];
% CD4DistributionOfRecentDiagnoses=[];
% for i=1:NumberOfPatients
% 
%         TimeDistributionOfRecentDiagnoses((i-1)*NoParameterisations+1:i*NoParameterisations)=Patient(i).TimeFromInfectionToDiagnosis;
%         CD4DistributionOfRecentDiagnoses((i-1)*NoParameterisations+1:i*NoParameterisations)=Patient(i).CD4CountAtDiagnosis;
%         DateMatrix(:, i)=Patient(i).InfectionDateDistribution;
%         if Patient(i).DateOfDiagnosisContinuous>= RangeOfCD4Averages(1) && Patient(i).DateOfDiagnosisContinuous< RangeOfCD4Averages(2)
%             NoPatientInRange=NoPatientInRange+1;
%             InfectionTimeMatrix(:, NoPatientInRange)=Patient(i).TimeFromInfectionToDiagnosis;
%             if (Patient(i).ExposureRoute<=4)% exposure coding of 1,2,3,4 are MSM of some variety
%                 MSMCaseIndicator(NoPatientInRange)=1;
%             else
%                 MSMCaseIndicator(NoPatientInRange)=0;
%             end
%         end
%         
% end
% %remove all those elements that are not used
% InfectionTimeMatrix(:, NoPatientInRange+1:NumberOfPatients)=[];
% MSMCaseIndicator( NoPatientInRange+1:NumberOfPatients)=[];
% timevalue=toc;
% 
% % find proportion that are MSM, proportion that are not MSM
% % cout to allow a pre allocation
% MSMCount=0;
% NonMSMCount=0;
% for i=1:NumberOfPatients
%     if (Patient(i).ExposureRoute<=4)% exposure coding of 1,2,3,4 are MSM of some variety
%         MSMCount=MSMCount+1;
%     else
%         NonMSMCount=NonMSMCount+1;
%     end
% end
% MSMDateMatrix=zeros(NoParameterisations, MSMCount);
% NonMSMDateMatrix=zeros(NoParameterisations, NonMSMCount);
% MSMCD4=zeros(1, MSMCount);
% NonMSMCD4=zeros(1, NonMSMCount);
% MSMDate=zeros(1, MSMCount);
% NonMSMDate=zeros(1, NonMSMCount);
% MSMInfectionTimeMatrix=zeros(NoParameterisations, MSMCount);
% NonMSMInfectionTimeMatrix=zeros(NoParameterisations, NonMSMCount);
% 
% MSMCount=0;
% NonMSMCount=0;
% for i=1:NumberOfPatients
%     if (Patient(i).ExposureRoute<=4)% exposure coding of 1,2,3,4 are MSM of some variety
%         MSMCount=MSMCount+1;
%         MSMDateMatrix(:, MSMCount)=Patient(i).InfectionDateDistribution;
%         MSMDate(MSMCount)=Patient(i).DateOfDiagnosisContinuous;
%         MSMCD4(MSMCount)=Patient(i).CD4CountAtDiagnosis;
%         MSMInfectionTimeMatrix(:,MSMCount)=Patient(i).TimeFromInfectionToDiagnosis;
%     else
%         NonMSMCount=NonMSMCount+1;
%         NonMSMDateMatrix(:, NonMSMCount)=Patient(i).InfectionDateDistribution;
%         NonMSMDate(NonMSMCount)=Patient(i).DateOfDiagnosisContinuous;
%         NonMSMCD4(NonMSMCount)=Patient(i).CD4CountAtDiagnosis;
%         NonMSMInfectionTimeMatrix(:,NonMSMCount)=Patient(i).TimeFromInfectionToDiagnosis;
%     end
% end
% %plot(MSMDistributionForThisSimulationDiagnosedInfections')
% %plot(NonMSMDistributionForThisSimulationDiagnosedInfections')
% 
% 
% HistYearSlots=(CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize));
% 
% for SimNumber=1:NoParameterisations
%     disp(['Finding undiagnosed ' num2str(SimNumber) ' of ' num2str(NoParameterisations)]);
%     
%     ExpectedTimesVector=InfectionTimeMatrix(SimNumber, :);%(for this Sim)
%     InfectionsByYearDiagnosed=hist(DateMatrix(SimNumber, :), HistYearSlots+0.5*StepSize);% 0.5*StepSize used to centralise the bar plots in the the hist function
%     MSMInfectionsByYearDiagnosed=hist(MSMDateMatrix(SimNumber, :), HistYearSlots+0.5*StepSize);% 0.5*StepSize used to centralise the bar plots in the the hist function
%     [~, TotalInTimeVector]=size(ExpectedTimesVector);
%     
%         %ProportionOfExpectedTimesVectorExpectedPerStep=StepSize/(RangeOfCD4Averages(2)-RangeOfCD4Averages(1));
%         %TotalInStepResample=round(TotalInTimeVector*ProportionOfExpectedTimesVectorExpectedPerStep);%this parameter is not acually used in any meaningful way in this code
%         
%         % Find an estimate for the number of infections which are undiagnosed
%         [~, LastPositionInArray]=size(HistYearSlots);
%         YearIndex=0;
%         for YearStep=HistYearSlots
%             YearIndex=YearIndex+1;
%             n=LastPositionInArray-YearIndex+1;
%             if n>MaxYears/StepSize %i.e if year step is greater than 20 years
%                 TotalUndiagnosedInfections(YearIndex)=0;
%                 MSMTotalUndiagnosedInfections(YearIndex)=0;
%             else
%                 %if TotalInStepResample<0
%                 %    DistributionForThisSimulationUndiagnosedInfectionsPrecise(YearIndex)=0;
%                 %else
%                     AdjustmentFactor=2*n/(2*n-1);
%                     %Adjust for the fact that we are cutting across triangle in determining the future cases i.e.:
%                     %|\
%                     %|\|\
%                     %|\|\|\
%                     %2.5, 1.5, 0.5
%                     TotalDiagnosedInBackprojectionEstimate=round(InfectionsByYearDiagnosed(YearIndex)*AdjustmentFactor);
%                     replacement=true;
%                     %create a really big vector to sample from. This should be about 50 times bigger than what's needed.
%                     SampleIndex=randsample(TotalInTimeVector, TotalInTimeVector, replacement);
%                     %RandomisedExpectedTimesVector=randsample(ExpectedTimesVector, TotalInTimeVector, replacement);
%                     RandomisedExpectedTimesVector=ExpectedTimesVector(SampleIndex);
%                     MSMSampleVector=MSMCaseIndicator(SampleIndex);
%                     
%                     
%                     NumberFoundDiagnosed=0;
%                     NumberOfUnidagnosedInfectionsThisStep=0;
%                     CountSamples=0;
%                     MSMIncludedInforwardProjection=0;
%                     
%                     LowerBoundFound=false;
%                     UpperBoundFound=false;
%                     while (UpperBoundFound==false)%NumberFoundDiagnosed<TotalDiagnosedInBackprojectionEstimate+1
% 
%                         CountSamples=CountSamples+1;
%                         
%                         NewTimeToAdd=RandomisedExpectedTimesVector(CountSamples);
%                         TimeToFind=(CD4BackProjectionYearsWhole(2)+1-YearStep);
%                         % Determine if the infection would have occure in this time step
%                         if NewTimeToAdd<TimeToFind
%                             NumberFoundDiagnosed=NumberFoundDiagnosed+1;
%                         else
%                             NumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep+1;
%                             MSMIncludedInforwardProjection=MSMIncludedInforwardProjection+MSMSampleVector(CountSamples);
%                         end
%                         % Determine 
%                         if (NumberFoundDiagnosed==TotalDiagnosedInBackprojectionEstimate && LowerBoundFound==false)
%                             LowerBoundFound=true;
%                             LowerBoundNumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep;
%                             LowerBoundOfUndiagnosedMSM=MSMIncludedInforwardProjection;
%                         end
%                         if (NumberFoundDiagnosed==TotalDiagnosedInBackprojectionEstimate+1)
%                             UpperBoundFound=true;
%                             UpperBoundNumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep;
%                             UpperBoundOfUndiagnosedMSM=MSMIncludedInforwardProjection;
%                         end
%                     end
%                     DiffInUndiagnosedEstimate=UpperBoundNumberOfUnidagnosedInfectionsThisStep-LowerBoundNumberOfUnidagnosedInfectionsThisStep;
%                     UndiagnosedEstimateInThisStep=round(LowerBoundNumberOfUnidagnosedInfectionsThisStep+rand*DiffInUndiagnosedEstimate);
%                     TotalUndiagnosedInfections(YearIndex)=UndiagnosedEstimateInThisStep;
%                     if (DiffInUndiagnosedEstimate==0)%to avoid divide by zero error
%                         MSMTotalUndiagnosedInfections(YearIndex)=LowerBoundNumberOfUnidagnosedInfectionsThisStep;
%                     else
%                         ProportionInUncertainZoneThatAreMSM=(UpperBoundOfUndiagnosedMSM-LowerBoundOfUndiagnosedMSM)/DiffInUndiagnosedEstimate;
%                         UncertainZoneMSM=round((UpperBoundOfUndiagnosedMSM-LowerBoundOfUndiagnosedMSM)*ProportionInUncertainZoneThatAreMSM*rand);
%                         MSMTotalUndiagnosedInfections(YearIndex)=LowerBoundNumberOfUnidagnosedInfectionsThisStep+UncertainZoneMSM;
%                     end
%                 %end
%             end
%         end
% 
%     %Create a matrix of all simulations
%     DistributionUndiagnosedInfectionsPrecise(SimNumber, :)=TotalUndiagnosedInfections;
%     MSMDistributionUndiagnosedInfectionsPrecise(SimNumber, :)=MSMTotalUndiagnosedInfections;
%     DistributionDiagnosedInfectionsPrecise(SimNumber, :)=InfectionsByYearDiagnosed;
%     MSMDistributionDiagnosedInfectionsPrecise(SimNumber, :)=MSMInfectionsByYearDiagnosed;
%     
%     %Sum up the results for the undiagnosed infections into year blocks
%     YearIndex=0;
%     StepIndex=0;
%     DistributionForThisSimulationUndiagnosedInfections=zeros(1, (CD4BackProjectionYearsWhole(2)-CD4BackProjectionYearsWhole(1)+1));
%     MSMDistributionForThisSimulationUndiagnosedInfections=zeros(1, (CD4BackProjectionYearsWhole(2)-CD4BackProjectionYearsWhole(1)+1));
%     for Year=CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2)
%         YearIndex=YearIndex+1;
%         for TenSteps=1:10
%             StepIndex=StepIndex+1;
%             DistributionForThisSimulationUndiagnosedInfections(YearIndex)=DistributionForThisSimulationUndiagnosedInfections(YearIndex)+TotalUndiagnosedInfections(StepIndex);
%             MSMDistributionForThisSimulationUndiagnosedInfections(YearIndex)=MSMDistributionForThisSimulationUndiagnosedInfections(YearIndex)+MSMTotalUndiagnosedInfections(StepIndex);
%         end        
%     end
%     
%     %State the histogram year centres
%     YearCentres=(CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2))+0.5;
%     %Find the infections that have already been diagnosed
% 
% 
%     
%     DistributionDiagnosedInfections(SimNumber, :)=hist(DateMatrix(SimNumber, :), YearCentres);
%     DistributionUndiagnosedInfections(SimNumber, :)=DistributionForThisSimulationUndiagnosedInfections;
%     MSMDistributionUndiagnosedInfections(SimNumber, :)=MSMDistributionForThisSimulationUndiagnosedInfections;
%     
%     MSMDistributionDiagnosedInfections(SimNumber, :)=hist(MSMDateMatrix(SimNumber, :), YearCentres);
%     NonMSMDistributionDiagnosedInfections(SimNumber, :)=hist(NonMSMDateMatrix(SimNumber, :), YearCentres);
%     
%     PropMSMDistributionDiagnosedInfections(SimNumber, :)=MSMDistributionDiagnosedInfections(SimNumber, :)./DistributionDiagnosedInfections(SimNumber, :);
% end

%% Identifying MSM
% Find all MSM
MSMCaseIndicator=false(1, NumberOfPatients);
for i=1:NumberOfPatients
    if (Patient(i).ExposureRoute<=4)% exposure coding of 1,2,3,4 are MSM of some variety
        MSMCaseIndicator(i)=true;
    else
        MSMCaseIndicator(i)=false;
    end
end


%% Forward simulate 
ForwardSimulate

%% Create a diagnosis plot
[FineDiagnoses]=DiagnosesByTime(Patient, CD4BackProjectionYearsWhole(1), StepSize, CD4BackProjectionYearsWhole(2)+1-StepSize);


[DiagnosesByYear]=DiagnosesByTime(Patient, CD4BackProjectionYearsWhole(1), 1, CD4BackProjectionYearsWhole(2));

[MSMDiagnosesByYear]=DiagnosesByTime(Patient(MSMCaseIndicator), CD4BackProjectionYearsWhole(1), 1, CD4BackProjectionYearsWhole(2));

[NonMSMDiagnosesByYear]=DiagnosesByTime(Patient(~MSMCaseIndicator), CD4BackProjectionYearsWhole(1), 1, CD4BackProjectionYearsWhole(2));



[MSMFineDiagnoses]=DiagnosesByTime(Patient(MSMCaseIndicator), CD4BackProjectionYearsWhole(1), StepSize, CD4BackProjectionYearsWhole(2)+1-StepSize);

%% Find total undiagnosed at all points in time
% HistYearSlots=(CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize));
% [~, NumberOfYearSlots]=size(HistYearSlots);
% UndiagnosedMatrix=zeros(NoParameterisations, NumberOfYearSlots );
% for i=1:NumberOfPatients
%     if mod(i, 100)==0
%         disp(['Finding when patient ' num2str(i) ' is undiagnosed']);
%     end
%     if Patient(i).PreviouslyDiagnosedOverseas==0%exclude those who were diagnosed overseas
%         YearSlotCount=0;
%         for YearStep=HistYearSlots
%             YearSlotCount=YearSlotCount+1;
%             UndiagnosedAddtionVector=Patient(i).InfectionDateDistribution<YearStep & YearStep<Patient(i).DateOfDiagnosisContinuous ;
%             %Add this value to the matrix across the no. simulations dimension
%             UndiagnosedMatrix(:, YearSlotCount)=UndiagnosedMatrix(:, YearSlotCount)+UndiagnosedAddtionVector';
%         end
%     end
% end

[UndiagnosedPatient]=UndiagnosedByTime(Patient, CD4BackProjectionYearsWhole(1), StepSize, (CD4BackProjectionYearsWhole(2)+1-StepSize));
[MSMUndiagnosedPatient]=UndiagnosedByTime(Patient(MSMCaseIndicator), CD4BackProjectionYearsWhole(1), StepSize, (CD4BackProjectionYearsWhole(2)+1-StepSize));




%Add the undiagnosed with time (who have been diagnosed) to the people we know will be diagnosed in the future
TotalUndiagnosedByTime.Time=UndiagnosedPatient.Time ;
TotalUndiagnosedByTime.N=UndiagnosedSummed+UndiagnosedPatient.N ;
MSMTotalUndiagnosedByTime.Time=MSMUndiagnosedPatient.Time ;
MSMTotalUndiagnosedByTime.N=MSMUndiagnosedSummed+MSMUndiagnosedPatient.N ;

NonMSMTotalUndiagnosedByTime.Time=TotalUndiagnosedByTime.Time;
NonMSMTotalUndiagnosedByTime.N=TotalUndiagnosedByTime.N-MSMTotalUndiagnosedByTime.N ;




[NumSims, NumStepsInYearDimension]=size(TotalUndiagnosedByTime.N);
for SimCout=1:NumSims
    EffectiveTestingRate(SimCout, :)=FineDiagnoses.N./TotalUndiagnosedByTime.N(SimCout, :);
    MSMEffectiveTestingRate(SimCout, :)=MSMFineDiagnoses.N./MSMTotalUndiagnosedByTime.N(SimCout, :);
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

YearCount=0;
StepsToAverageOver=round(1/StepSize);
MSMYearlyEffectiveTestingRate=[];
for YearStepCount=1:10:NumStepsInYearDimension
    YearCount=YearCount+1;
    MSMYearlyEffectiveTestingRate(:, YearCount)=mean(MSMEffectiveTestingRate(:, YearStepCount:YearStepCount+StepsToAverageOver-1), 2);
    RaisedPower=round(1/StepSize);
    MSMYearlyEffectiveTestingRate(:, YearCount)=1-(1-MSMYearlyEffectiveTestingRate(:, YearCount)).^RaisedPower;%Do a probability transform (0.1 to 1 years)
end




%% Determine the time until infection for the population with time
[~, NumberOfPatients]=size(Patient);
%Set all year times to zero 
YearIndex=0;
TimeSinceInfection=[];
TimeSinceInfectionYearIndex=CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2);
for Year=TimeSinceInfectionYearIndex
    YearIndex=YearIndex+1;
    TimeSinceInfection(YearIndex).v=-ones(1, NumberOfPatients*NumSims);
end
%For all of the years
for i=1:NumberOfPatients
    YearIndex=0;
    for Year=CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2)
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
%CreateFigure1
CreateFigure2;
CreateFigure3;
CreateFigure4(TotalUndiagnosedByTime, PlotSettings.YearsToPlot, 'Figure 4 TotalUndiagnosedByTime');
CreateFigure4(MSMTotalUndiagnosedByTime, PlotSettings.YearsToPlot, 'Figure 4 MSMTotalUndiagnosedByTime');
CreateFigure4(NonMSMTotalUndiagnosedByTime, PlotSettings.YearsToPlot, 'Figure 4 NonMSMTotalUndiagnosedByTime');
h_legend=legend( {'Median', '95% uncertainty bound'},  'Location','SouthEast');
legend('boxoff');
print('-dpng ','-r300',['ResultsPlots/Figure 4 NonMSMTotalUndiagnosedByTime.png']) 

PropMSMUndiagnosed=MSMTotalUndiagnosedByTime;
PropMSMUndiagnosed.N=MSMTotalUndiagnosedByTime.N./TotalUndiagnosedByTime.N;
PropMSMUndiagnosed.Median=median(PropMSMUndiagnosed.N, 1);
PropMSMUndiagnosed.UCI=prctile(PropMSMUndiagnosed.N, 97.5, 1);
PropMSMUndiagnosed.LCI=prctile(PropMSMUndiagnosed.N, 2.5, 1);
CreateFigure4(PropMSMUndiagnosed, PlotSettings.YearsToPlot, 'Appendix PropMSMTotalUndiagnosedByTime')



PropMSM=DiagnosesByYear;
PropMSM.Value=MSMDiagnosesByYear.N./DiagnosesByYear.N;
plot(PropMSM.Time, PropMSM.Value);
mean(RecentMSMCaseIndicator)% a mean of the MSM appearance in the last 5 years of diagnoses

% inspecting the proportion of people undiagnosed
hold on;
plot(PropMSMUndiagnosed.Time, PropMSMUndiagnosed.Median);
plot(PropMSMUndiagnosed.Time, median(MSMUndiagnosedSummed./UndiagnosedSummed, 1));
hold off;
%comes out to a flat 70% which is not expected

% Ok at 
% RandomisedExpectedTimesVector
% MSMSampleVector

% Definitely something wrong by
% UndiagnosedCaseData
% UndiagnosedSummed

plot(median(MSMDistributionUndiagnosedInfections./DistributionUndiagnosedInfections, 1));






RandomisedExpectedTimesVector=ExpectedTimesVector(SampleIndex);
MSMSampleVector=RecentMSMCaseIndicator(SampleIndex);
DistComparisonYear=0.5:1:20;
MSMSampleDistribution=hist(RandomisedExpectedTimesVector(MSMSampleVector), DistComparisonYear);
NonMSMSampleDistribution=hist(RandomisedExpectedTimesVector(~MSMSampleVector), DistComparisonYear);
NormMSMSampleDistribution=MSMSampleDistribution/sum(MSMSampleDistribution);
NormNonMSMSampleDistribution=NonMSMSampleDistribution/sum(NonMSMSampleDistribution);
plot(DistComparisonYear+0.5, [NormMSMSampleDistribution; NormNonMSMSampleDistribution]);
plot(DistComparisonYear+0.5, MSMSampleDistribution./(MSMSampleDistribution+NonMSMSampleDistribution));
   
tempMSM=false(1, 0);
tempDate=[];
for iSim=1:NoParameterisations
    iSim
    tempDate=[tempDate UndiagnosedCaseData(iSim).InfectionDate];
    tempMSM=[tempMSM UndiagnosedCaseData(iSim).MSM];
end

MSMDateDistribution=hist(tempDate(tempMSM), PropMSM.Time+0.5);
DateDistribution=hist(tempDate, PropMSM.Time+0.5);
plot(PropMSM.Time, [MSMDateDistribution; DateDistribution])
plot(PropMSM.Time, MSMDateDistribution./DateDistribution)

MSMDateDistribution=hist(UndiagnosedCaseData(SimNumber).InfectionDate(UndiagnosedCaseData(SimNumber).MSM), PropMSM.Time+0.5);
DateDistribution=hist(UndiagnosedCaseData(SimNumber).InfectionDate(), PropMSM.Time+0.5);
plot(PropMSM.Time, [MSMDateDistribution; DateDistribution])
plot(PropMSM.Time, MSMDateDistribution./DateDistribution)
            

DistComparisonYear=0.5:1:20;
MSMSampleDistribution=hist(reshape(InfectionTimeMatrix(:, RecentMSMCaseIndicator), 1, []), DistComparisonYear);
NonMSMSampleDistribution=hist(reshape(InfectionTimeMatrix(:, ~RecentMSMCaseIndicator), 1, []), DistComparisonYear);
MSMSampleDistribution=MSMSampleDistribution/sum(MSMSampleDistribution);
NonMSMSampleDistribution=NonMSMSampleDistribution/sum(NonMSMSampleDistribution);
plot(DistComparisonYear+0.5, [MSMSampleDistribution; NonMSMSampleDistribution])


CreateFigure5
CreateOtherPlots
CreateResultUncertaintyAroundTime
%OutputPlots %old plots output
toc(TimeALL)

YearValueVector=CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize);


%% Sensitivity analysis
SensitivityAnalysis

%% Paper sentences
TotalUndiagnosedByTime.Median=median(TotalUndiagnosedByTime.N, 1);
[MaxMedUndiagnosed, IndexOfMax]= max(TotalUndiagnosedByTime.Median);
YearMaxMedUndiagnosed=TotalUndiagnosedByTime.Time(IndexOfMax);
LCI=prctile(TotalUndiagnosedByTime.N(:, IndexOfMax), 2.5);
UCI=prctile(TotalUndiagnosedByTime.N(:, IndexOfMax), 97.5);
disp(['The model estimates that the number of people living with undiagnosed HIV peaked in ' num2str(YearMaxMedUndiagnosed) ' at ' num2str(MaxMedUndiagnosed) '(' num2str(LCI) '-' num2str(UCI) ') cases.']);

LCI=prctile(TotalUndiagnosedByTime.N(:, end), 2.5);
UCI=prctile(TotalUndiagnosedByTime.N(:, end), 97.5);
disp(['Final year of undiagnosed ' num2str(TotalUndiagnosedByTime.Median(end)) '(' num2str(LCI) '-' num2str(UCI) ') cases.']);


SubsetUndiagnosed.N=TotalUndiagnosedByTime.N(:, IndexOfMax:end);
SubsetUndiagnosed.Median=TotalUndiagnosedByTime.Median(IndexOfMax:end);
SubsetUndiagnosed.Time=TotalUndiagnosedByTime.Time(IndexOfMax:end);
[MinMedUndiagnosed, IndexOfMin]= min(SubsetUndiagnosed.Median);
LCI=prctile(SubsetUndiagnosed.N(:, IndexOfMin), 2.5);
UCI=prctile(SubsetUndiagnosed.N(:, IndexOfMin), 97.5);
YearMinMedUndiagnosed=SubsetUndiagnosed.Time(IndexOfMin);
disp(['Min since max occurred in ' num2str(YearMinMedUndiagnosed) ' with ' num2str(MinMedUndiagnosed) '(' num2str(LCI) '-' num2str(UCI) ') cases.']);










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


% save('PatientSaveFiles/SimulationState.mat');
toc(TimeALL)

% At the end of the simulation, it may be desirable to perform a mortlaity calculation
% To do this, change folder to the MoralityCalculations
% Run CalculateAIDSAndMortality
% Run CollateResultsForOutput
% NOTE: care should be taken to ensure that all individuals (previously
% diagnosed overseas or not) to get the correct figure for proportion of
% people living with HIV 
