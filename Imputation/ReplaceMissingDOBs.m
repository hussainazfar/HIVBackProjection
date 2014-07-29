clear;

%open file
FileName='Data/notifications2014exposure.xls';
SheetName='Sheet1';
[a, b, c]=xlsread(FileName,  SheetName);%Approx 2.3 seconds

%The first row is the column headers
VariableName=c(1, :);

%Determine the number of people in the data file
[NumberOfPatients, ~]=size(c);
NumberOfPatients=NumberOfPatients-1;

%Cut the header data from the rest of the data
c=c(2:NumberOfPatients+1, :);
b=b(2:NumberOfPatients+1, :);

%read dob, year of diagnosis

DOB=b(:,strcmp(VariableName, 'dob'));
YOB=datenum(DOB, 'dd/mm/yyyy');
DateHIV=b(:,strcmp(VariableName, 'datehiv'));
% for each person
for i=1:NumberOfPatients
    % if a person has a NaN entry for their DOB
    if (isnan(DOB{i})) %this is extremely hacky 
        disp(['Replacing record ' num2str(i)]);
        % find records with the same year and with an actual DOB
        [NoOfSamples, ~]=size(aaaaa);
        if NoOfSamples==0
            %choose a year at random from  the whole data set
        else
        
            % select at random a year of birth
            % create a random date
            % set it to the empty record
        end
    end
end


% Save file to excel
