function [ Sex ] = ImputeMissingSexData( Sex )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
MalePop = 0;
FemalePop = 0;
OtherPop = 0;

    for x = 1:length(Sex)
        if Sex(x) == 1
            MalePop = MalePop + 1;
        elseif Sex(x) == 2
            FemalePop = FemalePop + 1;
        elseif Sex(x) == NaN
            %Do Nothing
        else
            OtherPop = OtherPop + 1;
        end
    end
    
    AvgMalePop = (MalePop) / (MalePop + FemalePop + OtherPop);
    AvgFemalePop = (FemalePop) / (MalePop + FemalePop + OtherPop);
    AvgOtherPop = (OtherPop) / (MalePop + FemalePop + OtherPop);
    
    ExtractIndex =~ isnan(Sex);
    
    
end

