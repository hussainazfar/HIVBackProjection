
FunctionPointer=@TestFunction;
FunctionInput.NumberOfSamples=10000;
ParameterBounds=[0, 10; 0, 10];

ExpectedOutput=[22    30    40     7     4    13    30    37    14     3];


% OptimisationSettings.ErrorFunction
OptimisationSettings.OutputPlotFunction=@PlotOptimisationOutput;


StochasticOptimise(FunctionPointer, FunctionInput, ParameterBounds, ExpectedOutput, OptimisationSettings)