function [ PatientsIncluded, PatientsRemoved ] = RemoveDuplicates( Patient )
%RemoveDuplicates.m checks the structure Patient for any duplicates that
%might exist and removes recurrences
%   The structure Patient is evaluated and duplicated data is removed from
%   structure Patient, updated and returned to PatientsIncluded Structure.
%   All Duplicate copies are stored in another structure Patients Removed.

NoPatients = length(Patient);

Duplicates = [];
YearBirthAll = zeros(1, NoPatients);
SexAll = zeros(1, NoPatients);
DateDiagnosisAll = zeros(1, NoPatients);

for x = 1:NoPatients
    YearBirthAll(x) = Patient(x).YearBirth;
    SexAll(x) = Patient(x).Sex;
    DateDiagnosisAll(x) = Patient(x).DateOfDiagnosisContinuous;
end

for SexUnderAnalysis = 1:2
    SexIndex = SexUnderAnalysis == SexAll;

    UniqueBirthYears = unique(YearBirthAll(SexIndex));                      %Used to avoid years in which there are no people born in that year which may cause problems later in the codes
    
    %for each year in the data
    for ThisBirthYear = UniqueBirthYears
        
        IndicesForThisYear = [];
        DOB = [];
        
        % Select patients with birthdates in the year
        for x = 1:NoPatients
            if Patient(x).YearBirth == ThisBirthYear && Patient(x).Sex == SexUnderAnalysis
                IndicesForThisYear = [IndicesForThisYear x];
                DOB = [DOB Patient(x).DOB];
            end
        end
        
        if mod(ThisBirthYear, 4) == 0                                         %leap year
            PossibleDates = 366;
        else
            PossibleDates = 365;
        end    
            
        UniqueDOBVector = unique(DOB);
        NoUniqueDates = length(UniqueDOBVector);

        TotalRecordsInThisYear = length(IndicesForThisYear);
        NumberExpectedThisYear = PossibleDates * log(PossibleDates/(PossibleDates-NoUniqueDates));
        NumberExpectedThisYear = round(NumberExpectedThisYear);
        
        %disp([num2str(NumberExpectedThisYear) ' expected out of ' num2str(TotalRecordsInThisYear) ' in ' num2str(ThisBirthYear)]);
        
        
        NumberConfirmed = 0;
        
        ThisYearsDuplicateSample = [];
        
        % For each date remove the first diagnosis on a date
        for ThisDOB = UniqueDOBVector
            %Find records in this year with this DOB
            PossibleDuplicatesOnThisDayIndex = strcmp(DOB,ThisDOB);
            PossibleDuplicatesOnThisDay = IndicesForThisYear(PossibleDuplicatesOnThisDayIndex);
            
            % Find the earliest diagnosis date
            [~, MinIndex ] = min(DateDiagnosisAll(PossibleDuplicatesOnThisDay));
            
            %Remove this as a possible duplicate from this 
            PossibleDuplicatesOnThisDay(MinIndex) = [];
            
            ThisYearsDuplicateSample = [ThisYearsDuplicateSample  PossibleDuplicatesOnThisDay];
            NumberConfirmed = NumberConfirmed + 1;                          %note that this always adds 1 
        end
        
        NumberToRemove = TotalRecordsInThisYear - NumberExpectedThisYear;
         
        %select, at random, the duplicates
        NumberInSample = length(ThisYearsDuplicateSample);
        if NumberToRemove >= NumberInSample
            Duplicates = [Duplicates ThisYearsDuplicateSample];
        else
            Duplicates = [Duplicates randsample(ThisYearsDuplicateSample, NumberToRemove, false)];  %replacement=false
        end
        
    end
end

PatientsIncluded = Patient;
PatientsIncluded(Duplicates) = [];
PatientsRemoved = Patient(Duplicates);

TotalDiagnoses = hist(DateDiagnosisAll, 1980.5:2013.5);
NumDuplicates = hist(DateDiagnosisAll(Duplicates), 1980.5:2013.5);
Prop = NumDuplicates./TotalDiagnoses;

clf;
bar(1980:2013, Prop*100);
xlabel('Year','fontsize', 22);
ylabel('Estimated duplicate diagnoses (%)','fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18)
    box off;
    
    xlim([1980 2014])
    
    print('-dpng ','-r300','ResultsPlots/Appendix figure duplicates.png')
