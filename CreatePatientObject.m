function [Patient]=CreatePatientObject(LineDataMatrix)
%% Read data from the notifications file and do some clean up of the postcodes

%Create a patient structure to return
Patient(1:LineDataMatrix.NumberOfPatients)=PatientClass;

%% Assign the excel entries to the variables in Patient 
for i=1:LineDataMatrix.NumberOfPatients
    
    if mod(i, 1000)==0
        disp(['Loading notification ', num2str(i), ' of ',  num2str(LineDataMatrix.NumberOfPatients)]);
    end
    
    Patient(i).ID=LineDataMatrix.ID(i);
    Patient(i).YearBirth=LineDataMatrix.YearBirth(i);
    Patient(i).DOB=LineDataMatrix.DOB(i);
    Patient(i).Sex=LineDataMatrix.Sex(i);
    Patient(i).DateOfDiagnosis=LineDataMatrix.DateOfDiagnosis(i);
    Patient(i).YearOfDiagnosis=LineDataMatrix.YearOfDiagnosis(i);
    Patient(i).DateOfDiagnosisContinuous=LineDataMatrix.DateOfDiagnosisContinuous(i);
    Patient(i).CD4CountAtDiagnosis=LineDataMatrix.CD4CountAtDiagnosis(i);
    Patient(i).ExposureRoute=LineDataMatrix.ExposureRoute(i);
    Patient(i).RecentInfection=LineDataMatrix.RecentInfection(i);
    Patient(i).CountryOfBirth=LineDataMatrix.CountryOfBirth(i);
    Patient(i).PreviouslyDiagnosedOverseas=LineDataMatrix.PreviouslyDiagnosedOverseas(i);
    
    Patient(i).DateIll=LineDataMatrix.DateIll(i);
    Patient(i).DateIndetWesternBlot=LineDataMatrix.DateIndetWesternBlot(i);
    Patient(i).DateLastNegative=LineDataMatrix.DateLastNegative(i);
    
    Patient(i).SimulatedIndividual=0;
    
    %Patient(i).IndigenousStatus=LineDataMatrix.IndigenousStatus(i);
    
end


%% Assign people without birth year a year
%this section is no longer necessary as imputation of date of birth occurs
%in the SAS file imputation (which is much better at imputation than my
%imputation method)
% % disp('Assigning patients without a birth year a new birth year based on other diagnoses');
% % DiagsByYear=CreateYearInitialiser(Patient);
% % for i=1:NumberOfPatients
% %     if Patient(i).YearBirth==0
% %         Patient(i).YearBirth=CreateYear(Patient(i).YearOfDiagnosis, DiagsByYear);
% %     end
% end


end