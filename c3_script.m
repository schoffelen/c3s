clear all;

% create data
data = c3_data('ar');

mix = zeros(8,12)+0.05;
for k = 1:8
  mix(k,k:(k+4)) = [0.2 0.5 1 0.5 0.2];
end

datamix = data;
datamix.trial = mix*data.trial;
datamix.label = datamix.label(3:10);

% temporally whitened data, univariate AR model, order 1
cfg        = [];
cfg.method = 'bsmart';
cfg.order  = 1;
cfg.univariate = true;
cfg.output = 'residual';
datamix2   = ft_mvaranalysis(cfg, datamix);

% temporally whitened data, multivariate AR model, order 1
cfg        = [];
cfg.method = 'bsmart';
cfg.order  = 1;
cfg.output = 'residual';
datamix3   = ft_mvaranalysis(cfg, datamix);

cfg     = [];
cfg.covariance = 'yes';
covmix  = ft_timelockanalysis(cfg, datamix);
covmix2 = ft_timelockanalysis(cfg, datamix2);
covmix3 = ft_timelockanalysis(cfg, datamix3);

% spatial prewhitening based on data covariance
[u,s,v] = svd(covmix.cov);
S = diag(sqrt(1./diag(s))); %S(end) = 0;
P = u*S*u'; % spatial whitening matrix
datamixw       = datamix;
datamixw.trial = P*datamix.trial;

% spatial prewhitening based on temporally prewhitened data covariance,
% model order 1, univariate
[u,s,v] = svd(covmix2.cov);
S  = diag(sqrt(1./diag(s))); %S(end) = 0;
P2 = u*S*u'; % spatial whitening matrix
datamixw2       = datamix;
datamixw2.trial = P2*datamix.trial;

% spatial prewhitening based on temporally prewhitened data covariance,
% model order 1, multivariate
[u,s,v] = svd(covmix3.cov);
S  = diag(sqrt(1./diag(s))); %S(end) = 0;
P3 = u*S*u'; % spatial whitening matrix
datamixw3       = datamix;
datamixw3.trial = P3*datamix.trial;

% original data 
[fd,      c,     g]      = c3s_fng(data,     0);
[fdr,     ~,     gr]     = c3s_fng(data,     1);

% mixed data 
[fdmix,   cmix,  gmix]     = c3s_fng(datamix,  0);
[fdmixr,  ~,     gmixr]    = c3s_fng(datamix,  1);

% mixed, temporally whitened data, univariate
[fdmix2,  cmix2, gmix2]    = c3s_fng(datamix2, 0);
[fdmixr2, ~,     gmix2r]   = c3s_fng(datamix2, 1);

% mixed, temporally whitened data, multivariate
[fdmix3,  cmix3, gmix3]    = c3s_fng(datamix3, 0);
[fdmixr3, ~,     gmix3r]   = c3s_fng(datamix3, 1);

% mixed, spatially whitened, data covariance
[fdmixw,   cmixw, gmixw]   = c3s_fng(datamixw,  0);
[fdmixwr,  ~,     gmixwr]  = c3s_fng(datamixw,  1);

% mixed, spatially whitened, temporally whitened covariance, univariate
[fdmixw2,  cmixw2, gmixw2] = c3s_fng(datamixw2, 0);
[fdmixw2r, ~,     gmixw2r] = c3s_fng(datamixw2, 1);

% mixed, spatially whitened, temporally whitened covariance, multivariate
[fdmixw3,  cmixw3, gmixw3] = c3s_fng(datamixw3, 0);
[fdmixw3r, ~,     gmixw3r] = c3s_fng(datamixw3, 1);

% create beamformer spatial filters based on the mixed covariance and spatially filter
% the mixed data
for k = 1:size(mix,2)
  lf = mix(:,k);
  lfC = lf'/covmix.cov;
  w(k,:) = (lfC*lf)\lfC;
end
dataunmix       = datamix;
dataunmix.trial = w*datamix.trial;
dataunmix.label = data.label;
[fdunmix,  cunmix, gunmix]  = c3s_fng(dataunmix, 0);
[fdunmixr, ~,      gunmixr] = c3s_fng(dataunmix, 1);

% create spatial filters based on the spatially whitened covariance and spatially filter
% the whitened mixed data
cfg = [];
cfg.covariance = 'yes';
covmixw = ft_timelockanalysis(cfg,datamixw);
for k = 1:size(mix,2)
  lf = P'*mix(:,k);
  lfC = lf'/covmixw.cov;
  ww(k,:) = (lfC*lf)\lfC;
end
dataunmixw       = datamix;
dataunmixw.trial = ww*datamixw.trial;
dataunmixw.label = data.label;
[fdunmixw,  cunmixw, gunmixw]  = c3s_fng(dataunmixw, 0);
[fdunmixwr, ~,       gunmixwr] = c3s_fng(dataunmixw, 1);

cfg = [];
cfg.covariance = 'yes';
covmixw2 = ft_timelockanalysis(cfg,datamixw2);
for k = 1:size(mix,2)
  lf  = P2'*mix(:,k);
  lfC = lf'/covmixw2.cov;
  ww2(k,:) = (lfC*lf)\lfC;
end
dataunmixw2 = datamixw2;
dataunmixw2.trial = ww2*datamixw2.trial;
dataunmixw2.label = data.label;
[fdunmixw2,  cunmixw2, gunmixw2]  = c3s_fng(dataunmixw2, 0);
[fdunmixw2r, ~,        gunmixw2r] = c3s_fng(dataunmixw2, 1);

% for plotting granger
cfgp = []; 
cfgp.parameter = 'grangerspctrm';

cfgmath = [];
cfgmath.parameter = 'grangerspctrm';
cfgmath.operation = 'max(x1-x2,0)';

% for plotting coherence
cfgp2 = [];
cfgp2.parameter = 'cohspctrm';

cfgmath2 = [];
cfgmath2.parameter = 'cohspctrm';
cfgmath2.operation = 'abs(x1)';

% in the plots, black is always the 'ground truth'

% coherence looks overall pretty messed up, specifically for close-by nodes
% (which have comparatively high instantaneous mixing). Overall, spatial
% whitening leads to improvement. Beamformer unmixing as well, but
% occasionally it performs worse than the mixed data.

figure;ft_connectivityplot(cfgp2,ft_math(cfgmath2,cmix),...
                                 ft_math(cfgmath2,cmixw2),...
                                 ft_math(cfgmath2,cunmix),...
                                 ft_math(cfgmath2,c));
                               
g.grangerspctrm = g.grangerspctrm./2; % to get the scale similar to the other variables
gr.grangerspctrm = gr.grangerspctrm./2;


figure;ft_connectivityplot(cfgp, gmix,...
                                 gmixw2,...
                                 gunmix,...
                                 g);

% reverse granger corrected granger causality estimates suffer from the
% mixing, spatial whitening recovers the simulated patterns of interaction,
% unmixing also, but there is still some residual spurious connectivity

figure;ft_connectivityplot(cfgp, ft_math(cfgmath,gmix,gmixr),...
                                 ft_math(cfgmath,gmixw2,gmixw2r),...
                                 ft_math(cfgmath,gunmix,gunmixr),...
                                 ft_math(cfgmath,g,gr));

