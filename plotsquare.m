function plotsquare(data, frange, varargin)

if nargin<2 || isempty(frange)
  if isstruct(data)
    foi    = data.freq;
    frange = data.freq([1 end]);
  else
    foi    = 1:size(data,3);
    frange = [1 size(data,3)];
  end
end
if numel(frange)==1
  frange = [1 1].*frange;
end


param = ft_getopt(varargin, 'param', 'grangerspctrm');
cmap  = ft_getopt(varargin, 'cmap',  'hot');

if isstruct(data)
  if ~isfield(data, 'label')
    data = ft_checkdata(data, 'cmbrepresentation', 'full');
  end
  tmpcfg = [];
  tmpcfg.frequency = frange;
  tmpcfg.avgoverfreq = true;
  data = ft_selectdata(tmpcfg, data);
  dat  = data.(param);
else
  findx(1) = nearest(frange(1), foi);
  findx(2) = nearest(frange(2), foi);

  dat = nanmean(data(:,:,findx(1):findx(2)),3);
end

imagesc(dat);
colormap(cmap);
