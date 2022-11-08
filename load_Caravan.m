%% load_Caravan - saves ...
%
%   This script loads Caravan data, calculates mean fluxes and hydrological
%   signatures, and saves it as csv file.
%   
%   References
%   Kratzert, Frederik, Nearing, Grey, Addor, Nans, Erickson, Tyler, Gauch, 
%   Martin, Gilon, Oren, Gudmundsson, Lukas, Hassidim, Avinatan, Klotz, 
%   Daniel, Nevo, Sella, Shalev, Guy, & Matias, Yossi. (2022). Caravan - A 
%   global community dataset for large-sample hydrology (0.4) [Data set]. 
%   Zenodo. https://doi.org/10.5281/zenodo.6647189
%
%   Copyright (C) 2022
%   This software is distributed under the GNU Public License Version 3.
%   See <https://www.gnu.org/licenses/gpl-3.0.en.html> for details.

close all
clear all
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
dataset_list = ["camels", "camelsaus", "camelsbr", "camelscl", "camelsgb", "hysets", "lamah"];

for i = 1:7
    
    % Define dataset name
    dataset_name = dataset_list(i);
    
    % Load data into Matlab
    [attributes, timeseries] = load_Caravan_helper(path, dataset_name);

    % Calculate signatures
%     signatures = calc_BasicSet(timeseries.Q, timeseries.t);
    signatures = calc_All(...
       timeseries.Q, timeseries.t, timeseries.P, timeseries.PET, timeseries.T);
    % Make table with IDs
    signatures.gauge_id = attributes.gauge_id;
    signatures = struct2table(signatures);


    table_tmp = join(attributes,signatures);
    
    if exist('complete_table', 'var')
        complete_table = [complete_table; table_tmp];
    else
        complete_table = table_tmp;
    end
    
    % Free memory
    clear attributes
    clear timeseries
    clear table_tmp
    
end

%writetable(complete_table,'complete_table.csv')

% todo: make sure that timeseries of P and Q match

%% Plot results
figure; hold on
histogram(complete_table.PETmean.*365)
histogram(complete_table.pet_mean.*365)
figure; hold on
histogram(complete_table.Pmean.*365)
histogram(complete_table.p_mean.*365)

figure; hold on
scatter(complete_table.aridity,1-complete_table.Q_mean./complete_table.p_mean,5)
scatter(100./complete_table.ari_ix_sav,1-complete_table.Qmean./complete_table.Pmean,5)
xlabel('PET/P'); ylabel('1-Q/P')
plot(0.001:0.001:1,0.001:0.001:1,'k-')
plot(1:100,ones(size(1:100)),'k-')
plot(0.001:100,zeros(size(0.001:100)),'k--')
xlim([0 5])
ylim([-0.5 1])
% set(gca,'xscale','log')

figure; hold on
scatter(complete_table.slp_dg_sav,complete_table.BFI,25,100./complete_table.ari_ix_sav,'filled')
xlabel('Slope'); ylabel('BFI')
colorbar;
caxis([0 2]);
set(gca,'xscale','log')
cor = corr(complete_table.slp_dg_sav,complete_table.BFI,'type','Spearman','rows','complete')
parcor = partialcorr(complete_table.slp_dg_sav,complete_table.BFI,complete_table.frac_snow,'type','Spearman','rows','complete')
parcor = partialcorr(complete_table.slp_dg_sav,complete_table.BFI,100./complete_table.ari_ix_sav,'type','Spearman','rows','complete')
parcor = partialcorr(complete_table.slp_dg_sav,complete_table.BFI,complete_table.Tmean,'type','Spearman','rows','complete')

figure; hold on
scatter(100./complete_table.ari_ix_sav,complete_table.slp_dg_sav)
cor = corr(100./complete_table.ari_ix_sav,complete_table.slp_dg_sav,'type','Spearman','rows','complete')
xlim([0 5])
