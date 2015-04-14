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
    end
    
    methods
        %Constructor for any object of this class
        function obj = CD4Class(obj)
            obj.StartingCD4Count = 0;
            obj.AverageCD4Count = 0;
            obj.MeasuredCD4Count = 0;
            obj.IndexTest = false;
            obj.Time = 0;
        end
    end
    
end

