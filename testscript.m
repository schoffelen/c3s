% start with 'data'

tmpcfg = [];
tmpcfg.channel = data.label([8 9 12:14 17 18]);
data = ft_selectdata(tmpcfg, data);
[fd, c, g, freq] = c3s_fng(data);
[~,  ~, gr]      = c3s_fng(data,1);

[data_mix, lf, sourcemodel, headmodel, indx] = c3_mix(data,7,11);
[fd_mix,c_mix,g_mix, freq_mix]               = c3s_fng(data_mix);
[~,     ~,    g_mixr]                        = c3s_fng(data_mix,1);

[data_mix, lf, sourcemodel, headmodel, indx] = c3_mix(data,7,101);
[fd_mix,c_mix]                               = c3s_fng(data_mix);
[data_unmix, F] = c3s_source(data_mix, sourcemodel, headmodel);
[fd_unmix,c_unmix,g_unmix, freq_unmix] = c3s_fng(data_unmix);
[~,     ~,    g_unmixr]                = c3s_fng(data_unmix,1);

[data_mix_noise, noise]     = c3_addnoise(data_mix, 25, 'white');
[fd_mix_noise,c_mix_noise]  = c3s_fng(data_mix_noise);
[data_unmix_noise, F_noise] = c3s_source(data_mix_noise, sourcemodel, headmodel);
[fd_unmixn,c_unmixn,g_unmixn, freq_unmixn] = c3s_fng(data_unmix_noise);
[~,     ~,    g_unmixnr]                   = c3s_fng(data_unmix_noise,1);

for k = 1:10
  selrpt = randperm(numel(data_mix_noise.trial),150);
  tmpcfg = [];
  tmpcfg.trials = selrpt;
  [data_unmix_noise, F_noise] = c3s_source(ft_selectdata(tmpcfg, data_mix_noise), sourcemodel, headmodel);
  [fd_unmixn,c_unmixn,g_unmixn, freq_unmixn] = c3s_fng(data_unmix_noise);
  [~,     ~,    g_unmixnr]                   = c3s_fng(data_unmix_noise,1);
  G{1,k} = g_unmixn;
  Gr{1,k} = g_unmixnr;
end

data2 = data;

tmpcfg = [];
tmpcfg.channel = data2.label(4);
tmpdata = ft_selectdata(tmpcfg, data2);

tmpcfg = [];
tmpcfg.bpfilter = 'yes';
tmpcfg.bpfreq   = [8 12];
tmpdataf = ft_preprocessing(tmpcfg, tmpdata);

data2.trial = cellrowassign(data2.trial, tmpdata.trial+0.5.*tmpdataf.trial, 4);
[fd2, c2, g2, freq2] = c3s_fng(data2);
[~,  ~, gr2]      = c3s_fng(data2,1);

[data_mix2]      = c3_mix(data2,7,101);
[fd_mix2,c_mix2] = c3s_fng(data_mix2);
[data_unmix2, F2] = c3s_source(data_mix2, sourcemodel, headmodel);
[fd_unmix2,c_unmix2,g_unmix2] = c3s_fng(data_unmix2);
[~,     ~,    g_unmixr2]      = c3s_fng(data_unmix2,1);

data_mix_noise2 = data_mix2;
data_mix_noise2.trial = data_mix2.trial + noise;
[fd_mix_noise2,c_mix_noise2]  = c3s_fng(data_mix_noise2);
[data_unmix_noise2, F_noise2] = c3s_source(data_mix_noise2, sourcemodel, headmodel);
[fd_unmixn2,c_unmixn2,g_unmixn2] = c3s_fng(data_unmix_noise2);
[~,     ~,    g_unmixnr2]                   = c3s_fng(data_unmix_noise2,1);
