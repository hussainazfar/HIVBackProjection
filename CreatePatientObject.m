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
    
    Patient(x).Sex = LineDataMatrix.Sex(x);
    Patient(x).DateOfDiagnosis = LineDataMatrix.DateOfDiagnosis(x);
    Patient(x).YearOfDiagnosis = LineDataMatrix.YearOfDiagnosis(x);
    Patient(x).DateOfDiagnosisContinuous = LineDataMatrix.DateOfDiagnosisContinuous(x);
    Patient(x).CD4CountAtDiagnosis = LineDataMatrix.CD4CountAtDiagnosis(x);
    Patient(x).ExposureRoute = LineDataMatrix.Exp(x);  
    Patient(x).DateIll = LineDataMatrix.DateIll(x);
    Patient(x).DateIndetWesternBlot = LineDataMatrix.DateIndetWesternBlot(x);
    Patient(x).DateLastNegative = LineDataMatrix.DateLastNegative(x);
    Patient(x).Age = LineDataMatrix.Age(x);
    Patient(x).SimulatedIndividual = 0;
    
end

end

