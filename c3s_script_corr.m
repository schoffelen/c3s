if ~exist('filename', 'var')
  error('filename should be supplied');
end

if ~exist('params', 'var')
  params = [];
end

if ~exist('snr', 'var')
  snr = 5;
end

if ~exist('nchan', 'var')
  nchan = 101;
end

[data, params] = c3s_makedata([], params);
[fd, c, g]   = c3s_fng(data);
[~,  ~, g_r] = c3s_fng(data, 1);
[fd_mix, c_mix, g_mix, g_r_mix, data_mix, lf, sourcemodel, headmodel, indx] = c3s_mix_fng(data, true, snr, nchan);
[fd_unmix, c_unmix, g_unmix, g_r_unmix, data_unmix, F] = c3s_unmix_fng(data_mix, sourcemodel, headmodel);

save(filename, 'fd', 'g', 'c', 'g_r', 'fd_mix', 'g_mix', 'c_mix', 'g_r_mix', 'lf', 'fd_unmix', 'g_unmix', 'c_unmix', 'g_r_unmix', 'F', 'params', 'snr');