%% Create a plot of the expected distributions of time until diagnosis for different CD4 counts in Australia


% %Select CD4s from YearOfDiagnosedDataEnd
% CD4ForOptimisation=-ones(size(Patient));
% Count=0;
% for P=Patient
%     Count=Count+1;
%     if (P.DateOfDiagnosisContinuous>=YearOfDiagnosedDataEnd-5 && P.DateOfDiagnosisContinuous<YearOfDiagnosedDataEnd)
%         CD4ForOptimisation(Count)=P.CD4CountAtDiagnosis;
%     end
% end
% CD4ForOptimisation(CD4ForOptimisation<-0.5)=[];
% 
% % the following is done as a hack to increase the samples to make a smooth curve
% CD4ForOptimisation=[CD4ForOptimisation CD4ForOptimisation CD4ForOptimisation CD4ForOptimisation];


disp( 'Starting parallel Matlab...');
matlabpool(str2num(getenv( 'NUMBER_OF_PROCESSORS' ))-2);%this may not work in all processors

% NumberOfTimeSamples=100;
% [Times, StartingCD4, TestingProbVec, IdealPopTimesStore, IdealPopTestingCD4 ]=CreateIndividualTimeUntilDiag(CD4ForOptimisation, Ax, NumberOfTimeSamples, RandomNumberStream);
% [Times, StartingCD4, TestingParameter]=CreateIndividualTimeUntilDiag(CD4ForOptimisation, Ax, RandomNumberStream);
% IdealPopTimesStore= GenerateCD4 using TestingParameter and PX.Number of CD4s to generate = big as ofund in CreateIndividualTimeUntilDiag
SamplesPerSim=10000;
parfor CurrentParamNumber=1:Px.NoParameterisations 
    set(RandomNumberStream,'Substream',CurrentParamNumber);
    
    %Choose the current parameterision
    Pxi=Px;

    
    
    Pxi.FractionalDeclineToRebound=Px.FractionalDeclineToReboundVec(CurrentParamNumber); % select a sample of this parameter
    Pxi.SQRCD4Decline=Px.SQRCD4DeclineVec(CurrentParamNumber);
    Pxi.SimulatedPopSize=SamplesPerSim;
    OptimisedParameters=OptimisationResults(end).TestingParameter(CurrentParamNumber).Result;%use the last year's worth of data
    [~, Data(CurrentParamNumber)]=GenerateCD4Count(OptimisedParameters, Pxi);

    
%     IdealPopTimesStore=Data.Time;
%     IdealPopTestingCD4=Data.CD4;
    
end

matlabpool close;

%% Realign the data 
TimeDitributionToSample=zeros(1,Px.NoParameterisations*SamplesPerSim);
CD4DistributionToSample=zeros(1,Px.NoParameterisations*SamplesPerSim);
for CurrentParamNumber=1:Px.NoParameterisations
    TimeDitributionToSample((CurrentParamNumber-1)*SamplesPerSim+1:(CurrentParamNumber)*SamplesPerSim)=Data(CurrentParamNumber).Time;
    CD4DistributionToSample((CurrentParamNumber-1)*SamplesPerSim+1:(CurrentParamNumber)*SamplesPerSim)=Data(CurrentParamNumber).CD4;
end


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

%% Select the data that has observations closse to the 200, 350 and 500
Count=0;
for iCD4=PlotSettings.ListOfCD4sToPlot
    Count=Count+1;
    Index=(CD4DistributionToSample<iCD4+10)&(CD4DistributionToSample>iCD4-10);
    
    MedianTimeUntilDiagnosisAtCD4=median(TimeDitributionToSample(Index));
    LQRTimeUntilDiagnosisAtCD4=prctile(TimeDitributionToSample(Index), 25);
    UQRTimeUntilDiagnosisAtCD4=prctile(TimeDitributionToSample(Index), 75);
    disp(['The median estimated time between infection and diagnosis was ' num2str(MedianTimeUntilDiagnosisAtCD4, '%.1f') ' (IQR: ' num2str(LQRTimeUntilDiagnosisAtCD4, '%.1f') '-' num2str(UQRTimeUntilDiagnosisAtCD4, '%.1f') ') years for diagnoses with CD4 counts of ' num2str(iCD4) 'cells/microL at diagnosis.']);
    
    Output=hist(TimeDitributionToSample(Index), CD4TimeHistPlotSpacing);
    Output=Output/sum(Output)/StepSize;%Normalise, divide by StepSize to make it look better
    PlotHandle{Count}=plot(CD4TimeHistPlotSpacing, Output, 'Color' , ColourHolder{Count},'LineWidth',2);
end

%% Format the graph
xlabel('Time between infection and diagnosis (years)','fontsize', 22);
ylabel('Annual probability','fontsize', 22);
set(gca,'Color',[1.0 1.0 1.0]);
set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
set(gca, 'fontsize', 18)
box off;

xlim([0 15])
set(gca,'XTick',0:15)
    
h_legend=legend([PlotHandle{1} PlotHandle{2} PlotHandle{3}], [num2str(PlotSettings.ListOfCD4sToPlot(1)) '  cells/\muL'], [num2str(PlotSettings.ListOfCD4sToPlot(2)) '  cells/\muL'] , [num2str(PlotSettings.ListOfCD4sToPlot(3)) '  cells/\muL'], 'Location','NorthEast');
set(h_legend, 'fontsize', 16)
%Make a title for the legend
h_title=get(h_legend, 'title');
set(h_title, 'string', 'CD4 count at diagnosis');
set(h_title, 'fontsize', 16)

legend('boxon')

print('-dpng ','-r300','ResultsPlots/Figure 2 Time since infection distributions by CD4.png')
hold off;