clear
% Read in data and sort
[~, DateOfDiagnosis, ~]=xlsread('DateOfHIV2013.xlsx', 'Combined','A2:A16569');
All.CD4Value=xlsread('DateOfHIV2013.xlsx', 'Combined', 'B2:B16569');

% interpret date
YearOfDiagnosis=year(datenum(DateOfDiagnosis, 'dd/mm/yyyy'));
DaysInYear = yeardays(YearOfDiagnosis, 0);
All.DateOfDiagnosisContinuous=YearOfDiagnosis+  (datenum(DateOfDiagnosis, 'dd/mm/yyyy')-datenum(YearOfDiagnosis, 1,1))./yeardays(YearOfDiagnosis);

% % Select MSM
% %1, 2, 4, 11, 16
% 
% % Read in data and sort
% [~, DateOfDiagnosis, ~]=xlsread('DateOfHIV.xlsx', 'MSMCategories','A2:A12651');
% MSM.CD4Value=xlsread('DateOfHIV.xlsx', 'MSMCategories', 'B2:B12651');
% 
% % interpret date
% YearOfDiagnosis=year(datenum(DateOfDiagnosis, 'dd/mm/yyyy'));
% DaysInYear = yeardays(YearOfDiagnosis, 0);
% MSM.DateOfDiagnosisContinuous=YearOfDiagnosis+  (datenum(DateOfDiagnosis, 'dd/mm/yyyy')-datenum(YearOfDiagnosis, 1,1))./yeardays(YearOfDiagnosis);
% 
% % Read in data and sort
% [~, DateOfDiagnosis, ~]=xlsread('DateOfHIV.xlsx', 'NonMSMCategories','A2:A2875');
% NonMSM.CD4Value=xlsread('DateOfHIV.xlsx', 'NonMSMCategories', 'B2:B2875');
% 
% % interpret date
% YearOfDiagnosis=year(datenum(DateOfDiagnosis, 'dd/mm/yyyy'));
% DaysInYear = yeardays(YearOfDiagnosis, 0);
% NonMSM.DateOfDiagnosisContinuous=YearOfDiagnosis+  (datenum(DateOfDiagnosis, 'dd/mm/yyyy')-datenum(YearOfDiagnosis, 1,1))./yeardays(YearOfDiagnosis);

FirstYear=floor(min(All.DateOfDiagnosisContinuous));
LastYear=floor(max(All.DateOfDiagnosisContinuous));

% Sort by date
[All.MeanCD4, All.UCI, All.LCI, All.MedianCD4, All.UQRCD4, All.LQRCD4]=CalculateStatistics(FirstYear, LastYear, All.DateOfDiagnosisContinuous, All.CD4Value);
% [MSM.MeanCD4, MSM.UCI, MSM.LCI, MSM.MedianCD4, MSM.UQRCD4, MSM.LQRCD4]=CalculateStatistics(FirstYear, LastYear, MSM.DateOfDiagnosisContinuous, MSM.CD4Value);
% [NonMSM.MeanCD4, NonMSM.UCI, NonMSM.LCI, NonMSM.MedianCD4, NonMSM.UQRCD4, NonMSM.LQRCD4]=CalculateStatistics(FirstYear, LastYear, NonMSM.DateOfDiagnosisContinuous, NonMSM.CD4Value);
% [MeanCD4, UCI, LCI, MedianCD4, UQRCD4, LQRCD4]=CalculateStatistics(FirstYear, LastYear, DateOfDiagnosisContinuous, CD4Value);
% [MeanCD4, UCI, LCI, MedianCD4, UQRCD4, LQRCD4]=CalculateStatistics(FirstYear, LastYear, DateOfDiagnosisContinuous, CD4Value);
%[MeanCD4, UCI, LCI, MedianCD4, UQRCD4, LQRCD4]=CalculateStatistics(FirstYear, LastYear, DateOfDiagnosisContinuous, CD4Value);


Year=FirstYear:LastYear;
clf;
CreateUncertaintyPlot(Year, All.MeanCD4, All.UCI, All.LCI, 'b');
xlabel('Year of diagnosis','fontsize', 22);
ylabel('Mean CD4 count at diagnosis (95% CI)','fontsize', 22);
set(gca,'XTick',1980:5:2015)
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
print('-dpng ','-r300','Appendix2 Mean95%CI CD4.png')

% clf;
% MSMHandle=CreateUncertaintyPlot(Year-0.1, MSM.MeanCD4, MSM.UCI, MSM.LCI, 'b');
% hold on;
% NonMedianHandle=CreateUncertaintyPlot(Year+0.1, NonMSM.MeanCD4, NonMSM.UCI, NonMSM.LCI, 'r');
% xlabel('Year of diagnosis','fontsize', 22);
% ylabel('Mean CD4 count at diagnosis (95% CI)','fontsize', 22);
% set(gca,'XTick',1980:5:2015)
% set(gca,'Color',[1.0 1.0 1.0]);
% set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
% set(gca, 'fontsize', 18)
% box off;
% h_legend=legend([ MSMHandle NonMedianHandle], {'MSM', 'Non-MSM'} ,  'Location','NorthEast');
% print('-dpng ','-r300','MSMvsNonMSM Mean95%CI CD4.png')
% 
% 
% 
% clf;
% Year=FirstYear:LastYear;
% CreateUncertaintyPlot(Year, All.MedianCD4, All.UQRCD4, All.LQRCD4, 'b');
% xlabel('Year of diagnosis','fontsize', 22);
% ylabel('Median CD4 count at diagnosis (IQR)','fontsize', 22);
% set(gca,'XTick',1980:5:2015)
% set(gca,'Color',[1.0 1.0 1.0]);
% set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
% set(gca, 'fontsize', 18)
% box off;
% print('-dpng ','-r300','Appendix2 MedianIQR CD4.png')
% 
% clf;
% Year=FirstYear:LastYear;
% MSMHandle=CreateUncertaintyPlot(Year-0.1, MSM.MedianCD4, MSM.UQRCD4, MSM.LQRCD4, 'b');
% hold on;
% NonMedianHandle=CreateUncertaintyPlot(Year+0.1, NonMSM.MedianCD4, NonMSM.UQRCD4, NonMSM.LQRCD4, 'r');
% xlabel('Year of diagnosis','fontsize', 22);
% ylabel('Median CD4 count at diagnosis (IQR)','fontsize', 22);
% set(gca,'XTick',1980:5:2015)
% set(gca,'Color',[1.0 1.0 1.0]);
% set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
% set(gca, 'fontsize', 18)
% box off;
% h_legend=legend([ MSMHandle NonMedianHandle], {'MSM', 'Non-MSM'} ,  'Location','NorthEast');
% print('-dpng ','-r300','MSMvsNonMSM MedianIQR CD4.png')
