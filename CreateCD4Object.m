function [ PatientCD4 ] = CreateCD4Object( Pxi, PatientCD4 )
%Read Data from Pxi and create a simulation of CD4 counts to be used for
%CD4 Generation

%% Assign CD4 Counts against each object
LogInitialCD4Vector = normrnd(Pxi.MedianLogHealthyCD4, Pxi.StdLogHealthyCD4, [1 Pxi.SimulatedPopSize]);
InitialCD4Vector = exp(LogInitialCD4Vector);

for x = 1:Pxi.SimulatedPopSize
    PatientCD4(x).StartingCD4Count = InitialCD4Vector(x);
end

end

