function [DeduplicatedPatients, DateOfDiagnosisOfDuplicates]=RemoveDuplicates(Patient)

DeduplicatedPatients=[];
DateOfDiagnosisOfDuplicates=[];

[~, NoPatients]=size(Patient);
IncludeIndex=zeros(1, NoPatients);

YearBirthAll=zeros(1, NoPatients);
SexAll=zeros(1, NoPatients);
DateDiagnosisAll=zeros(1, NoPatients);

for i=1:NoPatients
    YearBirthAll(i)=Patient(i).YearBirth;
    SexAll(i)=Patient(i).Sex;
    DateDiagnosisAll(i)= Patient(i).DateOfDiagnosisContinuous;
end

for SexUnderAnalysis=1:2
    Sexindex=SexUnderAnalysis==SexAll;
    MinBirthYear=min(YearBirthAll(Sexindex));
    MaxBirthYear=max(YearBirthAll(Sexindex));

    %for each year in the data
    for ThisBirthYear=MinBirthYear:MaxBirthYear
        IndexInMain=[];
        DOB={};
        % Select patients with birthdates in the year
        for i=1:NoPatients
            if Patient(i).YearOfBirth==ThisBirthYear && Patient(i).Sex==SexUnderAnalysis
                IndexInMain=[IndexInMain i];
                DOB=[DOB Patient(i).DOB];
                
            end
        end
        
        if mod(ThisBirthYear, 4)==0 %leap year
            PossibleDates=366;
        else
            PossibleDates=365;
        end    
            
        
        UniqueDateVector=unique(DOB);
        [~, NoUniqueDates]=size(UniqueDateVector);

        
        NoToKeep=PossibleDates*LN(PossibleDates/(PossibleDates-NoUniqueDates));
        
        % For each date remove the first diagnosis on a date
        for ThisDate=UniqueDateVector
            SubIndex=strcmp(DOB,ThisDate);
            
            IndicesOnThisDay=IndexInMain(SubIndex);
            
            
            [~, MinIndex]=min(DateDiagnosisAll(IndicesOnThisDay));
            
            IncludeIndex(MinIndex)=1;
            %remove this index from the dates that might be duplicates
            IndexToRemove=MinIndex==IndexInMain;
            IndexInMain(IndexToRemove)=[];
            DOB(IndexToRemove)=[];
            %Reduce the number to keep by one (as we have kept one)
            NoToKeep=NoToKeep-1;
        end
        
        [~, NoRemaining]=size(IndexInMain);
        
        NoToKeep=round(NoToKeep);
        
        if NoToKeep>NoRemaining %catch cases where the method over estimates duplicates
            NoToKeep=NoRemaining;
        end
        if NoToKeep<0
            NoToKeep=0;
        end
        
        IndicesToKeep=randsample(IndexInMain, NoToKeep, false);%replacement=false
        %store these results
        IncludeIndex(IndicesToKeep)=1;
    end
end

DeduplicatedPatients=Patient(IncludeIndex);


subplot(1,3, 1);
hist(DateDiagnosisAll, 1980.5:2013.5)

subplot(1,3, 2);
hist(DateDiagnosisAll(IncludeIndex), 1980.5:2013.5)


 

