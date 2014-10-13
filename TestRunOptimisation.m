
FunctionPointer=@TestFunction;
% FunctionInput.NumberOfSamples=400;
FunctionInput.NumberOfSamples=50;
ParameterBounds=[0, 10; 0, 10];

% Generate the expected output
% Parameters(1)=2;
% Parameters(2)=7;
% TestFunction(Parameters, FunctionInput)
OptimisationSettings.SamplesPerRound=100;

% ExpectedOutput=[23    54    38    17     7    38    92    92    34     5];
ExpectedOutput=[1     6     7     3     2     3    11    15     2     0];


% OptimisationSettings.ErrorFunction
OptimisationSettings.OutputPlotFunction=@PlotOptimisationOutput;
OptimisationSettings.PlotParameters=true;
% OptimisationSettings=[];
StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, ExpectedOutput, OptimisationSettings)