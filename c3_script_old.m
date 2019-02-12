clear all;

% create data
try
  load(fullfile('/home/language/jansch/projects/c3','simdata.mat'));
catch  
  data = c3_data('ar_reverse');
  save(fullfile('/home/language/jansch/projects/c3','simdata.mat'), 'data');
end
  
%[freq, fd, freqH] = c3_spectral(data);
[freq, fd, ~] = c3_spectral(data);
g          = ft_checkdata(c3_connectivity(freq, 'granger'), 'cmbrepresentation', 'full');
%ddtf       = c3_connectivity(freqH, 'ddtf');
%gpdc       = c3_connectivity(freqH, 'gpdc');

% mix
nchan = numel(data.label);
[data_mix_orig, lf, sourcemodel, headmodel, indx] = c3_mix(data, nchan+(nchan-1)*15);

% add a little bit of noise to make the multivariate decomposition
% numerically well-behaved
data_mix = c3_addnoise(data_mix_orig, 20, 'pink');

% spectral representation (sensor-level)
[freq_mix, fd_mix, freqH_mix, mixing, unmixing] = c3_spectral(data_mix, [], 1);

% unmix with beamformer and do spectral analysis
[data_source, F]         = c3_source(data_mix, sourcemodel, headmodel);
[freq_source, fd_source] = c3_spectral(data_source);

% compute granger
f_source   = freq_source;
f_source.fourierspctrm = f_source.fourierspctrm(:,:,1:257);
f_source.freq = f_source.freq(1:257);

tmpcfg = [];
tmpcfg.channel = f_source.label(1:2:end);

g_source   = ft_checkdata(c3_connectivity(ft_selectdata(tmpcfg, f_source), 'granger'), 'cmbrepresentation', 'full');
%pdc_source = c3_connectivity(freqH_mix, 'gpdc', F);
%dtf_source = c3_connectivity(freqH_mix, 'ddtf', F);
c_source   = c3_connectivity(ft_checkdata(f_source, 'cmbrepresentation', 'fullfast'), 'coh');

% unmix with beamformer and do spectral analysis
[data_source_pw, F_pw]         = c3_source(data_mix, sourcemodel, headmodel, 'bf_white');
[freq_source_pw, fd_source_pw] = c3_spectral(data_source_pw);
g_source_pw                    = ft_checkdata(c3_connectivity(freq_source_pw, 'granger'), 'cmbrepresentation', 'full');
pdc_source_pw                  = c3_connectivity(freqH_mix, 'gpdc', F_pw);
dtf_source_pw                  = c3_connectivity(freqH_mix, 'ddtf', F_pw);
