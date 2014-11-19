function [Diagnosis]=DiagnosesByTime(Patient, StartDate, StepSize, EndDate)%End date + stepsize
    Diagnosis.Time=StartDate:StepSize:EndDate;
    Diagnosis.N=zeros(size(Diagnosis.Time));

    for P=Patient
        %add diagnosis date to appropriate position for a fine level reporting
        % Ref=ceil((P.DateOfDiagnosisContinuous-CD4BackProjectionYears(1))/StepSize);
        % The above may be more efficient in javascript later
        Ref=Diagnosis.Time<=P.DateOfDiagnosisContinuous & P.DateOfDiagnosisContinuous <Diagnosis.Time+StepSize;
        if sum(Ref)==1
            Diagnosis.N(Ref)=Diagnosis.N(Ref)+1;
        end
    end
end


