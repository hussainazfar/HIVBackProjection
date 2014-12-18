function [PC2SR]=InitialisePCToSR()
% Code by James Jansson 1/12/2010
%% Initialise PostCode to SR System
% Loads the Postcode to SLA concordance file and the SLA to SR concordance file
PCToSLAFileName='LocationData/CP2006SLA_2006POA.xls';
SLAToSRFileName='LocationData/SLAtoSR2006.xlsx';

[SRGeom SRName]=shaperead('LocationData/SR07aAUST_region.shp');

[NumberOfSR ~]=size(SRName);

for i=1:NumberOfSR
    PC2SR.SRList(i)=str2num(SRName(i).SRCODE07);
end
PC2SR.SRList=PC2SR.SRList';

%% Load Postcode to SLA file
[a b PC2SR.SLACode]=xlsread(PCToSLAFileName, 'A2:A4002');
[a b PC2SR.Postcode]=xlsread(PCToSLAFileName, 'C2:C4002');
% [a PC2SR.SLACode c]=xlsread(PCToSLAFileName, 'A2:A4002');
% [a PC2SR.Postcode c]=xlsread(PCToSLAFileName, 'C2:C4002');
[PC2SR.PostcodeRatio b c]=xlsread(PCToSLAFileName, 'E2:E4002');


%% Load SLA to SR file

%Note: for 2006, there was no definitive code for each SLA. Each SLA had a
%4 digit code. Similar codes between states were distinguished by the use 
%of the 1-digit state code. This is also the first digit of the statistical
%region code. 
%The 2007 SLA codes have the 2006 SLA codes as the last 4 digits and the
%state code as the first digit. i.e. NSW=1, 2006 SLA=4506, 2007SLA=1XXX4506

% [a b PC2SR.SR]=xlsread(SLAToSRFileName, 'A2:A1427');
% [a b PC2SR.SRSLA]=xlsread(SLAToSRFileName, 'B2:B1427');
[PC2SR.SRNum b PC2SR.SR]=xlsread(SLAToSRFileName, 'A2:A1427');
[PC2SR.SRSLA b c]=xlsread(SLAToSRFileName, 'B2:B1427');
[PC2SR.Metro a b ]=xlsread(SLAToSRFileName, 'C2:C1427');

end