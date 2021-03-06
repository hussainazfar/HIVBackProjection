function [ CD4CountHistogram, Data ] = GenerateCD4Count( TestingParameters, Pxi )
%GenerateCD4Count function takes a healthy population and simulates the CD4 decline
% according to assumptions contained in in Pxi and the TestingP. In doing
% so, it creates the number of people expected in the correct proportions
% by CD4.

%Start with the number of observations
SimulatedPopSize = Pxi.SimulatedPopSize;

%NumIndex = 1:SimulatedPopSize;

%Initialize object PatientCD4 of class CD4Class
PatientCD4(1:Pxi.SimulatedPopSize) = CD4Class;

%% Generate an initial distribution, i.e. Generate Starting CD4 Count
for x = 1:SimulatedPopSize
    [ PatientCD4 ] = CreateCD4Object(Pxi, PatientCD4);
end

%% For all people, find the time after which the person was defined as diagnosed
for y = 1:SimulatedPopSize
    %Testing to see if Patient is Diagnosed During Rapid Decline
    [ PatientCD4(y).IndexTest, PatientCD4(y).AverageCD4Count, PatientCD4(y).Time, PatientCD4(y).MeasuredCD4Count ] = TestRapidDecline(PatientCD4(y).StartingCD4Count, Pxi, TestingParameters);
         
    if (PatientCD4(y).IndexTest == false)
        %Testing to see if Patient is Diagnosed During Rapid Rebound
        [ PatientCD4(y).IndexTest, PatientCD4(y).AverageCD4Count, PatientCD4(y).Time, PatientCD4(y).MeasuredCD4Count ] = TestRapidRebound(PatientCD4(y).StartingCD4Count, Pxi, TestingParameters);
    else
        continue
    end
    
    if (PatientCD4(y).IndexTest == false)
        %Testing to see when patient was diagnosed and CD4 Count at
        %Diagnosis
        [ PatientCD4(y).IndexTest, PatientCD4(y).AverageCD4Count, PatientCD4(y).Time, PatientCD4(y).MeasuredCD4Count ] = TestSQRDecline(PatientCD4(y).StartingCD4Count, Pxi, TestingParameters, Pxi.StepSize, Pxi.MaxYears);
    else
        continue
    end
end

for x = 1:SimulatedPopSize
    Data.CD4(x) = PatientCD4(x).MeasuredCD4Count;
end

mu = Data.CD4;
logmu = log(mu+1);%plus 10 to avoid the problems associated with log zero. Note that for people with a CD4 of zero, this should be within range when selecting "nearest neighbours"
sigma = 0.930 - 0.110*logmu;
LogSamples = normrnd(logmu,sigma);
Data.CD4 = exp(LogSamples);

% Return results
CD4CountHistogram=hist(Data.CD4, 50:100:1450);

end
