%% Collate results for table 6.1.1

clear Temp
YearRanges=1980:YearOfDiagnosedDataEnd;
[~, YearSize]=size(YearRanges);
SimSize=200;
GenderSize=2;
StateSize=9;
[~, NoPatients]=size(AllPatients);
TotalPeople=zeros(YearOfDiagnosedDataEnd-1980+1, SimSize);

MatrixValues=zeros(YearSize, GenderSize, StateSize, SimSize);

YearCount=0;
for Year=1980:YearOfDiagnosedDataEnd
    YearCount=YearCount+1;
    disp(Year)
    for i=1:NoPatients
        
        TotalPeople(YearCount, :)=TotalPeople(YearCount, :)+AllPatients(i).AliveAndHIVPosInYear(Year);
        Temp(1, 1, 1, :)=AllPatients(i).AliveAndHIVPosInYear(Year);

        if AllPatients(i).Sex==1 || AllPatients(i).Sex==3
            SexValue=1;
        else
            SexValue=2;
        end
        

        MatrixValues(YearCount, SexValue,  AllPatients(i).StateAtDiagnosis, :)=MatrixValues(YearCount, SexValue,  AllPatients(i).StateAtDiagnosis, :)+Temp;
    end
end

TotalMedian=median(TotalPeople, 2);
TotalLCI=prctile(TotalPeople, 2.5, 2);
TotalUCI=prctile(TotalPeople, 97.5, 2);
hold off
plot(YearRanges, TotalMedian)

TotalThisYearUncertainty=[TotalMedian(YearRanges==YearOfDiagnosedDataEnd),TotalLCI(YearRanges==YearOfDiagnosedDataEnd),TotalUCI(YearRanges==YearOfDiagnosedDataEnd) ];
disp('The total number of people currently living with diagnosed HIV is (95% uncertainty bounds)');
disp([num2str(TotalThisYearUncertainty(1)) ' (' num2str(TotalThisYearUncertainty(2)) '-' num2str(TotalThisYearUncertainty(3)) ')']);
TotalLastYearUncertainty=[TotalMedian(YearRanges==YearOfDiagnosedDataEnd-1),TotalLCI(YearRanges==YearOfDiagnosedDataEnd-1),TotalUCI(YearRanges==YearOfDiagnosedDataEnd-1) ];

% Results by state
StateSum=squeeze(sum(MatrixValues, 2));
ResultsState=median(StateSum, 3);
ResultsStateLCI=prctile(StateSum, 2.5, 3);
ResultsStateUCI=prctile(StateSum, 97.5, 3);

% 2012
StateUncertaintyLastYear=[ResultsState(YearRanges==YearOfDiagnosedDataEnd-1, :);ResultsStateLCI(YearRanges==YearOfDiagnosedDataEnd-1, :);ResultsStateUCI(YearRanges==YearOfDiagnosedDataEnd-1, :) ];
%2013
StateUncertaintyThisYear=[ResultsState(YearRanges==YearOfDiagnosedDataEnd, :);ResultsStateLCI(YearRanges==YearOfDiagnosedDataEnd, :);ResultsStateUCI(YearRanges==YearOfDiagnosedDataEnd, :) ];

% Results by sex
SexSum=squeeze(sum(MatrixValues, 3));
ResultsSex=median(SexSum, 3);
ResultsSexLCI=prctile(SexSum, 2.5, 3);
ResultsSexUCI=prctile(SexSum, 97.5, 3);
SexUncertaintyThisYear=[ResultsSex(YearRanges==YearOfDiagnosedDataEnd, :);ResultsSexLCI(YearRanges==YearOfDiagnosedDataEnd, :);ResultsSexUCI(YearRanges==YearOfDiagnosedDataEnd, :) ];


% Results by sex and state
ResultsDetailed=median(MatrixValues, 4);
ResultsDetailedLCI=prctile(MatrixValues, 2.5, 4);
ResultsDetailedUCI=prctile(MatrixValues, 97.5, 4);

% The 2012 report figure (for checking)
LastYearsTable=squeeze(ResultsDetailed(YearRanges==YearOfDiagnosedDataEnd-1, :, :));
% The 2013 report figures by sex and state
ThisYearsTable=squeeze(ResultsDetailed(YearRanges==YearOfDiagnosedDataEnd, :, :));
ThisYearsTableLCI=squeeze(ResultsDetailedLCI(YearRanges==YearOfDiagnosedDataEnd, :, :));
ThisYearsTableUCI=squeeze(ResultsDetailedUCI(YearRanges==YearOfDiagnosedDataEnd, :, :));


ResultForReport=ThisYearsTable';
ResultForReportLCI=ThisYearsTableLCI';
ResultForReportUCI=ThisYearsTableUCI';

% NSW	2	1
% VIC	7	2
% QLD	4	3
% SA	5	4
% WA	8	5
% TAS	6	6
% NT	3	7
% ACT	1	8