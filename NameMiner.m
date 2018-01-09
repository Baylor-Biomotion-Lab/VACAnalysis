function [ CategorizedNames, SubNo, TrialNo, categories,activities ] = NameMiner( contents )
% Uses Jenny's naming convention and finds the category, activity, subject
% and trial number for each trial.

% Input can either be a directory of names EX:
% contents=dir('*.mat')
% Or input can be a single name or cell with names EX:
% contents='R_Subj1_BF_335_TR03.mat'


% If we are using a directory of names, we want to get the categories and
% activities. Otherwise, we want the SubNo and TrialNo
SubNo=1;
if isstruct(contents)
    namesL=length(contents);
    names=cell(namesL,1);
    [names{1:namesL}]=contents(1:namesL).name;
    SubNo=NaN;
    TrialNo=NaN;
else
    contents=cellstr(contents);
    namesL=length(contents);
    names=contents;
end
CategorizedNames=cell(namesL,5);

for name=1:namesL
    str=names{name};
    
    if ~strcmp(str(end-4:end),'.mat')
        str=sprintf('%s.mat',str);
    end
    expression='(\w+)_(\w+)_(\w+)_(\w+)_(\w+).mat';
    tokens=regexp(str,expression,'tokens');
    
    subStr=tokens{1}{2};
    subExp='(\d+)';
    Sub=regexp(subStr,subExp,'tokens');
    Sub=str2double(Sub{1});
    
    Category=tokens{1}{3};
    
    Activity=tokens{1}{4};
    
    trialStr=tokens{1}{5};
    trialExp='(\d+)';
    Trial=regexp(trialStr,trialExp,'tokens');
    Trial=str2double(Trial{1});
    
    
    CategorizedNames{name,1}=names{name};
    CategorizedNames{name,2}=Sub;
    CategorizedNames{name,3}=Trial;
    CategorizedNames{name,4}=Activity;
    CategorizedNames{name,5}=Category;
end

categories=unique(CategorizedNames(:,5));
activities=unique(CategorizedNames(:,4));

if ~isnan(SubNo)
    SubNo=Sub;
    TrialNo=Trial;
end

CategorizedNames=cell2table(CategorizedNames,'VariableNames',{'Name', 'SubNo', 'TrialNo', 'Activity', 'Category'});

end

