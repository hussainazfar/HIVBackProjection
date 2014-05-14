% function FindCD4CountOfRecentInfections

RecentInfectionCD4AtDiagnosis=-1*ones(1, NumberOfPatients);
RecentInfectionAgeAtDiagnosis=-1*ones(1, NumberOfPatients);

for i=1:NumberOfPatients
    if mod(i, 1000)==0
        disp(i)
    end
    if Patient(i).RecentInfection==1 && Patient(i).DateOfDiagnosisContinuous>=2012 && Patient(i).DateOfDiagnosisContinuous< 2013
        RecentInfectionCD4AtDiagnosis(i)=Patient(i).CD4CountAtDiagnosis;
        
        RecentInfectionAgeAtDiagnosis(i)=Patient(i).CurrentAge(Patient(i).DateOfDiagnosisContinuous);
    end
end

RecentInfectionCD4AtDiagnosis(RecentInfectionCD4AtDiagnosis<-0.5)=[];
RecentInfectionAgeAtDiagnosis(RecentInfectionAgeAtDiagnosis<-0.5)=[];


disp('CD4 count at diagnosis of those diagnosed in 2012')
disp('Mean')
disp(mean(RecentInfectionCD4AtDiagnosis))

disp('Median')
disp(median(RecentInfectionCD4AtDiagnosis))


disp('Age at diagnosis of those diagnosed in 2012')
disp('Mean')
disp(mean(RecentInfectionAgeAtDiagnosis))

disp('Median')
disp(median(RecentInfectionAgeAtDiagnosis))