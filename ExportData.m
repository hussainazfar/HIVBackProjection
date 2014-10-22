function [SaveMatrix]=ExportData(Patients)%, FileName )

SaveMatrix=[];


Row=0;
for ThisPatient=Patients
    Row=Row+1;
    
    
    
    
    
    MeanTime=mean(ThisPatient.TimeFromInfectionToDiagnosis);
    MedianTime=median(ThisPatient.TimeFromInfectionToDiagnosis);
    
    SaveMatrix{Row,1}=ThisPatient.ID;
    SaveMatrix{Row,2}=ThisPatient.DateOfDiagnosisContinuous;
    SaveMatrix{Row,3}=ThisPatient.DateOfDiagnosis{:};
    SaveMatrix{Row,4}=ThisPatient.CD4CountAtDiagnosis;
    
    SaveMatrix(Row, 5)=MeanTime;
    SaveMatrix(Row, 6)=MedianTime;
    
    
end

xlswrite(SaveMatrix, FileName);