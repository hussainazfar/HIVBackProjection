function [ PatientCD4 ] = TestRapidDecline( PatientCD4, Pxi, TestingParameters )
%This function tests whether Patient was diagnosed during Rapid Decline
%Phase

PatientCD4.AverageCD4Count = PatientCD4.StartingCD4Count * (1 + Pxi.FractionalDeclineToTrough) / 2;
Duration = Pxi.TimeUntilTrough;
PatientCD4.IndexTest = DiagnosedDuringStep(TestingParameters, PatientCD4.AverageCD4Count, Duration);

    if (PatientCD4.IndexTest == true)
        %Calculate the time
        RandomDistanceAlongThisStep = rand();
        TimeAtDiagnosis = Pxi.TimeUntilTrough * RandomDistanceAlongThisStep;
        PatientCD4.Time = TimeAtDiagnosis;
        PatientCD4.MeasuredCD4Count = PatientCD4.StartingCD4Count .* ((1-RandomDistanceAlongThisStep) * 1 + RandomDistanceAlongThisStep * Pxi.FractionalDeclineToTrough);
    end

end

