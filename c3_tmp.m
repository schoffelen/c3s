cfg = [];
cfg.nsignal = 2;
cfg.coupling = [0 0.15;0.15 0];
cfg.ampl     = [0.2 0.08;0.05 0.1];
cfg.delay    = [0 0.05;0.015 0];
cfg.bpfreq(:,:,1) = [40 40; 7  7];
cfg.bpfreq(:,:,2) = [60 60;15 15];
cfg.method = 'ar_reverse';
cfg.fsample = 1000;
cfg.ntrials = 200;
cfg.triallength = 1;
datax = ft_connectivitysimulation(cfg);

cfgf = [];
cfgf.method = 'mtmfft';
cfgf.output = 'fourier';
cfgf.tapsmofrq = 1;
cfgf.pad = 2;
freqx = ft_freqanalysis(cfgf, datax);
freqx = ft_checkdata(freqx, 'cmbrepresentation', 'fullfast');

cfgc         = [];
cfgc.method  = 'coh';
coh  = ft_connectivityanalysis(cfgc, freqx);

cfgg        = [];
cfgg.method = 'granger';
cfgg.granger.sfmethod = 'bivariate';
g  = ft_connectivityanalysis(cfgg, freqx);

fd  = ft_freqdescriptives([],ft_checkdata(freqx,  'cmbrepresentation', 'sparse'));



