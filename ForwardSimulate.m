%% function ForwardSimulate

% the purpose of this function is to simulate the undiagnosed individuals


%% Step 1: Collect sampling data
DateMatrix=zeros(NoParameterisations, NumberOfPatients);

InfectionTimeMatrix=zeros(NoParameterisations, NumberOfPatients);

RecentMSMCaseIndicator=false(1, NumberOfPatients);


NoPatientInRange=0;
for i=1:NumberOfPatients
    DateMatrix(:, i)=Patient(i).InfectionDateDistribution;

    if RangeOfCD4Averages(1)<=Patient(i).DateOfDiagnosisContinuous  && Patient(i).DateOfDiagnosisContinuous< RangeOfCD4Averages(2)
        NoPatientInRange=NoPatientInRange+1;
        InfectionTimeMatrix(:, NoPatientInRange)=Patient(i).TimeFromInfectionToDiagnosis;
        if (Patient(i).ExposureRoute<=4)% exposure coding of 1,2,3,4 are MSM of some variety
            RecentMSMCaseIndicator(NoPatientInRange)=true;
        else
            RecentMSMCaseIndicator(NoPatientInRange)=false;
        end
    end
end
%remove all those elements that are not used
InfectionTimeMatrix(:, NoPatientInRange+1:NumberOfPatients)=[];
RecentMSMCaseIndicator( NoPatientInRange+1:NumberOfPatients)=[];


TotalMSM=sum(MSMCaseIndicator);
MSMDateMatrix=zeros(NoParameterisations, TotalMSM);
MSMi=0;
for i=1:NumberOfPatients
    if MSMCaseIndicator(i)==true
        MSMi=MSMi+1;
        MSMDateMatrix(:, MSMi)=Patient(i).InfectionDateDistribution;
    end
end
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


for SimNumber=1:NoParameterisations
    disp(['Forward projecting undiagnosed sim ' num2str(SimNumber) ' of ' num2str(NoParameterisations)]);
    ExpectedTimesVector=InfectionTimeMatrix(SimNumber, :);%(for this Sim)
    [~, TotalInTimeVector]=size(ExpectedTimesVector);
    UndiagnosedCaseData(SimNumber).MSM=false(1,0);% because [] creates an empty NUMERICAL array which causes a type problem later on
    UndiagnosedCaseData(SimNumber).InfectionDate=[];
            
    YearIndex=0;
    IncludeInForwardProjection=false(1, NoPatientInRange);
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
            MSMSampleVector=RecentMSMCaseIndicator(SampleIndex);
            RandomisedInfectionDate=Year+rand(1, 10*TotalInTimeVector);
            
            %Add the simulated cases to a structure to store for later use
            CountSamples=0;
            NumberFoundDiagnosed=0;
            NumberOfUnidagnosedInfectionsThisStep=0;

            LowerBoundFound=false;
            UpperBoundFound=false;
            while (UpperBoundFound==false)%NumberFoundDiagnosed<TotalDiagnosedInBackprojectionEstimate+1
                CountSamples=CountSamples+1;

                % Determine if the infection represents one that is undiagnosed by the last data
                if RandomisedInfectionDate(CountSamples) + RandomisedExpectedTimesVector(CountSamples)<CutOffYear %%% THIS LINE COULD BE PROBLEMATIC DUE TO OVER SAMPLING
                    NumberFoundDiagnosed=NumberFoundDiagnosed+1;
                else % if the simulated individual has not been diagnosed by the cut off date
                    IncludeInForwardProjection(CountSamples)=true; 
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
            
            %work out the difference in the upper and lower estimate, find
            %a random value between the two, and select up to those many
            %individuals
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
            UndiagnosedCaseData(SimNumber).ExpectedTimeUntilDiagnoses=[UndiagnosedCaseData(SimNumber).ExpectedTimeUntilDiagnoses RandomisedExpectedTimesVector(NumericalIncludeInForwardProjection)];
        end
    end
    
    DistributionDiagnosedInfections(SimNumber, :)=hist(DateMatrix(SimNumber, :), YearVector+0.5);
    MSMDistributionDiagnosedInfections(SimNumber, :)=hist(MSMDateMatrix(SimNumber, :), YearVector+0.5);
    PropMSMDistributionDiagnosedInfections(SimNumber, :)=MSMDistributionDiagnosedInfections(SimNumber, :)./DistributionDiagnosedInfections(SimNumber, :);
    
end

TotalInfectionsPerYear=DistributionDiagnosedInfections+DistributionUndiagnosedInfections;

HistYearSlots=(CD4BackProjectionYearsWhole(1):StepSize:(CD4BackProjectionYearsWhole(2)+1-StepSize))+0.5*StepSize;
for SimNumber=1:NoParameterisations
    DistributionUndiagnosedInfectionsPrecise(SimNumber, :)=hist(UndiagnosedCaseData(SimNumber).InfectionDate, HistYearSlots);
    DistributionDiagnosedInfectionsPrecise(SimNumber, :)=hist(DateMatrix(SimNumber,:), HistYearSlots);
end

%Perform the above operation, but instead look at msm only
for SimNumber=1:NoParameterisations
    MSMDistributionUndiagnosedInfectionsPrecise(SimNumber, :)=hist(UndiagnosedCaseData(SimNumber).InfectionDate(UndiagnosedCaseData(SimNumber).MSM), HistYearSlots);
    MSMDistributionDiagnosedInfectionsPrecise(SimNumber, :)=hist(MSMDateMatrix(SimNumber,:), HistYearSlots);
end




%Find the number of people undiagnosed by end of 2013 in each year
% Note that all the diagnoses in the DistributionUndiagnosedInfectionsPrecise are undiagnosed.  
UndiagnosedSummed=[];
IndexCount=0;
for TempYear=HistYearSlots
    IndexCount=IndexCount+1;
    % Find sum of all currently undiagnosed
    if IndexCount==1
        UndiagnosedSummed(:, IndexCount)=DistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    else
        UndiagnosedSummed(:, IndexCount)=UndiagnosedSummed(:, IndexCount-1)+DistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    end
end

%Find the number of people undiagnosed by end of 2013 in each year
% Note that all the diagnoses in the DistributionUndiagnosedInfectionsPrecise are undiagnosed.  
MSMUndiagnosedSummed=[];
IndexCount=0;
for TempYear=HistYearSlots
    IndexCount=IndexCount+1;
    % Find sum of all currently undiagnosed
    if IndexCount==1
        MSMUndiagnosedSummed(:, IndexCount)=MSMDistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    else
        MSMUndiagnosedSummed(:, IndexCount)=MSMUndiagnosedSummed(:, IndexCount-1)+MSMDistributionUndiagnosedInfectionsPrecise(:, IndexCount);
    end
end



DiagnosisDateVec=zeros(1, NumberOfPatients);
for i=1:NumberOfPatients
    DiagnosisDateVec(i)=Patient(i).DateOfDiagnosisContinuous;
end
DiagnosisDistributionPrecise=hist(DiagnosisDateVec, HistYearSlots);



%Plotting multiple simulations
% hold on;
% plot(YearVector, TotalInfectionsPerYear');
% plot(YearVector, DistributionDiagnosedInfections');
% hold off;
% 
% 
% plot(HistYearSlots, DistributionDiagnosedInfectionsPrecise')
% 
% 
% hold on;
% plot(HistYearSlots, mean(DistributionDiagnosedInfectionsPrecise, 1)')
% plot(HistYearSlots, mean(DistributionUndiagnosedInfectionsPrecise, 1)')
% plot(HistYearSlots, mean(DistributionDiagnosedInfectionsPrecise+DistributionUndiagnosedInfectionsPrecise, 1)')
% plot(HistYearSlots, DiagnosisDistributionPrecise, 'r')
% hold off;

