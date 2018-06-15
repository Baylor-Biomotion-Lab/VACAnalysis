function data = prettyPlots(type,trial,dur,variable,direction, plotOn, varargin)
%prettyPlots generates publication-worthy plots
%   type:       If you want it to load a trial, or give it raw data to plot
%   trial:      What trial to load
%   dur:        If you want it to go over the whole length of the trial
%   variable:   Which variable you desire to analyze, such as RHipAngles
%   direction:  x (ad/abduction),y (flexion,extension),z (internal,
%               extternal rotation)
% prettyPlots('trial','R_Subj10_Free_335_TR02','stance','RHipAngles','x')
% outputs a plot for that specific trial for right hip angles over the
% stance phase.

if nargin>6
    bounded = 1;
else
    bounded = 0;
end
switch type
    case 'trial'
        load(trial, 'ModelOutputHelp', 'TrialInfo', 'RightStancePhase', 'LeftStancePhase')
        direction = lower(direction);
        switch direction
            case 'x'
                directionNo = 1;
            case 'y'
                directionNo = 2;
            case 'z'
                directionNo = 3;
            otherwise
                error('Unaccepted direction')
        end
        if strcmp(dur,'whole')
            startFrame = 1;
            endFrame = length(ModelOutputHelp{1,3}{1});
        elseif strcmp(dur,'stance')
            if strcmp(TrialInfo.FootDominance, 'R')
                startFrame = RightStancePhase(1,1);
                endFrame = RightStancePhase(1,2);
            else
                startFrame = LeftStancePhase(1,1);
                endFrame = LeftStancePhase(1,2);
            end
        end
        data = ModelOutputHelp{strcmp(variable, ModelOutputHelp{:,2}),3}{1}(startFrame:endFrame,directionNo);
    case 'raw'
        data = trial;
end
if plotOn ~= 1
    return
end
figure()
if bounded == 1
    [dataLineH, dataAreaH] = boundedline(linspace(0,100,length(data)), data, std(data), 'alpha');
    set(dataLineH, 'Color', [0 .48 .21], 'LineStyle', '-', 'LineWidth', 2.5, 'DisplayName', 'Old')
    set(dataAreaH, 'FaceColor', [0 .48 .21], 'DisplayName', '');
else
    plot(linspace(0,100,length(data)), data, 'Color', [0 .48 .21], 'LineStyle', '-', 'LineWidth', 2.5)
end
niceTitle = varConverter(variable, dur, direction);
title(niceTitle)
xlabel('Gait %')
ylabelString = sprintf('Angle(%c)', char(176));
ylabel(ylabelString)
set(gca, ...
    'Box',      'off'   ,   ...
    'YGrid',    'on'    ,   ...
    'XGrid',    'on'    ,   ...
    'GridColor', [0 0 0],   ...
    'LineWidth', 1     ,   ...
    'FontSize', 12)


%% Functions
    function niceTitle = varConverter(variable, dur, direction)
        switch variable
            case 'RHipAngles'
                varString = 'Right Hip Angle';
            case 'LHipAngles'
                varString = 'Left Hip Angle';
            case 'RKneeAngles'
                varString = 'Right Knee Angle';
            case 'LKneeAngles'
                varString = 'Left Knee Angle';
            case 'RAnkleAngles'
                varString = 'Right Ankle Angle';
            case 'LAnkleAngles'
                varString = 'Left Ankle Angle';
            otherwise
                error('Add in variable %s to var converter', variable)
        end
        switch dur
            case 'whole'
                durString = 'Over Whole Trial';
            case 'stance'
                durString = 'Over Stance Phase';
        end
        switch direction
            case 'x'
                dirString = 'Flexion/Extension';
            case 'y'
                dirString = 'Adduction/Abduction';
            case 'z'
                dirString = 'Internal/External Rotation';
        end
        niceTitle = sprintf('%s %s %s', varString, dirString, durString);
        
    end
end