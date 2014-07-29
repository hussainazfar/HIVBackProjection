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

    UniqueBirthYears=unique(YearBirthAll(Sexindex));%Used to avoid years in which there are no people born in that year which may cause problems later in the codes
    
    %for each year in the data
    for ThisBirthYear=UniqueBirthYears
        IndexInMain=[];
        DOB={};
        % Select patients with birthdates in the year
        for i=1:NoPatients
            if Patient(i).YearBirth==ThisBirthYear && Patient(i).Sex==SexUnderAnalysis
                IndexInMain=[IndexInMain i];
                DOB=[DOB Patient(i).DOB];
            end
        end
        
        if mod(ThisBirthYear, 4)==0 %leap year
            PossibleDates=366;
        else
            PossibleDates=365;
        end    
            
        DOB
        UniqueDateVector=unique(DOB);
        [~, NoUniqueDates]=size(UniqueDateVector);

        
        NoToKeep=PossibleDates*log(PossibleDates/(PossibleDates-NoUniqueDates));
        
        % For each date remove the first diagnosis on a date
        for ThisDate=UniqueDateVector
            SubIndex=strcmp(DOB,ThisDate);
            
            IndicesOnThisDay=IndexInMain(SubIndex);
            
            
            [~, MinIndex]=min(DateDiagnosisAll(IndicesOnThisDay));
            
            IndexInMain
            SubIndex
            IndicesOnThisDay
            MinIndex
            ThisDate
            UniqueDateVector
            
            
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

NumWithDuplicates=hist(DateDiagnosisAll, 1980.5:2013.5);
NumWithoutDuplicates=hist(DateDiagnosisAll(IncludeIndex), 1980.5:2013.5);
Prop=NumWithoutDuplicates./NumWithDuplicates;
subplot(1,3, 3);
plot(1980:2013, Prop);

 

