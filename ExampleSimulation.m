clc; 
clear;
NumberOfTimeSamples=200;
[Px]=LoadBackProjectionParameters(NumberOfTimeSamples, 1);
ExampleData; %Load the example data, CD4ForOptimisation

RandomNumberStream = RandStream('mlfg6331_64','Seed',158943);
RandStream.setGlobalStream(RandomNumberStream);

Px.ConsiderRecentInfection=0;
%If you have evidence of some of the patient records containing evidence of
%recent infection (last 12 months) the algorithm will automatically adjust
%to place less of the infections within the last 12 months.
%Px.ConsiderRecentInfection=1;
%Px.PropWithRecentDiagDataPresentThisYear=0.3;

disp( 'Starting parallel Matlab...');
matlabpool(getenv( 'NUMBER_OF_PROCESSORS' ));%this may not work in all processors

disp('Finding 100 times for each of the CD4 counts at diagnosis in the data set');
[Times, StartingCD4, TestingProbVec, IdealPopTimesStore, IdealPopTestingCD4 ]=CreateIndividualTimeUntilDiag(CD4ForOptimisation, Px, NumberOfTimeSamples, RandomNumberStream);
matlabpool close;

clf;%clear the figure
hold on;
for SimNum=1:NumberOfTimeSamples
    plot(CD4ForOptimisation, (Times(:, SimNum))', '.');
end
hold off;

print('-dpng ','-r300','ResultsPlots/Time vs CD4 of example data.png')






TimeDitributionToSample=reshape(IdealPopTimesStore, 1, []);
CD4DistributionToSample=reshape(IdealPopTestingCD4, 1, []);

PlotSettings.ListOfCD4sToPlot=[200 350 500];
CD4TimeHistPlotSpacing=(0.0:0.1:20)+0.05;
ColourHolder{1}=[1.0 0.0 0.0];
ColourHolder{2}=[0.0 0.0 1.0];
ColourHolder{3}=[0.0 1.0 0.0];

ColourHolder{1}=[0.0 0.0 0.0];
ColourHolder{2}=[0.4 0.4 0.4];
ColourHolder{3}=[0.8 0.8 0.8];
LineStyleHolder{1}='-';
LineStyleHolder{2}='-';
LineStyleHolder{3}='-';

clf;%clear the current figure ready for plotting
hold on;
Count=0;
for iCD4=PlotSettings.ListOfCD4sToPlot
    Count=Count+1;
    Index=(CD4DistributionToSample<iCD4+10)&(CD4DistributionToSample>iCD4-10);
    
    MedianTimeUntilDiagnosisAtCD4=median(TimeDitributionToSample(Index));
    disp(['The median estimated time between infection and diagnosis was ' num2str(MedianTimeUntilDiagnosisAtCD4, '%.1f') ' years for diagnoses with CD4 counts of ' num2str(iCD4) 'cells/microL at diagnosis.']);
    
    Output=hist(TimeDitributionToSample(Index), CD4TimeHistPlotSpacing);
    Output=Output/sum(Output);%Normalise
    PlotHandle{Count}=plot(CD4TimeHistPlotSpacing, Output, 'Color' , ColourHolder{Count},'LineWidth',2);
end


xlabel('Time between infection and diagnosis (years)','fontsize', 22);
ylabel('Probability','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;

xlim([0 15])
set(gca,'XTick',0:15)
    
h_legend=legend([PlotHandle{1} PlotHandle{2} PlotHandle{3}], [num2str(PlotSettings.ListOfCD4sToPlot(1)) '  (cells/\muL)'], [num2str(PlotSettings.ListOfCD4sToPlot(2)) '  (cells/\muL)'] , [num2str(PlotSettings.ListOfCD4sToPlot(3)) '  (cells/\muL)'], 'Location','NorthEast');
set(h_legend, 'fontsize', 16)
%Make a title for the legend
h_title=get(h_legend, 'title');
set(h_title, 'string', 'CD4 count at diagnosis');
set(h_title, 'fontsize', 16)

legend('boxon')

print('-dpng ','-r300','ResultsPlots/Distribution of time since infection of example data.png')
hold off;