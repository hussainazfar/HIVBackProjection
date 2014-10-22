function ExportData(Patients, FileName )

Matrix

Row=0;
for ThisPatient=Patients
    Row=Row+1;
    
    
    
    TimeBetweenInfection
    
    MeanTime=mean(ThisPatient.TimeFromInfectionToDiagnosis);
    MedianTime=median(ThisPatient.TimeFromInfectionToDiagnosis);
    
    ThisPatient.ID
    ThisPatient.DateOfDiagnosisContinuous

    SaveMatrix(Row, :)=
end

xlswrite(SaveMatrix, FileName);