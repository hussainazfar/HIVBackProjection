function [ PatientCD4 ] = TestRapidRebound( PatientCD4, Pxi, TestingParameters )
%This function tests whether Patient was diagnosed during Rapid Rebound
%Phase

PatientCD4.AverageCD4Count = PatientCD4.StartingCD4Count * (Pxi.FractionalDeclineToRebound + Pxi.FractionalDeclineToTrough) / 2;
Duration = Pxi.TimeUntilRebound - Pxi.TimeUntilTrough;
PatientCD4.IndexTest = DiagnosedDuringStep(TestingParameters, AverageCD4Count, Duration);

    if (PatientCD4.IndexTest == true)
        %Calculate the time
        RandomDistanceAlongThisStep = rand();
        TimeAtDiagnosis = Pxi.TimeUntilTrough + (Pxi.TimeUntilRebound - Pxi.TimeUntilTrough) * RandomDistanceAlongThisStep;
        PatientCD4.Time = TimeAtDiagnosis;
        PatientCD4.MeasuredCD4Count = PatientCD4.StartingCD4Count .* ((1 - RandomDistanceAlongThisStep) * Pxi.FractionalDeclineToTrough + RandomDistanceAlongThisStep * Pxi.FractionalDeclineToRebound);
    end
end
