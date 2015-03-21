%% This Script Loads all of the settings for simulation
%% The Number of Parameterisations used to generate uncertainity, Take input from user ideal value is 200
prompt = 'Please Enter Number of Simulations to run: ';
result = input(prompt);

if isempty(result) == true
    result = 2 * (str2num(getenv( 'NUMBER_OF_PROCESSORS' )));
    fprintf(1, 'Using default value of: %d\n', result);
        
elseif ischar(result) == true
    result = 2 * (str2num(getenv( 'NUMBER_OF_PROCESSORS' )));
    fprintf(1,'Invalid Entry! Using default value of: %d\n', result);
        
elseif result < (str2num(getenv( 'NUMBER_OF_PROCESSORS' )))
    result = str2num(getenv( 'NUMBER_OF_PROCESSORS' ));
    %fprintf(1, 'Number of Parameterisations too low! Using a minimum value of: %d', result);
else
    result = result;
end

Sx.NoParameterisations = result;
clear prompt;
clear result;

%% Request User whether to Depulicate Records or Not
result = false;

while  result == false
    disp(' ');
    prompt = 'Are you expecting Duplication in Data(Y/N)? '; 
    x = input(prompt, 's');
    
    if isempty(x) == true
        result = true;
        disp('Using default value of: Yes');
        disp(' ');
    
    elseif x == 'N' || 'n'
        result = false;
        break
    
    elseif x == 'Y' || 'y'
        result = true;
        break
        
    else
        disp(' ');  
        disp('Invalid Entry! Please Enter a Valid Character');
    end
end

Sx.DeduplicateDiagnoses = result;
clear prompt;
clear result;

%% Setup Random Variable Stream
RandomNumberStream = RandStream('mlfg6331_64','Seed',1385646);
RandStream.setGlobalStream(RandomNumberStream);
%Use the below code in any parfor loop to use appropriate substreams for the rand generator (i is the loop number)
%set(stream,'Substream',i);

%% Recent Infection Consideration
result = false;

while  result == false
    prompt = 'Consider Recent Infections(Y/N)? '; 
    x = input(prompt, 's');
    
    if isempty(x) == true
        result = true;
        disp('Using default value of: Yes');
    
    elseif x == 'N' || 'n'
        result = false;
        break
    
    elseif x == 'Y' || 'y'
        result = true;
        break
        
    else
        disp('Invalid Entry! Please Enter a Valid Character');
    end
end

Sx.ConsiderRecentInfection = result;
clear prompt;
clear result;
%% Input Date Settings
result = 10;
while result ~= 1 || result ~= 2
    disp(' ');
    disp('Please enter the date format in file:');
    disp('1. dd/mm/yyyy  - Default Format');
    disp('2. mm/dd/yyyy');
    prompt = 'Please Enter Selection(Press Enter/Return for default): '; 
    x = input(prompt);
    
    if isempty(x) == true
        result = 'dd/mm/yyyy';
        fprintf(1, 'Using default value of: %s\n', result);
        break
        
    elseif x == 1
        result = 'dd/mm/yyyy';
        break
        
    elseif x == 2
        result = 'mm/dd/yyyy';
        break
   
    else
        disp('Invalid Entry! Please Enter a Valid Number');
    end
end
Sx.DateFormat = result;
clear prompt;
clear result;
%% Load the patient data into a large matrix
result = 0.5;

while  result == 0.5
    disp(' ');
    disp('Sampling factor is data compression to improve simulation time, please indicate how may records to process');
    disp('1. 5000 - Take a Random Sample of 5000 Records');
    disp('2. 10000 - Take a Random Sample of 10000 Records');
    disp('3. Use 100% of Data File');
    disp('4. Use 75% of Data File');
    disp('5. Use 50% of Data File');
    disp('6. Use 25% of Data File');
    prompt = 'Please Enter Sampling Factor: '; 
    x = input(prompt);
    
    if isempty(x) == true
        result = 0.75;
        disp('Using default value of: 25%');
        break
             
    elseif x == 1 
        result = 5000;
        break
        
    elseif x == 2
        result = 10000;
        break
        
    elseif x == 3
        result = 1;
        break
        
    elseif x == 4
        result = 0.25;
        break
        
    elseif x == 5
        result = 0.50;
        break
        
    elseif x == 6
        result = 0.75;
        break
    else
        disp(' ');  
        disp('Invalid Entry! Please Enter a Valid Number');
    end
end

Sx.SamplingFactor = result;
clear prompt;
clear result;

LoadTime = tic;
ParameterLocalStorageLocation = 'Parameters/';

HIVFile = 'Imputation\Data\Data.xls';
SheetName='Dataset_1';

pause(0.5);
clc;
%open file format, return separately the postcodes and other subsections of the data 
[LineDataMatrix, LocationDataMatrix, YearOfDiagnosedDataEnd, BackProjectStartSingleYearAnalysis, CD4BackProjectionYearsWhole] = LoadNotificationFile(HIVFile, SheetName, Sx.SamplingFactor, Sx.DateFormat);

disp(' ');
disp('-Total Data File Load Time-');
toc(LoadTime)
disp('------------------------------------------------------------------');

%% Program Settings - Geographic Considerations first two variables to be set as false if not required
RunID='BackProject';
Sx.MaxYears = 20;                                                           %Max years is the maximum number of years a person can spend without being diagnosed with HIV. 
Sx.StepSize = 0.1;                                                          %Declaring Step Size

Sx.PerformGeographicCalculations = false;                                        %do movement calculations and break up according to location
Sx.InitialisePCToSRThisSim = false;                                              %re-perform this function. Only relevant if geographic calculations take place
Sx.UseGeneticAlgorithmOptimisation = true;

RangeOfCD4Averages = [(YearOfDiagnosedDataEnd-5+1) (YearOfDiagnosedDataEnd+1)];              
RangeOfCD4AveragesForForwardProjection = [(YearOfDiagnosedDataEnd-5+1) (YearOfDiagnosedDataEnd+1)];
%% Optimisation Settings & Plot Settings
Sx.HistogramCentres = 25:50:4975;
PlotSettings.ListOfCD4sToPlot=[200 350 500];
PlotSettings.YearsToPlot=[1970 CD4BackProjectionYearsWhole(2)];
PlotSettings.YearsToPlotForCD4AtDiagnosis=[1985 CD4BackProjectionYearsWhole(2)];


