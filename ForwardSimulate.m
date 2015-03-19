%% function ForwardSimulate
% the purpose of this function is to simulate the undiagnosed individuals

%% Step 1: Collect sampling data
fprintf(1, '\nForward Projecting Patients Undiagnosed In Simulations\n');
ForwardTimer = tic;

DateMatrix = zeros(Sx.NoParameterisations, NumberOfPatients);

InfectionTimeMatrix = zeros(Sx.NoParameterisations, NumberOfPatients);

NoPatientInRange = 0;

for x = 1:NumberOfPatients
    DateMatrix(:, x) = Patient(x).InfectionDateDistribution;

    if (RangeOfCD4Averages(1) <= Patient(x).DateOfDiagnosisContinuous)  && (Patient(x).DateOfDiagnosisContinuous < RangeOfCD4Averages(2))
        NoPatientInRange = NoPatientInRange + 1;
        InfectionTimeMatrix(:, NoPatientInRange) = Patient(x).TimeFromInfectionToDiagnosis;        
    end
end
%remove all those elements that are not used
InfectionTimeMatrix(:, NoPatientInRange+1:NumberOfPatients) = [];
HistWholeYearVec = (CD4BackProjectionYearsWhole(1):1:CD4BackProjectionYearsWhole(2)) + 0.5;

%% Step 2: determine the number of people in diagnosed in each whole year
YearVector = CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2);
[~, YearSlots] = size(YearVector);
DiagnosedInfectionsByYear = zeros(Sx.NoParameterisations, YearSlots);
for CurrentSim = 1:Sx.NoParameterisations
    YearIndex = 0;
    for Year = YearVector
        YearIndex = YearIndex+1;
        DiagnosedInfectionsByYear(CurrentSim, YearIndex) = sum(Year <= DateMatrix(CurrentSim, :) & DateMatrix(CurrentSim, :)<Year+1);
    end
end

%% Step 3: randomly sample the population that is passed into a structure that preserves the undiagnosed cases
DistributionForThisSimulationUndiagnosedInfections = zeros(1, (CD4BackProjectionYearsWhole(2)-CD4BackProjectionYearsWhole(1)+1));

CutOffYear = CD4BackProjectionYearsWhole(2)+1;

for SimNumber = 1:Sx.NoParameterisations
    fprintf(1, '\nForward Projection Progress: %.2f%%', (100 * SimNumber / Sx.NoParameterisations));
    ExpectedTimesVector = InfectionTimeMatrix(SimNumber, :);                %(for this Sim)
    [~, TotalInTimeVector] = size(ExpectedTimesVector);
    UndiagnosedCaseData(SimNumber).InfectionDate = [];
    UndiagnosedCaseData(SimNumber).ExpectedTimeUntilDiagnosis = [];
    
    YearIndex = 0;
    IncludeInForwardProjection = false(1, NoPatientInRange);
    for Year = YearVector
        YearIndex = YearIndex+1;
        if CutOffYear-Year > Sx.MaxYears                                       %i.e if year step is greater than 20 years
            TotalUndiagnosedInfections(YearIndex) = 0;
            
        else
            TotalDiagnosedInBackprojectionEstimate = DiagnosedInfectionsByYear(CurrentSim, YearIndex);
            %create a really big vector to sample from. This should be about 50 times bigger than what's needed.
            replacement = true;
            SampleIndex = randsample(TotalInTimeVector, 10*TotalInTimeVector, replacement);%under a 5 year aeverage, this gives 50 times the samples per year, which should be sufficient
            
            RandomisedExpectedTimesVector = ExpectedTimesVector(SampleIndex);
            RandomisedInfectionDate = Year + rand(1, 10*TotalInTimeVector);
            
            %Add the simulated cases to a structure to store for later use
            CountSamples = 0;
            NumberFoundDiagnosed = 0;
            NumberOfUnidagnosedInfectionsThisStep = 0;

            LowerBoundFound = false;
            UpperBoundFound = false;
            while (UpperBoundFound == false)%NumberFoundDiagnosed<TotalDiagnosedInBackprojectionEstimate+1
                CountSamples = CountSamples + 1;

                % Determine if the infection represents one that is undiagnosed by the last data
                if RandomisedInfectionDate(CountSamples) + RandomisedExpectedTimesVector(CountSamples) < CutOffYear
                    NumberFoundDiagnosed = NumberFoundDiagnosed+1;
                else % if the simulated individual has not been diagnosed by the cut off date
                    IncludeInForwardProjection(CountSamples) = true; 
                    
                    %%%%%%%%%%%%%%%Add index of person selected
                    %%%%%%%%%%%%%%%CopyPeopleArray[count]=SampleIndex%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    NumberOfUnidagnosedInfectionsThisStep = NumberOfUnidagnosedInfectionsThisStep+1;
                end
                
                % Determine whether the simulation has reached the expected number of people
                if (NumberFoundDiagnosed == TotalDiagnosedInBackprojectionEstimate && LowerBoundFound == false)
                    LowerBoundFound = true;
                    LowerBoundNumberOfUnidagnosedInfectionsThisStep = NumberOfUnidagnosedInfectionsThisStep;
                end
                if (NumberFoundDiagnosed == TotalDiagnosedInBackprojectionEstimate + 1)
                    UpperBoundFound = true;
                    UpperBoundNumberOfUnidagnosedInfectionsThisStep = NumberOfUnidagnosedInfectionsThisStep;
                end
            end
            
            %work out the difference in the upper and lower estimate, find
            %a random value between the two, and select up to those many
            %individuals
            DiffInUndiagnosedEstimate = UpperBoundNumberOfUnidagnosedInfectionsThisStep - LowerBoundNumberOfUnidagnosedInfectionsThisStep;
            
            %%%%%%%%%%%%%%%%%%azfar: this is the total%%%%%%%%%%%%%
            UndiagnosedEstimateInThisStep = round(LowerBoundNumberOfUnidagnosedInfectionsThisStep + rand*DiffInUndiagnosedEstimate);
            
            %%%%%%%%%%%%%%Take the first UndiagnosedEstimateInThisStep
            %%%%%%%%%%%%%%indicies in CopyPeopleArray%%%%%%%%%%%%%
            
            %%%%%%%%%%%%Find out the date of diagnosis\
            %%%%%%%%%%%%%adjust date of birth - age of date of birth should be the
            %same%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            % Clear out IncludeInForwardProjection greater than UndiagnosedEstimateInThisStep
            NumericalIncludeInForwardProjection = 1:(10*TotalInTimeVector);
            NumericalIncludeInForwardProjection = NumericalIncludeInForwardProjection(IncludeInForwardProjection);
            if sum(IncludeInForwardProjection) > UndiagnosedEstimateInThisStep
                NumericalIncludeInForwardProjection(UndiagnosedEstimateInThisStep+1:end) = [];  %delete excess contents
            end       
            
            DistributionUndiagnosedInfections(SimNumber, YearIndex) = UndiagnosedEstimateInThisStep;
            UndiagnosedCaseData(SimNumber).InfectionDate = [UndiagnosedCaseData(SimNumber).InfectionDate RandomisedInfectionDate(NumericalIncludeInForwardProjection)];%NumericalIncludeInForwardProjection
            UndiagnosedCaseData(SimNumber).ExpectedTimeUntilDiagnosis = [UndiagnosedCaseData(SimNumber).ExpectedTimeUntilDiagnosis RandomisedExpectedTimesVector(NumericalIncludeInForwardProjection)];
        end
    end
    
    DistributionDiagnosedInfections(SimNumber, :) = hist(DateMatrix(SimNumber, :), YearVector+0.5);    
end    
    
TotalInfectionsPerYear = DistributionDiagnosedInfections + DistributionUndiagnosedInfections;

HistYearSlots = (CD4BackProjectionYearsWhole(1):Sx.StepSize:(CD4BackProjectionYearsWhole(2)+1-Sx.StepSize))+0.5*Sx.StepSize;
for SimNumber = 1:Sx.NoParameterisations
    DistributionUndiagnosedInfectionsPrecise(SimNumber, :) = hist(UndiagnosedCaseData(SimNumber).InfectionDate, HistYearSlots);
    DistributionDiagnosedInfectionsPrecise(SimNumber, :) = hist(DateMatrix(SimNumber,:), HistYearSlots);
end

%Find the number of people undiagnosed by end of 2013 in each year
% Note that all the diagnoses in the DistributionUndiagnosedInfectionsPrecise are undiagnosed.  
UndiagnosedSummed = [];
IndexCount = 0;
for TempYear = HistYearSlots
    IndexCount = IndexCount+1;
    % Find sum of all currently undiagnosed
    if IndexCount == 1
        UndiagnosedSummed(:, IndexCount) = DistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    else
        UndiagnosedSummed(:, IndexCount) = UndiagnosedSummed(:, IndexCount-1) + DistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    end
end

DiagnosisDateVec = zeros(1, NumberOfPatients);
for x = 1:NumberOfPatients
    DiagnosisDateVec(x) = Patient(x).DateOfDiagnosisContinuous;
end

DiagnosisDistributionPrecise = hist(DiagnosisDateVec, HistYearSlots);

fprintf(1, '\n\n-Time to Forward Project All Simulations-\n');
toc(ForwardTimer)
disp('------------------------------------------------------------------');

