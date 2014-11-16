function [LineDataMatrix, LocationDataMatrix]=LoadNotificationFile(HIVFile, SheetName, LoadLocationInformation)
%% Read data from the notifications file


disp('Loading Notification Data File');
Timer=tic;
disp('Openning the Excel file');
[a, b, c]=xlsread(HIVFile,  SheetName);%Approx 2.3 seconds

%The first row is the column headers
VariableName=c(1, :);
LineDataMatrix.VariableNames=VariableName;
%Determine the number of people in the data file
[NumberOfPatients, ~]=size(c);
NumberOfPatients=NumberOfPatients-1;
LineDataMatrix.NumberOfPatients=NumberOfPatients;
LocationDataMatrix.NumberOfPatients=NumberOfPatients;
%Cut the header data from the rest of the data
c=c(2:NumberOfPatients+1, :);
b=b(2:NumberOfPatients+1, :);

toc(Timer)

%% Assign the excel entries to the relevant LineDataMatrix section
if sum(strcmp(VariableName, 'id'))==1
    LineDataMatrix.ID=cell2mat(c(:,strcmp(VariableName, 'id')));
end
LineDataMatrix.YearBirth=cell2mat(c(:,strcmp(VariableName, 'yearbirth')));


LineDataMatrix.Sex=cell2mat(c(:,strcmp(VariableName, 'sex')));
%Determine time of diagnosis
for i=1:NumberOfPatients%this needs to be done line by line because it is a string
    LineDataMatrix.DateOfDiagnosis(i)=c(i,strcmp(VariableName, 'datehiv'));
    LineDataMatrix.DOB(i)=c(i,strcmp(VariableName, 'dob'));
end
LineDataMatrix.YearOfDiagnosis=year(datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy'));
LineDataMatrix.DateOfDiagnosisContinuous=LineDataMatrix.YearOfDiagnosis+  (datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy')-datenum(LineDataMatrix.YearOfDiagnosis, 1,1))./yeardays(LineDataMatrix.YearOfDiagnosis);


% Load the date of last negative and the date of illness
LineDataMatrix.LastNegative=NaN(1, NumberOfPatients);
if sum(strcmp(VariableName, 'dateneg'))==1   %dateill dateindet
    Column=strcmp(VariableName, 'dateneg');
    for i=1:NumberOfPatients%this needs to be done line by line because it is a string
        DateText=c(i,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            Year=year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear=datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.LastNegative(i)=Year+  DaysSinceYear./yeardays(Year);
        end
    end
end

LineDataMatrix.DateIll=NaN(1, NumberOfPatients);
if sum(strcmp(VariableName, 'dateill'))==1   %dateill dateindet
    Column=strcmp(VariableName, 'dateill');
    for i=1:NumberOfPatients%this needs to be done line by line because it is a string
        DateText=c(i,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            Year=year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear=datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIll(i)=Year+  DaysSinceYear./yeardays(Year);
        end
    end
end

LineDataMatrix.DateIndetWesternBlot=NaN(1, NumberOfPatients);
if sum(strcmp(VariableName, 'dateindet'))==1   %dateill dateindet
    Column=strcmp(VariableName, 'dateindet');
    for i=1:NumberOfPatients%this needs to be done line by line because it is a string
        DateText=c(i,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            Year=year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear=datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIndetWesternBlot(i)=Year+  DaysSinceYear./yeardays(Year);
        end
    end
end




% Load indigenous status
if sum(strcmp(VariableName, 'indigenous'))==1
    LineDataMatrix.IndigenousStatus=cell2mat(c(:,strcmp(VariableName, 'indigenous')));
end
LineDataMatrix.CD4CountAtDiagnosis=cell2mat(c(:,strcmp(VariableName, 'cd4base')));
LineDataMatrix.ExposureRoute=cell2mat(c(:,strcmp(VariableName, 'exp')));
LineDataMatrix.RecentInfection=cell2mat(c(:,strcmp(VariableName, 'recent')));
% Load and clean up previously diagnoses overseas
LineDataMatrix.PreviouslyDiagnosedOverseas=cell2mat(c(:,strcmp(VariableName, 'previ_diag_overseas')));
LineDataMatrix.PreviouslyDiagnosedOverseas(isnan(LineDataMatrix.PreviouslyDiagnosedOverseas))=0;


for i=1:NumberOfPatients %this needs to be done line by line because it is a string
%     disp('set');
%     size(VariableName)
%     size(c)
%     strcmp(VariableName, 'country_prev_diag')
    LineDataMatrix.CountryOfBirth(i)=c(i,strcmp(VariableName, 'country_prev_diag'));
end

if LoadLocationInformation
    %find the elements which are dedicated to location, load them into the LocationDataMatrix
    LocationDataMatrix.PostcodeAtDiagnosis=cell2mat(c(:, strcmp(VariableName, 'postcode')));
    LocationDataMatrix.StateAtDiagnosis=cell2mat(c(:, strcmp(VariableName, 'state')));
    
    LocationDataMatrix.StateAtDiagnosis=NotificationStateToABSState(LocationDataMatrix.StateAtDiagnosis);
end

end