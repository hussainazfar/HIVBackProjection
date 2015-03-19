function [Undiagnosed] = UndiagnosedByTime(Patient, StartDate, StepSize, EndDate)
    Undiagnosed.Time = StartDate:StepSize:EndDate;
    [~, NumberOfYearSlots] = size(Undiagnosed.Time);
    [~, NoParameterisations] = size(Patient(1).InfectionDateDistribution);
    Undiagnosed.N = zeros(NoParameterisations, NumberOfYearSlots);

    x = 0;
       
    for P = Patient
        x = x + 1;
        
        if mod(x, 1000) == 0
            fprintf(1, 'Progress: %.2f%%\n', (100*x/length(Patient)));             %disp(['Finding when patient ' num2str(x) ' is undiagnosed']);
        end
        
        YearSlotCount = 0;
        for YearStep = Undiagnosed.Time;
            YearSlotCount = YearSlotCount+1;
            UndiagnosedAddtionVector = (P.InfectionDateDistribution < YearStep) & (YearStep < P.DateOfDiagnosisContinuous);
            %Add this value to the matrix across the no. simulations dimension
            Undiagnosed.N(:, YearSlotCount) = Undiagnosed.N(:, YearSlotCount) + UndiagnosedAddtionVector';
        end
    end
end