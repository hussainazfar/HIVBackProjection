function [TimeUntilDiagnosis]=GenerateTimeUntilDiagnosisVaiable(SimulatedPopSize, CurrentPAttempt, NumberOfCD4s, Pxi)

% Using the testing rate, determine the time until testing. 
    % The exponential cummulative distribution for this is:
    % f=1-e^(-kt)
    % at t=1, f=p, where p is the annual probabilty of testing
    % this gives k=-ln(1-p)
    % rearranging the equation in terms of t
    % t=ln(1-f)/ln(1-p)
    
    if Pxi.ConsiderRecentInfection==false %simple annual testing rate, no consideration of recent infection
        TimeUntilDiagnosis=log(1-rand(1,SimulatedPopSize))/log(1-CurrentPAttempt);
    else
        % if the proportion of people who were recently diagnosed is beyond the annual testing rate, then the algorithm should still find some additional people in this group
        if Pxi.PropWithRecentDiagDataPresentThisYear<CurrentPAttempt %TESTED
            OptimisationMultiple=SimulatedPopSize/NumberOfCD4s;%how many simulated cases there are per diagnosed case
            
            %Determine how many should be simulated into the first year
            TotalSimulatedIntoFirstYear=round((CurrentPAttempt-Pxi.PropWithRecentDiagDataPresentThisYear)*SimulatedPopSize);

            %Create the time until diagnosis for those who are expected to be diagnosed within one year
            %randomly choose an exponential decay between year zero and year one
            %t=1-> max(rand)=CurrentPAttempt
            % this ensures the same exponential decay shape while only
            % delivering reults between zero and 1 year 
            % TESTED, works
            TimeUntilDiagnosisFirstYear=log(1-CurrentPAttempt*rand(1,TotalSimulatedIntoFirstYear))/log(1-CurrentPAttempt);
            
            % Determine the total number of people to be diagnosed after one year 
            TotalSimulatedAfterOneYear=SimulatedPopSize-TotalSimulatedIntoFirstYear;
            %Create a time until testing using the exponential distribution and add one year
            TimeUntilDiagnosisOtherYears=1+log(1-rand(1,TotalSimulatedAfterOneYear))/log(1-CurrentPAttempt);
            

            TimeUntilDiagnosis=[TimeUntilDiagnosisFirstYear TimeUntilDiagnosisOtherYears];
            % Randomly shuffle results
            TimeUntilDiagnosis=TimeUntilDiagnosis(randperm(size(TimeUntilDiagnosis,2)));
        else % there are sufficient people with evidence of 
            %for those to be simulated, add one year
            TimeUntilDiagnosis=1+log(1-rand(1,SimulatedPopSize))/log(1-CurrentPAttempt);
        end
    end

end