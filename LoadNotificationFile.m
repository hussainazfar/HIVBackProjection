function [LineDataMatrix, LocationDataMatrix, YearOfDiagnosedDataEnd, BackProjectStartSingleYearAnalysis, CD4BackProjectionYearsWhole] = LoadNotificationFile(HIVFile, SheetName, SamplingFactor, DateFormat)
%% Read data from the notifications file

LoadTime = tic;
disp('Loading Excel Notification Data File');
[a, b, c] = xlsread(HIVFile,  SheetName);

disp(' ');
disp('-Time to Load File-');
toc(LoadTime)
disp('------------------------------------------------------------------');
disp(' ');

disp('Arranging Data File into Appropriate Matrices');
disp(' ');
LoadTime = tic;

%The first row is the column headers
VariableName = c(1, :);
LineDataMatrix.VariableNames = VariableName;
%Determine the number of people in the data file
[NumberOfPatients, ~] = size(c);                                               %Number of Patients in complete file

%Cut the header data from the rest of the data
c = c(2:NumberOfPatients, :);

%Determine the number of people in modifie file
[NumberOfPatients, ~] = size(c);

%% Assign the excel entries to the relevant LineDataMatrix section
%Creating Arrays for each date element:
LineDataMatrix.DateOfDiagnosis = NaN(1, NumberOfPatients);
LineDataMatrix.DateLastNegative = NaN(1, NumberOfPatients);
LineDataMatrix.DateIll = NaN(1, NumberOfPatients);
LineDataMatrix.DateIndetWesternBlot = NaN(1, NumberOfPatients);

%Determine time of diagnosis
for x = 1:NumberOfPatients                                                  %this needs to be done line by line because it is a string
    LineDataMatrix.DateOfDiagnosis(x) = c(x, strcmp(VariableName, 'Date_of_HIV_diagnosis'));
    if strcmp(DateFormat, 'mm/dd/yyyy') == 1
        S1 = LineDataMatrix.DateOfDiagnosis(x);
        D = datenum(S1, 'dd/mm/yyyy');
        LineDataMatrix.DateOfDiagnosis(x) = D;
    end        
end
LineDataMatrix.YearOfDiagnosis = year(datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy'));
LineDataMatrix.DateOfDiagnosisContinuous = LineDataMatrix.YearOfDiagnosis + (datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy') - datenum(LineDataMatrix.YearOfDiagnosis, 1,1)) ./ yeardays(LineDataMatrix.YearOfDiagnosis);

%Determine Last Negative HIV Test
if sum(strcmp(VariableName, 'DateLastNegative')) == 1                       %Last Time Patient was diagnosed as not infected
    Column = strcmp(VariableName, 'DateLastNegative');
    for x = 1:NumberOfPatients                                                %this needs to be done line by line because it is a string
        DateText = c(x ,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            if strcmp(DateFormat, 'mm/dd/yyyy') == 1
                S1 = LineDataMatrix.DateLastNegative(x);
                D = datenum(S1, 'dd/mm/yyyy');
                LineDataMatrix.DateLastNegative(x) = D;
            end  
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy') - datenum(Year, 1,1);
            LineDataMatrix.DateLastNegative(x) = Year +  DaysSinceYear ./ yeardays(Year);
        end
    end
end

%Determine Seroconversion Symptoms appearance date
if sum(strcmp(VariableName, 'Seroconversion_illness_at_HIV_diagnosis')) == 1 
    Column = strcmp(VariableName, 'Seroconversion_illness_at_HIV_diagnosis');
    for x = 1:NumberOfPatients                                                %this needs to be done line by line because it is a string
        DateText = c(x,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            if strcmp(DateFormat, 'mm/dd/yyyy') == 1
                S1 = LineDataMatrix.DateIll(x);
                D = datenum(S1, 'dd/mm/yyyy');
                LineDataMatrix.DateIll(x) = D;
            end
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy') - datenum(Year, 1,1);
            LineDataMatrix.DateIll(x) = Year + DaysSinceYear ./ yeardays(Year);
        end
    end
end

%Determine Indeterminate Western Blot Test Date
for x = 1:NumberOfPatients                                                  %this needs to be done line by line because it is a string
    LineDataMatrix.DateIndetWesternBlot(x) = c(x, strcmp(VariableName, 'Indeterminate_western_blot_at_HIV_diagnosis'));
end
if sum(strcmp(VariableName, 'Indeterminate_western_blot_at_HIV_diagnosis')) == 1
    Column = strcmp(VariableName, 'Indeterminate_western_blot_at_HIV_diagnosis');
    for x = 1:NumberOfPatients                                                %this needs to be done line by line because it is a string
        DateText = c(x,Column);
        if strcmp(DateText, '')
            % do nothing
        else
            if strcmp(DateFormat, 'mm/dd/yyyy') == 1
                S1 = LineDataMatrix.DateIll(x);
                D = datenum(S1, 'dd/mm/yyyy');
                LineDataMatrix.DateIll(x) = D;
            end
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        end
    end
end

%Load all Numerical arrays
LineDataMatrix.Sex = cell2mat(c(:,strcmp(VariableName, 'Sex')));
LineDataMatrix.Age = cell2mat(c(:,strcmp(VariableName, 'Age_at_diagnosis')));
LineDataMatrix.CD4CountAtDiagnosis = cell2mat(c(:,strcmp(VariableName, 'CD4_count')));
LineDataMatrix.Exp = cell2mat(c(:,strcmp(VariableName, 'Sub_population')));


%% %% Finding Data Start Date and Data End Date

%YearOfDiagnosedDataEnd = floor(max(x(:)));                                  %For data that doesn't go beyond last detected HIV case in data file
%BackProjectStartSingleYearAnalysis = 4 + floor(min(x(:)));                  %For data that doesn't go behind first detected HIV case in data file
%CD4BackProjectionYearsWhole = [BackProjectStartSingleYearAnalysis-19 YearOfDiagnosedDataEnd];

%% Sample all data according to input given by user

if SamplingFactor == 0.25 || SamplingFactor == 0.50 || SamplingFactor == 0.75
    y = randsample(length(c), ceil(SamplingFactor * length(c)));
    y = sort(y, 'descend');    
    
    c(y, :) = [];                                                         %Reshape vector c to Compressed State with randomnly selected indexes from Notification File
    
elseif SamplingFactor == 5000 || SamplingFactor == 10000
    w = randsample(length(c), SamplingFactor);
    w = sort(w, 'descend');
      
    for d = w
        z = c(d, :);
    end
        c = z;
else
    %Do Nothing
end

%% Determine the number of people in the data file
[NumberOfPatients, ~] = size(c);
NumberOfPatients = NumberOfPatients;
LineDataMatrix.NumberOfPatients = NumberOfPatients;
LocationDataMatrix.NumberOfPatients = NumberOfPatients;
disp('-Time to Rearrange Data into Matrices-');
toc(LoadTime)
disp('------------------------------------------------------------------');
end