function [AIDSProgression, ViralLoadProbability, VLCD4Locator]=SetUpAIDSProgession

%Open load file
%Create a locator matrix
disp('Loading AIDS progression basic data');
VLCD4Ref= xlsread('AIDSProgression\MoveToAIDSLoadFile.xlsx', 'B5:D19');
%VLCD4Locator = zeros;
for i=1:15
    VLCD4Locator(VLCD4Ref(i, 1), VLCD4Ref(i, 2))= VLCD4Ref(i, 3);
end

%Create a viral load probability matrix
ViralLoadProbability = xlsread('AIDSProgression\MoveToAIDSLoadFile.xlsx', 'J12:N15');

%Load data for AIDS Kaplan Meier curve
[~, FileNames]=xlsread('AIDSProgression\MoveToAIDSLoadFile.xlsx', 'A5:A19');
AIDSProgression(1:15)=AIDSProgressionClass;
disp('Loading Mellors KaplanMeier Data');
for i=1:15
    AIDSProgression(i)=AIDSProgression(i).LoadFromFile(['AIDSProgression\' FileNames{i}], VLCD4Ref(i, 1), VLCD4Ref(i, 2));
end

disp('FindingExponentialFits');
for i=1:15
    AIDSProgression(i)=AIDSProgression(i).FitExpFunction;
end


% disp('PlottingResults');
% hold on;
% for i=1:15
%     RandRGB=0.9*rand(1,3);
%     PointDataYSim=1:-0.02:0.02;
%     PointDataXSim=nthroot((log(PointDataYSim)./-AIDSProgression(i).a), AIDSProgression(i).b);
% 
%     plot(AIDSProgression(i).PointDataX, AIDSProgression(i).PointDataY, 'Color', RandRGB);
%     
%     plot(PointDataXSim, PointDataYSim, 'Color', RandRGB);
% 
% end
% 
% hold off;
end
