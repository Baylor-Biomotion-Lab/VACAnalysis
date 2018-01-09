% function Table2Copy=PhaseAligner
% Use the resample function to be able to plot stance phases along the same length.
% Version 2.3
close all
clc
clear
set(0,'DefaultFigureWindowStyle','docked')
cd('H:\Research\MATLAB\VAC\CollectedData\Test')
%% User Input
% Input desired trials to analyze
% Note: Order of trials does not matter, but trials must be in groups of
% sizes equivalent to the variable TrialNo.
% If you would like to only select a specific activity, set the variable
% "Activity" to that activity. Otherwise, set "Activity" = 0.

[To_Load, PathName,~]=uigetfile('*.mat', 'Multiselect', 'on');
[ CategorizedTable, ~, ~, Conditions ,activities ] = NameMiner( To_Load );
vars={'RHipAngles', 'LHipAngles', 'RAnkleAngles','LAnkleAngles','LKneeAngles','RAnkleAngles'};

for act=1:length(activities)
    Activity=activities{act};
    close all
    for var=1:length(vars)
        close all
        VariableName=vars{var};
        
        % Default directions are usually x=flex/ext, y=ab/adduction, z=int/ext rotation% Give information about how many trials to analyze and how many conditions
        % you are comparing data across.
        
        % Number of trials per condition. Trials in To_Load should be arranged in
        % this way.
        TrialNo=3;
        
        EMGNo=0;
        
        
        
        ConditionNo=length(Conditions);
        
        if ischar(Activity)
            To_Load=CategorizedTable{strcmp(CategorizedTable{:,4}, Activity),1};
        end
        
        % The last piece of user input is on line #76
        files=length(To_Load);
        data=cell(files,5);
        
        
        % % Error checking to keep you in line
        % if TrialNo>8
        %     error('Max number of trials right now is 8.')
        % end
        %
        % if files/TrialNo ~= ConditionNo
        %     error('Incorrect file number. Check TrialNo, ConditionNo, and To_Load')
        % end
        
        
        files=length(To_Load);
        
        ConditionNums=1:files;
        for trial=1:files
            
            if ~strcmp(To_Load{trial}(end-3:end),'.mat')
                To_Load{trial}=sprintf('%s.mat',To_Load{trial});
            end
            load(To_Load{trial},'ModelOutput', 'ModelOutputHelp','RightStancePhase', 'LeftStancePhase', 'RightSwingPhase', 'LeftSwingPhase', 'EMGTable', 'TrialInfo')
            
            ModelNames=ModelOutputHelp{:,2};
            Variable=find(strcmp(ModelNames,VariableName));
            
            if isempty(Variable)
                error('Incorrect variable name')
            end
            
            [~,directions]=size(ModelOutput{Variable,1});
            if directions>3
                error('Please choose a variable that only has x, y, and z directions')
            end
            %{
                    Choose which phase type/foot to use:
                    RightStancePhase
                    RightSwingPhase
                    LeftStancePhase
                    LeftSwingPhase
    
                    Note: Won't work if the trial does not have the required phase.
            %}
            try
                if strcmp(TrialInfo.FootDominance, 'R')
                    PhaseBegin=RightStancePhase(1,1); PhaseEnd=RightStancePhase(1,2);
                else
                    PhaseBegin=LeftStancePhase(1,1); PhaseEnd=LeftStancePhase(1,2);
                end
            catch
                PhaseBegin=1; PhaseEnd=length(ModelOutput{1,1});
                warning('Unable to load phase for trial %s file %g', To_Load{trial}, trial)
            end
            
            for direction=1:3
                data{trial,direction}=ModelOutput{Variable}(PhaseBegin:PhaseEnd,direction); %#ok<USENS>
            end
            
            data{trial,5}=ConditionNums(trial);
            
            if EMGNo == 0
                continue
            elseif numel(EMGTable)<4
                error('Incorrect EMG Table for this trial')
            else
                dataL=length(ModelOutput{Variable});
                EMGL=length(EMGTable{EMGNo,2}{1});
                EMGResamp=resample(EMGTable{EMGNo,2}{1}, dataL, EMGL);
                data{trial,4}=EMGResamp(PhaseBegin:PhaseEnd);
            end
        end
        
        EMGResample=4;
        if EMGNo == 0
            data(:,4)=[];
            EMGResample=3;
        end
        
        SortedData=cell(size(data));
        
        % Sort the cell by size (look into getting rid of array)
        for direction=1:EMGResample
            datasize=cellfun('size', data(:,direction), 1);
            [~,index]=sort(datasize,'descend');
            SortedData(:,direction)=data(index, direction);
            if EMGResample==3 && direction==1
                SortedData(:,4)=data(index,4);
            elseif EMGResample~=3 && direction == 1
                SortedData(:,5)=data(index,5);
            end
        end
        
        % Resample each data set down to the shortest piece of data
        DNew=length(SortedData{files});
        xax=(1:DNew)/DNew*100;
        for trial=1:files-1
            for direction=1:EMGResample
                DOld=length(SortedData{trial, direction});
                SortedData{trial, direction}=resample(SortedData{trial, direction},DNew,DOld);
            end
        end
        % Re-sort according to order in To_Load
        [~,index]=sort([SortedData{:,end}]);
        SortedData=SortedData(index,:);
        %% Subplot each data point
        figure(1)
        directionNames={'x','y','z', 'EMG'};
        
        for direction=1:3
            %Subplot each data point
            subplot(3,1,direction)
            hold on
            for trial=1:files
                plot(xax,SortedData{trial,direction})
            end
            PlotTitle=sprintf('%s in %s-Direction',VariableName,directionNames{direction});
            title(PlotTitle);
            xlabel('% of Phase')
            ylabel(VariableName)
            hold off
        end
        legend(To_Load,'interpreter','none', 'Location','northeast')
        %% Group trials, each with an appropriate color
        figure(2)
        Colors={'r'; 'g'; 'b'; 'k'; 'm'; 'c';  'w'; 'y'};
        
        for direction=1:3
            ColorCount=1; TrialCount=1;
            subplot(3,1,direction)
            hold on
            for trial=1:files
                plot(xax,SortedData{trial,direction},Colors{ColorCount});
                TrialCount=TrialCount+1;
                if TrialCount>TrialNo
                    TrialCount=1;
                    ColorCount=ColorCount+1;
                end
            end
            PlotTitle=sprintf('%s in %s-Direction Grouped',VariableName,directionNames{direction});
            title(PlotTitle);
            xlabel('% of Phase')
            ylabel(VariableName)
            hold off
        end
        %% Average the variables and plot them
        figure(3)
        SortedDataAvg=cell(size(Conditions));
        for direction=1:3
            trial=1;
            fileNext=trial+TrialNo-1;
            
            subplot(3,1,direction)
            hold on
            for condition=1:ConditionNo
                % I couldn't find anything to average the cells the way I wanted
                % to, so this is a custom function
                    SortedDataAvg{condition}=AvgCells(SortedData(:,direction),trial,fileNext);

                trial=trial+TrialNo;
                fileNext=trial+TrialNo-1;
                plot(xax,SortedDataAvg{condition}, Colors{condition})
            end
            PlotTitle=sprintf('%s in %s-Direction Averaged',VariableName,directionNames{direction});
            title(PlotTitle);
            xlabel('% of Phase')
            ylabel(VariableName)
            hold off
        end
        % Put in conditions here to get a legend
        if ~isempty(Conditions) && length(Conditions)==ConditionNo
            legend(Conditions, 'interpreter', 'none')
        end
        
        %% Save figure 3 as image
                cd('H:\Research\MATLAB\VAC\ArticulateLabPics')
                imageName=sprintf('%s_%s.png', VariableName, Activity);
                saveas(figure(3), imageName);
    end
end