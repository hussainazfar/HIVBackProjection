function ForwardSimulate

% the purpose of this function is to simulate the undiagnosed individuals

% Step 1: determine the number of people in diagnosed in each whole year
DateMatrix=zeros(NoParameterisations, NumberOfPatients);
InfectionTimeMatrix=zeros(NoParameterisations, NumberOfPatients);
MSMCaseIndicator=zeros(1, NumberOfPatients);

NoPatientInRange=0;
TimeDistributionOfRecentDiagnoses=[];
CD4DistributionOfRecentDiagnoses=[];
for i=1:NumberOfPatients

        TimeDistributionOfRecentDiagnoses((i-1)*NoParameterisations+1:i*NoParameterisations)=Patient(i).TimeFromInfectionToDiagnosis;
        CD4DistributionOfRecentDiagnoses((i-1)*NoParameterisations+1:i*NoParameterisations)=Patient(i).CD4CountAtDiagnosis;
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

for CurrentSim=1:NoParameterisations
    
    InfectionByYear(CurrentSim, :)=
end


% Step 2: randomly sample the population

%choose a random time in the period

% each time a sample occur



DateIndeterminantWB
EarlietTimeWB=DateIndeterminantWB-40;

EarlietTimeLN=LastNegative;

EarlietTimeSeroConvIll=DateIll-40;

EarliestTime=max(EarlietTimeWB, EarlietTimeLN, EarlietTimeSeroConvIll);

ApproxDate
