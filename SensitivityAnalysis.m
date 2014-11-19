%function SensitivityAnalysis


% Compare the max incidence with the forced start dates
[MaxIncidence, MaxIncidenceYearIndex]=max(DistributionTotal, [], 2);
plot(Px.FirstInfectionDateVec, MaxIncidence, '.', 'MarkerSize', 20)
ylim([0, inf])

%Display R values and P values
[r, rp]=corrcoef(Px.FirstInfectionDateVec, MaxIncidence);
rstring=['r=' num2str(r(1,2))];
if rp(1, 2)<0.001
    pstring='p<0.001';
else
    pstring=['p=', num2str(rp(1, 2))];
end
yrange=get(gca,'ylim');
xrange=get(gca,'xlim');
htexthandle=text(xrange(1)+0.04*(xrange(2)-xrange(1)),yrange(1)+0.10*(yrange(2)-yrange(1)),{rstring, pstring} );
set(htexthandle, 'FontSize', 18);

xlabel('First infection date','fontsize', 22);
ylabel('Peak incidence','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
 
print('-dpng ','-r300','ResultsPlots/Appendix Max inc v first infection.png')




%plot(Px.FirstInfectionDateVec,YearVectorLabel(MaxIncidenceYearIndex))

% Compare post primary CD4 infection to time between infection and diagnosis
plot(Px.BaselineCD4MedianVec,TimeSinceInfectionMatrix(end).Median, '.', 'MarkerSize', 20)
ylim([0, inf])

%Display R values and P values
[r, rp]=corrcoef(Px.BaselineCD4MedianVec, TimeSinceInfectionMatrix(end).Median);
rstring=['r=' num2str(r(1,2))];
if rp(1, 2)<0.001
    pstring='p<0.001';
else
    pstring=['p=', num2str(rp(1, 2))];
end
yrange=get(gca,'ylim');
xrange=get(gca,'xlim');
htexthandle=text(xrange(1)+0.04*(xrange(2)-xrange(1)),yrange(1)+0.10*(yrange(2)-yrange(1)),{rstring, pstring} );
set(htexthandle, 'FontSize', 18);

xlabel('Median post-primary CD4 count','fontsize', 22);
ylabel('Median time until diagnosis (years)','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
lsline
print('-dpng ','-r300','ResultsPlots/Appendix post-primary CD4 v time until diag.png')





% Compare CD4 decline to time between infection and diagnosis
plot(Px.SQRCD4DeclineVec,TimeSinceInfectionMatrix(end).Median, '.', 'MarkerSize', 20)
ylim([0, inf])

%Display R values and P values
[r, rp]=corrcoef(Px.SQRCD4DeclineVec, TimeSinceInfectionMatrix(end).Median);
rstring=['r=' num2str(r(1,2))];
if rp(1, 2)<0.001
    pstring='p<0.001';
else
    pstring=['p=', num2str(rp(1, 2))];
end
yrange=get(gca,'ylim');
xrange=get(gca,'xlim');
htexthandle=text(xrange(1)+0.04*(xrange(2)-xrange(1)),yrange(1)+0.10*(yrange(2)-yrange(1)),{rstring, pstring} );
set(htexthandle, 'FontSize', 18);

xlabel('Median square root CD4 decline','fontsize', 22);
ylabel('Median time until diagnosis (years)','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
lsline
print('-dpng ','-r300','ResultsPlots/Appendix sqr decline v time until diag.png')



% Compare CD4 decline to incidence in final year
plot(Px.SQRCD4DeclineVec,DistributionTotal(:, end), '.', 'MarkerSize', 20)
ylim([0, inf])

%Display R values and P values
[r, rp]=corrcoef(Px.SQRCD4DeclineVec, DistributionTotal(:, end));
rstring=['r=' num2str(r(1,2))];
if rp(1, 2)<0.001
    pstring='p<0.001';
else
    pstring=['p=', num2str(rp(1, 2))];
end
yrange=get(gca,'ylim');
xrange=get(gca,'xlim');
htexthandle=text(xrange(1)+0.04*(xrange(2)-xrange(1)),yrange(1)+0.10*(yrange(2)-yrange(1)),{rstring, pstring} );
set(htexthandle, 'FontSize', 18);

xlabel('Median square root CD4 decline','fontsize', 22);
ylabel('Incidence in final year of simulation','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
lsline
print('-dpng ','-r300','ResultsPlots/Appendix sqr decline v incidence in final year.png')


% Compare baseline post-primary infection CD4 to incidence in final year
plot(Px.BaselineCD4MedianVec,DistributionTotal(:, end), '.', 'MarkerSize', 20)
ylim([0, inf])

%Display R values and P values
[r, rp]=corrcoef(Px.BaselineCD4MedianVec, DistributionTotal(:, end));
rstring=['r=' num2str(r(1,2))];
if rp(1, 2)<0.001
    pstring='p<0.001';
else
    pstring=['p=', num2str(rp(1, 2))];
end
yrange=get(gca,'ylim');
xrange=get(gca,'xlim');
htexthandle=text(xrange(1)+0.04*(xrange(2)-xrange(1)),yrange(1)+0.10*(yrange(2)-yrange(1)),{rstring, pstring} );
set(htexthandle, 'FontSize', 18);

xlabel('Median CD4 following primary infection','fontsize', 22);
ylabel('Incidence in final year of simulation','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;
lsline

print('-dpng ','-r300','ResultsPlots/Appendix Baseline CD4 v incidence in final year.png')
