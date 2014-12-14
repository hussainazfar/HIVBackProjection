% function SurveillanceReport
clear
clc
TimeALL=tic;

%% Load settings for the simualtion
% LoadSettings
YearOfDiagnosedDataEnd=2014;% for data that doesn't go beyond 2013
% HIVFile='Imputation\hiv20062014dataincompleteimputation.xls';
HIVFile='Imputation\hiv20062014dataincompleteexposureimputation.xls';
SheetName='Dataset_1';
LoadSettings



%% Seed the random variables
RandomNumberStream = RandStream('mlfg6331_64','Seed',1385646);
RandStream.setGlobalStream(RandomNumberStream);

%Use the below code in any parfor loop to use appropriate substreams for the rand generator (i is the loop number)
%set(RandomNumberStream,'Substream',SimNum);

%%
if InitialisePCToSRThisSim==false
    load([ParameterLocalStorageLocation 'PC2SR.mat']);%If PC2SR file cannot be found, it may need to be generated
else
    % Initialise postcode to statistical region coder
    disp('Initialising PCToSR system');
    [PC2SR]=InitialisePCToSR();
    
end


%% Load the patient data into a large matrix and create objects to store patient data
disp('Loading saved basic patient class data');

%open file format, return separately the postcodes and other subsections of the data 
[LineDataMatrix, LocationDataMatrix]=LoadNotificationFile(HIVFile, SheetName, PerformGeographicCalculations);

%Place data from LineDataMatrix into PatientData
[Patient]=CreatePatientObject(LineDataMatrix);

%Add state data to the system
Patient=GeoAddLocationData(Patient, LocationDataMatrix, PC2SR);

[Patient, DuplicatePatient]=RemoveDuplicates(Patient);

Identifier=1;
SavePatientClass(Patient, 'PatientSaveFiles',  Identifier);

%%
CalculateAIDSAndMortality


%% Collate results for table 6.1.1

clear Temp
YearRanges=1980:YearOfDiagnosedDataEnd;
[~, YearSize]=size(YearRanges);
SimSize=100;
GenderSize=2;
StateSize=9;
[~, NoPatients]=size(Patient);
TotalPeople=zeros(YearOfDiagnosedDataEnd-1980+1, SimSize);

MatrixValues=zeros(YearSize, GenderSize, StateSize, SimSize);

YearCount=0;
for Year=1980:YearOfDiagnosedDataEnd
    YearCount=YearCount+1;
    disp(Year)
    for i=1:NoPatients
        
        TotalPeople(YearCount, :)=TotalPeople(YearCount, :)+Patient(i).AliveAndHIVPosInYear(Year);
        Temp(1, 1, 1, :)=Patient(i).AliveAndHIVPosInYear(Year);

        if Patient(i).Sex==1 || Patient(i).Sex==3
            SexValue=1;
        else
            SexValue=2;
        end
        

        MatrixValues(YearCount, SexValue,  Patient(i).StateAtDiagnosis, :)=MatrixValues(YearCount, SexValue,  Patient(i).StateAtDiagnosis, :)+Temp;
    end
end

TotalMedian=median(TotalPeople, 2);
TotalLCI=prctile(TotalPeople, 2.5, 2);
TotalUCI=prctile(TotalPeople, 97.5, 2);
hold off
plot(YearRanges, TotalMedian)

TotalThisYearUncertainty=[TotalMedian(YearRanges==YearOfDiagnosedDataEnd),TotalLCI(YearRanges==YearOfDiagnosedDataEnd),TotalUCI(YearRanges==YearOfDiagnosedDataEnd) ];
disp(TotalThisYearUncertainty);
TotalLastYearUncertainty=[TotalMedian(YearRanges==YearOfDiagnosedDataEnd-1),TotalLCI(YearRanges==YearOfDiagnosedDataEnd-1),TotalUCI(YearRanges==YearOfDiagnosedDataEnd-1) ];

% Results by state
StateSum=squeeze(sum(MatrixValues, 2));
ResultsState=median(StateSum, 3);
ResultsStateLCI=prctile(StateSum, 2.5, 3);
ResultsStateUCI=prctile(StateSum, 97.5, 3);

% 2012
StateUncertaintyLastYear=[ResultsState(YearRanges==YearOfDiagnosedDataEnd-1, :);ResultsStateLCI(YearRanges==YearOfDiagnosedDataEnd-1, :);ResultsStateUCI(YearRanges==YearOfDiagnosedDataEnd-1, :) ];
%2013
StateUncertaintyThisYear=[ResultsState(YearRanges==YearOfDiagnosedDataEnd, :);ResultsStateLCI(YearRanges==YearOfDiagnosedDataEnd, :);ResultsStateUCI(YearRanges==YearOfDiagnosedDataEnd, :) ];

% Results by sex
SexSum=squeeze(sum(MatrixValues, 3));
ResultsSex=median(SexSum, 3);
ResultsSexLCI=prctile(SexSum, 2.5, 3);
ResultsSexUCI=prctile(SexSum, 97.5, 3);
SexUncertaintyThisYear=[ResultsSex(YearRanges==YearOfDiagnosedDataEnd, :);ResultsSexLCI(YearRanges==YearOfDiagnosedDataEnd, :);ResultsSexUCI(YearRanges==YearOfDiagnosedDataEnd, :) ];


% Results by sex and state
ResultsDetailed=median(MatrixValues, 4);
ResultsDetailedLCI=prctile(MatrixValues, 2.5, 4);
ResultsDetailedUCI=prctile(MatrixValues, 97.5, 4);

% The 2012 report figure (for checking)
LastYearsTable=squeeze(ResultsDetailed(YearRanges==YearOfDiagnosedDataEnd-1, :, :));
% The 2013 report figures by sex and state
ThisYearsTable=squeeze(ResultsDetailed(YearRanges==YearOfDiagnosedDataEnd, :, :));
ThisYearsTableLCI=squeeze(ResultsDetailedLCI(YearRanges==YearOfDiagnosedDataEnd, :, :));
ThisYearsTableUCI=squeeze(ResultsDetailedUCI(YearRanges==YearOfDiagnosedDataEnd, :, :));


ResultForReport=ThisYearsTable';
ResultForReportLCI=ThisYearsTableLCI';
ResultForReportUCI=ThisYearsTableUCI';

% NSW	2	1
% VIC	7	2
% QLD	4	3
% SA	5	4
% WA	8	5
% TAS	6	6
% NT	3	7
% ACT	1	8

