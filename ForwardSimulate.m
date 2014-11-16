%function ForwardSimulate

% the purpose of this function is to simulate the undiagnosed individuals

%% Step 1: Collect sampling data
DateMatrix=zeros(NoParameterisations, NumberOfPatients);
InfectionTimeMatrix=zeros(NoParameterisations, NumberOfPatients);
MSMCaseIndicator=zeros(1, NumberOfPatients);

NoPatientInRange=0;
%TimeDistributionOfRecentDiagnoses=[];
%CD4DistributionOfRecentDiagnoses=[];
for i=1:NumberOfPatients

    %TimeDistributionOfRecentDiagnoses((i-1)*NoParameterisations+1:i*NoParameterisations)=Patient(i).TimeFromInfectionToDiagnosis;
    %CD4DistributionOfRecentDiagnoses((i-1)*NoParameterisations+1:i*NoParameterisations)=Patient(i).CD4CountAtDiagnosis;
    DateMatrix(:, i)=Patient(i).InfectionDateDistribution;
    if Patient(i).DateOfDiagnosisContinuous>= RangeOfCD4Averages(1) && Patient(i).DateOfDiagnosisContinuous< RangeOfCD4Averages(2)
        NoPatientInRange=NoPatientInRange+1;
        InfectionTimeMatrix(:, NoPatientInRange)=Patient(i).TimeFromInfectionToDiagnosis;
        if (Patient(i).ExposureRoute<=4)% exposure coding of 1,2,3,4 are MSM of some variety
            MSMCaseIndicator(NoPatientInRange)=1;
        else
            MSMCaseIndicator(NoPatientInRange)=0;
        end
    end
end
%remove all those elements that are not used
InfectionTimeMatrix(:, NoPatientInRange+1:NumberOfPatients)=[];
MSMCaseIndicator( NoPatientInRange+1:NumberOfPatients)=[];

HistWholeYearVec=(CD4BackProjectionYearsWhole(1):1:CD4BackProjectionYearsWhole(2))+0.5;

%% Step 2: determine the number of people in diagnosed in each whole year
YearVector=CD4BackProjectionYearsWhole(1):CD4BackProjectionYearsWhole(2);
[~, YearSlots]=size(YearVector);
DiagnosesByYear=zeros(NoParameterisations, YearSlots);
for CurrentSim=1:NoParameterisations
    YearIndex=0;
    for Year=YearVector
        YearIndex=YearIndex+1;
        DiagnosesByYear(CurrentSim, YearIndex)=sum(Year>=DateMatrix(CurrentSim, :) & DateMatrix(CurrentSim, :)<Year+1);
    end
end

%% Step 3: randomly sample the population that is passed into a structure that preserves the undiagnosed cases
CutOffYear=CD4BackProjectionYearsWhole(2)+1;

IncludeInForwardProjection=false(1, NoPatientInRange);
for SimNumber=1:NoParameterisations
    disp(['Finding undiagnosed ' num2str(SimNumber) ' of ' num2str(NoParameterisations)]);
    ExpectedTimesVector=InfectionTimeMatrix(SimNumber, :);%(for this Sim)
    
    YearIndex=0;
    for Year=YearVector
        YearIndex=YearIndex+1;
        if CutOffYear-Year>MaxYears %i.e if year step is greater than 20 years
            TotalUndiagnosedInfections(YearIndex)=0;
            MSMTotalUndiagnosedInfections(YearIndex)=0;
        else
            
            
            %create a really big vector to sample from. This should be about 50 times bigger than what's needed.
            replacement=true;
            SampleIndex=randsample(10*TotalInTimeVector, TotalInTimeVector, replacement);
            
            RandomisedExpectedTimesVector=ExpectedTimesVector(SampleIndex);
            MSMSampleVector=MSMCaseIndicator(SampleIndex);
            RandomisedInfectionDate=Year+rand(1, 10*TotalInTimeVector);
            
            %Add the simulated cases to a structure to store for later use
            CountSamples=0;
            NumberFoundDiagnosed=0;
            NumberOfUnidagnosedInfectionsThisStep=0;
            MSMIncludedInforwardProjection=0;

            LowerBoundFound=false;
            UpperBoundFound=false;
            while (UpperBoundFound==false)%NumberFoundDiagnosed<TotalDiagnosedInBackprojectionEstimate+1
                CountSamples=CountSamples+1;

                % Determine if the infection would have occured in this time step
                if RandomisedInfectionDate(CountSamples) + RandomisedExpectedTimesVector(CountSamples)<CutOffYear
                    NumberFoundDiagnosed=NumberFoundDiagnosed+1;
                else % if the simulated individual has not been diagnosed by the cut off date
                    IncludeInForwardProjection(CountSamples)=true; % note this vector is not a true indicator of whether the person is 
                    NumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep+1;
                    MSMIncludedInforwardProjection=MSMIncludedInforwardProjection+MSMSampleVector(CountSamples);
                end
                
                % Determine whether the simulation has reached the expected number of people
                if (NumberFoundDiagnosed==TotalDiagnosedInBackprojectionEstimate && LowerBoundFound==false)
                    LowerBoundFound=true;
                    LowerBoundNumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep;
                    LowerBoundOfUndiagnosedMSM=MSMIncludedInforwardProjection;
                end
                if (NumberFoundDiagnosed==TotalDiagnosedInBackprojectionEstimate+1)
                    UpperBoundFound=true;
                    UpperBoundNumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep;
                    UpperBoundOfUndiagnosedMSM=MSMIncludedInforwardProjection;
                end
            end
            
            DiffInUndiagnosedEstimate=UpperBoundNumberOfUnidagnosedInfectionsThisStep-LowerBoundNumberOfUnidagnosedInfectionsThisStep;
            UndiagnosedEstimateInThisStep=round(LowerBoundNumberOfUnidagnosedInfectionsThisStep+rand*DiffInUndiagnosedEstimate);
            TotalUndiagnosedInfections(YearIndex)=UndiagnosedEstimateInThisStep;
            
            % Clear out IncludeInForwardProjection greater than UndiagnosedEstimateInThisStep
            NumericalIncludeInForwardProjection=1:(10*TotalInTimeVector);
            NumericalIncludeInForwardProjection=NumericalIncludeInForwardProjection(IncludeInForwardProjection);
            if sum(IncludeInForwardProjection)>UndiagnosedEstimateInThisStep
                NumericalIncludeInForwardProjection(UndiagnosedEstimateInThisStep+1:end)=[];%delete excess contents
            end
            
            MSMTotalUndiagnosedInfections(YearIndex)=sum(MSMSampleVector(NumericalIncludeInForwardProjection));
            
            
            UndiagnosedCaseData(SimNumber, YearIndex).MSM
            UndiagnosedCaseData(SimNumber, YearIndex).InfectionDate
        end
    end
end
%     DateIndeterminantWB
%     EarlietTimeWB=DateIndeterminantWB-40;
% 
%     EarlietTimeLN=LastNegative;
% 
%     EarlietTimeSeroConvIll=DateIll-40;
% 
%     EarliestTime=max(EarlietTimeWB, EarlietTimeLN, EarlietTimeSeroConvIll);
% 
%     ApproxDate
% 
% 
% end