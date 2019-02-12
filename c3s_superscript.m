 %% c3s_superscript

clear;

basedir = '/home/language/jansch/projects/c3s/data';

snr  = 8;
indx = [9 17];
params.coupling_indx = indx;
params.ampl          = ones(25,1)./10;
params.ampl(indx)    = 0.2;

datadir = fullfile(basedir, 'snr8_indx9-17');
mkdir(datadir);
cd(datadir);
for k = 1:25
  filename=fullfile(pwd,sprintf('data_corr%03d',k));
  qsubfeval('c3s_execute_script','c3s_script_corr',{'filename' filename},{'snr',snr},{'params',params},'memreq',16*1024^3,'timreq',90*60);
end

