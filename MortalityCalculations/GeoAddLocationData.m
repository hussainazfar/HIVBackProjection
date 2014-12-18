function [Patient]=GeoAddLocationData(Patient, LocationDataMatrix, PC2SR)
%% Read data from the notifications file and do some clean up of the postcodes




%% Assign the excel entries to the variables in Patient 
for i=1:LocationDataMatrix.NumberOfPatients
    
    if mod(i, 1000)==0
        disp(['Loading notification ', num2str(i), ' of ',  num2str(LocationDataMatrix.NumberOfPatients)]);
    end
    Patient(i).StateAtDiagnosis=LocationDataMatrix.StateAtDiagnosis(i);
    Patient(i).PostcodeAtDiagnosis=LocationDataMatrix.PostcodeAtDiagnosis(i);
end




%% Clean up postcode data
disp('Removing undefinded postcodes');
Postcodes=cell2mat(PC2SR.Postcode);
tic
for i=1:LocationDataMatrix.NumberOfPatients
    %disp([i Patient(i).PostcodeAtDiagnosis]);
    if isnan(Patient(i).PostcodeAtDiagnosis)==true
        Patient(i).PostcodeAtDiagnosis=0;
    elseif Patient(i).PostcodeAtDiagnosis==0
        %don't do anything
    else
        %try to find if the postcode is present in the PostcodeToSLA data
        IndexOfRelevantPostCode=Patient(i).PostcodeAtDiagnosis==Postcodes;
        if sum(IndexOfRelevantPostCode)==0
            %Postcode not found
            Patient(i).PostcodeAtDiagnosis(1)=0;
        end
    end
end
toc
%% If the patient does not have an initial postcode, create one for them
disp('Assigning patients without postcodes a postcode based on other diagnoses');
tic
%This section sorts all the data into years and states such that it can be
%drawn upon for giving those without a postcode an estimated postcode
DiagsByYearState=GeoCreatePostcodeInitialiser(Patient);
NumberOfRandomlyAssignedPostcodes=0;
for i=1:LocationDataMatrix.NumberOfPatients
    if Patient(i).PostcodeAtDiagnosis==0
        Patient(i).PostcodeAtDiagnosis=GeoCreatePostcode(Patient(i).StateAtDiagnosis, Patient(i).YearOfDiagnosis, DiagsByYearState);
        NumberOfRandomlyAssignedPostcodes=NumberOfRandomlyAssignedPostcodes+1;
    end
end
toc

end