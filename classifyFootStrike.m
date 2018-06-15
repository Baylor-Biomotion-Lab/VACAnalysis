function [FSClass, FSA] = classifyFootStrike(staticTrial, dynamicTrial)
%classifyFootStrike classifies foot strikes as midfoot,forefoot,or rearfoot
% Requires both a static trial for standing and a dynamic trial for
% footstrike.
% Assumes facing television (feet are in x-direction) during static pose,
% and running/walking along y-direction.
%
% [FSClass,FSA] = classifyFootStrike('R_Subj19_Pegasus_Static_TR01.mat','R_Subj19_Pegasus_335_TR02.mat')
% returns the FSClass as a string categorizing it as well as the angle used
% to determine this (FSA = Foot strike angle).
load(staticTrial, 'MarkerNames', 'trajectories', 'TrialInfo')
euclid2D = @(x1,y1,x2,y2) sqrt((x1-x2)^2 + (y1-y2)^2);
% Grab heel and toe marker trajectories
if strcmp(TrialInfo.FootDominance,'R')
    heel = table2array(trajectories{strcmp(MarkerNames, 'RHEE')});
    toe = table2array(trajectories{strcmp(MarkerNames,'RTOE')});
else
    heel = table2array(trajectories{strcmp(MarkerNames, 'RHEE')});
    toe = table2array(trajectories{strcmp(MarkerNames,'RTOE')});
end
FrameStart = TrialInfo.StartTrial;
% Get rid of 0s because that's when the trial was cropped (if it was
% cropped).
heelxS = heel(FrameStart,1);
heelyS = heel(FrameStart,2);
heelzS = heel(FrameStart,3);

toexS = toe(FrameStart,1);
toeyS = toe(FrameStart,2);
toezS = toe(FrameStart,3);

% staticAngle = angle3D(heelx,heely,heelz,toex,toey,toez);
hypS = euclid2D(heelxS,heelzS,toexS,toezS);
oppS = (toezS-heelzS);
staticAngle = asind(oppS/hypS);

clearvars MarkerNames trajectories TrialInfo

load(dynamicTrial, 'MarkerNames', 'trajectories', 'TrialInfo', 'RightStancePhase', 'LeftStancePhase')
% Grab heel and toe marker trajectories
if strcmp(TrialInfo.FootDominance,'R')
    heel = table2array(trajectories{strcmp(MarkerNames, 'RHEE')});
    toe = table2array(trajectories{strcmp(MarkerNames,'RTOE')});
    FSFrame = RightStancePhase(1,1);
else
    heel = table2array(trajectories{strcmp(MarkerNames, 'RHEE')});
    toe = table2array(trajectories{strcmp(MarkerNames,'RTOE')});
    FSFrame = LeftStancePhase(1,1);
end

heelxD = heel(FSFrame,1);
heelyD = heel(FSFrame,2);
heelzD = heel(FSFrame,3);

toexD = toe(FSFrame,1);
toeyD = toe(FSFrame,2);
toezD = toe(FSFrame,3);

% dynamicAngle = angle3D(heelx,heely,heelz,toex,toey,toez);
hypD = euclid2D(heelyD,heelzD,toeyD,toezD);
oppD = (toezD-heelzD);
dynamicAngle = asind(oppD/hypD);

FSA = dynamicAngle - staticAngle;

if -1.6<FSA && FSA<8
    FSClass = 'MFS';
elseif FSA>8
    FSClass = 'RFS';
else
    FSClass = 'FFS';
end
end
