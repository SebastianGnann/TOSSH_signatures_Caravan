function [attributes, timeseries] = ...
    load_Caravan_helper(path, dataset_name, save_struct)
%saveCAMELSstruct_AUS Creates struct file with CAMELS AUS data.
%   - Loads hydro-meteorological time series and catchment attributes
%   - Timeseries are loaded for the period in which all data are available 
%
%   INPUT
%   path: Caravan data path
%   dataset_name: Caravan dataset, e.g. camels, camelsgb, etc.
%   save_struct: whether to save struct file or not
%
%   OUTPUT
%   attributes: struct file with attribute data
%   timeseries: struct file with timeseries data
%
%   Copyright (C) 2022
%   This software is distributed under the GNU Public License Version 3.
%   See <https://www.gnu.org/licenses/gpl-3.0.en.html> for details.

if nargin < 2
    error('Not enough input arguments.')
elseif nargin < 3
    save_struct = false;
end

%% Specify paths
path_attributes = strcat(path, 'attributes/', dataset_name,'/');
path_timeseries = strcat(path, 'timeseries/csv/', dataset_name,'/');

if ~(exist(path_attributes) == 7)
    error('Cannot find catchment attributes path.')
end
if ~(exist(path_timeseries) == 7)
    error('Cannot find timeseries path.')
end

%% Load catchment attributes
attributes_caravan = readtable(...
    strcat(path_attributes,'attributes_caravan_',dataset_name,'.csv'),...
    'ReadVariableNames',true);

attributes_hydroatlas = readtable(...
    strcat(path_attributes,'attributes_hydroatlas_',dataset_name,'.csv'),...
    'ReadVariableNames',true);

% merge attributes
attributes = join(attributes_caravan,attributes_hydroatlas);

%% Load hydro-meteorological time series
% To extract the time series, we loop over all catchments. 
% There are many more time series, but we focus on a few for now.
len = length(attributes.gauge_id);
t = cell(len,1); % time
P = cell(len,1); % precipitation
PET = cell(len,1); % potential evapotranspiration
Q = cell(len,1); % streamflow
T = cell(len,1); % temperature
Pmean = nan(len,1); % precipitation
PETmean = nan(len,1); % potential evapotranspiration
Qmean = nan(len,1); % streamflow
Tmean = nan(len,1); % temperature


fprintf('Loading catchment timeseries data...\n')
for i = 1:len % loop over all catchments
    
    if mod(i,100) == 0 % check progress
        fprintf('%.0f/%.0f\n',i,len)
    end
    
    tmp_table = readtable(...
        strcat(path_timeseries,attributes.gauge_id{i},'.csv'),...
        'ReadVariableNames',true);
    
    t{i} = datetime(tmp_table.date);
    % total_precipitation_sum	
    P{i} = tmp_table.total_precipitation_sum;
    % potential_evaporation_sum	
    PET{i} = tmp_table.potential_evaporation_sum;
    % streamflow
    Q{i} = tmp_table.streamflow;
    % temperature_2m_mean
    T{i} = tmp_table.temperature_2m_mean;
    
    PETmean(i) = mean(PET{i},'omitnan');
    Qmean(i) = mean(Q{i},'omitnan');
    Pmean(i) = mean(P{i},'omitnan');
    Tmean(i) = mean(T{i},'omitnan');
    
end

% add hydro-meteorological time series to struct file
timeseries.t = t;
timeseries.P = P;
timeseries.PET = PET;
timeseries.Q = Q;
timeseries.T = T;

attributes.Pmean = Pmean;
attributes.PETmean = PETmean;
attributes.Qmean = Qmean;
attributes.Tmean = Tmean;

% save the struct file
if save_struct
    % todo: update name
    save('Caravan/Data/timeseries.mat','-struct','timeseries')
end

end
