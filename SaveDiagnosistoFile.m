function [ ] = SaveDiagnosistoFile( TotalUndiagnosedByTime,  DiagnosedInfectionsByYear, StepSize)
%The purpose of this function is to write all data relating to diagnosis to
%a file
disp(' ');
disp('------------------------------------------------------------------');
disp('Saving Diagnosed/Undiagnosed Data to an Excel File');
Output_Data = floor(TotalUndiagnosedByTime.Time);
Output_Data = unique(Output_Data);

tempavgstep = mean(TotalUndiagnosedByTime.N);
timetorepeat = 1 / StepSize;
sum = 0;
CountIndex = 1;

for x = 1:length(TotalUndiagnosedByTime.N)
    
    sum = tempavgstep(x) + sum;
    
    if mod(x, timetorepeat) == 0
        Output_Data(2, CountIndex) = ceil(sum);
        CountIndex = CountIndex + 1;
        sum = 0;
    end
end

Output_Data(3, :) = ceil(mean(DiagnosedInfectionsByYear));
Output_Data = Output_Data';

headers = {'Year', 'Total_Undiagnosed_Cases', 'Total_Diagnosed_Cases'};
xlswrite('Results\Year_Diagnosis_Cases.xls', headers, 'Sheet1');
xlswrite('Results\Year_Diagnosis_Cases.xls', Output_Data, 'Sheet1', 'A2');
end

