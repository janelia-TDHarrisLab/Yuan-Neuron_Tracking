
function plotDriftHist

% for an output path, count up the result directories, for each, load
% Output.mat, plot histograms of z distances used to determine drift.

output_path = 'C:\Users\colonellj\Documents\matlab_ephys\Neuron_Tracking_fork\Neuron_Tracking\CA_examples\MB107';

% count up datasets:
filelist = dir(output_path);
% find directories result(nm)
nRes = 0;
for i = 1:numel(filelist)
    if startsWith(filelist(i).name, 'result_')
        nRes = nRes + 1;
        res{nRes} = filelist(i).name;
        % parse name to get index of first dataset in the pair
        res_ind(nRes) = sscanf(res{nRes},'result_%d');
    end
end

numRow = ceil(nRes/4);  % Build tiled figure with four columns, as many rows as needed
panelWidth = 8; % cm
panelHeight = panelWidth*0.8;
figWidth = 4*panelWidth;
figHeight = numRow*panelHeight;

% match binsize and range to that used for drift estimation in z_estimate.m
binsize = 4;
edges = (-100:binsize:100);

h = figure('Name','drift_hist','Units','Centimeters', 'Position',[1,10,figWidth,figHeight]);
tiledlayout(numRow,4);

for i = 1:nRes
    nexttile;
    currInd = find(res_ind==i);
    co = load(fullfile(output_path,res{currInd},'Output.mat'));
    curr_mode = co.output.z_mode;
    curr_zVals = co.output.diffZ;
    histogram(curr_zVals,edges);
    title(sprintf('%s, drift est = %.1f um',res{currInd}, curr_mode), 'Interpreter','None');
end

end
