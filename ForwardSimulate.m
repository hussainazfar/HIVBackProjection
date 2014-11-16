%% function ForwardSimulate

% the purpose of this function is to simulate the undiagnosed individuals


%% Step 1: Collect sampling data
DateMatrix=zeros(NoParameterisations, NumberOfPatients);
InfectionTimeMatrix=zeros(NoParameterisations, NumberOfPatients);
MSMCaseIndicator=false(1, NumberOfPatients);

NoPatientInRange=0;
for i=1:NumberOfPatients
    DateMatrix(:, i)=Patient(i).InfectionDateDistribution;
    if Patient(i).DateOfDiagnosisContinuous>= RangeOfCD4Averages(1) && Patient(i).DateOfDiagnosisContinuous< RangeOfCD4Averages(2)
        NoPatientInRange=NoPatientInRange+1;
        InfectionTimeMatrix(:, NoPatientInRange)=Patient(i).TimeFromInfectionToDiagnosis;
        if (Patient(i).ExposureRoute<=4)% exposure coding of 1,2,3,4 are MSM of some variety
            MSMCaseIndicator(NoPatientInRange)=true;
        else
            MSMCaseIndicator(NoPatientInRange)=false;
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
DiagnosedInfectionsByYear=zeros(NoParameterisations, YearSlots);
for CurrentSim=1:NoParameterisations
    YearIndex=0;
    for Year=YearVector
        YearIndex=YearIndex+1;
        DiagnosedInfectionsByYear(CurrentSim, YearIndex)=sum(Year<=DateMatrix(CurrentSim, :) & DateMatrix(CurrentSim, :)<Year+1);
    end
end

%% Step 3: randomly sample the population that is passed into a structure that preserves the undiagnosed cases
DistributionForThisSimulationUndiagnosedInfections=zeros(1, (CD4BackProjectionYearsWhole(2)-CD4BackProjectionYearsWhole(1)+1));
MSMDistributionForThisSimulationUndiagnosedInfections=zeros(1, (CD4BackProjectionYearsWhole(2)-CD4BackProjectionYearsWhole(1)+1));

CutOffYear=CD4BackProjectionYearsWhole(2)+1;

IncludeInForwardProjection=false(1, NoPatientInRange);
for SimNumber=1:NoParameterisations
    disp(['Finding undiagnosed ' num2str(SimNumber) ' of ' num2str(NoParameterisations)]);
    ExpectedTimesVector=InfectionTimeMatrix(SimNumber, :);%(for this Sim)
    UndiagnosedCaseData(SimNumber).MSM=[];
    UndiagnosedCaseData(SimNumber).InfectionDate=[];
            
    YearIndex=0;
    for Year=YearVector
        YearIndex=YearIndex+1;
        if CutOffYear-Year>MaxYears %i.e if year step is greater than 20 years
            TotalUndiagnosedInfections(YearIndex)=0;
            MSMTotalUndiagnosedInfections(YearIndex)=0;
        else
            TotalDiagnosedInBackprojectionEstimate=DiagnosedInfectionsByYear(CurrentSim, YearIndex);
            %create a really big vector to sample from. This should be about 50 times bigger than what's needed.
            replacement=true;
            SampleIndex=randsample(TotalInTimeVector, 10*TotalInTimeVector, replacement);%under a 5 year aeverage, this gives 50 times the samples per year, which should be sufficient
            
            RandomisedExpectedTimesVector=ExpectedTimesVector(SampleIndex);
            MSMSampleVector=MSMCaseIndicator(SampleIndex);
            RandomisedInfectionDate=Year+rand(1, 10*TotalInTimeVector);
            
            %Add the simulated cases to a structure to store for later use
            CountSamples=0;
            NumberFoundDiagnosed=0;
            NumberOfUnidagnosedInfectionsThisStep=0;

            LowerBoundFound=false;
            UpperBoundFound=false;
            while (UpperBoundFound==false)%NumberFoundDiagnosed<TotalDiagnosedInBackprojectionEstimate+1
                CountSamples=CountSamples+1;

                % Determine if the infection would have occured in this time step
                
                if RandomisedInfectionDate(CountSamples) + RandomisedExpectedTimesVector(CountSamples)<CutOffYear %%% THIS LINE COULD BE PROBLEMATIC DUE TO OVER SAMPLING
                    NumberFoundDiagnosed=NumberFoundDiagnosed+1;
                else % if the simulated individual has not been diagnosed by the cut off date
                    IncludeInForwardProjection(CountSamples)=true; % note this vector is not a true indicator of whether the person is 
                    NumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep+1;
                end
                
                % Determine whether the simulation has reached the expected number of people
                if (NumberFoundDiagnosed==TotalDiagnosedInBackprojectionEstimate && LowerBoundFound==false)
                    LowerBoundFound=true;
                    LowerBoundNumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep;
                end
                if (NumberFoundDiagnosed==TotalDiagnosedInBackprojectionEstimate+1)
                    UpperBoundFound=true;
                    UpperBoundNumberOfUnidagnosedInfectionsThisStep=NumberOfUnidagnosedInfectionsThisStep;
                end
            end
            
            DiffInUndiagnosedEstimate=UpperBoundNumberOfUnidagnosedInfectionsThisStep-LowerBoundNumberOfUnidagnosedInfectionsThisStep;
            UndiagnosedEstimateInThisStep=round(LowerBoundNumberOfUnidagnosedInfectionsThisStep+rand*DiffInUndiagnosedEstimate);
            
            % Clear out IncludeInForwardProjection greater than UndiagnosedEstimateInThisStep
            NumericalIncludeInForwardProjection=1:(10*TotalInTimeVector);
            NumericalIncludeInForwardProjection=NumericalIncludeInForwardProjection(IncludeInForwardProjection);
            if sum(IncludeInForwardProjection)>UndiagnosedEstimateInThisStep
                NumericalIncludeInForwardProjection(UndiagnosedEstimateInThisStep+1:end)=[];%delete excess contents
            end
            
            MSMUndiagnosedEstimateInThisStep=sum(MSMSampleVector(NumericalIncludeInForwardProjection));
            
            
            DistributionUndiagnosedInfections(SimNumber, YearIndex)=UndiagnosedEstimateInThisStep;
            MSMDistributionUndiagnosedInfections(SimNumber, YearIndex)=MSMUndiagnosedEstimateInThisStep;

            UndiagnosedCaseData(SimNumber).MSM=[UndiagnosedCaseData(SimNumber).MSM MSMSampleVector(NumericalIncludeInForwardProjection)];
            UndiagnosedCaseData(SimNumber).InfectionDate=[UndiagnosedCaseData(SimNumber).InfectionDate RandomisedInfectionDate(NumericalIncludeInForwardProjection)];%NumericalIncludeInForwardProjection
            
        end
    end
    
    DistributionDiagnosedInfections(SimNumber, :)=hist(DateMatrix(SimNumber, :), YearVector);
    MSMDistributionDiagnosedInfections(SimNumber, :)=hist(MSMDateMatrix(SimNumber, :), YearVector);
    PropMSMDistributionDiagnosedInfections(SimNumber, :)=MSMDistributionDiagnosedInfections(SimNumber, :)./DistributionDiagnosedInfections(SimNumber, :);
    
end





DistributionUndiagnosedInfectionsPrecise(SimNumber, :)=TotalUndiagnosedInfections;
DistributionDiagnosedInfectionsPrecise(SimNumber, :)=InfectionsByYearDiagnosed;


%     MSMDistributionUndiagnosedInfectionsPrecise(SimNumber, :)=MSMTotalUndiagnosedInfections;
%     DistributionDiagnosedInfectionsPrecise(SimNumber, :)=InfectionsByYearDiagnosed;
%     MSMDistributionDiagnosedInfectionsPrecise(SimNumber, :)=MSMInfectionsByYearDiagnosed;

HistYearSlots=(CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize))+0.5*StepSize;
for SimNumber=1:NoParameterisations
    DistributionUndiagnosedInfectionsPrecise(SimNumber, :)=hist(UndiagnosedCaseData(SimNumber).InfectionDate, HistYearSlots);
    DistributionDiagnosedInfectionsPrecise(SimNumber, :)=hist(DateMatrix(SimNumber,:), HistYearSlots);
end

%Plotting multiple simulations
plot(YearVector, (DistributionDiagnosedInfections+DistributionUndiagnosedInfections)')
plot(HistYearSlots, DistributionDiagnosedInfectionsPrecise')





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