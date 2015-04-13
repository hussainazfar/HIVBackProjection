function [ CD4CountHistogram, Data ] = GenerateCD4CountModified( TestingParameters, Pxi )
%GenerateCD4Count function takes a healthy population and simulates the CD4 decline
% according to assumptions contained in in Pxi and the TestingP. In doing
% so, it creates the number of people expected in the correct proportions
% by CD4.
StepSize = Pxi.StepSize;
MaxYears = Pxi.MaxYears;

%Start with the number of observations
SimulatedPopSize = Pxi.SimulatedPopSize;

NumIndex = 1:SimulatedPopSize;

%Initialize object PatientCD4 of class CD4Class
PatientCD4(1:Pxi.SimulatedPopSize) = CD4Class;

%% Generate an initial distribution, i.e. Generate Starting CD4 Count
for x = 1:SimulatedPopSize
    [ PatientCD4 ] = CreateCD4Object(Pxi, PatientCD4);
end

%% For all people, find the time after which the person was defined as diagnosed
for x = 0:StepSize:MaxYears
    for y = 1:SimulatedPopSize
        if (PatientCD4(y).IndexTest == false)
            %Testing to see if Patient is Diagnosed During Rapid Decline
            MeanCD4Count = PatientCD4(y).StartingCD4Count * (1 + Pxi.FractionalDeclineToTrough) / 2;
            Duration = Pxi.TimeUntilTrough;
            PatientCD4(y).IndexTest = DiagnosedDuringStep(TestingParameters, MeanCD4Count, Duration);
            
            %Calculate the time
            if (PatientCD4(y).IndexTest == true)
                RandomDistanceAlongThisStep = rand();
                TimeAtDiagnosis = Pxi.TimeUntilTrough * RandomDistanceAlongThisStep;
                PatientCD4(y).Time = TimeAtDiagnosis;
                PatientCD4(y).CD4 = PatientCD4(y).StartingCD4Count .* ((1-RandomDistanceAlongThisStep) * 1 + RandomDistanceAlongThisStep * Pxi.FractionalDeclineToTrough);
            elseif (PatientCD4(y).IndexTest == false)
                MeanCD4Count = PatientCD4(y).StartingCD4Count * (Pxi.FractionalDeclineToRebound + Pxi.FractionalDeclineToTrough) / 2;
                Duration = Pxi.TimeUntilRebound - Pxi.TimeUntilTrough;
                PatientCD4(y).IndexTest = DiagnosedDuringStep(TestingParameters, MeanCD4Count, Duration);
                
                %Calculate the time
                RandomDistanceAlongThisStep = rand();
                TimeAtDiagnosis = Pxi.TimeUntilTrough + (Pxi.TimeUntilRebound - Pxi.TimeUntilTrough) * RandomDistanceAlongThisStep;
                PatientCD4(y).Time = TimeAtDiagnosis;
                PatientCD4(y).CD4 = PatientCD4(y).StartingCD4Count .* ((1 - RandomDistanceAlongThisStep) * Pxi.FractionalDeclineToTrough + RandomDistanceAlongThisStep * Pxi.FractionalDeclineToRebound);
            end
        elseif (PatientCD4(y).IndexTest == true)
            continue
        end        
    end
end

end

