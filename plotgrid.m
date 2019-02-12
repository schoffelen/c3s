function plotgrid(n,indxwhite,indxred,indxyellow)

if nargin<3
  indxred = [];
end
if nargin<4
  indxyellow = [];
end

for k = 1:numel(indxwhite)
  plot([0.5 n+0.5],[1 1]*indxwhite(k),'w');
  plot([1 1]*indxwhite(k),[0.5 n+0.5],'w');
end

for k = 1:numel(indxred)
  plot([0.5 n+0.5],[1 1]*indxred(k),'r');
  plot([1 1]*indxred(k),[0.5 n+0.5],'r');
end
 
for k = 1:numel(indxred)
  plot([0.5 n+0.5],[1 1]*indxyellow(k),'y');
  plot([1 1]*indxyellow(k),[0.5 n+0.5],'y');
end

plot([0.5 n+0.5],[0.5 n+0.5], 'w');