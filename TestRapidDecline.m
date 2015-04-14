function [ IndexTest, AverageCD4Count, Time, MeasuredCD4Count ] = TestRapidDecline( StartingCD4Count, Pxi, TestingParameters )
%This function tests whether Patient was diagnosed during Rapid Decline
%Phase

AverageCD4Count = StartingCD4Count * (1 + Pxi.FractionalDeclineToTrough) / 2;
Duration = Pxi.TimeUntilTrough;
IndexTest = DiagnosedDuringStep(TestingParameters, AverageCD4Count, Duration);

    if (IndexTest == true)
        %Calculate the time
        RandomDistanceAlongThisStep = rand();
        Time = Pxi.TimeUntilTrough * RandomDistanceAlongThisStep;
        MeasuredCD4Count = StartingCD4Count .* ((1-RandomDistanceAlongThisStep) * 1 + RandomDistanceAlongThisStep * Pxi.FractionalDeclineToTrough);
    else
        Time = 0;
        MeasuredCD4Count = 0;
    end

end

