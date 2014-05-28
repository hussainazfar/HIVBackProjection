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
Year=FirstYear:LastYear;

CreateUncertaintyPlot(Year, MeanCD4, UCI, LCI);
xlabel('Year of diagnosis','fontsize', 22);
ylabel('Mean CD4 count at diagnosis (95% CI)','fontsize', 22);
set(gca,'XTick',1980:5:2015)
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
print('-dpng ','-r300','Appendix2 Mean95%CI CD4.png')


Year=FirstYear:LastYear;
CreateUncertaintyPlot(Year, MedianCD4, UQRCD4, LQRCD4);
xlabel('Year of diagnosis','fontsize', 22);
ylabel('Median CD4 count at diagnosis (IQR)','fontsize', 22);
set(gca,'XTick',1980:5:2015)
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
print('-dpng ','-r300','Appendix2 MedianIQR CD4.png')
