clear
% Read in data and sort
[~, DateOfDiagnosis, ~]=xlsread('DateOfHIV.xlsx', 'Sheet4','A2:A15525');
CD4Value=xlsread('DateOfHIV.xlsx', 'Sheet4', 'B2:B15525');

% interpret date
YearOfDiagnosis=year(datenum(DateOfDiagnosis, 'dd/mm/yyyy'));
DaysInYear = yeardays(YearOfDiagnosis, 0);

DateOfDiagnosisContinuous=YearOfDiagnosis+  (datenum(DateOfDiagnosis, 'dd/mm/yyyy')-datenum(YearOfDiagnosis, 1,1))./yeardays(YearOfDiagnosis);

%sort

FirstYear=floor(min(DateOfDiagnosisContinuous));
LastYear=floor(max(DateOfDiagnosisContinuous));
NumberOfYears=LastYear-FirstYear+1;

MeanCD4=zeros(1, NumberOfYears);
MedianCD4=zeros(1, NumberOfYears);
STDCD4=zeros(1, NumberOfYears);
NCD4=zeros(1, NumberOfYears);
UQRCD4=zeros(1, NumberOfYears);
LQRCD4=zeros(1, NumberOfYears);
YearCount=1;
for Year=FirstYear:LastYear
    Index=(Year<=DateOfDiagnosisContinuous) & (DateOfDiagnosisContinuous<Year+1);
    CD4ThisYear=CD4Value(Index);
    MeanCD4(YearCount)=mean(CD4ThisYear);
    MedianCD4(YearCount)=median(CD4ThisYear);
    STDCD4(YearCount)=std(CD4ThisYear);
    [NCD4(YearCount), ~]=size(CD4ThisYear);
    UQRCD4(YearCount)=prctile(CD4ThisYear, 75);
    LQRCD4(YearCount)=prctile(CD4ThisYear, 25);
    
    YearCount=YearCount+1;
end

UCI=MeanCD4+1.96*STDCD4./sqrt(NCD4);
LCI=MeanCD4-1.96*STDCD4./sqrt(NCD4);

plot(MeanCD4)
hold on;
plot(UCI)
plot(LCI)
hold off;




plot(MedianCD4)
hold on;
plot(UQRCD4)
plot(LQRCD4)
hold off;
% Plot the out put