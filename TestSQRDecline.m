function [ IndexTest, AverageCD4Count, Time, MeasuredCD4Count ] = TestSQRDecline( StartingCD4Count, Pxi, TestingParameters, StepSize, MaxYears )
%TestSQRDecline Determines the time period at which the Patient was diagnosed after Infection
%% Calculate Starting Point for Infection after Rebound
CD4AtRebound = StartingCD4Count .* Pxi.FractionalDeclineToRebound;

% Generate a squareroot decline for this Individual
m = Pxi.SQRCD4Decline;
v = (Pxi.SDSQRDeclineIndividual)^2;
MinimumCD4Decline = 0.1 * Pxi.SQRCD4Decline;

mu = log((m^2) / sqrt(v+m^2));
sigma = sqrt(log(v/(m^2) + 1));

%Remove declines that are less than 10% of the squareroot annual decline
%This is to avoid negative declines and divide by zero errors. Note that it is expected that around 0.9% of the population would have this level according to these calculations
IndividualCD4Decline = MinimumCD4Decline - 0.1;

while (IndividualCD4Decline < MinimumCD4Decline)
    IndividualCD4Decline = lognrnd(mu,sigma);
end

IndexTest = false;
AverageCD4Count = 0;
TimeSinceRebound = 0;
Step = 0;

while (IndexTest == false)
    Step = Step + 1;

    TimeMidpoint = TimeSinceRebound + StepSize/2;
    SqrCD4AtRebound = sqrt(CD4AtRebound);
    
    % Calculate CD4 at midpoint to find the average testing rate
    % We don't need to worry about stochasticity at this point because the
    % average CD4 is more likely to indicate health at a point in time than
    % day to day variation.
    
    if TimeMidpoint < Pxi.TimeAtLinearDecline 
        % calculate the squareroot decline
        SqrCD4AtMidpoint = SqrCD4AtRebound-TimeMidpoint*IndividualCD4Decline;
        CD4AtMidpoint = SqrCD4AtMidpoint.^2;
        
    else 
        
        % calculate the CD4 count at the point at which linear decline occurs
        UntestedSqrCD4AtLinearDecline = SqrCD4AtRebound - Pxi.TimeAtLinearDecline .*IndividualCD4Decline;
        UntestedCD4AtLinearDecline = UntestedSqrCD4AtLinearDecline.^2;
        % calculate the liner decline
        TimeSinceLinearDecline = TimeMidpoint - Pxi.TimeAtLinearDecline;
        % linearCD4Decline=2(sqrCD4decline*t + sqr(startingCD4))*sqrCD4decline
        %mean(UntestedDeclines)positive
        LinearCD4Decline = 2 * (-IndividualCD4Decline * Pxi.TimeAtLinearDecline + SqrCD4AtRebound) .* IndividualCD4Decline;
        % Calculate the squareroot decline at TimeAtLinearDecline
        CD4AtMidpoint = UntestedCD4AtLinearDecline - TimeSinceLinearDecline * LinearCD4Decline;
    end
    
    
    %Make all <0 CD4s zero
    if (CD4AtMidpoint < 0)
        CD4AtMidpoint = 0;
    end
    
    IndexTest = DiagnosedDuringStep(TestingParameters, CD4AtMidpoint, StepSize);

    if (IndexTest == true)
        RandomDistanceAlongThisStep = rand();
        TimeSinceReboundAtDiagnosis = TimeSinceRebound + RandomDistanceAlongThisStep * StepSize;
        Time = Pxi.TimeUntilRebound + TimeSinceReboundAtDiagnosis;
        MeasuredCD4Count = CD4AtMidpoint;
    end  

    %Finally, to catch problems with testing rates, if it has been more than 20 years, stop
    if TimeSinceRebound > MaxYears
        %Calculate the time
        RandomDistanceAlongThisStep = rand();
        TimeSinceReboundAtDiagnosis = TimeSinceRebound + RandomDistanceAlongThisStep * StepSize;

        Time = Pxi.TimeUntilRebound+TimeSinceReboundAtDiagnosis;
        MeasuredCD4Count = CD4AtMidpoint;
        IndexTest = true;
        %warning('Some of the elements in the GenerateCD4Count reached 50 years, which is probably too long');
    end
    
    TimeSinceRebound = TimeSinceRebound + StepSize;
end
end

