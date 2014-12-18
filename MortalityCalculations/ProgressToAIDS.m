function [Patient YearOfDiagnosisArray] = ProgressToAIDS(Patient, AIDSProgression, ViralLoadProbability, VLCD4Locator)
    %determine how many patients there are
    [~, NumberOfPatients]=size(Patient);
    CutOffYearForAIDS=1997;
    %
    YearOfDiagnosisArray=[];
    
    for i=1:NumberOfPatients
        if Patient(i).YearOfDiagnosis<=CutOffYearForAIDS
            %Determine what CD4 reference it should be 
            
            if Patient(i).CD4CountAtDiagnosis>=0 &&	Patient(i).CD4CountAtDiagnosis<=200
                CD4Ref=1;
            elseif Patient(i).CD4CountAtDiagnosis>200 &&	Patient(i).CD4CountAtDiagnosis<=350
                CD4Ref=2;
            elseif Patient(i).CD4CountAtDiagnosis>350 &&	Patient(i).CD4CountAtDiagnosis<=500
                CD4Ref=3;
            elseif Patient(i).CD4CountAtDiagnosis>500
                CD4Ref=4;
            else
                error('CD4 not set');
            end
            %determine a random viral load level
            ReferenceFound=false;
            RandomValue=rand;
            VLRef=0;
            while ReferenceFound==false
                VLRef=VLRef+1;
                if RandomValue<=ViralLoadProbability(CD4Ref, VLRef)
                    ReferenceFound=true;
                end
            end
            %Determine position in list

            ListReference=VLCD4Locator(CD4Ref, VLRef);

            %determine the time until AIDS
            
            TimeUntilAIDS=AIDSProgression(ListReference).GenerateTimeToAIDS;
            YearOfAIDSDiagnosis=Patient(i).DateOfDiagnosisContinuous+TimeUntilAIDS;


            if YearOfAIDSDiagnosis<=CutOffYearForAIDS
                Patient(i).YearOfAIDSDiagnosis=YearOfAIDSDiagnosis;
                [~, NumberOfAIDSDiagnoses]=size(YearOfDiagnosisArray);
                NumberOfAIDSDiagnoses=NumberOfAIDSDiagnoses+1;
                YearOfDiagnosisArray(NumberOfAIDSDiagnoses)=Patient(i).YearOfDiagnosis;
            end
        end
    end
     %save('YearOfDiagnosisArray.mat', 'YearOfDiagnosisArray');

end