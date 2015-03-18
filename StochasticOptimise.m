function [OptimisedParameters, OptimisedParametersVector, OptimisationDetails]=StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, ExpectedOutput, OptimisationSettings)
% The output of this function are a group of parameter sets which
% distributed based on their probability of beating the best estimate

% This function assumes that the shape of the error function indicates the
% general location of the best selection for the unknown variables.
% FunctionPointer: FunctionPointer = @functionname

% FunctionInput Other information passed to the function 

% ParameterBounds - a matrix with a maximum and a minimum for each parameter

% OptimisationSettings: This determines the methods that are used by the simulation, such as the error function. 
    % OptimisationSettings.MaxTime - stops after MaxTime seconds
    % OptimisationSettings.Parallel - not yet implemented
    % OptimisationSettings.ErrorFunction - a custom error function that can be used to determine the 
    % OptimisationSettings.OutputPlotFunction - used to plot the optimised parameters
    % OptimisationSettings.PlotParameters - (true or false) 
    % OptimisationSettings.SamplesPerRound - used to determine the points per dimension
    % OptimisationSettings.DisplayTimer - used to show the timer at each step
    
% ExpectedOutput - the values to compare against to check for the error

OptimisationTimer=tic;

%% Import all OptimisationSettings that exist
try
    MaxTime=OptimisationSettings.MaxTime;                                   % in seconds, time until the optimisation stops on its own
    TimeOut=true;
catch
    MaxTime=-1;
    TimeOut=false;
end

try
    ErrorFunction=OptimisationSettings.ErrorFunction; % if someone has set the error function error function should be of the form ErrorFunction(ThisOutput, ExpectedOutput)
    CustomErrorFunction=true;
catch
    CustomErrorFunction=false;                                              % use simple additive error over the vector
end

try
    OutputPlotFunction=OptimisationSettings.OutputPlotFunction; 
    PlotOutput=true;
catch
    PlotOutput=false; 
end

try
    PlotParameters=OptimisationSettings.PlotParameters; 
catch
    PlotParameters=false; 
end

try
    DisplayTimer=OptimisationSettings.DisplayTimer; 
catch
    DisplayTimer=false; 
end

%% Optimisation parameters
[NumberOfDimensions, ~] = size(ParameterBounds);

BaselineSamplesPerRound = 4^NumberOfDimensions;% this is the baseline value of this 
try
    SamplesPerRound = OptimisationSettings.SamplesPerRound; 
    if SamplesPerRound < BaselineSamplesPerRound
        warning('The number of SamplesPerRounds is set too low. It is recommended that there is at least four samples per parameter optimised. e.g. a 2D optimisation would require 4*4=16 samples per round');
    end
catch
    SamplesPerRound = BaselineSamplesPerRound;
end

try
    NumberOfRounds = OptimisationSettings.NumberOfRounds; 
    
catch
    NumberOfRounds = 10;
end
FractionToKeep = 0.6666^NumberOfDimensions;                                 %This is to ensure that just over half of the range in each dimension is kept per round, to ensure that the solution converges quickly
NumberToKeep = floor(SamplesPerRound * FractionToKeep);
PointsPerDimension = NumberToKeep^(1 / NumberOfDimensions);                 %used later on to determine the mean distance between points in each dimension


%Sims per round
% Choose random values between the bounds
    % 4 per dimension
    
    % choose the best 50%
    % find the range between the max and min of each dimension
    % the variable distance around each point is range/4*2
    % Choose 2 new points per existing point, randomly spaced


%% Find the position of the very best point
% Create initial unknown parameter sampling
for i = 1:NumberOfDimensions
    ParameterEstimates(:,i) = (ParameterBounds(i, 2) - ParameterBounds(i, 1)) .* rand(1, SamplesPerRound) + ParameterBounds(i, 1);
end

MeanDistanceBetweenPoints = zeros(1, NumberOfDimensions);
ErrorVector = zeros(1, SamplesPerRound);

RoundCount = 0;
while (RoundCount<NumberOfRounds)  && (TimeOut==false || toc(OptimisationTimer) < MaxTime) % && (the standard deviation hasn't changed all that much)
	RoundCount = RoundCount + 1;
    if DisplayTimer == true
        disp(['Starting step ' num2str(RoundCount) ' of ' num2str(NumberOfRounds) ', ' num2str(toc(OptimisationTimer)) ' seconds elapsed']);
    end
    
    % Run the Simulation
    for SimCount = 1:SamplesPerRound
        [SimulatedOutputThisSim, OtherOutput] = FunctionPointer( ParameterEstimates(SimCount, :), FunctionInput);
        % Find the error from the given final results
        if CustomErrorFunction == true
            ErrorVector(SimCount) = ErrorFunction(ExpectedOutput, SimulatedOutputThisSim) ;  
        else
            ErrorVector(SimCount)=  sum(abs(ExpectedOutput - SimulatedOutputThisSim));  
        end
        SimOutputVector(SimCount, :) = SimulatedOutputThisSim;
    end
    
    %Sort by error
    [~, ErrorIndex] = sort(ErrorVector);
    
    %Select the ones with best errors
    BestIndex = ErrorIndex(1:NumberToKeep);
    BestParameterEstimates = ParameterEstimates(BestIndex, :);


    %% Plot and save the best results
    if PlotParameters == true 
        clf;
        hold on;
        plot(ParameterEstimates(:, 1), ParameterEstimates(:, 2), 'b.');     %this only plots the first 2 dimensions
        plot(BestParameterEstimates(:, 1), BestParameterEstimates(:, 2), 'b.');
        
        xlabel('Parameter 1','fontsize', 22);
        ylabel('Parameter 2','fontsize', 22);
        set(gca,'Color',[1.0 1.0 1.0]);
        set(gcf,'Color',[1.0 1.0 1.0]);                                     %makes the grey border white
        set(gca, 'fontsize', 18)
        box off;
        xlim([ParameterBounds(1, 1) ParameterBounds(1, 2)]);
        ylim([ParameterBounds(2, 1) ParameterBounds(2, 2)]);
        print('-dpng ','-r300',['OptimisationPlots/ParameterFit' num2str(RoundCount) '.png'])
    end
    if PlotOutput == true 
        clf;
        OutputPlotFunction(ExpectedOutput, SimOutputVector);
        print('-dpng ','-r300',['OptimisationPlots/ModelOutput' num2str(RoundCount) '.png']);
    end



    % 
    for Dim = 1:NumberOfDimensions
        %Find the min and max in each dimension
        MinVal = min(BestParameterEstimates(:, Dim));
        MaxVal = max(BestParameterEstimates(:, Dim));
        MeanDistanceBetweenPoints(Dim) = (MaxVal-MinVal)/(PointsPerDimension-1);
    end


    for NewPointCount = 1:SamplesPerRound
        %Choose a good point 
        GoodIndex = randsample(NumberToKeep, 1);
        %vary it

        for Dim = 1:NumberOfDimensions
            PointInRange = false;
            while PointInRange == false
                TestPoint(Dim) = BestParameterEstimates(GoodIndex, Dim)+2*MeanDistanceBetweenPoints(Dim).*(1-2*rand); %double the mean distance to allow for expansion
                if TestPoint(Dim)>=ParameterBounds(Dim, 1) && TestPoint(Dim)<=ParameterBounds(Dim, 2)      %if within bounds keep
                    PointInRange = true;
                end 
            end
        end
        %Add to vector
        ParameterEstimates(NewPointCount, :) = TestPoint;
    end
end

OptimisedParameters = BestParameterEstimates(1, :);
OptimisedParametersVector = BestParameterEstimates;

OptimisationDetails.TotalOptimisationTime = toc(OptimisationTimer);

end 




