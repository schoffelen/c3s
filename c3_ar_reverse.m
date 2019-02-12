
fs    = 1000;
Nyq   = fs./2;
foi   = (0:0.2:Nyq);
omega = foi./fs;
n     = numel(omega);

nsignal = 2;
coupling = [0 0.15;0.15 0];
ampl     = [0.2 0.08;0.05 0.1];
delay    = [0 0.05;0.015 0];
fband(:,:,1) = [40 40; 7  7];
fband(:,:,2) = [60 60;15 15];


slope         = 0.5;
oneoverf_ampl = sqrt(max(omega(2)./10,omega).^-slope);
oneoverf_ampl = oneoverf_ampl./oneoverf_ampl(1);

mask = false(nsignal, nsignal, n);
findx = fband;
for k = 1:numel(fband)
  
  findx(k) = nearest(foi, fband(k));
end

krn = zeros(size(mask));
phi = zeros(size(krn));
dat = zeros(size(krn));
coupling_ampl = zeros(size(krn));
for k = 1:nsignal

  for m = 1:nsignal
    if all(isfinite(squeeze(findx(k,m,:)))),
      mask(k,m,findx(k,m,1):findx(k,m,2)) = true;
    end
    krn(k,m,mask(k,m,:))                = hanning(sum(mask(k,m,:)))';

    phi(k,m,:) = 2.*pi.*delay(k,m).*foi;
    phi(k,m,:) = phi(k,m,:).*mask(k,m,:);
    phi(k,m,mask(k,m,:)) = phi(k,m,mask(k,m,:))-mean(phi(k,m,mask(k,m,:)));
    
    coupling_ampl(k,m,:) = coupling(k,m).*krn(k,m,:);
  end
end
for k = 1:nsignal
  dat(k,k,:) = oneoverf_ampl;
  for m = 1:nsignal
    dat(k,k,:) = dat(k,k,:)+krn(m,m,:).*ampl(k,m);
  end
end

% now we can create a spectral transfer matrix
tf = zeros(nsignal,nsignal,n)+1i.*zeros(nsignal,nsignal,n);
for k = 1:nsignal
  for m = 1:nsignal
    if k~=m
      tf(k,m,:) = coupling_ampl(k,m,:).*exp(1i.*phi(k,m,:));
    else
      tf(k,m,:) = dat(k,m,:);
    end
  end
end

% create the cross spectral matrix
c = zeros(size(tf));
for k = 1:n
  c(:,:,k) = tf(:,:,k)*tf(:,:,k)'; % assume noise to be I, i.e. the tf to swallow the amplitudes
end

freq           = [];
freq.crsspctrm = c;
freq.label     = {'chan01';'chan02'};
freq.freq      = foi;
freq.dimord    = 'chan_chan_freq';

cfgt        = [];
cfgt.method = 'transfer';
cfgt.granger.sfmethod = 'bivariate';
t          = ft_connectivityanalysis(cfgt, freq);
t.noisecov = repmat(t.noisecov, [1 numel(t.freq)]);
t          = ft_checkdata(t, 'cmbrepresentation', 'full');
t.noisecov = t.noisecov(:,:,1);

% compute the model coefficients
a = transfer2coeffs(t.transfer,t.freq);

order = 999;
cfg = [];
cfg.params = a;
cfg.triallength = 2;
cfg.noisecov = t.noisecov.*fs.*cfg.triallength./2;
cfg.ntrials  = 200;
cfg.fsample  = fs;
cfg.nsignal  = 2;
cfg.method   = 'ar';
data2 = ft_connectivitysimulation(cfg);

cfgf = [];
cfgf.method = 'mtmfft';
cfgf.output = 'fourier';
cfgf.tapsmofrq = 1;
cfgf.pad = 2;
freq2 = ft_freqanalysis(cfgf, data2 );
freq2 = ft_checkdata(freq2, 'cmbrepresentation', 'fullfast');

cfgc         = [];
cfgc.method  = 'coh';
coh  = ft_connectivityanalysis(cfgc, freq);
coh2 = ft_connectivityanalysis(cfgc, freq2);

cfgg        = [];
cfgg.method = 'granger';
cfgg.granger.sfmethod = 'bivariate';
g  = ft_connectivityanalysis(cfgg, freq);
g2 = ft_connectivityanalysis(cfgg, freq2);

t2 = ft_connectivityanalysis(cfgt, freq2);
t2.noisecov = repmat(t2.noisecov, [1 numel(t.freq)]);
t2          = ft_checkdata(t2, 'cmbrepresentation', 'full');
t2.noisecov = t2.noisecov(:,:,1);

fd  = ft_freqdescriptives([],ft_checkdata(freq,  'cmbrepresentation', 'sparse'));
fd2 = ft_freqdescriptives([],ft_checkdata(freq2, 'cmbrepresentation', 'sparse'));

