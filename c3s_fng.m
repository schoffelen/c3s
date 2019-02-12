function [fd, c, g, freq] = c3s_fng(data, reversetime, parametric, order)


if nargin<2 || isempty(reversetime)
  reversetime = false;
end

if nargin<3 || isempty(parametric)
  parametric = false;
end

if nargin<4
  order = 50;
end

if ~isstruct(data) && exist('data','file')
  filename = data;
  load(filename, 'data');
elseif isstruct(data)
  % this is ok
end

[freq, fd] = c3_spectral(data, 2, false, parametric, order);
if reversetime
  freq.fourierspctrm = conj(freq.fourierspctrm);
end

if nargout>1
  try
    c = c3_connectivity(ft_checkdata(freq, 'cmbrepresentation', 'fullfast'), 'coh');
  catch
    c = c3_connectivity(ft_checkdata(freq, 'cmbrepresentation', 'full'), 'coh');
  end  
end
if nargout>2
  g = c3_connectivity(freq,'granger');
end

if exist('filename','var')
  save(filename, 'fd', 'g', 'c', '-append');
end