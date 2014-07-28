function [DeduplicatedPatients, DateOfDiagnosisOfDuplicates]=RemoveDuplicates(Patient)

DeduplicatedPatients=[];
DateOfDiagnosisOfDuplicates=[];

[~, NoPatients]=size(Patient);

%find the earliest year in the data
MinBirthYear=10000;
MaxBirthYear=0;
for i=1:NoPatients
    if Patient(i).YearBirth<MinBirthYear
        MinBirthYear=Patient(i).YearBirth;
    end
    if Patient(i).YearBirth>MaxBirthYear
        MaxBirthYear=Patient(i).YearBirth;
    end
end    

    
%for each year in the data
for ThisBirthYear=MinBirthYear:MaxBirthYear
% Select patients with birthdates in the year
    if (Patient(i).YearBirth==ThisBirthYear)
        
    end

end
