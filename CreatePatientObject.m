function [ Patient ] = CreatePatientObject( LineDataMatrix )
%Read data from the notifications file and do some clean up of the postcodes
%   Create a patient structure to return to main program, all inputs are
%   taken from LineDataMatrix which holds complete information from
%   Imputation Data File
Patient(1:LineDataMatrix.NumberOfPatients) = PatientClass;

%% Assign the excel entries to the variables in Patient 
for x = 1:LineDataMatrix.NumberOfPatients
    
    if mod(x, 1000)==0
        disp(['Loading Notification Progress: ', num2str(100 * x / LineDataMatrix.NumberOfPatients), '%']);     
    end
    
    Patient(x).ID = LineDataMatrix.ID(x);
    Patient(x).YearBirth = LineDataMatrix.YearBirth(x);
    Patient(x).DOB = LineDataMatrix.DOB(x);
    Patient(x).Sex = LineDataMatrix.Sex(x);
    Patient(x).DateOfDiagnosis = LineDataMatrix.DateOfDiagnosis(x);
    Patient(x).YearOfDiagnosis = LineDataMatrix.YearOfDiagnosis(x);
    Patient(x).DateOfDiagnosisContinuous = LineDataMatrix.DateOfDiagnosisContinuous(x);
    Patient(x).CD4CountAtDiagnosis = LineDataMatrix.CD4CountAtDiagnosis(x);
    Patient(x).ExposureRoute = LineDataMatrix.ExposureRoute(x);
    Patient(x).RecentInfection = LineDataMatrix.RecentInfection(x);
    Patient(x).CountryOfBirth = LineDataMatrix.CountryOfBirth(x);
    Patient(x).PreviouslyDiagnosedOverseas = LineDataMatrix.PreviouslyDiagnosedOverseas(x);
    
    Patient(x).DateIll = LineDataMatrix.DateIll(x);
    Patient(x).DateIndetWesternBlot = LineDataMatrix.DateIndetWesternBlot(x);
    Patient(x).DateLastNegative = LineDataMatrix.DateLastNegative(x);
    
    Patient(x).SimulatedIndividual = 0;
    
    %Patient(x).IndigenousStatus=LineDataMatrix.IndigenousStatus(x);
    
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

