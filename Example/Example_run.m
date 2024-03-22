% An example of tracking units, with reference data
% The original data are from animal AL032 in the paper
%
%----------add packages----------
% EDIT to match your system
% Path to this repository
addpath(genpath('C:\Users\colonellj\Documents\matlab_ephys\Neuron_Tracking_fork\Neuron_Tracking'))
% Path to npy-matlab
addpath(genpath('C:\Users\colonellj\Documents\npy-matlab-master'))

% This script expects each day's data to be in subdirectories under
% input.input_path. The directories are named 'D<day id>'.
% Each days data must include:
% from phy output generated by KS25: 
%       channel_map.npy         channel indicies used in sort
%       channel_positions.npy   X,Z coordinates for each used channel
%
% other required input:
% MEAN WAVEFORMS (file name specified by 'input.wf_name': 
%       The mean waveforms must be in an npy file with dimensions (nUnit,
%       nChan,nt). For data collected with SpikeGLX, use the C_Waves utility.
%       This pipeline was developed using mean waveforms calculated using the
%       drift corrected data from KS2.5.:
%           --save the KS2.5 working output file, and rez2.mat structure
%           --run ks25_phy_toBinary.m -> creates an unwhitened version of the
%          data and runs C_Waves. 
%       C_Waves can also be run on the original data, or the data post
%       processing by CatGT. 
% UNIT CALLS (file name specified by input.KSLabel_name)
%   Tab delimited file with one header line and two columns. Can include
%   all units, or a subset.
%   Column 1 = unit index, 0 based (matching phy)
%   Column 2 = 'good' or other. Only units indicies with the 'good' label
%   are included in matching. Indicies not present in this file are not
%   used.
% metrics.csv file from the ecephys pipeline or a .csv file with one header
% line and at least two columns. Required columns and header labels (in quotes):
%   'cluster_id' = unit index, 0 based
%   'firing_rate' = firing rate, in Hz
%
%
% 
%       
%----------EDIT to define paths for input----------
input.input_path = 'C:\Users\colonellj\Documents\matlab_ephys\Neuron_Tracking_fork\Neuron_Tracking\Example'; % parent directory of data files 
input.EMD_path = fullfile(input.input_path,'EMD_input\'); % Directory for this pipeline to store input, create before running
input.wf_name = 'ksproc_mean_waveforms.npy'; % name for mean waveform files
input.KSLabel_name = 'cluster_KSLabel.tsv'; % name for files of unit calls
input.chan_pos_name = 'channel_positions.npy';
input.chan_map_name = 'channel_map.npy'; 
input.shank = -1; % To include all shanks, set to -1, for 2.0 probes, set to 0-based probe index to limit to single shank


% Input data characteristics
input.fs = 30000; %acquisition rate, Neuropixels default
input.ts = 82; %wf time samples, set by C_Waves

% parameters for running match
input.l2_weights = 1500;
input.threshold = 10; %z distance threshold for matched units, 10um recommended, can change if needed
input.validation = 0; % set to 1 if you are including validation data, see README for format
input.xStep = 32; %space between columns of sites, um (NP 2.0 = 32, can find in the channel map)
input.zStep = 15; %space between rows of sites, um (NP 2.0 = 15, can find in the channel map)
input.dim_mask = logical([1,1,1,0,0,0,0,0,0,1]); %default = x,z,y position, waveform distance
input.dim_mask_physical = logical([1,1,1,0,0,0,0,0,0,0]);
input.dim_mask_wf = logical([0,0,0,0,0,0,0,0,0,1]);
input.diagDistCalc = true; % set to true to include separate calcualtion of distance and waveform sim matrices

numData = 5; %Number of datasets to match



%----------Unit tracking----------
if exist(input.EMD_path, 'dir') == 0
    mkdir(input.EMD_path);
end

% Read in chan_pos and chan_map from first day; all other days should match
chan_pos = readNPY(fullfile(input.input_path, 'D1', input.chan_pos_name));
chan_map = readNPY(fullfile(input.input_path, 'D1', input.chan_map_name));

% Find match of all datasets (default: day n and day n+1, can be changed to track between non-consecutive datasets)
for id = 1:numData-1
    input.data_path1 = ['D',num2str(id)]; % first dataset, NEED CHANGE 
    input.data_path2 = ['D',num2str(id+1)]; % second dataset, NEED CHANGE
    result_dir = sprintf('result_%d_%d',id,id+1);
    input.result_path = fullfile(input.input_path,result_dir); %result directory 
    input.input_name = ['input',num2str(id),'.mat']; 
    input.input_name_post = ['input_post',num2str(id),'.mat']; 
    input.filename_pre = ['EMD_pre',num2str(id),'.mat']; 
    input.filename_post = ['EMD_post',num2str(id),'.mat']; 
    input.chan_pos = chan_pos;
    input.chan_map = chan_map;
    mwf1 = readNPY(fullfile(input.input_path, input.data_path1, input.wf_name));
    mwf2 = readNPY(fullfile(input.input_path, input.data_path2, input.wf_name));
    NT_main(input, mwf1, mwf2);
end



%% ----------Plot matched units----------
% Select a first datasets (integer in [1:numData-1] and
plot_id = 1;
% Select unit index in the list of matches with z distance < threshold
plot_unit_index = 18;

input_plot = input;
input_plot.data_path1 = ['D',num2str(plot_id)];
input_plot.data_path2 = ['D',num2str(plot_id+1)];
result_dir = sprintf('result_%d_%d',plot_id,plot_id+1);
input_plot.result_path = fullfile(input.input_path,result_dir); %result directory 
input_plot.filename_post = ['EMD_post',num2str(plot_id),'.mat']; 

% plot unit locations and matches of curr_id and curr_id+1
% includes all matches (z distance threshold not applied).
plot_unit(input_plot);

% Plot sample waveform from 
plot_out = load(fullfile(input_plot.result_path,'Output.mat'));
% find matched units with zdist < 10 um
all_matches = plot_out.output.all_results_post;
thresh_match_ind = all_matches(:,7) < 10;
thresh_matches = all_matches(thresh_match_ind,:);
% in all_matches:
%     column 2 = unit index for dataset (plot_id + 1)
%     column 3 = unit index on dataset (plot_id)
plot_waveform(input_plot, thresh_matches(plot_unit_index,3),thresh_matches(plot_unit_index,2));

% Z distance distribution
plot_z(fullfile(input_plot.result_path));


% waveform vs physical distance. INPUT = result path 
plot_dist(input_plot);


%% Find chains
for id = 1:numData-1 % Load data
    result_dir = sprintf('result_%d_%d',id,id+1);
    all_input(id) = load(fullfile(input.input_path,result_dir, "Input.mat")); 
    all_output(id) = load(fullfile(input.input_path,result_dir,'Output.mat'));
end
[chain_all,z_loc,len] = chain_summary(all_input,all_output,numData,input.input_path);
fprintf('Completed chain search. \n')

if ~isempty(len)

%----------Plot chains of interest (waveform, firing rate, original location, drift-corrected location, L2)----------
full_chain = chain_all(len == numData,:); %find chains with length across all datasets
[L2_value,fr_all,fr_change,x_loc_all,z_loc_all] = chain_stats(all_input,all_output,full_chain,numData,input.input_path);

numChain = size(full_chain,1);
ichain = 1; %which chain to plot, please enter a number between 1 and numChain as input, NEED CHANGE  

figure()
for id = 1:numData-1
    % plot waveform
    plot_wf(all_input, full_chain, L2_value, chan_pos, numData, ichain, id);
end
% plot firing rate
plot_fr(fr_all, fr_change, numData, ichain);
% plot location
plot_loc(all_input,x_loc_all,z_loc_all, chan_pos, numData,ichain)

end