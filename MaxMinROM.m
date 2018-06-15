function [MaxVars, MinVars, ROMVars] = MaxMinROM(directory, fileName)
% Grab max and min values for specific model outputs from Vicon Nexus
%
% [MaxVars, MinVars, ROMVars] = MaxMinROM lets you select a file from
% anywhere and grabs its maximum values (MaxVars), minimum values
% (MinVars), and range of motion values (ROMVars). 
%
% [MaxVars, MinVars, ROMVars] = MaxMinROM(directory) changes the directory
% so you don't have to keep navigating to where the correct folder is (useful when analyzing a lot from the same data set). 
%
% [MaxVars, MinVars, ROMVars] = MaxMinROM(directory, fileName) finds a
% specfic file in that directory and analyzes it.
% 
%
%
% Examples:
%   % Analyze any trial
%     [MaxVars, MinVars, ROMVars] = MaxMinROM
%   % Analyze a trial in the Blue Marble dataset 
%     [MaxVars, MinVars, ROMVars] =  MaxMinROM('H:\Research\MATLAB\VAC\CollectedData\BlueMarble')
%   % Analyze trial BM_Subj1_Paper_HAL_TR01.mat in the Blue Marble dataset
%     [MaxVars, MinVars, ROMVars] = MaxMinROM('H:\Research\MATLAB\VAC\CollectedData\BlueMarble', 'BM_Subj1_Paper_HAL_TR01.mat')
%
if nargin>1
    To_Load = fileName;
else
    [To_Load, ~,~]=uigetfile('*.mat');
end

if nargin == 1 || nargin > 1
    cd(directory)
end
% We only want angles, so we're going to ignore all that other stuff
DV = GetDesiredVariables;

load(To_Load, 'ModelOutputHelp')
vars = length(DV);
MaxVars = zeros(vars, 3);
MinVars = zeros(vars, 3);
for var = 1:vars
    varNo = find(strcmp(ModelOutputHelp{:,2}, DV{var}));
    data  = ModelOutputHelp{varNo,3}{:};
    data(data==0) = NaN;
    MaxVars(var,:) = max(data);
    MinVars(var,:) = min(data);
end
ROMVars = MaxVars - MinVars;

MaxVars = array2table(MaxVars);
MinVars = array2table(MinVars);
ROMVars = array2table(ROMVars);

MaxVars.Properties.RowNames = DV;
MaxVars.Properties.VariableNames = {'Flex_Ext', 'Ad_Abduction', 'Int_Ext_Rotation'};
MinVars.Properties.RowNames = DV;
MinVars.Properties.VariableNames = {'Flex_Ext', 'Ad_Abduction', 'Int_Ext_Rotation'};
ROMVars.Properties.RowNames = DV;
ROMVars.Properties.VariableNames = {'Flex_Ext', 'Ad_Abduction', 'Int_Ext_Rotation'};
%% Functions
    function DV = GetDesiredVariables()
        DV  = {'LNeckAngles';'LSpineAngles';'RNeckAngles';'RSpineAngles';'LShoulderAngles';'RShoulderAngles';'LElbowAngles';'RElbowAngles';'LWristAngles';'RWristAngles';'LHipAngles';'RHipAngles';'LKneeAngles';'RKneeAngles';'LAnkleAngles';'RAnkleAngles';'LFFootAngles';'RFFootAngles';'LHeadAngles';'LThoraxAngles';'LPelvisAngles';'RHeadAngles';'RThoraxAngles';'RPelvisAngles'};
    end

end