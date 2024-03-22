function fitZ_series

% for a series of datasets, load the EMD match files, fit the distribution 
% of z distances to folded gaussian + exp to extract estimated FP.
close all;  % close figures
addpath(genpath('C:\Users\colonellj\Documents\matlab_ephys\Neuron_Tracking_fork\Neuron_Tracking')); % path to repo
% path to EMD results (in Example script, this is given by: input.EMD_path)
output_path = 'C:\Users\colonellj\Documents\matlab_ephys\Neuron_Tracking_fork\Neuron_Tracking\CA_examples\MB109\EMD_input';
fg_width = 3.5;  % set to -1 to fit fg_width for each dist

% count up datasets:
filelist = dir(output_path);
% for each EMD_post
nRes = 0;
for i = 1:numel(filelist)
    if startsWith(filelist(i).name, 'EMD_post')
        nRes = nRes + 1;
        emd_res{nRes} = filelist(i).name;
    end
end

% for each EMD point found, fetch the zDist data from all_results column 7
% and fit.

fp_est_10um = zeros([nRes,1]);

for i = 1:nRes
    currDat = load(fullfile(output_path,emd_res{i}));
    zDist_all = currDat.all_results(:,7);
    [~,data_label,~] = fileparts(emd_res{i});
    currVal = fit_zDist( zDist_all, data_label, fg_width  );
    fp_est_10um(i) = currVal;
end

save(fullfile(output_path, 'zdist_fit_res.mat'), "emd_res","fp_est_10um");

% combine individual plots into one big figure (easier to look at and save)


% get list of open figures
h =  findobj('type','figure');
% n = length(h);
% 
% nDay = n/2;
% build list of figure numbers
for i = 1:2*nRes
    fig_num(i)=h(i).Number;
end

% get size of one panel
fig1_pos = h(1).Position;
% Prepare the new figure and layout 
nRow = 2;
nCol = nRes;
fig_width = nCol * fig1_pos(3);
fig_height = nRow * fig1_pos(4);

f = figure('Name', 'composite','Position',[100,100,fig_width,fig_height]); 
t = tiledlayout(f,2,nRes); 
plotOrder=[1:2:nRes*2,2:2:nRes*2];

% Paste figures on the tiles 

for i = 1:2*nRes
    currIndex = find(fig_num == plotOrder(i));
    currFig = h(currIndex);
    currChild = copyobj(currFig.Children, t);
    axCurr = findobj(currChild, 'type', 'axes');
    axCurr.Layout.Tile = i;
end


end