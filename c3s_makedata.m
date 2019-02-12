function [data, params] = c3s_makedata(filename, params)

rng('default');
rng('shuffle');

if nargin<1 ||isempty(filename)
  savedata = false;
else
  savedata = true;
end

if nargin<2 || isempty(params)
  params = [];
end
params.nsignal = ft_getopt(params, 'nsignal', 25);
params.ntrials = ft_getopt(params, 'ntrials', 1);
params.triallength = ft_getopt(params, 'triallength', 200);
params.cuttrials   = ft_getopt(params, 'cuttrials', 1);
params.ampl    = ft_getopt(params, 'ampl', randn(params.nsignal,1)./10+0.2);
params.fsample = ft_getopt(params, 'fsample', 1000);

params.coupling_indx     = ft_getopt(params, 'coupling_indx',     [9 17],        1);
params.coupling_strength = ft_getopt(params, 'coupling_strength', [0 0.2;  0 0], 1);
params.coupling_delay    = ft_getopt(params, 'coupling_delay',    [0 0.05; 0 0], 1);

if ~isempty(params.cuttrials)
  cfg2         = [];
  cfg2.length  = params.cuttrials;
else
  cfg2 = [];
end

if params.nsignal>2
data = cell(1, params.nsignal);
for k = 1:params.nsignal
  cfg          = [];
  cfg.nsignal  = 1;
  cfg.coupling = 0;
  cfg.ampl     = params.ampl(k);
  cfg.delay    = 0;
  cfg.bpfreq   = zeros(1,1,2)+nan;
  if mod(k+1,2)==0
    cfg.bpfreq = cat(3, 8+randn(1)./2, 12+randn(1)./2);
  end
  cfg.method      = 'ar_reverse';
  cfg.fsample     = params.fsample;
  cfg.ntrials     = params.ntrials;
  cfg.triallength = params.triallength;
  tmp             = ft_connectivitysimulation(cfg);
  tmp.label{1}    = sprintf('signal%03d',k);
  if ~isempty(cfg2)
    tmp = ft_redefinetrial(cfg2, tmp);
  end
  data{k}         = tmp;
  clear tmp;
end

if iscell(data)
  data = ft_appenddata([],data{:});
end
end

if ~(all(params.coupling_strength(:)==0) || isempty(params.coupling_strength))
  cfg          = [];
  cfg.nsignal  = 2;
  cfg.ampl     = diag([0.2 0.1]);
  cfg.bpfreq   = cat(3,[8 8;nan 8],[12 12;nan 12]);
  
  cfg.coupling = params.coupling_strength;
  cfg.delay    = params.coupling_delay;
  
  cfg.method   = 'ar_reverse';
  cfg.fsample  = params.fsample;
  cfg.ntrials  = params.ntrials;
  cfg.triallength = params.triallength;
  tmp = ft_connectivitysimulation(cfg);
  if ~isempty(cfg2)
    tmp = ft_redefinetrial(cfg2, tmp);
  end
  data = tmp; clear tmp;
  data.time(:) = data.time(1);
else
  data.time(:) = data.time(1);
  
  data.trial = cellrowassign(data.trial, tmp.trial, params.coupling_indx);
  clear tmp;
end

if savedata
  save(filename, 'data');
end