function [Undiagnosed]=UndiagnosedByTime(Patient, StartDate, StepSize, EndDate)
    Undiagnosed.Time=StartDate:StepSize:EndDate;
    [~, NumberOfYearSlots]=size(Undiagnosed.Time);
    [~, NoParameterisations]=size(Patient(1).InfectionDateDistribution);
    Undiagnosed.N=zeros(NoParameterisations, NumberOfYearSlots);

    i=0;
    for P=Patient
        i=i+1;
        if mod(i, 100)==0
            disp(['Finding when patient ' num2str(i) ' is undiagnosed']);
        end
        
        YearSlotCount=0;
        for YearStep=Undiagnosed.Time;
            YearSlotCount=YearSlotCount+1;
            UndiagnosedAddtionVector=P.InfectionDateDistribution<YearStep & YearStep<P.DateOfDiagnosisContinuous ;
            %Add this value to the matrix across the no. simulations dimension
            Undiagnosed.N(:, YearSlotCount)=Undiagnosed.N(:, YearSlotCount)+UndiagnosedAddtionVector';
        end
    end
end