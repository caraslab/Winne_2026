function plotRepresentativeBehavior(subjectfile, figsavepath)
% plotRepresentativeBehavior(subjectfile, figsavepath)
%
% Description:
%   Loads a MAT file containing behavioral data for a single subject (an 'output'
%   struct array). Plots (1) an example psychometric fit and (2) threshold as a
%   function of log10(training day). Fits a linear regression to threshold vs.
%   log10(day) and reports the slope in the figure title as an index of learning rate.
%   Saves the figure as a vectorized PDF.
%
% Inputs:
%   subjectfile  - String. Path to the MAT file containing the subject 'output' struct.
%   figsavepath  - String. Path where figure will be saved.
%
%   Written by ML Caras Aug 2025

data = load(subjectfile,'output');
out = data.output;

%Preallocate and initialize
threshvec = nan(numel(out),1);
figure;
clr = [0.5 0.5 0.5];

%Plot psychometric fit
xfit = out(6).fitdata.fit_plot.x;
yfit = out(6).fitdata.fit_plot.dprime;

xpoints = out(6).dprimemat(:,1);
ypoints = out(6).dprimemat(:,2);

subplot(1,2,1)
plot(xfit,yfit,'-','linewidth',2,'color',clr)
hold on
plot(xpoints,ypoints,'o','markersize',12,'markerfacecolor',clr,'color',clr)

%Format plot
xlabel ('AM depth (dB)')
ylabel ('d''');
myformat


% Extract thresholds
for k = 1:numel(out)
    threshvec(k) = out(k).fitdata.threshold;
end

% Plot the trajectory
x = [1:numel(out)]';
xlog = log10(x);
y = threshvec;


subplot(1,2,2)
plot(xlog,y,'s-','linewidth',2,'Markersize', 12,...
    'color', clr, 'MarkerFaceColor',clr);
hold on


%Calculate the regression line
p = polyfit(xlog,y,1);
yfit = polyval(p,xlog);
slope = p(1);

%Plot the regression line
plot(xlog,yfit,'k-','linewidth',2);

%Format the plot
xlabel('Adaptive training day')
ylabel('Threshold (dB)')
myformat
xtick = log10(1:7);
set(gca,'xtick',xtick);
xticklabels = round(10.^xtick,0);
xticklabels = arrayfun(@num2str, xticklabels, 'UniformOutput', false);
set(gca,'xticklabels', xticklabels)
set(gca,'xlim', [-0.1 1.1])
title( sprintf('Slope = %.2f dB/log(day)', p(1)) );


%save figure
fig1 = gcf;
fname = fullfile(figsavepath,'RepresentativeBehavior.pdf');
exportgraphics(fig1, fname, 'ContentType','vector');



end