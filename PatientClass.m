classdef PatientClass %< handle  
   properties %(SetAccess='private')
%       HIVStatus;
%       AIDSStatus;
%       Alive;
      YearBirth;
      Sex;
      DateOfDiagnosis;%text
      DateOfDiagnosisContinuous;%decimal
      YearOfDiagnosis;%rounded
      TimeFromInfectionToDiagnosis;%used to store an array of the expected distribution of time since infection
%       InfectionDate;%indicates the actual date of infection selected for this individual 
      InfectionDateDistribution;%indicates the actual date of infection selected for this individual
      YearOfAIDSDiagnosis;
      %YearTable;%%%%%%%%%%%DEPRECIATED
%       YearFirstTreatment;%the year that patient goes on to treatment for the first time
      IndigenousStatus;
      PostcodeAtDiagnosis;
      StateAtDiagnosis;
      SLAAtDiagnosis;
      SRAtDiagnosis;
      SSDAtDiagnosis;
%       PopulationCategory;%Category values
%       % GroupCode.MSM=1;
%       % GroupCode.HeteroOnlyMale=2;
%       % GroupCode.Female=3;
%       % GroupCode.MSMIDU=4;
%       % GroupCode.HeteroOnlyMaleIDU=5;
%       % GroupCode.FemaleIDU=6;
      

      
      CD4CountAtDiagnosis;
      ExposureRoute;
%       DateOfDeath;
%       DateOfDeathContinuous;
      YearOfDeath;%this is the only death flag (decimal year)
      PreviouslyDiagnosedOverseas;
      OverseasDiagnosisCountry;
      OverseasDiagnosisDate;
      RecentInfection;
      CountryOfBirth;
      

      HAARTStart;
      HAARTStop;
      
      %This variable is to indicate that it is simulated case or a case that has been actually diagnosed in real life
      %Set to 0 if real case, 1 if simulated
      SimulatedIndividual;
      
      
      RegimenLine;%number of regimen that the patient is up to
%       CD4CountArray;

%       Condition;%an array of conditions that have corresponding numerical code. Days from start of simulation until condition appears
%       Cancer;%an array of cancers that have corresponding numerical code. Days from start of simulation until condition appears
      %Cancer(i).Year: year of cancer (i) diagnosis
      %Cancer(i).Name:Name of Cancer
      %Cancer(i).Code: code of cancer
   end% properties

   methods

      function obj = PatientClass

      end
      

%       function obj = set.Alive(obj, Alive)
%          if Alive~=0 &&  Alive~=1
%             error('Incorrect alive status entered (not 1 or 0)')
%          end
%          obj.Alive = Alive;
%          
%       end 
%       
% 
%       function obj = set.HIVStatus(obj, HIVStatus)
%          if HIVStatus~=0 &&  HIVStatus~=1
%             error('Incorrect HIV status entered (not 1 or 0)')
%          end
%          obj.HIVStatus = HIVStatus;
%       end 
%       
% 
%       function obj = set.AIDSStatus(obj, AIDSStatus)
%          if AIDSStatus~=0 &&  AIDSStatus~=1
%             error('Incorrect AIDS status entered (not 1 or 0)')
%          end
%          obj.AIDSStatus = AIDSStatus;
%       end 
      

      
      
      function Age=CurrentAge(obj, Year)
          Age=Year-obj.YearBirth;
      end
      
      function AliveAndHIV=AliveAndHIVPosInYear(obj, Year)
          
          %This is a vectorised form to allow fast processing
          AliveAndHIV=obj.DateOfDiagnosisContinuous<=Year & Year<obj.YearOfDeath;
          
      end
      
      function AIDSStatus = CurrentAIDSStatus(obj, CurrentYear)
          if CurrentYear>=obj.YearOfAIDSDiagnosis
              AIDSStatus=true;
          else
              AIDSStatus=false;
          end
      end
      
      
      
      function obj = DetermineInfectionDateDistribution(obj)

          obj.InfectionDateDistribution=obj.DateOfDiagnosisContinuous- obj.TimeFromInfectionToDiagnosis;
      end
      
      function ExpectedInfections = ExpectedInfectionsPriorTo(obj, Year)
          %Gives the fractional (<1) amount of 
          [~, SizeDistArray]=size(obj.InfectionDateDistribution);
          ExpectedInfections=sum(obj.InfectionDateDistribution<Year)/SizeDistArray;
      end
      
      function PlotDistributionOfTimes(obj)
          % This function plots the distirbution of time between infection
          % and diagnosis for this individual.
            hist(obj.TimeFromInfectionToDiagnosis, 0.25:0.5:20);
            xlabel('Time until diagnosis (years)','fontsize', 18);
            ylabel('Probability density','fontsize', 18);
            set(gca,'Color',[1.0 1.0 1.0]);
            set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
            set(gca, 'fontsize', 18)
            box off;
            
            print('-dpng ','-r300',['TimeUntilDiagnosis' num2str(obj.CD4CountAtDiagnosis) '.png'])
            
            disp('CD4')
            disp(obj.CD4CountAtDiagnosis)
            disp('mean time to diagnosis')
            disp(mean(obj.TimeFromInfectionToDiagnosis))
            disp('median time to diagnosis')
            disp(median(obj.TimeFromInfectionToDiagnosis))
      end
      
      
      

   end% methods
end% classdef