clear;

%open file
FileName='Data/notifications2014exposure.xls';
SheetName='Sheet1';
[a, b, c]=xlsread(FileName,  SheetName);%Approx 2.3 seconds

%The first row is the column headers
VariableName=c(1, :);

%Determine the number of people in the data file
[NumberOfPatients, ~]=size(c);
NumberOfPatients=NumberOfPatients-1;

%Cut the header data from the rest of the data
c=c(2:NumberOfPatients+1, :);
b=b(2:NumberOfPatients+1, :);

%read dob, year of diagnosis

DOB=b(:,strcmp(VariableName, 'dob'));
% Determine which records don't have DOB data
EmptyDOBLogicalIndex=strcmp(DOB, '');
EmptyDOBsIndex=1:NumberOfPatients;
EmptyDOBsIndex=EmptyDOBsIndex(EmptyDOBLogicalIndex);



DateHIV=b(:,strcmp(VariableName, 'datehiv'));
YearHIV=year(DateHIV, 'dd/mm/yyyy');



SampleYearHIV=YearHIV;
SampleYearHIV(EmptyDOBLogicalIndex)=[];%Remove elements with empty data
SampleDOB=DOB;
SampleDOB(EmptyDOBLogicalIndex)=[];%Remove elements with empty data

SampleYOB=year(SampleDOB, 'dd/mm/yyyy');


EmptyDOBStrings={};
ithEmpty=0;
for Index=EmptyDOBsIndex %for all people without a DOB
    ithEmpty=ithEmpty+1;
    
    ithEmptyYearOfDiagnosis=YearHIV(Index);
    
    disp(['Replacing record ' num2str(Index) ' with year of diagnosis ' num2str(ithEmptyYearOfDiagnosis)]);
    % find records with the same year and with an actual DOB
    
    YOBsDiagThisYear=SampleYOB(SampleYearHIV==ithEmptyYearOfDiagnosis);
    [NoOfSamples, ~]=size(YOBsDiagThisYear);
    if NoOfSamples==0
        %choose a year at random from  the whole data set
        EmptyYOB=randsample(SampleYOB, 1);
    else
        EmptyYOB=randsample(YOBsDiagThisYear, 1);
    end
    
    % create a random date in that year
    DateNumber = datenum(EmptyYOB,1,1);
    
    if (mod(EmptyYOB, 4)==0)
        RandDays=floor(366*rand);
    else
        RandDays=floor(365*rand);
    end
    
    DateNumber=DateNumber+RandDays;
    
    DateString = datestr(DateNumber, 'dd/mm/yyyy');
    
    % set it to the empty record
    EmptyDOBStrings{ithEmpty}=DateString;

end

NewDOB=DOB;%copy in the original DOB strings
NewDOB(EmptyDOBsIndex)=EmptyDOBStrings;



% Save file to excel
