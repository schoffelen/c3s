function [fd, c, g, g_r, data, lf, sourcemodel, headmodel, indx] = c3s_mix_fng(data, noiseflag, snr, nchan)

if ~isstruct(data) && exist('data','file')
  filename = data;
  load(filename, 'data');
elseif isstruct(data)
  % this is ok
end

if nargin<2 || isempty(noiseflag)
  noiseflag = false;
end

if nargin<3 || isempty(snr)
  snr = 5;
end

if nargin<4 || isempty(nchan)
  nchan = 41;
end

[data, lf, sourcemodel, headmodel, indx] = c3_mix(data,25,nchan);
if noiseflag
  [data, noise]        = c3_addnoise(data, snr, 'spatiallycolored');
else
  noise = [];
end
%[fd, c, g] = c3s_fng(data);
%[~,  ~, g_r]  = c3s_fng(data, 1);
[fd, c] = c3s_fng(data);
%[~,  ~, g_r]  = c3s_fng(data, 1);
g = [];
g_r = [];

if exist('filename','var')
  if noiseflag
    newfilename = strrep(filename,'sensordata_corr','sensordata_corr_mix_noise');
    save(newfilename, 'data', 'fd', 'g', 'lf', 'sourcemodel', 'headmodel', 'c', 'g_r');
  else
    newfilename = strrep(filename,'sensordata_corr','sensordata_corr_mix');
    save(newfilename, 'data', 'fd', 'g', 'lf', 'sourcemodel', 'headmodel', 'c', 'g_r');
  end
end
  