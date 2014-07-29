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
EmptyDOBLogicalIndex=strcmp(DOB, '');
EmptyDOBsIndex=1:NumberOfPatients;
EmptyDOBsIndex=EmptyDOBsIndex(EmptyDOBLogicalIndex);

YOB=year(DOB, 'dd/mm/yyyy');

DateHIV=b(:,strcmp(VariableName, 'datehiv'));

SampleYearHIV=YearHIV;
SampleYearHIV(~EmptyDOBLogicalIndex)=[];
SampleYOB=YOB;
SampleYOB(~EmptyDOBLogicalIndex)=[];

% for each person
ithEmpty=0;
for Index=1:EmptyDOBsIndex
    ithEmpty=ithEmpty+1;
    
    disp(['Replacing record ' num2str(ithEmpty)]);
    % find records with the same year and with an actual DOB
    
    YOBsDiagThisYear=SampleYOB(SampleYearHIV==ithEmptyYOB)
    [NoOfSamples, ~]=size(YOBsDiagThisYear);
    if NoOfSamples==0
        %choose a year at random from  the whole data set
        EmptyYOB(ithEmpty)=randsample(SampleYOB, 1);
    else
        EmptyYOB(ithEmpty)=randsample(YOBsDiagThisYear, 1);
    end
    
    % create a random date in that year
    
    % set it to the empty record
    

end

NewDOB=DOB;
NewDOB(EmptyDOBs)=



% Save file to excel
