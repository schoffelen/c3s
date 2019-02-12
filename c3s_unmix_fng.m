function [fd, c, g, g_r, data, F] = c3s_unmix_fng(data, sourcemodel, headmodel)

if ~isstruct(data) && exist('data','file')
  filename = data;
  load(filename, 'data', 'sourcemodel', 'headmodel');
elseif isstruct(data)
  % this is ok
end

if ~exist('sourcemodel', 'var') && nargin<2
  sourcemodel = [];
  headmodel   = [];
end

if isempty(sourcemodel) || isempty(headmodel)
  error('sourcemodel should be specified');
end

[data, F]  = c3s_source(data, sourcemodel, headmodel, 'bf');
[fd, c, g] = c3s_fng(data);
[~,  ~, g_r]  = c3s_fng(data, 1);

if exist('filename','var')
  newfilename = strrep(filename,'mix','unmix');
  save(newfilename, 'F', 'fd', 'g', 'g_r', 'c');
end
  