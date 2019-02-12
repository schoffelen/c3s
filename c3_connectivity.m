function connectivity = c3_connectivity(freq, type, F, frange)

if nargin<4
  frange = [0 100];
end

if nargin<3
  F = [];
end

if nargin<2 || isempty(type)
  type = 'granger';
end

switch type
  case 'granger'
    cfgc                  = [];
    cfgc.method           = 'granger';
    cfgc.granger.sfmethod = 'bivariate';
    cfgc.granger.checkconvergence = false;
    cfgc.granger.feedback = 'no';
  case 'pdc'
    cfgc                  = [];
    cfgc.method           = 'pdc';
  case 'dtf'
    cfgc                  = [];
    cfgc.method           = 'dtf';
  case 'coh'
    cfgc                  = [];
    cfgc.method           = 'coh';
    cfgc.complex          = 'complex';
  case 'ddtf'
    cfgc                  = [];
    cfgc.method           = 'ddtf';
  case 'gpdc'
    cfgc                  = [];
    cfgc.method           = 'gpdc';  
  case {'transfer' 'iis'}
    cfgc                  = [];
    cfgc.method           = 'transfer';
    cfgc.granger.sfmethod = 'bivariate';
  case 'psi'
    cfgc                  = [];
    cfgc.method           = 'psi';
    cfgc.bandwidth        = 2;
end

if isfield(freq, 'transfer') && isfield(freq, 'label')
  % transfer function has already been computed
  connectivity = keepfields(freq, {'label' 'dimord' 'freq' 'cfg'});
  
  if ~isempty(F)
    if iscell(F)
      unmixing = F{4};
      mixing = F{3};
      L = F{2};
      F = F{1};
    else
      L = F';
      mixing = eye(size(F,2));
      unmixing =eye(size(F,2));
    end
    transfer = zeros(size(F,1),size(F,1),numel(freq.freq));
    crsspctrm = zeros(size(transfer));
    noisecov  = F*mixing*freq.noisecov*mixing'*F';
    for k = 1:numel(freq.freq)
      transfer(:,:,k) = pinv(((F*mixing)/freq.transfer(:,:,k))*(unmixing*L));
      crsspctrm(:,:,k) = transfer(:,:,k)*noisecov*transfer(:,:,k)';
    end
    freq.transfer = transfer;
    freq.crsspctrm = crsspctrm;
    freq.noisecov  = noisecov;
  end
  if isfield(freq, 'label') && size(F,1)~=numel(freq.label) && ~isempty(F)
    label = cell(size(F,1),1);
    for k = 1:numel(label)
      label{k} = sprintf('chan%03d',k);
    end
    connectivity.label = label;
  end
  switch type
    case 'pdc'
      connectivity.pdcspctrm = ft_connectivity_pdc(shiftdim(freq.transfer,-1),'invfun','pinv');
    case 'dtf'
      connectivity.dtfspctrm = ft_connectivity_dtf(shiftdim(freq.transfer,-1),'invfun','pinv');
    case 'gpdc'
      connectivity.gpdcspctrm = ft_connectivity_pdc(shiftdim(freq.transfer,-1),'invfun','pinv','noisecov',freq.noisecov);
    case 'ddtf'
      connectivity.ddtfspctrm = ft_connectivity_dtf(shiftdim(freq.transfer,-1),'invfun','pinv','crsspctrm',shiftdim(freq.crsspctrm,-1));  
    case 'granger'
      connectivity.grangerspctrm = ft_connectivity_granger(shiftdim(freq.transfer,-1),shiftdim(freq.noisecov,-1),shiftdim(freq.crsspctrm,-1),'dimord','rpt_chan_chan_freq');
  end
else
  connectivity = ft_connectivityanalysis(cfgc, freq);
  if strcmp(type, 'iis')
    cfgnew = [];
    cfgnew.method = 'iis';
    connectivity = ft_connectivityanalysis(cfgnew, connectivity);
  end
end

if ~isempty(frange) && numel(connectivity.freq)>1
  cfg = [];
  cfg.frequency = frange;
  connectivity  = ft_selectdata(cfg, connectivity);
end
