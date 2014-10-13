function [Result, OtherData]=TestFunction(Parameters, FunctionInput)
    NumberGroup1=round(FunctionInput.NumberOfSamples/3);
    NumberGroup2=FunctionInput.NumberOfSamples-NumberGroup1;
    sigma=1;
    mu=Parameters(1);
    Samples=normrnd(mu,sigma, 1,NumberGroup1);
    mu=Parameters(2);
    Samples=[Samples normrnd(mu,sigma, 1,NumberGroup2)];
    
    Result=hist(Samples, 0.5:9.5);
    OtherData=[];
end
