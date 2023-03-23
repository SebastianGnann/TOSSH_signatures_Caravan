%% load_Caravan - calculation of signatures for Caravan catchments
%
%   This script loads Caravan data, calculates mean fluxes and hydrological
%   signatures, and saves it as csv file.
%   
%   References
%   Kratzert, F., Nearing, G., Addor, N., Erickson, T., Gauch, M., Gilon, 
%   O., ... & Matias, Y. (2023). Caravan-A global community dataset for 
%   large-sample hydrology. Scientific Data, 10(1), 61.
%
%   Copyright (C) 2023
%   This software is distributed under the GNU Public License Version 3.
%   See <https://www.gnu.org/licenses/gpl-3.0.en.html> for details.

close all
clear all
clc

%% Data location and directories
% Add the Caravan repository to the Matlab paths. 
mydir = 'Caravan';
addpath(genpath(mydir));

% The resulting files will be stored in a folder named "results". If this
% folder does not exist yet, we have to create it.
if ~(exist(strcat(mydir,'/results')) == 7)
    mkdir (strcat(mydir,'/results'))
end

% Add TOSSH to path.
if (exist('TOSSH') == 7)
    addpath(genpath('TOSSH'));
else
    error('TOSSH toolbox needed. Can be downloaded from https://github.com/TOSSHtoolbox and should be in a folder named TOSSH in the same directory.')
end

% Add BrewerMap package.
if (exist('BrewerMap') == 7)
    addpath(genpath('BrewerMap'));
else
    error('BrewerMap toolbox needed. Can be downloaded from https://github.com/DrosteEffect/BrewerMap and should be in a folder named BrewerMap in the same directory.')
end

%% Caravan data
% First, we need to download and extract the Caravan data from:
% https://zenodo.org/record/7540792
path = 'D:/Data/Caravan/'; % replace with local path
dataset_list = ["camels", "camelsaus", "camelsbr", "camelscl", "camelsgb", "hysets", "lamah"];
%dataset_list = ["hysets"];

for i = 1:7
    
    % Define dataset name
    dataset_name = dataset_list(i);
    
    % Load data into Matlab
    [attributes, timeseries] = load_Caravan_helper(path, dataset_name);

    % Calculate signatures
    signatures = calc_All(...
       timeseries.Q, timeseries.t, timeseries.P, timeseries.PET, timeseries.T);
    % Make table with IDs
    signatures.gauge_id = attributes.gauge_id;
    signatures = struct2table(signatures);


    table_tmp = join(attributes,signatures);
    
    if exist('complete_table', 'var')
        TOSSH_signatures_Caravan = [TOSSH_signatures_Caravan; table_tmp];
    else
        TOSSH_signatures_Caravan = table_tmp;
    end
    
    % Free memory
    clear attributes
    clear timeseries
    clear table_tmp
    
end

% remove FDC to save space
TOSSH_signatures_Caravan.FDC = [];
TOSSH_signatures_Caravan.FDC_error_str = [];
writetable(TOSSH_signatures_Caravan,'./results/TOSSH_signatures_Caravan.csv')

%% Plot results
% test calculation
figure; hold on
histogram(TOSSH_signatures_Caravan.Pmean.*365)
histogram(TOSSH_signatures_Caravan.p_mean.*365)

% make Budyko-type figure
figure; hold on
scatter(TOSSH_signatures_Caravan.PET/TOSSH_signatures_Caravan.P,1-TOSSH_signatures_Caravan.TotalRR,5)
xlabel('PET/P'); ylabel('1-Q/P')
plot(0.001:0.001:1,0.001:0.001:1,'k-')
plot(1:100,ones(size(1:100)),'k-')
plot(0.001:100,zeros(size(0.001:100)),'k--')
xlim([0 5])
ylim([-0.5 1])
% set(gca,'xscale','log')

figure; hold on
scatter(100./TOSSH_signatures_Caravan.ari_ix_sav,1-TOSSH_signatures_Caravan.TotalRR,5)
xlabel('PET/P'); ylabel('1-Q/P')
plot(0.001:0.001:1,0.001:0.001:1,'k-')
plot(1:100,ones(size(1:100)),'k-')
plot(0.001:100,zeros(size(0.001:100)),'k--')
xlim([0 5])
ylim([-0.5 1])
% set(gca,'xscale','log')
