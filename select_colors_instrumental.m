function colors = select_colors_instrumental
% colors = select_colors_instrumental
%
% Description:
% Returns a 4×3 RGB matrix with fixed color assignments for experimental
% conditions used in instrumental training figures:
%   1) Untrained (gray)
%   2) 0 hr post-training (black)
%   3) 4 hr post-training (green)
%   4) 24 hr post-training (blue)
%
% Colors are drawn from MATLAB's 'colorcube' colormap
%
% Written by ML Caras Aug 2025

cmap = colormap('colorcube');

clr1 = [0.5,0.5,0.5];           %Untrained
clr2 = cmap(1,:);               %0 hr
clr3 = cmap(length(cmap)/4,:);  %4 hr
clr4 = cmap(length(cmap)/2,:);  %24 hr

colors = [clr1;clr2;clr3;clr4];

close all;