function [ CD4 ] = ImputeAbsentCD4Data( CD4 )
%This Function Imputes the CD4 Count at Diagnosis when only Year of
%Infection is available, a rough bootstrap method
    
    %Extract individuals with all data
    ExtractIndex =~ isnan(CD4);
    SampleCD4 = CD4(ExtractIndex);
        
    %Calculate Average/mean CD4 Values for Entire Data Set
    Average_CD4 = mean(SampleCD4);
    Average_CD4_SD = std(SampleCD4);
    
    %Check to see Number of values required
    Vector_Size = length(CD4) - length(SampleCD4);
    
    %Randomly Generate CD4 values based on entered data Set using Normal
    %Distribution
    CD4_Vector = abs(normrnd(Average_CD4, Average_CD4_SD, 1, Vector_Size));
     
    %Output NaN Values in CD4 Vector in main program
    for x = 1:length(CD4)
        if isnan(CD4(x)) == 1
            CD4(x) = 100 + CD4_Vector(randi(Vector_Size));
        else
            %Do Nothing
        end
    end
end

