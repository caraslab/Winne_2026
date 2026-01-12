function plot_ablation_pfs(chABC, saline, pase)
% plot_ablation_pfs(chABC, saline, pase)
%
% Description:
%   Plots psychometric functions (d' vs. AM depth) for three representative subjects/
%   treatments (chABC, Saline, and Penicillinase) for Day 1 and Day 8. For each input
%   struct (expected to contain an 'output' struct array), plots the fitted
%   psychometric curve and overlays raw data points, using a solid line for Day 1
%   and a dashed line for Day 8. Displays treatments side-by-side in subplots and
%   links axes for direct comparison.
%
% Inputs:
%   chABC      - Struct. Loaded subject data containing field 'output' (struct array).
%   saline     - Struct. Loaded subject data containing field 'output' (struct array).
%   pase       - Struct. Loaded subject data containing field 'output' (struct array).
%
% Outputs:
%   None.
%
%   Written by ML Caras Aug 2025


figure;

for i = 1:3

    switch i
        case 1
            h = chABC;
        case 2
            h = saline;
        case 3
            h = pase;
    end

%Plot data
s(i) = subplot(1,3,i);

for j = [1,8] %Days 1 and 8
   
    %Plot fit
    x = h.output(j).fitdata.fit_plot.x;
    y = h.output(j).fitdata.fit_plot.dprime;
    p = plot(x,y,'linewidth',2,'Color','black');

    if j == 8
        set(p,'LineStyle','--');
    end

    hold on

    %Plot data points
    x = h.output(j).dprimemat(:,1);
    y = h.output(j).dprimemat(:,2);
    p = plot(x,y,'ko','MarkerSize',9);

    if j == 1
        set(p,'MarkerFaceColor','black')
    end

end

xlabel('AM Depth (dB)')
ylabel('d''')
set(gca,'ytick',0:1:3,'TickDir','out','Box','off',...
    'LineWidth',1.5,'FontName','Arial','FontSize',16)

if i == 1
    title('chABC')
elseif i == 2
    title('Saline')
elseif i == 3
    title('Penicillinase')
end


end

linkaxes(s)
set(s(1),'ylim',[-0.1 3.1],'xlim',[-30 5])
set(gcf,'color','w')
