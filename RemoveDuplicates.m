function [PatientsIncluded, PatientsRemoved]=RemoveDuplicates(Patient)


[~, NoPatients]=size(Patient);

Duplicates=[];

YearBirthAll=zeros(1, NoPatients);
SexAll=zeros(1, NoPatients);
DateDiagnosisAll=zeros(1, NoPatients);

for i=1:NoPatients
    YearBirthAll(i)=Patient(i).YearBirth;
    SexAll(i)=Patient(i).Sex;
    DateDiagnosisAll(i)= Patient(i).DateOfDiagnosisContinuous;
end

for SexUnderAnalysis=1:2
    SexIndex=SexUnderAnalysis==SexAll;

    UniqueBirthYears=unique(YearBirthAll(SexIndex));%Used to avoid years in which there are no people born in that year which may cause problems later in the codes
    
    %for each year in the data
    for ThisBirthYear=UniqueBirthYears
        
        IndicesForThisYear=[];
        DOB={};
        % Select patients with birthdates in the year
        for i=1:NoPatients
            if Patient(i).YearBirth==ThisBirthYear && Patient(i).Sex==SexUnderAnalysis
                IndicesForThisYear=[IndicesForThisYear i];
                DOB=[DOB Patient(i).DOB];
            end
        end
        
        if mod(ThisBirthYear, 4)==0 %leap year
            PossibleDates=366;
        else
            PossibleDates=365;
        end    
            
        UniqueDOBVector=unique(DOB);
        [~, NoUniqueDates]=size(UniqueDOBVector);

        [~, TotalRecordsInThisYear]=size(IndicesForThisYear);
        NumberExpectedThisYear=PossibleDates*log(PossibleDates/(PossibleDates-NoUniqueDates));
        NumberExpectedThisYear=round(NumberExpectedThisYear);
        
        disp([num2str(NumberExpectedThisYear) ' expected out of ' num2str(TotalRecordsInThisYear) ' in ' num2str(ThisBirthYear)]);
        
        
        NumberConfirmed=0;
        
        ThisYearsDuplicateSample=[];
        
        % For each date remove the first diagnosis on a date
        for ThisDOB=UniqueDOBVector
            %Find records in this year with this DOB
            PossibleDuplicatesOnThisDayIndex=strcmp(DOB,ThisDOB);
            PossibleDuplicatesOnThisDay=IndicesForThisYear(PossibleDuplicatesOnThisDayIndex);
            
            % Find the earliest diagnosis date
            [~, MinIndex]=min(DateDiagnosisAll(PossibleDuplicatesOnThisDay));
            
            %Remove this as a possible duplicate from this 
            PossibleDuplicatesOnThisDay(MinIndex)=[];
            
            ThisYearsDuplicateSample=[ThisYearsDuplicateSample  PossibleDuplicatesOnThisDay];
            NumberConfirmed=NumberConfirmed+1;%note that this always adds 1 
        end
        
        NumberToRemove=TotalRecordsInThisYear-NumberExpectedThisYear;
         
        %select, at random, the duplicates
        [~, NumberInSample]=size(ThisYearsDuplicateSample);
        if NumberToRemove>=NumberInSample
            Duplicates=[Duplicates ThisYearsDuplicateSample];
        else
            Duplicates=[Duplicates randsample(ThisYearsDuplicateSample, NumberToRemove, false)];%replacement=false
        end
        
    end
end



PatientsIncluded=Patient;
PatientsIncluded(Duplicates)=[];
PatientsRemoved=Patient(Duplicates);


% 
% subplot(1,3, 1);
% hist(DateDiagnosisAll, 1980.5:2013.5)
% 
% subplot(1,3, 2);
% hist(DateDiagnosisAll(Duplicates), 1980.5:2013.5)
% 
TotalDiagnoses=hist(DateDiagnosisAll, 1980.5:2013.5);
NumDuplicates=hist(DateDiagnosisAll(Duplicates), 1980.5:2013.5);
Prop=NumDuplicates./TotalDiagnoses;
subplot(1,3, 3);
bar(1980:2013, Prop*100);

 

