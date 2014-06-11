function CreateUncertaintyPlot(x, Mid, Upper, Lower)

clf;
plot(x, Mid, 'o', 'LineWidth', 2);
hold on;
[~, sizex]=size(x);
d=(max(x)-min(x)+1)/sizex/4;
i=0;
for xi=x
   i=i+1;
   %middle line
   plot([xi xi], [Upper(i) Lower(i)], 'LineWidth', 2 );
   % Bars
   plot([xi-d xi+d], [Lower(i) Lower(i)], 'LineWidth', 2 );
   plot([xi-d xi+d], [Upper(i) Upper(i)], 'LineWidth', 2 );
end
hold off;