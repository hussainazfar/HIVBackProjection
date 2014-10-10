function [OptimisedParameters]=StochasticOptimise(FunctionPointer, ParameterBounds,  InitalValues, ExpectedOutput, OptimisationSettings, KnownParametersMean, KnownParametersSD, KnownParametersMinMax, NoUnknownParameters, )

% FunctionPointer: FunctionPointer = @functionname

% ParameterBounds - a matrix with a maximum and a minimum for each
% parameter

% OptimisationSettings: This determines the methods that are used by the
% simulation, such as the error function. 

MaxTime=-1;
try
    MaxTime=OptimisationSettings.MaxTime; % in seconds, time until the optimisation stops on its own
    TimeOut=true;
catch
    TimeOut=false;
end

try
    Parallelise=OptimisationSettings.Parallel; % set to true to true to run the simulation over multiple cores
catch
    Parallelise=false;
end

if Parallelise==true
    matlabpool(getenv('NUMBER_OF_PROCESSORS'));%this may not work in all processors
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

[NoKnownParamsToVary, ~]=size(KnownParametersMinMax);
% We have removed this, and will allow the user to do whatever tranform they
% feel on a normal distribution instead
% 
% if NoKnownParamsToVary>0
%     KnownParametersVar=KnownParametersSD.^2;
%     mu=log(KnownParametersMean.^2./sqrt(KnownParametersVar+KnownParametersMean.^2));
%     sigma=sqrt(log(KnownParametersVar./(KnownParametersMean.^2)+1));
% else
%     KnownParametersVar=[];
%     mu=[];
%     sigma=[];
% end



%Optimisation parameters
FullyExhaustiveSearch=false;
FractionToKeep=0.1;
%NumberOfSamplesPerRound=10^NoUnknownParameters;%used for finding singular best value
NumberOfSamplesPerRound=4^NoUnknownParameters;%used for finding singular best value
%NumberOfSamplesPerRound=7^NoUnknownParameters;
%NumberOfRounds=50;%used for finding singular best value
NumberOfSamplesBestPoint=100;
NumberOfRounds=40;%used for finding singular best value
NoToKeep=floor(NumberOfSamplesPerRound*FractionToKeep);
Resolution=100;%100 points per dimension. In this case 1% accuracy on the bounds of the unknown variable minmax

ChosenDistance=(UnknownParametersMinMax(:, 2)-UnknownParametersMinMax(:, 1))./NumberOfSamplesPerRound.^(1./NoUnknownParameters);
ChosenDistance=ChosenDistance*4;%Double the distance (so that the mean distance of a randomly selected point r=(0,1) mean=0.5 gives the right distance and double again to make the reduction work properly)
% DistanceReduction=0.9;
DistanceReduction=0.8;

PlotAllSteps=true;
PlotLastStep=true;




%initialise the multi-processor settings
%if ~matlabpool('size'); 
    disp('Starting parallel Matlab...');
%     UseAutoAssignProcessors=true; 
%     if UseAutoAssignProcessors
%         disp('Auto assigning processors for backprojection optimisation');
        matlabpool(getenv('NUMBER_OF_PROCESSORS'));%this may not work in all processors
%     else
%         disp('Hard setting processors for backprojection optimisation');
%         matlabpool(4);%this may not work in all processors
%     end
%end


%% Find the position of the very best point
OptimisationTimer=tic;
% Create initial unknown parameter sampling

for i=1:NoUnknownParameters
    ChosenParametersUnknown(:,i)=(UnknownParametersMinMax(i, 2)-UnknownParametersMinMax(i, 1))*rand(1, NumberOfSamplesPerRound)+UnknownParametersMinMax(i, 1);
end
for RoundCount=1:NumberOfRounds
    disp(['Starting step ' num2str(RoundCount) ' of ' num2str(NumberOfRounds) ' ' num2str(toc(OptimisationTimer)) ' seconds elapsed']);
    % Chose a vector of values for the known parameters using the mean and SD of the known parameters
    ChosenParametersKnown=zeros(NumberOfSamplesPerRound, NoKnownParamsToVary);
%     i=0;
%     for Dummy=mu%For each of the parameters
%         i=i+1;
    for i=1:NoKnownParamsToVary
        %Create numbers at random which would fall into the distribution
        %SelectionForThisParam=lognrnd(mu(i),sigma(i), NumberOfSamplesPerRound, 1);%choose nx1 matrix of these values
        SelectionForThisParam=normrnd(KnownParametersMean(i),KnownParametersSD(i), NumberOfSamplesPerRound, 1);%choose nx1 matrix of these values
        
        
        % Keep the parameters in the desired range
        SelectionForThisParam(SelectionForThisParam<KnownParametersMinMax(i, 1))=KnownParametersMinMax(i, 1);
        SelectionForThisParam(SelectionForThisParam>KnownParametersMinMax(i, 2))=KnownParametersMinMax(i, 2);
        
        ChosenParametersKnown(:, i)=SelectionForThisParam;
    end
    
    %Put the two sets of parameters together
    ChosenParameters=[ChosenParametersKnown ChosenParametersUnknown];
    
    SimResultVector=[];
    % Run the Simulation
    parfor SimCount=1:NumberOfSamplesPerRound
    %for SimCount=1:NumberOfSamplesPerRound
        
        [SimulatedOutputThisSim, OtherOutput]=Model(InitalValues, ChosenParameters(SimCount, :), SimulationSettings);
        SimResultVector(SimCount, :)=SimulatedOutputThisSim;
        % Find the error from the given final results
        ErrorVector(SimCount)=  ErrorFunction(ExpectedOutput, SimulatedOutputThisSim) ;  %sum((SimulatedOutputThisSim-ExpectedOutput).^2);%Error is square error (variance)
    end
    

    %Sort by error
    [~, ErrorIndex]=sort(ErrorVector);
    
    %Select the ones with best errors
    BestIndex=ErrorIndex(1:NoToKeep);
    BestUnknownParameters=ChosenParametersUnknown(BestIndex, :);
    BestKnownParameters=ChosenParametersKnown(BestIndex, :);
    


    %% Plot and save the best results
    if PlotAllSteps==true || (PlotLastStep==true && RoundCount==NumberOfRounds)
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


        %% Plot the function output
%         clf;
%         hold on;
%         plot(SimResultVector(:, 1), SimResultVector(:, 2), 'r.'); 
%         plot(ExpectedOutput( 1), ExpectedOutput( 2), 'b.'); %this only plots the first 2 dimensions
% 
%         xlabel('Parameter 1','fontsize', 22);
%         ylabel('Parameter 2','fontsize', 22);
%         set(gca,'Color',[1.0 1.0 1.0]);
%         set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
%         set(gca, 'fontsize', 18)
%         box off;
%         %xlim([0 1]);
%         %ylim([0 1]);
%         print('-dpng ','-r300',['OptimisationPlots/Model Results' num2str(RoundCount) '.png'])
    end


    %% Choose a vector of values for the unknown parameters
    ChosenDistance=ChosenDistance*DistanceReduction;

    NewPoint=0;
    while NewPoint<NumberOfSamplesPerRound
        %Choose a good point 
        GoodIndex=randsample(NoToKeep, 1);
        %vary it

        TestPoint=BestUnknownParameters(GoodIndex, :)+ChosenDistance'.*(1-2*rand(1, NoUnknownParameters));

        if TestPoint'>=UnknownParametersMinMax(:, 1) & TestPoint'<=UnknownParametersMinMax(:, 2)      %if within bounds keep
            NewPoint=NewPoint+1;
            %Add to vector
            ChosenParametersUnknown(NewPoint, :)=TestPoint;
        end    %else do nothing
    end

    
    
end

%% Run this particular point 100 times with all uncertainty to find the median error at the point. 
%Find the mean point of the optimisation
MeanOfBestPoints=mean(BestUnknownParameters, 1);
%MeanPoint=BestUnknownParameters(1, :);
MeanPointMat=ones([NumberOfSamplesBestPoint 1])*MeanOfBestPoints;

%Create a known parameter distribution
ChosenParametersKnown=[];

% i=0;
% for Dummy=mu%For each of the parameters
%     i=i+1;
for i=1:NoKnownParamsToVary
    %Create numbers at random which would fall into the distribution
    %SelectionForThisParam=lognrnd(mu(i),sigma(i), 1, NumberOfSamplesBestPoint);%choose 1x1 matrix of these values
    SelectionForThisParam=normrnd(KnownParametersMean(i),KnownParametersSD(i), NumberOfSamplesBestPoint, 1);%choose nx1 matrix of these values
    
    % Keep the parameters in the desired range
    SelectionForThisParam(SelectionForThisParam<KnownParametersMinMax(i, 1))=KnownParametersMinMax(i, 1);
    SelectionForThisParam(SelectionForThisParam>KnownParametersMinMax(i, 2))=KnownParametersMinMax(i, 2);

    ChosenParametersKnown(:, i)= SelectionForThisParam;
end

MeanPointMat
ChosenParametersKnown

size(MeanPointMat)
size(ChosenParametersKnown)


ChosenParameters=[ChosenParametersKnown MeanPointMat];
SimResultVector=[];
% Run the Simulation
ErrorVector=[];
parfor SimCount=1:NumberOfSamplesBestPoint
        [SimulatedOutputThisSim, OtherOutput]=Model(InitalValues, ChosenParameters(SimCount, :), SimulationSettings);
        % Find the error from the given final results
        SimResultVector(SimCount, :)=SimulatedOutputThisSim;
        ErrorVector(SimCount)=ErrorFunction(ExpectedOutput, SimulatedOutputThisSim); %sum((SimulatedOutputThisSim-ExpectedOutput).^2);%Error is square error (variance)
end

MedianErrorOfBestPoint=median(ErrorVector);






% Plot the function output
        clf;
        hold on;
        plot(SimResultVector(:, 1), SimResultVector(:, 2), 'r.'); 
        plot(ExpectedOutput( 1), ExpectedOutput( 2), 'b.'); %this only plots the first 2 dimensions

        xlabel('Parameter 1','fontsize', 22);
        ylabel('Parameter 2','fontsize', 22);
        set(gca,'Color',[1.0 1.0 1.0]);
        set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
        set(gca, 'fontsize', 18)
        box off;
        %xlim([0 1]);
        %ylim([0 1]);
        print('-dpng ','-r300',['OptimisationPlots/BestPoint.png'])




%% Run the simualtion across all possible positions in the unknown parameter ranges (going to need a lot of these)
% The parameter selection here needs to be uniform to ensure that when a
% point is selected, it indicates the probability of beating the 'best'
% parameter selection


if FullyExhaustiveSearch==false

    % Run the simulation across the section of the grid with the best point
    % Find if the number of points that were successful in that section of the
    % grid execeded a certain level (usually 1 good simulation is enough
    % evidence to try all of the surrounding areas. 

    clear ErrorVector;
    
    GridResolution=10; 
    TestsPerGridPosition=100;
    GridElementsInEachDimension=GridResolution.*ones(1, NoUnknownParameters);
    GridToTestNext=zeros(GridElementsInEachDimension);
    GridAlreadyTested=zeros(GridElementsInEachDimension);

    TotalGridSize=UnknownParametersMinMax(:, 2)-UnknownParametersMinMax(:, 1);
    GridSize=TotalGridSize/GridResolution;
    for DimCount=1:NoUnknownParameters
        GridMin(DimCount, :)=UnknownParametersMinMax(DimCount, 1):GridSize(DimCount):UnknownParametersMinMax(DimCount, 2)-GridSize(DimCount);%Find the minimums
        GridMax(DimCount, :)=UnknownParametersMinMax(DimCount, 1)+GridSize(DimCount):GridSize(DimCount):UnknownParametersMinMax(DimCount, 2);%Find the maximums
    end


    for DimCount=1:NoUnknownParameters
        BestPointCoordInGrid(DimCount)=find(MeanOfBestPoints(DimCount)>GridMin(DimCount, :) & MeanOfBestPoints(DimCount)<=GridMax(DimCount, :));
    end
    
    CellIndices=num2cell(BestPointCoordInGrid);
    GridToTestNext(CellIndices{:})=1;
    GridToTestNextCoord=FindXDim(GridToTestNext);
    

    
    [NumberOfGridToTestNext, ~]=size(GridToTestNextCoord);
    
    OptimisedUnknownParameters=[];
    OptimisedKnownParameters=[];
    AllTestedUnknownParameters=[];
    AllTestedKnownParameters=[];
    ChosenParametersKnown =[];
    ChosenParametersUnknown=[];

    % The while loop does not loop over NumberOfGridToTestNext. Rather, it
    % keeps looping while NumberOfGridToTestNext>0. 
    NumberOfGridPositionsSimulated=0;
    GridSimulationTimePointer=tic;

    
    while NumberOfGridToTestNext>0
        
        %Zero the GridToPossiblyTestNext, to use as a flag for the next possible simulation
        GridToPossiblyTestNext=zeros(GridElementsInEachDimension);
        
        
        %for all of the NumberOfGridToTestNext
        %create the random points to be sample with
        for GridCount=1:NumberOfGridToTestNext
            NumberOfGridPositionsSimulated=NumberOfGridPositionsSimulated+1;
            ThisGridCoord=GridToTestNextCoord(GridCount, :);
            
            
            GridTime=toc(GridSimulationTimePointer);
            disp([num2str(NumberOfGridPositionsSimulated) '; ' num2str(GridTime) ' seconds; Grid location to simulate within:']);
            disp(ThisGridCoord);
            
            %Indicate that this point has already been tested
                %Put into a form that matlab can use as indices
                CellIndices=num2cell(ThisGridCoord);
            GridAlreadyTested(CellIndices{:})=1;
    
            
            %Create a known parameter distribution
            [NumberofKnownParamters, ~]=size(KnownParametersMinMax);
            ChosenParametersKnown=zeros(TestsPerGridPosition, NumberofKnownParamters);
%             i=0;
%             for Dummy=mu%For each of the parameters
%                 i=i+1;
            for i=1:NoKnownParamsToVary
                %Create numbers at random which would fall into the distribution
                %SelectionForThisParam=lognrnd(mu(i),sigma(i), 1, TestsPerGridPosition);%choose 1x1 matrix of these values
                SelectionForThisParam=normrnd(KnownParametersMean(i),KnownParametersSD(i), 1, TestsPerGridPosition);%choose nx1 matrix of these values
                
                % Keep the parameters in the desired range
                SelectionForThisParam(SelectionForThisParam<KnownParametersMinMax(i, 1))=KnownParametersMinMax(i, 1);
                SelectionForThisParam(SelectionForThisParam>KnownParametersMinMax(i, 2))=KnownParametersMinMax(i, 2);

                ChosenParametersKnown(:, i)= SelectionForThisParam;
            end
            
            
            %Create the unknown parameter distribution for this grid position
            for DimCount=1:NoUnknownParameters
                MinThisGrid(DimCount)=GridMin(DimCount, ThisGridCoord(DimCount));
                MaxThisGrid(DimCount)=GridMax(DimCount, ThisGridCoord(DimCount));
            end
            
            for SimCount=1:TestsPerGridPosition
                ChosenParametersUnknown(SimCount, :)=MinThisGrid+(MaxThisGrid-MinThisGrid).*rand(1, NoUnknownParameters);
            end
            
            if NoKnownParamsToVary>0
                ChosenParameters=[ChosenParametersKnown ChosenParametersUnknown];
            else
                ChosenParameters=ChosenParametersUnknown;
            end
                
            parfor SimCount=1:TestsPerGridPosition
                
                [OutputThisSim, OtherOutput]=Model(InitalValues, ChosenParameters(SimCount, :), SimulationSettings);
                % Select ones that beat the median of the best point
                % Find the error from the given final results
                %SimResultVector(SimCount, :)=OutputThisSim;
                ErrorVector(SimCount)=ErrorFunction(ExpectedOutput, OutputThisSim); %sum((OutputThisSim-ExpectedOutput).^2);%Error is square error (variance)
            end
            
            %Find sims which beat the median error, and store
            SuccessfulSimIndex=ErrorVector<=MedianErrorOfBestPoint;
            OptimisedUnknownParameters=[OptimisedUnknownParameters; ChosenParametersUnknown(SuccessfulSimIndex, :)];
            AllTestedUnknownParameters=[AllTestedUnknownParameters; ChosenParametersUnknown];
            if NoKnownParamsToVary>0
                OptimisedKnownParameters=[OptimisedKnownParameters; ChosenParametersKnown(SuccessfulSimIndex, :)];
                AllTestedKnownParameters=[AllTestedKnownParameters; ChosenParametersKnown];
            end
            
            
            
            disp(['Success rate=' num2str(sum(SuccessfulSimIndex)/TestsPerGridPosition)]);
            
            if PlotAllSteps==true
                clf;
                hold on;
                plot(AllTestedUnknownParameters(:, 1), AllTestedUnknownParameters(:, 2), 'b.'); 
                plot(OptimisedUnknownParameters(:, 1), OptimisedUnknownParameters(:, 2), 'r.'); %this only plots the first 2 dimensions

                xlabel('Parameter 1','fontsize', 22);
                ylabel('Parameter 2','fontsize', 22);
                set(gca,'Color',[1.0 1.0 1.0]);
                set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
                set(gca, 'fontsize', 18)
                box off;
                xlim([0 1]);
                ylim([0 1]);
                print('-dpng ','-r300',['OptimisationPlots/UncertaintyGrid' num2str(NumberOfGridPositionsSimulated) '.png'])
            end
            
            
            % Find the next grid positions to inspect
            if sum(SuccessfulSimIndex)>0 %if (there is at least one point that beat the median count)
                VariationVec=[-1 1];
                % for each dimension
                for DimCount=1:NoUnknownParameters
                    for Variation=VariationVec
                        % determine the grid cell to move to
                        Move=ThisGridCoord;
                        Move(DimCount)=Move(DimCount)+Variation;
                        
                        %Determine if the grid cell is allowable
                        if Move(DimCount)<=GridResolution && Move(DimCount)>0
                            %Put into a form that matlab can use as indices
                            CellIndices=num2cell(Move);
                            GridToPossiblyTestNext(CellIndices{:})=1;
                            
                        end %else ignore that point
                    end
                end
            end 

        end    
            
        
        %Find the next Grid points to test
        GridToTestNext = GridToPossiblyTestNext & ~GridAlreadyTested; %Possibly test next AND NOT already tested
        GridToTestNextCoord=FindXDim(GridToTestNext);
        [NumberOfGridToTestNext, ~]=size(GridToTestNextCoord);
        
    end
else



    disp('Finding all equally likely points in the simualtion');

    TotalPointsToSample=Resolution^NoUnknownParameters;

    clear ErrorVector;
    %Create a known parameter distribution
    ChosenParametersKnown=[];
%     i=0;
%     for Dummy=mu%For each of the parameters
%         i=i+1;
    for i=1:NoKnownParamsToVary
        %Create numbers at random which would fall into the distribution
        %SelectionForThisParam=lognrnd(mu(i),sigma(i), 1, TotalPointsToSample);%choose 1x1 matrix of these values
        SelectionForThisParam=normrnd(KnownParametersMean(i),KnownParametersSD(i), 1, TotalPointsToSample);%choose nx1 matrix of these values
        
        % Keep the parameters in the desired range
        SelectionForThisParam(SelectionForThisParam<KnownParametersMinMax(i, 1))=KnownParametersMinMax(i, 1);
        SelectionForThisParam(SelectionForThisParam>KnownParametersMinMax(i, 2))=KnownParametersMinMax(i, 2);

        ChosenParametersKnown(:, i)= SelectionForThisParam;
    end

    % Create unknown parameter sampling
    ChosenParametersUnknown=[];
    for i=1:NoUnknownParameters
        ChosenParametersUnknown(:,i)=(UnknownParametersMinMax(i, 2)-UnknownParametersMinMax(i, 1))*rand(1, TotalPointsToSample)+UnknownParametersMinMax(i, 1);
    end

    if NoKnownParamsToVary>0
        ChosenParameters=[ChosenParametersKnown ChosenParametersUnknown];
    else
        ChosenParameters=[ ChosenParametersUnknown];
    end
    SimResultVector=[];
    % Run the Simulation
    ErrorVector=[];
    FinalTimer=tic;
    parfor SimCount=1:TotalPointsToSample
        if mod(SimCount, 1000)==0
            disp([num2str(SimCount) ' of ' num2str(TotalPointsToSample) ' time: ' num2str(toc(FinalTimer))]);
        end

        [SimulatedOutputThisSim, OtherOutput]=Model(InitalValues, ChosenParameters(SimCount, :), SimulationSettings);
        % Find the error from the given final results
        SimResultVector(SimCount, :)=SimulatedOutputThisSim;
        ErrorVector(SimCount)=ErrorFunction(ExpectedOutput, SimulatedOutputThisSim); % sum((SimulatedOutputThisSim-ExpectedOutput).^2);%Error is square error (variance)
    end

    LikelyPointIndex=ErrorVector<=MedianErrorOfBestPoint;

    sum(LikelyPointIndex)

    OptimisedUnknownParameters=ChosenParametersUnknown(LikelyPointIndex, :);
    OptimisedKnownParameters=ChosenParametersKnown(LikelyPointIndex, :);
end 

%Plot and save the chosen results
        clf;
        hold on;
        %plot(ChosenParametersUnknown(:, 1), ChosenParametersUnknown(:, 2), 'r.'); 
        plot(OptimisedUnknownParameters(:, 1), OptimisedUnknownParameters(:, 2), 'b.'); %this only plots the first 2 dimensions

        xlabel('Parameter 1','fontsize', 22);
        ylabel('Parameter 2','fontsize', 22);
        set(gca,'Color',[1.0 1.0 1.0]);
        set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
        set(gca, 'fontsize', 18)
        box off;
        xlim([0 1]);
        ylim([0 1]);
        print('-dpng ','-r300',['OptimisationPlots/DistributionOfLikelyParameterFits.png'])

matlabpool close;

end 




