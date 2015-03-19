function handlevalue = CreateUncertaintyPlot(x, Mid, Upper, Lower, LineColour)


handlevalue = plot(x, Mid, [ 'o' LineColour], 'LineWidth', 2);
hold on;
[~, sizex] = size(x);
d=(max(x) - min(x) + 1) / sizex / 4;
y = 0;
for xi=x
   y=y+1;
   %middle line
   plot([xi xi], [Upper(y) Lower(y)], LineColour, 'LineWidth', 2 );
   % Bars
   plot([xi-d xi+d], [Lower(y) Lower(y)], LineColour, 'LineWidth', 2 );
   plot([xi-d xi+d], [Upper(y) Upper(y)], LineColour, 'LineWidth', 2 );
end
hold off;