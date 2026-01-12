function colors = select_colors_adaptive
% colors = select_colors_adaptive
%
% Description:
% Returns a 4×3 RGB matrix with fixed color assignments for experimental
% conditions used in instrumental training figures:
%   1) Untrained (gray)
%   2) Instrumental (4 h post) (green)
%   3) Adaptive training 2-day (4 hr post) (purple)
%   4) Adaptive training 7-day (4 hr post) (orange)
%
% Colors are drawn from MATLAB's 'colorcube' colormap
%
% Written by ML Caras Aug 2025

cmap = colormap('colorcube');

%Adaptive training
clr1 = [0.5,0.5,0.5];
clr2 = cmap(length(cmap)/4,:);

cmap = colormap('lines');
clr3 = [0.6875, 0.4875 1]; %purple
clr4 = cmap(3,:);

colors = [clr1;clr2;clr3;clr4];

close all;