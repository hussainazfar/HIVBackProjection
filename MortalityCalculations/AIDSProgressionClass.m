classdef AIDSProgressionClass %< handle  
    %Loads CD4 and AIDS survival from file, determines a mathematical
    %function to fit to the Kaplan-Meier Data, and gives a random time
    %until AIDS based on CD4 and viral load levels
   properties %(SetAccess='private')
      a
      b
      PointDataX
      PointDataY
      CD4Band
      VLBand
      
   end% properties

    methods
        function obj = LoadFromFile(obj, FileName, CD4Band, VLBand)
            GraphData=xlsread(FileName);
 
            obj.PointDataX=GraphData(:, 1);
            obj.PointDataY=GraphData(:, 2);
         
            obj.CD4Band=CD4Band;
            obj.VLBand=VLBand;
        
        end
       
        function obj = FitExpFunction(obj)
            MaxNumberOfTries=1000000;

            CurrentTries=0;
            CurrentVariableChanging='a';

            aMultiplier=0.001;
            bMultiplier=0.001;

            a=1;
            b=1;
            LastError=1e300;

            while CurrentTries<MaxNumberOfTries && (aMultiplier>10^-13 && bMultiplier>10^-13)
                CurrentTries=CurrentTries+1;


                %add a random value to the current functional value taking turns for a and
                %b

                if CurrentVariableChanging=='a'
                    aTemp= a + aMultiplier*(rand-0.5);
                    bTemp=b;
                else
                    aTemp=a;
                    bTemp= b + bMultiplier*(rand-0.5);
                end
                
                %avoid nasty (impossible) -ve and zero aTemp values
                if aTemp<=0
                    aTemp=a;
                end
                    
                
                
                
%                 %Display change in a and b
%                 format long;
%                 disp(['This is' num2str(RandomIdentifier)]);
%                 disp(a);
%                 disp(b);
%                 disp(aMultiplier);
%                 disp(bMultiplier);

                %find the new error
                SimulatedX = nthroot((log(obj.PointDataY)./-aTemp), bTemp);
                CurrentError=sum((obj.PointDataX-SimulatedX).^2);


                if CurrentError>LastError
                    % if it has more error discard
                    % add 1 to the counter
                    % OR decrease multiplying fraction by 0.993
                    if CurrentVariableChanging=='a'
                        aMultiplier=aMultiplier*0.993;
                    else
                        bMultiplier=bMultiplier*0.993;
                    end
                else
                    % if it has less error keep
                    LastError=CurrentError;
                    a=aTemp;
                    b=bTemp;
                    %expand multiplying fraction by 1.020- maybe needs more due to the rareity
                    %that better solutions will be found?

                    if CurrentVariableChanging=='a'
                        aMultiplier=aMultiplier*1.020;
                    else
                        bMultiplier=bMultiplier*1.020;
                    end
                end

                %Swap which variable we are changing
                if CurrentVariableChanging=='a'
                    CurrentVariableChanging='b';
                else
                    CurrentVariableChanging='a';
                end
            end
            obj.a=a;
            obj.b=b;
        end
        
        function TimeUntilAIDS = GenerateTimeToAIDS(obj)
            RandomValue=rand;
            TimeUntilAIDS = nthroot((log(RandomValue)/-obj.a), obj.b);
            
        end
        
      
   end% methods
end% classdef