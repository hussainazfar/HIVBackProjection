function DiagnosisResult=DiagnosedDuringStep(TestingParameters, CD4Count, Duration)
RegularTestingRate=TestingParameters(1);
Curvature=TestingParameters(2);

SymptomaticTestingFunction=exp(-Curvature*CD4Count/200);
% Curvature [0, 1]
% Curvature in this case represents the testing rate at a CD4 count of 200
% If Regular testing is 50% per year and Curvature=0.2, the additional
% testing rate implies 60% testing


AnnualTestingProbability=RegularTestingRate+(1-RegularTestingRate)*SymptomaticTestingFunction;
TestingProbability=1-(1-AnnualTestingProbability).^Duration;

DiagnosisResult=rand(size(CD4Count))<TestingProbability;

end