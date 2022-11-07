%% load_Caravan - saves ...
%
%   This script loads ...
%   
%   References
%   xxx
%
%   Copyright (C) 2022
%   This software is distributed under the GNU Public License Version 3.
%   See <https://www.gnu.org/licenses/gpl-3.0.en.html> for details.

close all
% clear all
clc

%% Data location and directories
% Add the Caravan repository to the Matlab paths. 
mydir = 'Caravan';
addpath(genpath(mydir));

% The resulting files will be stored in a folder named "Data". If this
% folder does not exist yet, we have to create it.
if ~(exist(strcat(mydir,'/Data')) == 7)
    mkdir (strcat(mydir,'/Data'))
end

% Add TOSSH to path.
if (exist('TOSSH') == 7)
    addpath(genpath('TOSSH'));
else
    error('TOSSH toolbox needed. Can be downloaded from https://github.com/TOSSHtoolbox and should be in a folder named TOSSH in the same directory.')
end

%% Caravan data
% First, we need to download and extract the Caravan data from:
% https://zenodo.org/record/6647189
path = 'D:/Data/Caravan/';
dataset_list = ["camels", "camelsaus"]; %, "camelsbr"', ...
    %"camelscl", "camelsgb", "hysets", "lamah"];

for i = 1:2 %7
    
    % Define dataset name
    dataset_name = dataset_list(i);
    
    % Load data into Matlab
    [attributes, timeseries] = load_Caravan_helper(path, dataset_name);

    % Calculate signatures
    signatures = calc_BasicSet(timeseries.Q, timeseries.t);
    %signatures = calc_All(...
    %    timeseries.Q, timeseries.t, timeseries.P, timeseries.PET, timeseries.T);
    % Make table with IDs
    signatures.gauge_id = attributes.gauge_id;
    signatures = struct2table(signatures);


    table_tmp = join(attributes,signatures);
    if i>1
        complete_table = [complete_table; table_tmp];
    end
    
    % Free memory
    clear attributes
    clear timeseries
    clear table_tmp
    
end

writetable(complete_table,'complete_table.csv')

% Plot results
