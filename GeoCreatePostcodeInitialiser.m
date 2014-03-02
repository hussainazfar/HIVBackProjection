function DiagsByYearState=GeoCreatePostcodeInitialiser(Patient)
%% Create a postcode probability matrix
% This is used to assign people to postcodes if they have not got a
% postcode listed. The postcode will be assigned by understanding the 

% Diags(YearGroupPointer, StatePointer).numberofpostcodes=NumberOfPostcodes;
% 
% Diags(YearGroupPointer, StatePointer).Postcode(PostcodePointer)=PostCodeName e.g. 2010;
% 
% Diags(YearGroupPointer, StatePointer).NumberOfPeople(PostcodePointer)=NumberOfPeopleWithThatPostCode e.g 15000;
%
% Diags(YearGroupPointer, StatePointer).TotalNumberOfPeople= Number of people in that sate in that year who have post codes assigned
[~, NumberOfPatients]=size(Patient);

for YearGroupPointer=1:6
    for StatePointer=1:8
        Diags(YearGroupPointer, StatePointer).NumberOfPostcodes=0;
        Diags(YearGroupPointer, StatePointer).TotalNumberOfPeople=0;
    end
end


for i=1:NumberOfPatients
    % Sort only those with postcodes into YearGroup x State Struct:
    %check that the patient has a value for the postcode
    if isnan(Patient(i).PostcodeAtDiagnosis)==false && Patient(i).PostcodeAtDiagnosis~=0
        
        StatePointer=Patient(i).StateAtDiagnosis;
        YearGroupPointer=GeoGetYearGroupPointer(Patient(i).YearOfDiagnosis);
        
        %find the relevant postcode in the Diag struct
        if Diags(YearGroupPointer, StatePointer).NumberOfPostcodes==0
            %If there are no diagnoses for that state in that time period, create one
            Diags(YearGroupPointer, StatePointer).NumberOfPostcodes=1;
            Diags(YearGroupPointer, StatePointer).TotalNumberOfPeople=1;
            Diags(YearGroupPointer, StatePointer).Postcode(1)=Patient(i).PostcodeAtDiagnosis;
            Diags(YearGroupPointer, StatePointer).NumberOfPeople(1)=1;
        else
            %search for relevant postcodes
            PostcodeFound=false;
            for PostcodePointer=1:Diags(YearGroupPointer, StatePointer).NumberOfPostcodes
                
                if Diags(YearGroupPointer, StatePointer).Postcode(PostcodePointer)==Patient(i).PostcodeAtDiagnosis
                    Diags(YearGroupPointer, StatePointer).NumberOfPeople(PostcodePointer)=Diags(YearGroupPointer, StatePointer).NumberOfPeople(PostcodePointer)+1;
                    Diags(YearGroupPointer, StatePointer).TotalNumberOfPeople=Diags(YearGroupPointer, StatePointer).TotalNumberOfPeople+1;
                    PostcodeFound=true;
                end
            end
            if PostcodeFound==false
                %add a new entry
                
                Diags(YearGroupPointer, StatePointer).NumberOfPostcodes=Diags(YearGroupPointer, StatePointer).NumberOfPostcodes+1;
                NextEntry=Diags(YearGroupPointer, StatePointer).NumberOfPostcodes;
                Diags(YearGroupPointer, StatePointer).Postcode(NextEntry)=Patient(i).PostcodeAtDiagnosis;
                Diags(YearGroupPointer, StatePointer).NumberOfPeople(NextEntry)=1;
                Diags(YearGroupPointer, StatePointer).TotalNumberOfPeople=Diags(YearGroupPointer, StatePointer).TotalNumberOfPeople+1;
                
            end
        end
    end
end
DiagsByYearState=Diags;
end