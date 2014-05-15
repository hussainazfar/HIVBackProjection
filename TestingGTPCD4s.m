
[Px]=LoadBackProjectionParameters(100);

PopulationSizeToSimulate=10000;%1000000;
Ax=Px;
Ax.SquareRootAnnualDecline=mean(Ax.SquareRootAnnualDeclineVec);
Ax.FractionalDeclineToRebound=mean(Px.FractionalDeclineToReboundVec);
[TimeUntilDiagnosis, ~, TestingCD4]=GenerateTheoreticalPopulationCD4s(20*rand(1, PopulationSizeToSimulate), Ax);





%         size(IndexExceedTimeBinary)
%         size(SQRDecline)
%         mean(SQRDecline(IndexExceedTimeBinary))
%         mean(SQRDecline)
%         mean(DurationAtOrBelowZeroCD4(IndexExceedTimeBinary))
%         mean(DurationAtOrBelowZeroCD4)
%         mean(sqrtCD4AtRebound(~IndexExceedTimeBinary))
%         mean(sqrtCD4AtRebound(IndexExceedTimeBinary))
%         size(sqrtCD4AtRebound)
%         size(SQRDecline)
%         size(IndexExceedTimeBinary)
%         TimeWhenReachingZero
%         size(TimeWhenReachingZero)
%         mean(TimeWhenReachingZero(~IndexExceedTimeBinary))
%         mean(TimeWhenReachingZero(IndexExceedTimeBinary))

%         %error output
%         A=TestingCD4;
%         B=TestingCD4(IndiciesForResample);
%         
%         disp('This error')
%         disp([size(A), size(B)])
%         disp([class(A), class(B)])