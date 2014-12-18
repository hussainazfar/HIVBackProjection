function SavePatientClass(Patient, Location,  SimulationNumber)
ChunkSize=1000;
%determine the total size of 'Patient'
[~, NumRecords]=size(Patient);
%break 

NumberOfFilesSaved=0;
timer=tic;
for CurrentPosition=1:ChunkSize:NumRecords
    if CurrentPosition+ChunkSize-1>NumRecords
        CurrentEndPosition=NumRecords;
    else
        CurrentEndPosition=CurrentPosition+ChunkSize-1;
    end
    
    CurrentTime=toc(timer);
    if CurrentTime>5
        disp([num2str(CurrentTime) ' seconds ' num2str(CurrentPosition) ' of ' num2str(NumRecords)]);
    end
    
    %disp([CurrentPosition CurrentEndPosition]);
    %Save appropriate file
    NumberOfFilesSaved=NumberOfFilesSaved+1;
    PatientTemp=Patient(CurrentPosition:CurrentEndPosition);
    save([Location '/Patient' num2str(SimulationNumber) '-' num2str(NumberOfFilesSaved) '.mat'], 'PatientTemp');
end

save([Location '/NumberInFile' num2str(SimulationNumber) '.mat'], 'NumberOfFilesSaved');