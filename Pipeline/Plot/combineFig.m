
% script to paste a set of zfit figures into a single figure. 
% For this to work, all other figures must be closed before running
% fitZ_series.m

% count open figures
h =  findobj('type','figure');
n = length(h);

nDay = n/2;
% build list of figure numbers
for i = 1:n
    fig_num(i)=h(i).Number;
end

% get size of one panel
fig1_pos = h(1).Position;
% Prepare the new figure and layout 
nRow = 2;
nCol = nDay;
fig_width = nCol * fig1_pos(3);
fig_height = nRow * fig1_pos(4);

f = figure('Name', 'composite','Position',[100,100,fig_width,fig_height]); 
t = tiledlayout(f,2,4); 
plotOrder = [1,3,5,7,2,4,6,8];
% Paste figures on the tiles 

for i = 1:8
    currIndex = find(fig_num == plotOrder(i));
    currFig = h(currIndex);
    currChild = copyobj(currFig.Children, t);
    axCurr = findobj(currChild, 'type', 'axes');
    axCurr.Layout.Tile = i;
end
