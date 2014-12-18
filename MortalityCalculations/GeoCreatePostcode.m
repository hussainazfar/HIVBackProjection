function Postcode=GeoCreatePostcode(State, Year, Diags)

YearGroupPointer=GeoGetYearGroupPointer(Year);

RandomValue=rand*Diags(YearGroupPointer, State).TotalNumberOfPeople;
PeopleCount=0;

for PostcodePointer=1:Diags(YearGroupPointer, State).NumberOfPostcodes
    PeopleCount=PeopleCount+Diags(YearGroupPointer, State).NumberOfPeople(PostcodePointer);
    if RandomValue<=PeopleCount
        Postcode=Diags(YearGroupPointer, State).Postcode(PostcodePointer);
        return
    end
end

%if the postcode is not found, assign to any of the postcodes from that
%state from any time period


TotalStateDiags=0;
for YearGroupPointer=1:6
    TotalStateDiags=TotalStateDiags+Diags(YearGroupPointer, State).TotalNumberOfPeople;
end

PeopleCount=0;
RandomValue=rand*TotalStateDiags;
for YearGroupPointer=1:8
    for PostcodePointer=1:Diags(YearGroupPointer, State).NumberOfPostcodes
        PeopleCount=PeopleCount+Diags(YearGroupPointer, State).NumberOfPeople(PostcodePointer);
        if RandomValue<=PeopleCount
            Postcode=Diags(YearGroupPointer, State).Postcode(PostcodePointer);
            return
        end
    end
end



%PeopleCount
%Diags(YearGroupPointer, State).TotalNumberOfPeople;
error('Did not find a postcode');

end