%% This Script Loads all of the settings for simulation
%% The Number of Parameterisations used to generate uncertainity, Take input from user ideal value is 200
prompt = 'Please Enter Number of Parameterisations(Press Enter/Return for default): ';
result = input(prompt);

if isempty(result) == true
    result = 3 * (str2num(getenv( 'NUMBER_OF_PROCESSORS' )) - 1);
    disp('Using default value of: ');
    disp(result);
        
elseif ischar(result) == true
    result = 3 * (str2num(getenv( 'NUMBER_OF_PROCESSORS' )) - 1);
    disp('Invalid Entry! Using default value of: ');
    disp(result);
        
elseif result < (str2num(getenv( 'NUMBER_OF_PROCESSORS' )) - 1)
    result = str2num(getenv( 'NUMBER_OF_PROCESSORS' )) - 1;
    disp('Number of Parameterisations too low! Using a minimum value of:');
    disp(result);
else
    result = result;
end

Sx.NoParameterisations = result;
clear prompt;
clear result;

%% Request User whether to include Overseas Diagnosis or not
result = false;

while  result == false
    prompt = 'Analyse People Previously Diagnosed Overseas(Y/N)? - Press Enter/return key for default: '; 
    x = input(prompt, 's');
    
    if isempty(x) == true
        result = false;
        disp('Using default value of: No');
        disp(' ');
        break
        
    elseif x == 'N'
        result = false;
        break
    
    elseif x == 'Y'
        result = true;
        break
        
    elseif x == 'y'
        result = true;
        break
        
    elseif x == 'n'
        result = false;
        break
        
    else
        disp(' ');  
        disp('Invalid Entry! Please Enter a Valid Character');
    end
end

Sx.IncludePreviouslyDiagnosedOverseas = result;
clear prompt;
clear result;

%% Request User whether to Depulicate Records or Not
result = false;

while  result == false
    prompt = 'Deduplicate Records(Y/N)? - Press Enter/return key for default: '; 
    x = input(prompt, 's');
    
    if isempty(x) == true
        result = true;
        disp('Using default value of: Yes');
        disp(' ');
    elseif x == 'N'
        result = false;
        break
    
    elseif x == 'Y'
        result = true;
        break
        
    elseif x == 'y'
        result = true;
        break
        
    elseif x == 'n'
        result = false;
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

%% Simulation settings
%Max years is the maximum number of years a person can spend without being diagnosed with HIV. 
%Although longer times are possible in real life, so few would occur that we can successfully 
%ignore it in the name of simplicity and approximation
result = 20;

while  result == 20
    disp('');
    disp('Maximum Age is the maximum number of years a person  can spend without being diagnosed with HIV');
    disp('Range: 1 - 20 Years');
    prompt = 'Please Enter Maximum Age(Press Enter/Return for default): '; 
    x = input(prompt);
    
    if isempty(x) == true
        result = 20;
        disp('Using default value of: ');
        disp(result);
        break
        
    elseif x < 21
        if x > 0
            result = x;
            break
        else
            disp('Invalid Entry! Please Enter a Valid Number');
        end
   
    else
        disp('Invalid Entry! Please Enter a Valid Number');
    end
end

Sx.MaxYears = result;
clear prompt;
clear result;

%Declaring Step Size
Sx.StepSize = 0.1;
%% Recent Infection Consideration
result = false;

while  result == false
    prompt = 'Consider Recent Infections(Y/N)? - Press Enter/return key for default: '; 
    x = input(prompt, 's');
    
    if isempty(x) == true
        result = true;
        disp('Using default value of: Yes');
    elseif x == 'N'
        result = false;
        break
    
    elseif x == 'Y'
        result = true;
        break
        
    elseif x == 'y'
        result = true;
        break
        
    elseif x == 'n'
        result = false;
        break
        
    else
        disp('Invalid Entry! Please Enter a Valid Character');
    end
end

Sx.ConsiderRecentInfection = result;
clear prompt;
clear result;

%% Load the patient data into a large matrix
result = 0.5;

while  result == 0.5
    disp(' ');
    disp('Sampling factor is data compression to improve simulation time, 0.0 is no compression 0.9 is 90% compression');
    disp('Range: 0.0 - 0.9');
    prompt = 'Please Sampling Factor(Press Enter/Return for default): '; 
    x = input(prompt);
    
    if isempty(x) == true
        result = 0.5;
        disp('Using default value of: ');
        disp(result);
        disp(' ');
        break
        
    elseif x <= 0.9 
        if x >= 0.0
            result = x;
            break
        else
            disp(' ');  
            disp('Invalid Entry! Please Enter a Valid Number');
        end
   
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

HIVFile = 'Imputation\Data\notifications2014imputationformatted.xls';
SheetName='Dataset_1';

pause(0.5);
clc;
%open file format, return separately the postcodes and other subsections of the data 
[LineDataMatrix, LocationDataMatrix, YearOfDiagnosedDataEnd, BackProjectStartSingleYearAnalysis, CD4BackProjectionYearsWhole] = LoadNotificationFile(HIVFile, SheetName, Sx.SamplingFactor);

disp(' ');
disp('-Total Data File Load Time-');
toc(LoadTime)
disp('------------------------------------------------------------------');

%% Program Settings - Geographic Considerations first two variables to be set as false if not required
RunID='BackProject';
Sx.PerformGeographicCalculations = false;                                        %do movement calculations and break up according to location
Sx.InitialisePCToSRThisSim = false;                                              %re-perform this function. Only relevant if geographic calculations take place
Sx.UseGeneticAlgorithmOptimisation = true;

RangeOfCD4Averages = [(YearOfDiagnosedDataEnd-5+1) (YearOfDiagnosedDataEnd+1)];       %YearOfDiagnosedDataEnd not inclusive
RangeOfCD4AveragesForForwardProjection = [(YearOfDiagnosedDataEnd-5+1) (YearOfDiagnosedDataEnd+1)];
%% Optimisation Settings & Plot Settings
Sx.HistogramCentres = 25:50:4975;
PlotSettings.ListOfCD4sToPlot=[200 350 500];
PlotSettings.YearsToPlot=[1970 CD4BackProjectionYearsWhole(2)];
PlotSettings.YearsToPlotForCD4AtDiagnosis=[1985 CD4BackProjectionYearsWhole(2)];


