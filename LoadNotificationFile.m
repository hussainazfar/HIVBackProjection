function [LineDataMatrix, LocationDataMatrix, YearOfDiagnosedDataEnd, BackProjectStartSingleYearAnalysis, CD4BackProjectionYearsWhole] = LoadNotificationFile(HIVFile, SheetName, SamplingFactor)
%% Read data from the notifications file

LoadTime = tic;
disp('Loading Excel Notification Data file');
[a, b, c] = xlsread(HIVFile,  SheetName);

disp(' ');
disp('-Time to Load File-');
toc(LoadTime)
disp('------------------------------------------------------------------');
disp(' ');

disp('Arranging Data File into Appropriate Matrices');
disp(' ');
LoadTime = tic;
if SamplingFactor ~= 0.0
    x = randsample(length(c)-1, ceil((1.0 - SamplingFactor) * length(c)-1));
    x = sort(x, 'descend');    
    %for y = 1:length(x)                                                         %Reshape vectors a, b and c to Compressed State with randomnly selected indexes from Notification File
        %g = y + 1;
        a(x, :) = [];
        b(x, :) = [];
        c(x, :) = [];
        %disp('Loop: ');
    %end    
end
clear x;

%The first row is the column headers
VariableName = c(1, :);
LineDataMatrix.VariableNames = VariableName;

%Determine the number of people in the data file
[NumberOfPatients, ~] = size(c);
NumberOfPatients = NumberOfPatients - 1;
LineDataMatrix.NumberOfPatients = NumberOfPatients;
LocationDataMatrix.NumberOfPatients = NumberOfPatients;

%Cut the header data from the rest of the data
c = c(2:NumberOfPatients+1, :);
b = b(2:NumberOfPatients+1, :);
%% Finding Data Start Date and Data End Date
if sum(strcmp(VariableName, 'datehivdec')) == 1                             %Copy all data in column datehivdec to variable x
    x = cell2mat(c(:,strcmp(VariableName, 'datehivdec')));
end

YearOfDiagnosedDataEnd = floor(max(x(:)));                                  %For data that doesn't go beyond last detected HIV case in data file
BackProjectStartSingleYearAnalysis = 4 + floor(min(x(:)));                  %For data that doesn't go behind first detected HIV case in data file
CD4BackProjectionYearsWhole = [BackProjectStartSingleYearAnalysis-19 YearOfDiagnosedDataEnd];
%% Assign the excel entries to the relevant LineDataMatrix section
if sum(strcmp(VariableName, 'id')) == 1
    LineDataMatrix.ID = cell2mat(c(:,strcmp(VariableName, 'id')));
end

LineDataMatrix.YearBirth=cell2mat(c(:,strcmp(VariableName, 'yearbirth')));
LineDataMatrix.Sex=cell2mat(c(:,strcmp(VariableName, 'sex')));

%Determine time of diagnosis
for x = 1:NumberOfPatients                                                  %this needs to be done line by line because it is a string
    LineDataMatrix.DateOfDiagnosis(x)=c(x,strcmp(VariableName, 'datehiv'));
    LineDataMatrix.DOB(x)=c(x,strcmp(VariableName, 'dob'));
end

LineDataMatrix.YearOfDiagnosis=year(datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy'));
LineDataMatrix.DateOfDiagnosisContinuous=LineDataMatrix.YearOfDiagnosis+  (datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy')-datenum(LineDataMatrix.YearOfDiagnosis, 1,1))./yeardays(LineDataMatrix.YearOfDiagnosis);


% Load the date of last negative and the date of illness
LineDataMatrix.DateLastNegative = NaN(1, NumberOfPatients);
if sum(strcmp(VariableName, 'dateneg')) == 1                                %dateill dateindet
    Column = strcmp(VariableName, 'dateneg');
    for x = 1:NumberOfPatients                                              %this needs to be done line by line because it is a string
        DateText=c(x,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy') - datenum(Year, 1,1);
            LineDataMatrix.DateLastNegative(x) = Year+  DaysSinceYear./yeardays(Year);
        end
    end
end

LineDataMatrix.DateIll = NaN(1, NumberOfPatients);
if sum(strcmp(VariableName, 'dateill')) == 1                                %dateill dateindet
    Column = strcmp(VariableName, 'dateill');
    for x = 1:NumberOfPatients                                              %this needs to be done line by line because it is a string
        DateText = c(x,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIll(x) = Year + DaysSinceYear./yeardays(Year);
        end
    end
end

LineDataMatrix.DateIndetWesternBlot = NaN(1, NumberOfPatients);
if sum(strcmp(VariableName, 'dateindet')) == 1                                %dateill dateindet
    Column = strcmp(VariableName, 'dateindet');
    for x = 1:NumberOfPatients                                                %this needs to be done line by line because it is a string
        DateText=c(x,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            Year=year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear=datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIndetWesternBlot(x)=Year+  DaysSinceYear./yeardays(Year);
        end
    end
end

% Load indigenous status
if sum(strcmp(VariableName, 'indigenous')) == 1
    LineDataMatrix.IndigenousStatus = cell2mat(c(:,strcmp(VariableName, 'indigenous')));
end

LineDataMatrix.CD4CountAtDiagnosis = cell2mat(c(:,strcmp(VariableName, 'cd4base')));
LineDataMatrix.ExposureRoute = cell2mat(c(:,strcmp(VariableName, 'exp')));
LineDataMatrix.RecentInfection = cell2mat(c(:,strcmp(VariableName, 'recent')));

% Load and clean up previously diagnoses overseas
LineDataMatrix.PreviouslyDiagnosedOverseas = cell2mat(c(:,strcmp(VariableName, 'previ_diag_overseas')));
LineDataMatrix.PreviouslyDiagnosedOverseas(isnan(LineDataMatrix.PreviouslyDiagnosedOverseas)) = 0;


for x = 1:NumberOfPatients %this needs to be done line by line because it is a string
%     disp('set');
%     size(VariableName)
%     size(c)
%     strcmp(VariableName, 'country_prev_diag')
    LineDataMatrix.CountryOfBirth(x)=c(x,strcmp(VariableName, 'country_prev_diag'));
end

%find the elements which are dedicated to location, load them into the LocationDataMatrix
LocationDataMatrix.PostcodeAtDiagnosis = cell2mat(c(:, strcmp(VariableName, 'postcode')));
LocationDataMatrix.StateAtDiagnosis = cell2mat(c(:, strcmp(VariableName, 'state')));
LocationDataMatrix.StateAtDiagnosis = NotificationStateToABSState(LocationDataMatrix.StateAtDiagnosis);

disp('-Time to Rearrange Data into Matrices-');
toc(LoadTime)
disp('------------------------------------------------------------------');
end