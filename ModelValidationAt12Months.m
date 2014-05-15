% function ModelValidationAt12Months
%The purpose of this function is to valuidate the model regarding expected
%distribution of CD4s at 1 year. It is not designed to test the validity of
%the mean CD4. Rather it is ensuring that the distribution of healthy CD4
%translates well to the distribution of infected CD4 when doinging a
%proportional decrease in CD4 count across the whole distribution.

%Lang et al 1989 Patterns of T Lymphocyte Changes with Human Immunodeficiency Virus Infection: From Seroconversion to the Development of AIDS
%Fig 3 (panel 1) shows the proportion of CD4 counts of seroconverters at 12 months
%as:
%<500 CD4:    ~20%
%500-800 CD4: ~38%
%>800 CD4:    ~42%

%Kaufmann et al had 57% at <500 at 12 months, and 4% <200



%we will generate a theoretical population from the model and test them at
%1 year, find the distribution and see if it roughly represents the data
%above


Ax=Px;
Ax.SquareRootAnnualDecline=mean(Ax.SquareRootAnnualDeclineVec);
Ax.FractionalDeclineToRebound=mean(Px.FractionalDeclineToReboundVec);
[TimeUntilDiagnosis, ~, TestingCD4]=GenerateTheoreticalPopulationCD4s(ones(1, 10000), Ax);

sum(TestingCD4<500)/10000
sum(TestingCD4>800)/10000
sum(TestingCD4<200)/10000