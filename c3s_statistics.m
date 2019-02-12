if ~exist('datadir', 'var')
  datadir = '/home/language/jansch/projects/c3s/data/snr1_corr_indx9-17';
end
if ~exist('dosmooth', 'var')
  dosmooth = false;
end
%dosmooth = istrue(dosmooth);
cd(datadir);

d = dir('*corr*');
for k = 1:numel(d)
  fprintf('loading %s\n',d(k).name);
  load(d(k).name, 'g', 'g_r', 'g_unmix', 'g_r_unmix', 'g_mix', 'g_r_mix', 'F');
  filt{k} = F;
  G{k,1} = g;
  G{k,2} = g_r;
  G{k,3} = g_mix;
  G{k,4} = g_r_mix;
  G{k,5} = g_unmix;
  G{k,6} = g_r_unmix;
end

if dosmooth==1
  krn = gausswin_fwhm(25,5);
  krn = krn*krn';
  krn = krn./sum(krn(:));
  
  for k = 1:numel(G)
    G{k} = ft_checkdata(G{k},'cmbrepresentation','full');
    tmp = G{k}.grangerspctrm;
    tmp(~isfinite(tmp)) = 0;
    tmp = convn(tmp, krn, 'same');
    G{k}.grangerspctrm = tmp;  
  end
elseif dosmooth==2
  for k = 1:size(G,1)
    krn = filt{k}*filt{k}';
    krn = krn./sqrt(diag(krn)*diag(krn)');
    krn = abs(krn);
    G{k,5} = ft_checkdata(G{k,5},'cmbrepresentation','full');
    tmp = G{k,5}.grangerspctrm;
    tmp(~isfinite(tmp)) = 0;
    for kk = 1:size(tmp,3)
      tmp(:,:,kk) = krn*tmp(:,:,kk)*krn';
    end
    G{k,5}.grangerspctrm = tmp;
    G{k,6} = ft_checkdata(G{k,6},'cmbrepresentation','full');
    tmp = G{k,6}.grangerspctrm;
    tmp(~isfinite(tmp)) = 0;
    for kk = 1:size(tmp,3)
      tmp(:,:,kk) = krn*tmp(:,:,kk)*krn';
    end
    G{k,6}.grangerspctrm = tmp;
    
    
  end

  
end

n = 25;
cfg = [];
cfg.design = [ones(1,n) ones(1,n)*2;1:n 1:n];
cfg.statistic = 'depsamplesT';
cfg.ivar = 1;
cfg.uvar = 2;
cfg.method    = 'analytic';
cfg.parameter = 'grangerspctrm';
cfg.tail = 1;
stat       = ft_freqstatistics(cfg,G{:,1},G{:,2});
if ~isempty(G{1,3})
  stat_mix   = ft_freqstatistics(cfg,G{:,3},G{:,4});
else
  stat_mix = [];
end
stat_unmix = ft_freqstatistics(cfg,G{:,5},G{:,6});

if ~dosmooth
  stat.labelcmb = G{1,1}.labelcmb;
  if ~isempty(G{1,3})
    stat_mix.labelcmb = G{1,3}.labelcmb;
  end
  stat_unmix.labelcmb = G{1,5}.labelcmb;
end

if ~dosmooth
  save('stat', 'stat', 'stat_mix', 'stat_unmix');
else
  save('stat_smooth', 'stat', 'stat_mix', 'stat_unmix');
end