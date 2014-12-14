classdef MortalityClass < handle 
    properties 

        

        
        RatioAgeRange;
        RatioYearRange
        
        HIVSMR;
        AIDSSMR;
        
        
        YearlyPOfDeathMale;
        YearlyPOfDeathFemale;
        MortalityTableYearIndex;
        MortalityTableAgeIndex;
        YearDimSize;
        AgeDimSize;
        
        randvectorsize;
        randvector;
        randcount;
    end% properties

    methods
        function obj = LoadData(obj, MortalityTableFile, SMRFile,  NumberOfSamplesForLHSSMR)
            % Load the healthy population data
            obj.YearlyPOfDeathMale=xlsread(MortalityTableFile, 'malemortalitybyyear',  'B2:AJ102');
            obj.YearlyPOfDeathFemale=xlsread(MortalityTableFile, 'femalemortalitybyyear',  'B2:AJ102');
            obj.MortalityTableYearIndex=xlsread(MortalityTableFile, 'malemortalitybyyear',  'B1:AJ1');
            obj.MortalityTableAgeIndex=xlsread(MortalityTableFile, 'malemortalitybyyear',  'A1:A102');
            
            [~, obj.YearDimSize]=size(obj.MortalityTableYearIndex);
            [obj.AgeDimSize, ~]=size(obj.MortalityTableAgeIndex);
            
            
            
            %Load the standardised mortality ratios and their uncertainty ranges
            [obj.HIVSMR, obj.AIDSSMR, obj.RatioAgeRange, obj.RatioYearRange]=obj.LHSSMR(SMRFile, NumberOfSamplesForLHSSMR);
            
            %pre-fill a random matrix for speed later 
            obj.randvectorsize=5000000;
            obj.randvector=rand(1, obj.randvectorsize);
            obj.randcount=1;
        end
        
        function [HIVSMRStruct, AIDSSMRStruct, RatioAgeRange, RatioYearRange]=LHSSMR(obj, SMRFile, NumberOfSamples)
            %this function latin hypercube samples across all of the
            %uncertainty in the variables.

            %Load the HIV mortality rates 
            HIVSMR=xlsread(SMRFile, 'D4:F9');
            AIDSSMR=xlsread(SMRFile, 'D14:F19');
            HIVLCI=xlsread(SMRFile, 'H4:J9');
            AIDSLCI=xlsread(SMRFile, 'H14:J19');
            HIVUCI=xlsread(SMRFile, 'L4:N9');
            AIDSUCI=xlsread(SMRFile, 'L14:N19');

            %Establish the ranges for these variables
            RatioAgeRange=[ 0 25 35 45 55  65;  ...
                           25 35 45 55 65 200];
            RatioYearRange=[1900 1990 1997; ...
                            1990 1997 3000];
            [~, NumYearCategories]=size(RatioYearRange);
            [~, NumAgeCategories]=size(RatioAgeRange);

            %Convert to logarithm
            logHIVSMR=log(HIVSMR);
            logAIDSSMR=log(AIDSSMR);
            logHIVLCI=log(HIVLCI);
            logAIDSLCI=log(AIDSLCI);
            logHIVUCI=log(HIVUCI);
            logAIDSUCI=log(AIDSUCI);

            %Determine Standard Error
            logHIVSE=(logHIVUCI-logHIVLCI)/(2*1.96);
            logAIDSSE=(logAIDSUCI-logAIDSLCI)/(2*1.96);

            for YearIndex=1:NumYearCategories
                for AgeIndex=1:NumAgeCategories
                    logsample=normrnd(logHIVSMR(AgeIndex, YearIndex), (logHIVSE(AgeIndex, YearIndex)), [1 NumberOfSamples]);
            %         HIVSMRStruct(AgeIndex, YearIndex).v=exp(logsample);
                    HIVSMRStruct(AgeIndex, YearIndex, :)=exp(logsample);

                    logsample=normrnd(logAIDSSMR(AgeIndex, YearIndex), (logAIDSSE(AgeIndex, YearIndex)), [1 NumberOfSamples]);
            %         AIDSSMRStruct(AgeIndex, YearIndex).v=exp(logsample);
                    AIDSSMRStruct(AgeIndex, YearIndex, :)=exp(logsample);

                end
            end
        end
        
        
        
        function obj=RestartRandomNumbers(obj)
            %Required because duplicate vestors would be used otherwise in
            %multiple parallelised simulations
            %pre-fill a random matrix for speed later 
            obj.randvectorsize=5000000;
            obj.randvector=rand(1, obj.randvectorsize);
            obj.randcount=1;
        end
        

        
        function [YearOfDeath, AgeOfDeath]=DetermineDeath(obj, CurrentYear, CurrentAge, Sex, YearOfAIDSDevelopment, SimulationNumber)
            % Choose the appropriate matrix based on the sex
            if Sex==2 %female
                YearlyPOfDeath=obj.YearlyPOfDeathFemale;
            else % 'not' female (male and intersex)
                YearlyPOfDeath=obj.YearlyPOfDeathMale;
            end
            
            %Create a survival curve for this person
            
            CurrentYearFloor=floor(CurrentYear);
            YearIndex=CurrentYearFloor-obj.MortalityTableYearIndex(1)+1;
            
            CurrentAgeFloor=floor(CurrentAge);
            AgeIndex=CurrentAgeFloor+1;
            

            
            DeathRecorded=0;
            YearThisStep=CurrentYear;
            AgeThisStep=CurrentAge;
            
            %Here we break the variables out of the obj because MATLAB is
            %too slow to deal with referencing in such a way.
            AIDSSMRMat=obj.AIDSSMR(:, :, SimulationNumber);
            HIVSMRMat=obj.HIVSMR(:, :, SimulationNumber);
            
            while AgeIndex<200 && DeathRecorded==0
                
                if AgeIndex>obj.AgeDimSize%catch people who get past the last available data we have,
                    AgeIndex=obj.AgeDimSize;
                end
                
                if YearIndex>obj.YearDimSize%if the year extends to beyond results that we have at the moment
                    HealthyProbDeathThisYear=YearlyPOfDeath(AgeIndex, obj.YearDimSize);
                elseif YearIndex<1
                    HealthyProbDeathThisYear=YearlyPOfDeath(AgeIndex, 1);
                else
                    HealthyProbDeathThisYear=YearlyPOfDeath(AgeIndex, YearIndex);
                end
                
                
                
                %Determine AIDS/HIV ratio index
                SMRAgeIndex=obj.RatioAgeRange(1, :)<=AgeThisStep & AgeThisStep<obj.RatioAgeRange(2, :);
                SMRYearIndex=obj.RatioYearRange(1, :)<=YearThisStep & YearThisStep<obj.RatioYearRange(2, :);
                
                
                if YearThisStep>YearOfAIDSDevelopment
                    SMRatio=AIDSSMRMat(SMRAgeIndex, SMRYearIndex);
                else %note that if the YearOfAIDSDevelopment==[], we go to the 'else' section and use the HIV SMR rate
                    SMRatio=HIVSMRMat(SMRAgeIndex, SMRYearIndex);
                end
                
                
                

                ProbDeathThisYear=HealthyProbDeathThisYear*SMRatio;
                if ProbDeathThisYear>1%This is to catch cases where death is very high. If this actually occurs, there may be an issue with the reliability of the probability of death calculations
                    ProbDeathThisYear=1;
                end
                
                
                
                obj.randcount=obj.randcount+1;
                if obj.randcount>obj.randvectorsize
                    obj.randcount=1;
                end
                RandValue=obj.randvector(obj.randcount);
                
                if RandValue<ProbDeathThisYear
                    %the individual dies in this year
                    
                    %choose a random step between the beginning and end of this year
                    obj.randcount=obj.randcount+1;
                    if obj.randcount>obj.randvectorsize
                        obj.randcount=1;
                    end
                    RandValue=obj.randvector(obj.randcount);

                    YearOfDeath=YearThisStep+RandValue;
                    AgeOfDeath=AgeThisStep+RandValue;
                    DeathRecorded=1;
                end
                
                
                

                AgeIndex=AgeIndex+1;
                
                YearIndex=YearIndex+1;
                YearThisStep=YearThisStep+1;
                AgeThisStep=AgeThisStep+1;
            end

            
            
            
            
            
        end
        
        
      
        
    end
end