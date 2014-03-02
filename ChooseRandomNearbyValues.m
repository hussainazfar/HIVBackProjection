function [ReturnValues]=ChooseRandomNearbyValues(X, SourceVector, AssociatedValues, ClosestN)
% X - the real samples we are trying to find simulated matches for (1,q)
% SourceVector- the simulated samples 
% AssociatedValues - any other simulated values associated with the values in
    % the SourceVector. This is a (p,q) sized matrix, where p is the number
    % of otehr parameters
% ClosestN - the number of nearest samples to chose from

%The intention of this algorithm is to associate a real CD4 at testing
%with a simulated time until diagnosis by matching the real CD4 with a
%simulated CD4


%Determine the size of X
[~, q]=size(X);
[p, ~]=size(AssociatedValues);
ReturnValues=zeros(p, q);


%pre randomly choose the ClosestN=100 random numbers to save some time
r = randi(ClosestN,1, q);

i=0;
for Xi=X
     i=i+1;
     diff=abs(Xi-SourceVector);
     [~, Ind]=sort(diff);
     ReturnValues(:, i)=AssociatedValues(:, Ind(r(i)));%choose a random number from the first N closest results
end

end
