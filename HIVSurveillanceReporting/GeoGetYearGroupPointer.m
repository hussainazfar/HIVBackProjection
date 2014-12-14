function YearGroupPointer=GeoGetYearGroupPointer(Year)
%% Used in the CreatePostcodeInitialiser and CreatePostcode
% This function is used for consistency such that people can edit the
% function later without having to trawl through code twice.
    if Year<1985
        YearGroupPointer=1;
    elseif Year>=1985 && Year<=1989
        YearGroupPointer=2;
    elseif Year>=1990 && Year<=1994
        YearGroupPointer=3;
    elseif Year>=1995 && Year<=1999
        YearGroupPointer=4;
    elseif Year>=2000 && Year<=2004
        YearGroupPointer=5;
    else %Year>=2005
        YearGroupPointer=6;
    end
end