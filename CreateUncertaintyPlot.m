function handlevalue=CreateUncertaintyPlot(x, Mid, Upper, Lower, LineColour)


handlevalue=plot(x, Mid, [ 'o' LineColour], 'LineWidth', 2);
hold on;
[~, sizex]=size(x);
d=(max(x)-min(x)+1)/sizex/4;
i=0;
for xi=x
   i=i+1;
   %middle line
   plot([xi xi], [Upper(i) Lower(i)], LineColour, 'LineWidth', 2 );
   % Bars
   plot([xi-d xi+d], [Lower(i) Lower(i)], LineColour, 'LineWidth', 2 );
   plot([xi-d xi+d], [Upper(i) Upper(i)], LineColour, 'LineWidth', 2 );
end
hold off;