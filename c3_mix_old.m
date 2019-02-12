function [data, lf, sourcemodel, headmodel, indx] = c3_mix(data, npos, nchanout)

if nargin<2
  npos = numel(data.label);
end
if nargin<3
  nchanout = floor(npos./3);
end

nchan = numel(data.label);
nchan2 = floor(nchan./2);

npos2 = floor(npos./2);

% create some leadfields, a sourcemodel, and a headmodel
lf = [eye(npos);eye(npos);eye(npos)];
krn = sin(2.*pi.*(0.5:(npos-0.5))./npos)'.*gausswin(npos);
krn = krn./max(krn);
lf = convn(lf, krn);

n  = ceil(size(lf,1)./2);
lf = lf(n+(-npos2:npos2),:);%';

if npos==nchan
  % don't interpolate the lf, the mapping from channel to position is
  % 1-to-1
  indx = 1:npos;
else
  xval  = (0.5:(nchan-0.5))./nchan;
  xval2 = linspace(xval(1),xval(end),npos);
% %   lf2   = zeros(size(lf,1),numel(xval2));
% %   for k = 1:size(lf,1)
% %     lf2(k,:) = interp1(xval,lf(k,:),xval2,'pchip');
% %   end
%   [x,y] = ndgrid(xval,xval);
%   [x2,y2] = ndgrid(xval2,xval2);
%   lf2 = interpn(x,y,lf,x2,y2,'cubic');
%   lf_orig = lf;
%   lf      = lf2; clear lf2; 
  
  indx = zeros(1,nchan);
  for k = 1:nchan
    indx(k) = nearest(xval2,xval(k));
  end
end
npos = size(lf,2);

stepsize = floor(npos./nchanout);
lf = lf(stepsize:stepsize:end,:);

sourcemodel = [];
sourcemodel.pos = [zeros(npos,2) (1:npos)'];
for k = 1:npos
    sourcemodel.leadfield{k} = lf(:,k);
end
sourcemodel.inside = true(npos,1);
sourcemodel.unit = 'cm';

% make a headmodel
cfgh = [];
cfgh.method = 'infinite';
headmodel = ft_prepare_headmodel(cfgh);

% mix the data
data.trial = lf(:,indx)*data.trial;

label = cell(size(lf,1),1);
for k = 1:numel(label)
  label{k} = sprintf('chan%03d',k);
end
data.label = label;

sens.chanpos = rand(numel(data.label),3);
sens.elecpos = sens.chanpos;
sens.label   = data.label;
sens = ft_datatype_sens(sens);
data.elec = sens;
    