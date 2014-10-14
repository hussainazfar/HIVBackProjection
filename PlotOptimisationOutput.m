function PlotOptimisationOutput(ExpectedOutput, SimResultVector)
    % Plot the function output
    
    size(ExpectedOutput)
    size(SimResultVector)
    
    
    hold on;
    plot( SimResultVector, 'r'); 
    plot( ExpectedOutput, 'b.'); 
    xlabel('Bucket','fontsize', 22);
    ylabel('Count','fontsize', 22);
    set(gca,'Color',[1.0 1.0 1.0]);
    set(gcf,'Color',[1.0 1.0 1.0]);%makes the grey border white
    set(gca, 'fontsize', 18);
    box off;


end