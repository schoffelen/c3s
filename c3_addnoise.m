function [data, noise] = c3_addnoise(data, snr, type)

if nargin < 3 
  type = 'pink';
end

if nargin < 2
  snr = 100;
end

switch type
  case 'pink'
    noisefun = @pinknoise;
  case 'white'
    noisefun = @randn;
  case 'spatiallycolored'
    noisefun = @spatialnoise;
end

noise = cell(1,numel(data.trial));
for k = 1:numel(data.trial)
  if strcmp(type, 'spatiallycolored') && k==1
    [noise{k}, mix] = spatialnoise(size(data.trial{k}));
  elseif strcmp(type, 'spatiallycolored') && k>1
    noise{k} = spatialnoise(size(data.trial{k}), mix);
  else
    noise{k} = noisefun(size(data.trial{k}));
  end
  noise{k} = noise{k}./norm(noise{k},'fro');
  noise{k} = noise{k}.*norm(data.trial{k},'fro')/snr;
  data.trial{k} = data.trial{k} + noise{k};
end

function [out, mix] = spatialnoise(dim, mix)

if nargin<2 || isempty(mix)
  mix = [];
end

krn = gausswin(25,8);
krn = krn*krn';
krn = krn./sum(krn(:));
mix = convn(randn(dim(1),dim(1).*2),krn,'same');
out = mix*randn(dim.*[2 1]);
out = diag(sqrt(1./diag(out*out')))*out;
