function Patient=LoadPatientClass(Location, SimulationNumber)

load([Location '/NumberInFile' num2str(SimulationNumber) '.mat']);

load([Location '/Patient' num2str(SimulationNumber) '-' num2str(1) '.mat']);
Patient=PatientTemp;
for FileNumber=2:NumberOfFilesSaved
    disp([FileNumber NumberOfFilesSaved]);
    load([Location '/Patient' num2str(SimulationNumber) '-' num2str(FileNumber) '.mat']);
    Patient=[Patient PatientTemp];
end

