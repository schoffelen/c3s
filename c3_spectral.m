function [freq, fd, freqH, mixing, unmixing] = c3_spectral(data, tapsmofrq, pcaflag, parametric, order)

if nargin<5
  order = 10;
end

if nargin<4 || isempty(parametric)
  parametric = false;
end

if nargin<3 || isempty(pcaflag)
  pcaflag = false;
end

if nargin<2 || isempty(tapsmofrq)
  tapsmofrq = 2;
end

if parametric
  cfgm = [];
  cfgm.order = order;
  cfgm.method = 'bsmart';
  cfgm.channelcmb = ft_channelcombination({'all' 'all'}, data.label);
  %cfgm.channelcmb = cfgm.channelcmb(1:6,:);
  mdata = ft_mvaranalysis(cfgm, data);
  
  %cfgf = [];
  %cfgf.method = 'mvar';
  freq = ft_freqanalysis_mvar([], mdata);
  
  fd = ft_checkdata(freq, 'cmbrepresentation', 'full');
  fd   = keepfields(fd, {'freq' 'label' 'crsspctrm'});
  fd.dimord = 'chan_freq';
  pow = zeros(numel(fd.label), numel(fd.freq));
  for k = 1:numel(fd.freq)
    pow(:,k) = abs(diag(fd.crsspctrm(:,:,k)));
  end
  fd.powspctrm = pow;
  fd = rmfield(fd, 'crsspctrm');
  
else
  cfgf           = [];
  cfgf.method    = 'mtmfft';
  cfgf.taper     = 'dpss';
  cfgf.output    = 'fourier';
  cfgf.tapsmofrq = tapsmofrq;
  cfgf.pad       = 1.024.*4;
  freq           = ft_freqanalysis(cfgf, data);
  fd             = ft_freqdescriptives([], freq);
end

if nargout>2
  if pcaflag
    % perform a pca prior to the transfer function computation, and project
    % back
    cfg        = [];
    cfg.method = 'pca';
    comp       = ft_componentanalysis(cfg, data);
    v          = var(comp.trial,[],2);
    v          = cumsum(v)./sum(v);
    keepchan   = v<=0.99;
    
    cfg = [];
    cfg.channel = comp.label(keepchan);
    comp2       = ft_selectdata(cfg, comp);
    freq2       = ft_freqanalysis(cfgf, comp2);
    freqH       = ft_connectivity_csd2transfer(ft_checkdata(freq2,'cmbrepresentation','fullfast'));
    mixing      = comp2.topo;
    unmixing    = comp2.unmixing;
  else
    freqH = ft_connectivity_csd2transfer(ft_checkdata(freq,'cmbrepresentation','fullfast'));
  end
end