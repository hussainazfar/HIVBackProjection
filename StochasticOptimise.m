function [BestOptimisedParameterSet, OptimisedParametersVector]=StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, OptimisationSettings, ExpectedOutput)

% FunctionPointer: FunctionPointer = @functionname

% FunctionInput Other information passed to the function 

% ParameterBounds - a matrix with a maximum and a minimum for each parameter

% OptimisationSettings: This determines the methods that are used by the simulation, such as the error function. 
    % OptimisationSettings.MaxTime - stops after MaxTime seconds
    % OptimisationSettings.Parallel - not yet implemented
    % OptimisationSettings.ErrorFunction - a custom error function that can be used to determine the 
    % OptimisationSettings.OutputPlotFunction - used to plot the optimised parameters
    % OptimisationSettings.PlotParameters - (true or false) 

% ExpectedOutput - the values to compare against to check for the error

%% Import all OptimisationSettings that exist
try
    MaxTime=OptimisationSettings.MaxTime; % in seconds, time until the optimisation stops on its own
    TimeOut=true;
catch
    MaxTime=-1;
    TimeOut=false;
end

% try
%     Parallelise=OptimisationSettings.Parallel; % set to true to true to run the simulation over multiple cores
% catch
%     Parallelise=false;
% end
% if Parallelise==true
%     matlabpool(getenv('NUMBER_OF_PROCESSORS'));%this may not work in all processors
% end

try
    ErrorFunction=OptimisationSettings.ErrorFunction; % if someone has set the error function error function should be of the form ErrorFunction(ThisOutput, ExpectedOutput)
    CustomErrorFunction=true;
catch
    CustomErrorFunction=false; % use simple additive error over the vector
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


% The output of this function are a group of parameter sets which
% distributed based on their probability of beating the best estimate

% This function assumes that the shape of the error function indicates the
% general location of the best selection for the unknown variables. 

% Mathematical modellers are often presented with a situation where they
% have some estimates (with uncertainty) in their models, and a model
% structure based established science and assumptions about how things like
% infections spread. They then have some additonal epidemiological data
% that is believed to behave in the way decribed in their model, together
% with somde parameters which are unknown. The determination of these
% parameters or the 'fitting' of the model is often the most difficult job
% that a modeller must face, and it is easy to make mistakes at this stage.
% In addition, the majority of models are to complicated to work with
% traditional statistical models, meaning that the vigorous analysis of
% uncertainty in the model is over looked, poorly described, or stated in
% terms that do not truly detail the uncertainty in the model. 

% This optimisation methodology tries to overcome these limitations. It can
% take any stochastic model (including individual based models), treat it as a black box, use the
% measure of known parameters and their uncertainty to find an estimate for
% the unknown parameter and a probability based estimate for the
% uncertainty in the estimate for these unknown parameters.

% To do this, this optimisation methodology finds the point where the error
% function is at a global minimum. As this methodology can handle
% stochastic models, the result of a model run can be different from run to
% run. This means that the minimum error point may move around from run.
% This methodology finds the point that, on average, has the lowest measure
% of error when compared to the given data.

% Once we have an optimised point estimate for the global minimum, we run
% the simulation on this point many times, to create a distribution of
% errors between the model output and the data used for optimisation. We
% can then find the median error of this point. If we simulate this model
% anywhere else in the optimisation space, and the error from this new point
% beats the median error value at the global minimum for error, this tells
% us something about the probability that this new point is a candidate for
% inclusion as a possible optimised solution.

% What we can do then is simulate a whole heap of point in the optimisation
% space, and select those that beat the median error at the global minimum.
% The points tested at this stage need to be uniformly distributed
% on the optimisation space. 
% This is to ensure that the number of points in a given area in the optimisation
% space is representative of the probability of that given area producing a
% error result that is comparable to the error at the average global 
% minimum of error. 

% Discussion
% An advantage of this methodology is that the uncertainty ranges that are
% created by the optimisation create a relationship of allowable variables
% across the solution space of the best fitting parameters for the model. 
% That is, if parameter A can only be large when B is small and vice versa, 
% this optimisation method will create parameter set based on the 
% probability that they equal or better the error value at the point where
% the error is on avaerage at a global minimum. 

% This methodology is currently not highly optimised. The aim of the
% methodology is to properly specify the uncertainty of the unknown
% parameters based on the known parameters, model structure and inherent
% stochasticicty in the model. A variety of different methods could be used
% to find the global minimum for the error. The dsitinguishing feature of the model
% is knowing what to do with the singular point estimate in the model once
% we 


%Optimisation parameters
PointsPerDimension=4;
[NumberOfDimensions, ~]=size(ParameterBounds);
FractionToKeep=0.5;
NumberOfSamplesPerRound=PointsPerDimension^NoUnknownParameters;%used for finding singular best value
NumberOfRounds=40;%used for finding singular best value
NumberToKeep=floor(NumberOfSamplesPerRound*FractionToKeep);
Resolution=100;%100 points per dimension. In this case 1% accuracy on the bounds of the unknown variable minmax

%Sims per round
% Choose random values between the bounds
    % 4 per dimension
    
    % choose the best 50%
    % find the range between the max and min of each dimension
    % the variable distance around each point is range/4*2
    % Choose 2 new points per existing point, randomly spaced


%% Find the position of the very best point
% Create initial unknown parameter sampling
for i=1:NoUnknownParameters
    ChosenParametersUnknown(:,i)=(ParameterBounds(i, 2)-ParameterBounds(i, 1))*rand(1, NumberOfSamplesPerRound)+ParameterBounds(i, 1);
end

MeanDistanceBetweenPoints=zeros(1, NumberOfDimensions);
SimOutputVector=zeros(NumberOfSamplesPerRound, NumberOfDimensions);
ErrorVector=zeros(1, NumberOfSamplesPerRound);
OptimisationTimer=tic;
RoundCount=0;
while (RoundCount<NumberOfRounds)  && (TimeOut==false || toc(OptimisationTimer)<MaxTime) % && (the standard deviation hasn't changed all that much)
	RoundCount=RoundCount+1;
    disp(['Starting step ' num2str(RoundCount) ' of ' num2str(NumberOfRounds) ' ' num2str(toc(OptimisationTimer)) ' seconds elapsed']);

    % Run the Simulation
    for SimCount=1:NumberOfSamplesPerRound
        [SimulatedOutputThisSim, OtherOutput]=FunctionPointer(FunctionInput, ChosenParametersUnknown(SimCount, :));
        % Find the error from the given final results
        if CustomErrorFunction==true
            ErrorVector(SimCount)=  ErrorFunction(ExpectedOutput, SimulatedOutputThisSim) ;  
        else
            ErrorVector(SimCount)=  ErrorFunction(ExpectedOutput, SimulatedOutputThisSim) ;  
        end
        SimOutputVector(SimCount, :)=SimulatedOutputThisSim;
    end
    
    %Sort by error
    [~, ErrorIndex]=sort(ErrorVector);
    
    %Select the ones with best errors
    BestIndex=ErrorIndex(1:NumberToKeep);
    BestUnknownParameters=ChosenParametersUnknown(BestIndex, :);


    %% Plot and save the best results
    if PlotParameters==true 
        clf;
        hold on;
        plot(ChosenParametersUnknown(:, 1), ChosenParametersUnknown(:, 2), 'r.'); 
        plot(BestUnknownParameters(:, 1), BestUnknownParameters(:, 2), 'b.'); %this only plots the first 2 dimensions

        xlabel('Parameter 1','fontsize', 22);
        ylabel('Parameter 2','fontsize', 22);
        set(gca,'Color',[1.0 1.0 1.0]);
        set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
        set(gca, 'fontsize', 18)
        box off;
        xlim([0 1]);
        ylim([0 1]);
        print('-dpng ','-r300',['OptimisationPlots/ParameterFit' num2str(RoundCount) '.png'])
    end
    if PlotOutput==true 
        clf;
        PlotOptimisationOutput(ExpectedOutput, SimOutputVector);
        print('-dpng ','-r300',['OptimisationPlots/Model Results' num2str(RoundCount) '.png']);
    end



    % 
    for Dim=1:NumberOfDimensions
        %Find the min and max in each dimension
        MinVal=min(BestUnknownParameters(:, Dim));
        MaxVal=max(BestUnknownParameters(:, Dim));
        MeanDistanceBetweenPoints(Dim)=(MaxVal-MinVal)/(NumberPerDimension-1);
    end


    for NewPointCount=1:NumberOfSamplesPerRound
        %Choose a good point 
        GoodIndex=randsample(NumberToKeep, 1);
        %vary it

        for Dim=1:NumberOfDimensions
            PointInRange=false;
            while PointInRange==false
                TestPoint(Dim)=BestUnknownParameters(GoodIndex, :)+ChosenDistance'.*(1-2*rand(1, NumberOfDimensions));
                if TestPoint(Dim)>=ParameterBounds(:, 1) && TestPoint(Dim)<=ParameterBounds(:, 2)      %if within bounds keep
                    PointInRange=true;
                end 
            end
        end
        %Add to vector
        ChosenParametersUnknown(NewPointCount, :)=TestPoint;
    end
end


end 



