function [ IndexTest, AverageCD4Count, Time, MeasuredCD4Count ] = TestRapidRebound( StartingCD4Count, Pxi, TestingParameters )
%This function tests whether Patient was diagnosed during Rapid Rebound
%Phase

AverageCD4Count = StartingCD4Count * (Pxi.FractionalDeclineToRebound + Pxi.FractionalDeclineToTrough) / 2;
Duration = Pxi.TimeUntilRebound - Pxi.TimeUntilTrough;
IndexTest = DiagnosedDuringStep(TestingParameters, AverageCD4Count, Duration);

    if (IndexTest == true)
        %Calculate the time
        RandomDistanceAlongThisStep = rand();
        Time = Pxi.TimeUntilTrough + (Pxi.TimeUntilRebound - Pxi.TimeUntilTrough) * RandomDistanceAlongThisStep;
        MeasuredCD4Count = StartingCD4Count .* ((1 - RandomDistanceAlongThisStep) * Pxi.FractionalDeclineToTrough + RandomDistanceAlongThisStep * Pxi.FractionalDeclineToRebound);
    else
        Time = 0;
        MeasuredCD4Count = 0;
    end
end
