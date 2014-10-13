function PlotOptimisationOutput(ExpectedOutput, SimResultVector, ParameterBounds)
    % Plot the function output
    
    hold on;
    plot(SimResultVector(:, 1), SimResultVector(:, 2), 'r.'); 
    plot(ExpectedOutput( 1), ExpectedOutput( 2), 'b.'); %this only plots the first 2 dimensions

    xlabel('Parameter 1','fontsize', 22);
    ylabel('Parameter 2','fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18);
    box off;


end