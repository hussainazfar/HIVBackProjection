function Result=TestFunction(Parameters, FunctionInput)
    NumberPerGroup=round(FunctionInput.NumberOfSamples/2);

    sigma=1;
    mu=Parameters(1);
    Samples=normrnd(mu,sigma, 1,FunctionInput.NumberOfSamples);
    mu=Parameters(2);
    Samples=[Samples normrnd(mu,sigma, 1,FunctionInput.NumberOfSamples)];
    
    Result=hist(Samples, 0.5:9.5);
    
end
