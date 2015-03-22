function [LineDataMatrix, YearOfDiagnosedDataEnd, BackProjectStartSingleYearAnalysis, CD4BackProjectionYearsWhole Sx] = LoadNotificationFile(HIVFile, SheetName, Sx)
%% Read data from the notifications file

LoadTime = tic;
disp('Loading Excel Notification Data File');
[~, ~, c] = xlsread(HIVFile,  SheetName);

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
LineDataMatrix.DateLastNegative = NaN(1, NumberOfPatients);
LineDataMatrix.DateIll = NaN(1, NumberOfPatients);
LineDataMatrix.DateIndetWesternBlot = NaN(1, NumberOfPatients);
LineDataMatrix.DateOfDiagnosis = NaN(1, NumberOfPatients);

%Determine time of diagnosis
y = find(strcmp(VariableName, 'Date_of_HIV_diagnosis'));
if strcmp(Sx.DateFormat, 'mm/dd/yyyy') == 1
    S1 = c(:, y);
    D = datenum(S1, 'mm/dd/yyyy');
    S2 = datestr(D, 'dd/mm/yyyy');
    LineDataMatrix.DateOfDiagnosis = S2;
else
    LineDataMatrix.DateOfDiagnosis = c(:, y);
end 

LineDataMatrix.YearOfDiagnosis = year(datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy'));
LineDataMatrix.DateOfDiagnosisContinuous = LineDataMatrix.YearOfDiagnosis + (datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy') - datenum(LineDataMatrix.YearOfDiagnosis, 1,1)) ./ yeardays(LineDataMatrix.YearOfDiagnosis);

%Determine Last Negative HIV Test
y = find(strcmp(VariableName, 'Date_last_tested_HIV_negative'));
for x = 1:NumberOfPatients
    DateText = c(x, y);
        if strcmp(DateText, '')
            % do nothing
        elseif strcmp(Sx.DateFormat, 'mm/dd/yyyy')
            Year = year(datenum(DateText, 'mm/dd/yyyy'));
            DaysSinceYear = datenum(DateText, 'mm/dd/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateLastNegative(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateLastNegative(x) = Year + DaysSinceYear ./ yeardays(Year);
        end 
end
    
%Determine Seroconversion Symptoms appearance date
y = find(strcmp(VariableName, 'Seroconversion_illness_at_HIV_diagnosis'));
for x = 1:NumberOfPatients
    DateText = c(x, y);
        if strcmp(DateText, '')
            % do nothing
        elseif strcmp(Sx.DateFormat, 'mm/dd/yyyy')
            Year = year(datenum(DateText, 'mm/dd/yyyy'));
            DaysSinceYear = datenum(DateText, 'mm/dd/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIll(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIll(x) = Year + DaysSinceYear ./ yeardays(Year);
        end 
end

%Determine Indeterminate Western Blot Test Date
y = find(strcmp(VariableName, 'Indeterminate_western_blot_at_HIV_diagnosis'));
for x = 1:NumberOfPatients
    DateText = c(x, y);
        if strcmp(DateText, '')
            % do nothing
        elseif strcmp(Sx.DateFormat, 'mm/dd/yyyy')
            Year = year(datenum(DateText, 'mm/dd/yyyy'));
            DaysSinceYear = datenum(DateText, 'mm/dd/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        end 
end

%Load all Numerical arrays
LineDataMatrix.Sex = cell2mat(c(:,strcmp(VariableName, 'Sex')));
LineDataMatrix.Age = cell2mat(c(:,strcmp(VariableName, 'Age_at_diagnosis')));
LineDataMatrix.CD4CountAtDiagnosis = cell2mat(c(:,strcmp(VariableName, 'CD4_count')));
LineDataMatrix.Exp = cell2mat(c(:,strcmp(VariableName, 'Sub_population')));
%% Impute Missing fields
[ LineDataMatrix.Age ] = ImputeMissingAgeData( LineDataMatrix.DateOfDiagnosisContinuous, LineDataMatrix.Age );
[ LineDataMatrix.CD4CountAtDiagnosis ] = ImputeMissingCD4Data( LineDataMatrix.DateOfDiagnosisContinuous, LineDataMatrix.Age, LineDataMatrix.CD4CountAtDiagnosis );

%% Check to see if Exposure Code Filter is used
if Sx.ExpCode > 0
    Sx.ExpCodeTest = LineDataMatrix.Exp;
    x = find(Sx.ExpCodeTest == Sx.ExpCode);
    if isempty(x) == 1
        disp('No Exposure Code Found as Entered! Using all available Data');
        disp(' ');
    else
        LineDataMatrix.DateOfDiagnosis = LineDataMatrix.DateOfDiagnosis(x, :);
        LineDataMatrix.YearOfDiagnosis = LineDataMatrix.YearOfDiagnosis(x);
        LineDataMatrix.DateOfDiagnosisContinuous = LineDataMatrix.DateOfDiagnosisContinuous(x);
    
        LineDataMatrix.DateLastNegative = LineDataMatrix.DateLastNegative(x);
        LineDataMatrix.DateIll = LineDataMatrix.DateIll(x);
        LineDataMatrix.DateIndetWesternBlot = LineDataMatrix.DateIndetWesternBlot(x);
    
        LineDataMatrix.Sex = LineDataMatrix.Sex(x);
        LineDataMatrix.Age = LineDataMatrix.Age(x);
        LineDataMatrix.CD4CountAtDiagnosis = LineDataMatrix.CD4CountAtDiagnosis(x);
        LineDataMatrix.Exp = LineDataMatrix.Exp(x);
    end
end

%% Sample all data according to input given by user
NumberOfPatients = length(LineDataMatrix.DateOfDiagnosis);
if Sx.SamplingFactor == 0.25 || Sx.SamplingFactor == 0.50 || Sx.SamplingFactor == 0.75
    y = randsample(NumberOfPatients, ceil(Sx.SamplingFactor * NumberOfPatients));
    y = sort(y, 'descend');    
    
    %Reshape vectors to Compressed State with randomnly selected indexes from Notification File
    LineDataMatrix.DateOfDiagnosis(y, :) = [];
    LineDataMatrix.YearOfDiagnosis(y) = [];
    LineDataMatrix.DateOfDiagnosisContinuous(y) = [];
    
    LineDataMatrix.DateLastNegative(y) = [];
    LineDataMatrix.DateIll(y) = [];
    LineDataMatrix.DateIndetWesternBlot(y) = [];
    
    LineDataMatrix.Sex(y) = [];
    LineDataMatrix.Age(y) = [];
    LineDataMatrix.CD4CountAtDiagnosis(y) = [];
    LineDataMatrix.Exp(y) = [];
    
elseif Sx.SamplingFactor == 5000 || Sx.SamplingFactor == 10000
    y = randsample(NumberOfPatients, NumberOfPatients - Sx.SamplingFactor);
    if (Sx.SamplingFactor == 5000 && NumberOfPatients < 5000)
        disp('Length of records is less than 5000, using all available records!');
    elseif (Sx.SamplingFactor == 10000 && NumberOfPatients < 10000)
        disp('Length of records is less than 10000, using all available records!');
    else
        LineDataMatrix.DateOfDiagnosis(y, :) = [];
        LineDataMatrix.YearOfDiagnosis(y) = [];
        LineDataMatrix.DateOfDiagnosisContinuous(y) = [];
    
        LineDataMatrix.DateLastNegative(y) = [];
        LineDataMatrix.DateIll(y) = [];
        LineDataMatrix.DateIndetWesternBlot(y) = [];
    
        LineDataMatrix.Sex(y) = [];
        LineDataMatrix.Age(y) = [];
        LineDataMatrix.CD4CountAtDiagnosis(y) = [];
        LineDataMatrix.Exp(y) = [];    
    end
else
    %Do Nothing
end

%% Finding Data Start Date and Data End Date
YearOfDiagnosedDataEnd = max(LineDataMatrix.YearOfDiagnosis(:));                    %For data that doesn't go beyond last detected HIV case in data file
BackProjectStartSingleYearAnalysis = 4 + min(LineDataMatrix.YearOfDiagnosis(:));    %For data that doesn't go behind first detected HIV case in data file
CD4BackProjectionYearsWhole = [BackProjectStartSingleYearAnalysis-19 YearOfDiagnosedDataEnd];

if (Sx.UpperFirstInfectionDate >= min(LineDataMatrix.YearOfDiagnosis(:)))
    Sx.UpperFirstInfectionDate = min(LineDataMatrix.YearOfDiagnosis(:)) - 1;
end
if (Sx.LowerFirstInfectionDate >= Sx.UpperFirstInfectionDate)
    Sx.LowerFirstInfectionDate = Sx.UpperFirstInfectionDate - 20;
end

%% Determine the number of people in the data file
NumberOfPatients = length(LineDataMatrix.YearOfDiagnosis);
LineDataMatrix.NumberOfPatients = NumberOfPatients;
disp('-Time to Rearrange Data into Matrices-');
toc(LoadTime)
disp('------------------------------------------------------------------');
end