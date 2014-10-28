function [SaveMatrix]=ExportData(Patients, FileName )

SaveMatrix=[];


Row=0;
for ThisPatient=Patients
    Row=Row+1;
    
    
    
    
    
    MeanTime=mean(ThisPatient.TimeFromInfectionToDiagnosis);
    MedianTime=median(ThisPatient.TimeFromInfectionToDiagnosis);
    
    SaveMatrix{Row,1}=ThisPatient.ID;
    SaveMatrix{Row,2}=ThisPatient.DateOfDiagnosisContinuous;
    SaveMatrix{Row,3}=ThisPatient.DateOfDiagnosis{:};
    SaveMatrix{Row,4}=ThisPatient.PreviouslyDiagnosedOverseas;
    SaveMatrix{Row,5}=ThisPatient.CD4CountAtDiagnosis;
    
    SaveMatrix{Row, 6}=MeanTime;
    SaveMatrix{Row, 7}=MedianTime;
    
    
end

xlswrite( FileName, SaveMatrix);