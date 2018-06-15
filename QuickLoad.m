function [To_Load, nameTable] = QuickLoad(file)
%QuickLoad  Loads trials for a specific experiment.
% This will eliminate time spent selecting trials using dialog boxes.
% This function is meant to be updated regularly to accomodate increasing
% experiments.
%
% Current options:
%   [To_Load, nameTable] = QuickLoad('ADL') loads the activities of daily living study
%   [To_Load, nameTable] = QuickLoad('Shoes') loads the tibial stress fracture in shoes study
file = upper(file);
switch file
    case 'ADL'
        load('ADLQL.mat', 'To_Load')
    case 'SHOES'
        load('ShoesQL.mat', 'To_Load')
    otherwise
        error('Not a recognized file name.')
end
[ nameTable, ~, ~, ~, ~ ] = NameMiner( To_Load );
end

