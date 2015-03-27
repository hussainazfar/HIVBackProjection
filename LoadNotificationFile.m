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
LineDataMatrix.Sex = NaN(1, NumberOfPatients);
LineDataMatrix.Age = NaN(1, NumberOfPatients);
LineDataMatrix.CD4CountAtDiagnosis = NaN(1, NumberOfPatients);
LineDataMatrix.Exp = NaN(1, NumberOfPatients);

%Determine time of diagnosis
y = find(strcmp(VariableName, 'Date_of_HIV_diagnosis'));
%if strcmp(Sx.DateFormat, 'dd/mm/yyyy') == 1
%    S1 = c(:, y);
%    D = datenum(S1, 'dd/mm/yyyy');
%    S2 = datestr(D, 'dd/mm/yyyy');
%    LineDataMatrix.DateOfDiagnosis = S2;
%else
    LineDataMatrix.DateOfDiagnosis = c(:, y);
%end 

LineDataMatrix.YearOfDiagnosis = year(datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy'));
LineDataMatrix.DateOfDiagnosisContinuous = LineDataMatrix.YearOfDiagnosis + (datenum(LineDataMatrix.DateOfDiagnosis, 'dd/mm/yyyy') - datenum(LineDataMatrix.YearOfDiagnosis, 1,1)) ./ yeardays(LineDataMatrix.YearOfDiagnosis);

%Determine Last Negative HIV Test
y = find(strcmp(VariableName, 'Date_last_tested_HIV_negative'));
for x = 1:NumberOfPatients
    DateText = c(x, y); 
        if (strcmp(DateText, '') == 1) || (sum(isnan(cell2mat(DateText))) > 0)
            % do nothing
%        elseif strcmp(Sx.DateFormat, 'dd/mm/yyyy')
%            Year = year(datenum(DateText, 'dd/mm/yyyy'));
%            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
%            LineDataMatrix.DateLastNegative(x) = Year + DaysSinceYear ./ yeardays(Year);
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
        if (strcmp(DateText, '') == 1) || (sum(isnan(cell2mat(DateText))) > 0)
            % do nothing
%        elseif strcmp(Sx.DateFormat, 'dd/mm/yyyy')
%            Year = year(datenum(DateText, 'dd/mm/yyyy'));
%            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
%            LineDataMatrix.DateIll(x) = Year + DaysSinceYear ./ yeardays(Year);
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
        if (strcmp(DateText, '') == 1) || (sum(isnan(cell2mat(DateText))) > 0)
            % do nothing
%        elseif strcmp(Sx.DateFormat, 'dd/mm/yyyy')
%            Year = year(datenum(DateText, 'dd/mm/yyyy'));
%            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
%            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            Year = year(datenum(DateText, 'dd/mm/yyyy'));
            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        end 
end

%Load Numerical Array Sex
y = find(strcmp(VariableName, 'Sex'));
for x = 1:NumberOfPatients
    DateText = c(x, y);
        if (strcmp(DateText, '') == 1) || (sum(isnan(cell2mat(DateText))) > 0)
            % do nothing
%        elseif strcmp(Sx.DateFormat, 'dd/mm/yyyy')
%            Year = year(datenum(DateText, 'dd/mm/yyyy'));
%            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
%            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            LineDataMatrix.Sex(x) = cell2mat(DateText);
        end 
end

%Load Numerical Array Age
y = find(strcmp(VariableName, 'Age_at_diagnosis'));
for x = 1:NumberOfPatients
    DateText = c(x, y);
        if (strcmp(DateText, '') == 1) || (sum(isnan(cell2mat(DateText))) > 0)
            % do nothing
%        elseif strcmp(Sx.DateFormat, 'dd/mm/yyyy')
%            Year = year(datenum(DateText, 'dd/mm/yyyy'));
%            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
%            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            LineDataMatrix.Age(x) = cell2mat(DateText);
        end 
end

% Load Numerical Array CD4 Count
y = find(strcmp(VariableName, 'CD4_count'));
for x = 1:NumberOfPatients
    DateText = c(x, y);
        if (strcmp(DateText, '') == 1) || (sum(isnan(cell2mat(DateText))) > 0)
            % do nothing
%        elseif strcmp(Sx.DateFormat, 'dd/mm/yyyy')
%            Year = year(datenum(DateText, 'dd/mm/yyyy'));
%            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
%            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            LineDataMatrix.CD4CountAtDiagnosis(x) = cell2mat(DateText);
        end 
end

%Load Numerical Array Sub-Population
y = find(strcmp(VariableName, 'Sub_population'));
for x = 1:NumberOfPatients
    DateText = c(x, y);
        if (strcmp(DateText, '') == 1) || (sum(isnan(cell2mat(DateText))) > 0)
            % do nothing
%        elseif strcmp(Sx.DateFormat, 'dd/mm/yyyy')
%            Year = year(datenum(DateText, 'dd/mm/yyyy'));
%            DaysSinceYear = datenum(DateText, 'dd/mm/yyyy')-datenum(Year, 1,1);
%            LineDataMatrix.DateIndetWesternBlot(x) = Year + DaysSinceYear ./ yeardays(Year);
        else
            LineDataMatrix.Exp(x) = cell2mat(DateText);
        end 
end

%% Impute Missing fields
if sum(isnan(LineDataMatrix.Age)) < (0.75*NumberOfPatients)
    [ LineDataMatrix.Age ] = ImputeMissingAgeData( LineDataMatrix.DateOfDiagnosisContinuous, LineDataMatrix.Age );
    [ LineDataMatrix.CD4CountAtDiagnosis ] = ImputeMissingCD4Data( LineDataMatrix.DateOfDiagnosisContinuous, LineDataMatrix.Age, LineDataMatrix.CD4CountAtDiagnosis );
else
    disp('The number of Patients with available Age data is too low! Imputing CD4 Count based on Date of HIV Diagnosis...');
    [ LineDataMatrix.CD4CountAtDiagnosis ] = ImputeAbsentCD4Data( LineDataMatrix.CD4CountAtDiagnosis);
end

%% Check to see if Exposure Code Filter is used
if Sx.ExpCode > 0
    Sx.ExpCodeTest = LineDataMatrix.Exp;
    x = find(Sx.ExpCodeTest == Sx.ExpCode);
    if isempty(x) == 1
        disp(' ');
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
CD4BackProjectionYearsWhole = [min(LineDataMatrix.YearOfDiagnosis(:))-19 YearOfDiagnosedDataEnd];

Temp_Matrix = unique(LineDataMatrix.YearOfDiagnosis);                       %read in and record unique Years that exist

x = zeros(1,length(Temp_Matrix));                                           %This array will contain count of data against each year recorded in Data File

%parse Year of Diagnosis, count and record how many records exist in Year y
for y = 1:length(Temp_Matrix)                                               
    x(y) = length(find(LineDataMatrix.YearOfDiagnosis == Temp_Matrix(y)));
end

%parse Year of Diagnosis, and check if there are discontinuities, e.g.
%1997, 1999 have a gap, remove all such gaps until array is continuous,
%adjust values in corresponding coutn vector as well
z = 1;
for y = 1:(length(Temp_Matrix)-1)
    if (Temp_Matrix(z) == Temp_Matrix(z+1) - 1)
        z = z + 1;
    else
        Temp_Matrix = Temp_Matrix(2:length(Temp_Matrix));
        z = 1;
    end
end
y = 1 + length(x) - length(Temp_Matrix);
x = x(y:length(x));


%readjust te arrays so that beginning year has a minimum of 10 CD4 values
y = find(x < 10);

if sum(y) > 0
    x = x((1+max(y)):length(x));
    y = 1 + length(Temp_Matrix) - length(x);
    Temp_Matrix = Temp_Matrix(y:length(Temp_Matrix));
end

BackProjectStartSingleYearAnalysis = min(Temp_Matrix);    %For data that doesn't go behind first detected HIV case in data file

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