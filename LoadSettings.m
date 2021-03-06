%% This Script Loads all of the settings for simulation
%% The Number of Parameterisations used to generate uncertainity, Take input from user ideal value is 200
disp('------------------------------------------------------------------');
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
    result = round(result);
end

Sx.NoParameterisations = result;
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
    disp(' ');
    disp('------------------------------------------------------------------');
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
%result = 10;
%while result ~= 1 || result ~= 2
%    disp(' ');
%    disp('------------------------------------------------------------------');
%    disp('Please enter the date format in file:');
%    disp('1. dd/mm/yyyy  - Default Format');
%    disp('2. mm/dd/yyyy');
%    prompt = 'Please Enter Selection(Press Enter/Return for default): '; 
%    x = input(prompt);
%    
%    if isempty(x) == true
%        result = 'dd/mm/yyyy';
%        fprintf(1, 'Using default value of: %s\n', result);
%        break
%        
%    elseif x == 1
%        result = 'dd/mm/yyyy';
%        break
%        
%    elseif x == 2
%        result = 'mm/dd/yyyy';
%        break
%   
%    else
%        disp('Invalid Entry! Please Enter a Valid Number');
%    end
%end
%Sx.DateFormat = result;
%clear prompt;
%clear result;
%% Load the patient data into a large matrix
result = 0.5;

while  result == 0.5
    disp(' ');
    disp('------------------------------------------------------------------');
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
        result = 5000;
        disp('Using default value of: 5000');
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

%% Whether to filter data using Sub-Population Code
result = false;

while  result == false
    disp(' ');
    disp('------------------------------------------------------------------');
    disp('Sub-Population Codes from the Data File can be used to filter data to be used for simulation');
    prompt = 'Would you like to use Sub-Population Codes(Y/N): '; 
    x = input(prompt, 's');
    
    if isempty(x) == true
        result = false;
        disp('No filters used for this simulation');
        break
             
    elseif x == 'N' || x == 'n'
        result = false;
        break
        
    elseif x == 'Y' || x == 'y'
        result = true;
        break
        
    else
        disp(' ');  
        disp('Invalid Entry! Please Enter a Valid Number');
    end
end
clear x;
clear prompt;

y = 0;

while result == true
        prompt = 'Please Enter Sub-Population Code for Filteration (Press Enter if you want to cancel): ';
        x = input(prompt);
    
        if isempty(x) == true
            y = 0;
            break;
        
        elseif x == 0
            disp('Error: 0 is not a valid Sub-Population Code!')
        else
            y = x;
            break;
        end
        
end

Sx.ExpCode = y;
clear prompt;
clear result;
clear y;
%% Backprojection Date 
result = 1970;

while  result == 1970
    disp(' ');
    disp('------------------------------------------------------------------');
    disp('To create a valid Back Projection, the simulation requires approximate year the first HIV case may have occured');
    
    prompt = 'Please enter Upper Value of First Possible Infection (e.g. 1975): '; 
    x = input(prompt);
    if isempty(x)
        x = 1980;
    end
    
    prompt = 'Please enter Lower Value of First Possible Infection, should be less than Upper Range (e.g. 1970): '; 
    y = input(prompt);
    if isempty(y)
        y = 1975;
    end
    
    result = 1971;
    
    if (x < y)
        disp('Upper Value of First Possible Infection should be more than Lower Value');
        result = 1970;
    end
    
end

Sx.UpperFirstInfectionDate = x;
Sx.LowerFirstInfectionDate = y;
clear prompt;
clear result;

%% Manually set Distribution to be used for Back Projection Settings
result = 0;

while  result == 0
    disp(' ');
    disp('------------------------------------------------------------------');
    disp('The Backprojection Settings use the Median CD4 Counts for Healthy Individuals to estimate HIV Infections');
    disp('1. Default Settings - This Program Uses Results from multiple studies to calculate Median CD4 Counts');
    disp('2. Manually Define Log-Normal Distribution');
    prompt = 'Please Enter Selection: '; 
    x = input(prompt);
    
    if isempty(x) == true
        result = 1;
        disp('Using default settings');
        break
             
    elseif x == 1 
        result = x;
        break
        
    elseif x == 2
        disp(' ');
        prompt = 'Please Enter Mean Value for Log-Normal Distribution(max is 6.792): ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionMean = 6.792;
        else
            Sx.DistributionMean = y;
        end
        
        prompt = 'Please Enter Standard Deviation for Log-Normal Distribution: ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionSD = 0.3381;
        else
            Sx.DistributionSD = y;
        end
        
        clc;
        
        disp('     (1)');
        disp('     |\');
        disp('     | \        (3)');
        disp('     |  \       __ ');
        disp('     |   \     /  \');
        disp(' CD4 |    \   /    \  ');
        disp('     |     \_/      \(4)   ');
        disp('     |      (2)      \      ');
        disp('     |                \             ');
        disp('     |                 \               ');
        disp('     |____________________________ time');
        
        
        fprintf(1, '\n\nRefer to the figure above (Please Press Enter/Return Key if you are unsure about any value to load a default value from Database:\n');
        disp('This section refers to area marked as (2)');
        prompt = 'Please Enter Trough Value(i.e. the fall in CD4 count immediately after Infection): ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionFractionalDeclineToTrough = 418;
        else
            Sx.DistributionFractionalDeclineToTrough = y;
        end
            
        disp(' ');
        disp('This section refers to area marked as (3)');      
        prompt = 'Baseline CD4 Count Mean(i.e. after rebound): ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionBaselineCD4Median = 636;
        else
            Sx.DistributionBaselineCD4Median = y;
        end
        
        prompt = 'Baseline CD4 Standard Deviation(i.e. after rebound): ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionBaselineCD4Stdev = 25.5102;
        else
            Sx.DistributionBaselineCD4Stdev = y;
        end
        
        disp(' ');
        disp('This section refers to area marked as (4)');
        prompt = 'Please Indicate the CD4 Decline Rate: ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionMeanCD4Decline = 60.3646;
        else
            Sx.DistributionMeanCD4Decline = y;
        end
        
        prompt = 'Please Indicate the CD4 Decline Standard Deviation: ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionSDCD4Decline = 6.0885;
        else
            Sx.DistributionSDCD4Decline = y;
        end
        
        prompt = 'Please Indicate the Mean Square Root Annual Decline Rate: ';
        y = input(prompt);
        
        if isempty(y)
            Sx.DistributionMeanSquareRootAnnualDecline = 1.6;
        else
            Sx.DistributionMeanSquareRootAnnualDecline = y;
        end
        
        prompt = 'Please Indicate the Mean Square Root Annual Decline Standard Deviation: ';
        y = input(prompt);
        
        if isempty(y)
            Sx.SquareRootAnnualDeclineStdev = 0.1020;
        else
            Sx.SquareRootAnnualDeclineStdev = y;
        end
        
        if (Sx.DistributionMean > 0 && Sx.DistributionMean <= 6.792 && Sx.DistributionFractionalDeclineToTrough < exp(Sx.DistributionMean) && Sx.DistributionBaselineCD4Median > Sx.DistributionFractionalDeclineToTrough && Sx.DistributionBaselineCD4Median < exp(Sx.DistributionMean))
            result = x;     
        else
            disp('Invalid Entry, Please enter correct data!');
            result = 0;
        end
       
    else
        disp(' ');  
        disp('Invalid Entry! Please Enter a Valid Number');
    end
end

Sx.Distribution = result;
clear prompt;
clear result;

%% Load the patient data into a large matrix
LoadTime = tic;
ParameterLocalStorageLocation = 'Parameters/';

HIVFile = 'Imputation\Data\Data.xls';
SheetName = 'Dataset_1';

pause(0.5);
clc;
%open file format, return separately the postcodes and other subsections of the data 
[LineDataMatrix, YearOfDiagnosedDataEnd, BackProjectStartSingleYearAnalysis, CD4BackProjectionYearsWhole, Sx] = LoadNotificationFile(HIVFile, SheetName, Sx);

disp(' ');
disp('-Total Data File Load Time-');
toc(LoadTime)
disp('------------------------------------------------------------------');

%% Program Settings - Geographic Considerations first two variables to be set as false if not required
RunID='BackProject';
Sx.MaxYears = 20;                                                           %Max years is the maximum number of years a person can spend without being diagnosed with HIV. 
Sx.StepSize = 0.1;                                                          %Declaring Step Size

RangeOfCD4Averages = [(YearOfDiagnosedDataEnd-5+1) (YearOfDiagnosedDataEnd+1)];              
RangeOfCD4AveragesForForwardProjection = [(YearOfDiagnosedDataEnd-5+1) (YearOfDiagnosedDataEnd+1)];
%% Optimisation Settings & Plot Settings
Sx.HistogramCentres = 25:50:4975;
PlotSettings.ListOfCD4sToPlot=[200 350 500];
PlotSettings.YearsToPlot=[1970 CD4BackProjectionYearsWhole(2)];
PlotSettings.YearsToPlotForCD4AtDiagnosis=[1985 CD4BackProjectionYearsWhole(2)];


