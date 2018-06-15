function [ CategorizedNames, SubNo, TrialNo, categories,activities ] = NameMiner( contents )
%NameMiner finds categorical information for a trial name.  
%
% Input can either be a directory of names EX:
% contents=dir('*.mat')
% Or input can be a single name or cell with names EX:
% contents='R_Subj1_BF_335_TR03.mat'
%
% Category and activity will be held in cells, so to access you would need
% to do categories{1} for an individual trial. 
%
% If we are using a directory of names, we want to get the categories and
% activities. Otherwise, we want the SubNo and TrialNo
%
% [ CategorizedNames, SubNo, TrialNo, categories,activities ] = NameMiner( 'R_Subj1_BF_335_TR03.mat' )
% CategorizedNames will return a table containing all information
% SubNo will be 1
% Trial number will be 3
% Activity is 335 (code for running in this study)
% Category will be BF (barefoot in this study)

SubNo=1;
% Check if contents are a structure (directory) or not.
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
% Loop through each name and find its information
for name=1:namesL
    str=names{name};
    % These should all be .mat files
    if ~strcmp(str(end-4:end),'.mat')
        str=sprintf('%s.mat',str);
    end
    % The file names are separated by an '_' between each relevant piece of
    % information. 
    % First we will break the name up by these.
    expression='(\w+)_(\w+)_(\w+)_(\w+)_(\w+).mat';
    tokens=regexp(str,expression,'tokens');
    % Now we just need to go through each 'token'. The file should always 
    % be named in a specific order. 
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

