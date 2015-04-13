classdef CD4Class
    %Create a Class Definition for all CD4's in SimulatedPopSize
    %   Instead of working on vectors, this class definition focuses on
    %   operating in class based definitions to make it easier to parse
    %   through the records
    
    properties
        %Variables that are used in Generation of CD4 Counts
        StartingCD4Count;
		AverageCD4Count;
		MeasuredCD4Count;
        IndexTest;
        Time;
        CD4;
    end
    
    methods
        %Constructor for any object of this class
        function obj = CD4Class()
            obj.StartingCD4Count = NaN;
            obj.AverageCD4Count = NaN;
            obj.MeasuredCD4Count = NaN;
            obj.IndexTest = false;
            obj.Time = 0;
            obj.CD4 = 0;
        end
    end
    
end

