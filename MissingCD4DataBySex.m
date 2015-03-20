function [CD4]=MissingCD4DataBySex(Sex, Year, Age, CD4)
    for SexCount=0:1
        %Select individuals by sex
        SexIndex=SexCount==Sex;
        
        CD4(SexIndex)=MissingData(Year(SexIndex), Age(SexIndex), CD4(SexIndex));
    end
end
