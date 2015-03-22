classdef PatientClass
    %Create a Class Definition for all Patients in LineMatrixData
    %Code Sex
            % 1    Male
            % 2    Female
            % 3    Transgender
    %Code Exposure  - Exposure Route category
            % MSM	1
            % MSM IDU	2
            % Bisexual male	3
            % Bisexual male IDU	4
            % Heterosexual	5
            % Heterosexual, not further specified	6
            % Heterosexual IDU	7
            % High prevalence country	8
            % IDU only	9
            % Blood recipient only	10
            % MTCT	11
            % Unknown	12      
       
    properties                                                              %(SetAccess = 'private')
      Sex;
      DateOfDiagnosis;                                                      %text
      DateOfDiagnosisContinuous;                                            %decimal
      YearOfDiagnosis;                                                      %rounded
      TimeFromInfectionToDiagnosis;                                         %used to store an array of the expected distribution of time since infection
      InfectionDateDistribution;                                            %indicates the actual date of infection selected for this individual
      Age;                                                                  %Indicates age of Patient at Diagnosis
      
      %Variables that indicate recent diagnosis
      DateIll;
      DateIndetWesternBlot;
      DateLastNegative;
      
      CD4CountAtDiagnosis;
      ExposureRoute;
                 
      %This variable is to indicate that it is simulated case or a case that has been actually diagnosed in real life
      SimulatedIndividual;                                                  %Set to 0 if real case, 1 if simulated
      RegimenLine;                                                          %number of regimen that the patient is up to
    end                                                                     %End of Properties
    
    methods
        function obj = PatientClass(obj)
            obj.DateIll = NaN;
            obj.DateIndetWesternBlot = NaN;
            obj.DateLastNegative = NaN;
        end  
       
      function obj = DetermineInfectionDateDistribution(obj)
            obj.InfectionDateDistribution = obj.DateOfDiagnosisContinuous - obj.TimeFromInfectionToDiagnosis;
      end
      
      function ExpectedInfections = ExpectedInfectionsPriorTo(obj, Year)    %Gives the fractional (<1) amount
          [~, SizeDistArray] = size(obj.InfectionDateDistribution);
          ExpectedInfections = sum(obj.InfectionDateDistribution<Year) / SizeDistArray;
      end
      
      function PlotDistributionOfTimes(obj)                                 % This function plots the distirbution of time between infection and diagnosis for this individual.
            hist(obj.TimeFromInfectionToDiagnosis, 0.25:0.5:20);
            xlabel('Time until diagnosis (years)','fontsize', 18);
            ylabel('Probability density','fontsize', 18);
            set(gca,'Color',[1.0 1.0 1.0]);
            set(gcf,'Color',[1.0 1.0 1.0]);                                 %makes the grey border white
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
      
    end                                                                     %End of Methods
    
end                                                                         %End of Class Definition