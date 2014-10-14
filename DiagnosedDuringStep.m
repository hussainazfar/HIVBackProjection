function DiagnosisResult=DiagnosedDuringStep(TestingParameters, CD4Count, Duration)
RegularTestingRate=TestingParameters(1);
Curvature=TestingParameters(2);

SymptomaticTestingFunction=Curvature*exp(-CD4Count);
% Curvature [0, 1], but will almost certainly be >e

AnnualTestingProbability=RegularTestingRate+(1-RegularTestingRate)*SymptomaticTestingFunction;
TestingProbability=AnnualTestingProbability.^Duration;

DiagnosisResult=rand(size(CD4Count))<TestingProbability;

end