function data = c3_data(method)

if nargin<1
  method = 'ar';
end

switch method
  case 'ar'
    % generate a toy model, as per the connectivity tutorial on the fieldtrip
    % website
    cfg             = [];
    cfg.ntrials     = 200;
    cfg.triallength = 1;
    cfg.fsample     = 200;
    cfg.nsignal     = 3;
    cfg.method      = 'ar';
    cfg.params(:,:,1) = [ 0.8    0    0 ;
                            0  0.9  0.5 ;
                          0.4    0  0.5];
    
    cfg.params(:,:,2) = [-0.5    0    0 ;
                            0 -0.8    0 ;
                            0    0 -0.2];
    
    cfg.noisecov      = [ 0.3    0    0 ;
                            0    1    0 ;
                            0    0  0.2];
    data_conn  = ft_connectivitysimulation(cfg);
    cfg.params(:,:,1) = [ 0.5    0    0 ;
                            0  0.5    0 ;
                            0    0  0.5];
    
    cfg.params(:,:,2) = [-0.5    0    0 ;
                          0.5 -0.5    0 ;
                            0    0 -0.5];
    
    cfg.params(:,:,3) = [ 0.5    0    0 ;
                            0  0.5    0 ;
                          0.5    0  0.5];
    
                          
    cfg.noisecov      = [ 0.3    0    0 ;
                            0  0.3    0 ;
                            0    0  0.3];
  
    data_conn2 = ft_connectivitysimulation(cfg);
    
    % combine the connectivity data with a set of noisy time-series
    data2 = data_conn;
    for k = 1:numel(data2.trial)
      %data2.trial{k} = normr(randn(4,200)).*20;
      data2.trial{k} = normr(ft_preproc_baselinecorrect(pinknoise([6 200],[],4))).*40;
    end
    data2.label = {'chan01';'chan02';'chan04';'chan09';'chan11';'chan12'};
    data_conn.label  = {'chan03';'chan05';'chan07'};
    data_conn2.label = {'chan06';'chan08';'chan10'};
    data = ft_appenddata([],data_conn,data_conn2,data2);
    [srt,ix] = sort(data.label);
    data.label = srt;
    for k = 1:numel(data.trial)
      data.trial{k} = data.trial{k}(ix,:);
    end
    
    % make a sens array
    sens.chanpos = rand(12,3);
    sens.elecpos = sens.chanpos;
    sens.label   = data.label;
    sens = ft_datatype_sens(sens);
    data.elec = sens;
    
  case 'linear_mix'
    
    cfg        = [];
    cfg.ntrials     = 200;
    cfg.triallength = 1;
    cfg.fsample     = 200;
    cfg.nsignal     = 3;
    cfg.method      = 'linear_mix';
    cfg.mix    = eye(4); cfg.mix(4,:) = []; cfg.mix(1,4) = 0.8; cfg.mix(2,4) = 0.5; cfg.mix(1,1) = 0.2; cfg.mix(2,2) = 0.5; 
    cfg.delay  = zeros(3,4); cfg.delay(1,4) = 1; cfg.delay(2,4) = 0;
    cfg.bpfilter  = 'yes';
    cfg.bpfreq    = [40 50];
    cfg.bpfilttype = 'firws';
    cfg.absnoise   = 0;
    data_conn = ft_connectivitysimulation(cfg);
    for k = 1:numel(data_conn.trial)
      data_conn.trial{k} = data_conn.trial{k} + normr(pinknoise([3 200])).*10;
    end
    data_conn2 = ft_connectivitysimulation(cfg);
    for k = 1:numel(data_conn2.trial)
      data_conn2.trial{k} = data_conn2.trial{k} + normr(pinknoise([3 200])).*10;
    end
    
    cfg.bpfreq = [8 12];
    cfg.mix    = eye(4); cfg.mix(4,:) = []; cfg.mix(2,4) = 1.4; cfg.mix(3,4) = 1.6; cfg.mix(2,2) = 0.6; cfg.mix(3,3) = 0.4;
    cfg.delay  = zeros(3,4); cfg.delay(2,4) = -3; cfg.delay(3,4) = 0;
    data_conn3 = ft_connectivitysimulation(cfg);
    data_conn4 = ft_connectivitysimulation(cfg);
    
    data_conn.trial = data_conn.trial + data_conn3.trial;
    data_conn2.trial = data_conn2.trial + data_conn4.trial;
    
    
    data = data_conn;
    
    
    % combine the connectivity data with a set of noisy time-series
    data2 = data_conn;
    for k = 1:numel(data2.trial)
      %data2.trial{k} = normr(randn(4,200)).*20;
      data2.trial{k} = normr(pinknoise([7 200])).*10;
    end
    
    % combine the connectivity data with a set of noisy time-series
    data2 = data_conn;
    for k = 1:numel(data2.trial)
      %data2.trial{k} = normr(randn(4,200)).*20;
      data2.trial{k} = normr(pinknoise([7 200])).*10;
    end
    data2.label = {'chan01';'chan03';'chan05';'chan07';'chan09';'chan11';'chan13'};
    data_conn.label  = {'chan02';'chan06';'chan10'};
    data_conn2.label = {'chan04';'chan08';'chan12'};
    data = ft_appenddata([],data_conn,data_conn2,data2);
    [srt,ix] = sort(data.label);
    data.label = srt;
    for k = 1:numel(data.trial)
      data.trial{k} = data.trial{k}(ix,:);
    end
    
    % make a sens array
    sens.chanpos = rand(numel(data.label),3);
    sens.elecpos = sens.chanpos;
    sens.label   = data.label;
    sens = ft_datatype_sens(sens);
    data.elec = sens;

  case 'ar_reverse'
    
    cfg = [];
    cfg.nsignal = 3;
    cfg.coupling = [0 0.40 0;0.15 0 0;0 0 0];
    cfg.ampl     = [0.1 0.1 0;0.1 0.2 0;0 0 0.2];
    cfg.delay    = [0 0.05 0;0.01 0 0;0 0 0];
    cfg.bpfreq(:,:,1) = [40 40 nan; 7  7 nan; nan nan 15];
    cfg.bpfreq(:,:,2) = [60 60 nan;15 15 nan; nan nan 25];
    cfg.method = 'ar_reverse';
    cfg.fsample = 1000;
    cfg.ntrials = 200;
    cfg.triallength = 1;
    data_conn  = ft_connectivitysimulation(cfg);
    %data_conn2 = ft_connectivitysimulation(cfg);
    
    cfg = [];
    cfg.nsignal = 6;
    cfg.coupling = zeros(6);
    cfg.ampl     = eye(6).*.1;%zeros(6);
    cfg.delay    = zeros(6);
    cfg.bpfreq(:,:,1) = eye(6).*7; %nan(6,6);
    cfg.bpfreq(:,:,2) = eye(6).*15; cfg.bpfreq(cfg.bpfreq==0)=nan;%nan(6,6);
    cfg.method = 'ar_reverse';
    cfg.fsample = 1000;
    cfg.ntrials = 200;
    cfg.triallength = 1;
    data2  = ft_connectivitysimulation(cfg);
    
    
%     % combine the connectivity data with a set of noisy time-series
%     data2 = data_conn;
%     for k = 1:numel(data2.trial)
%       %data2.trial{k} = normr(randn(4,200)).*20;
%       data2.trial{k} = normr(pinknoise([6 1000])).*60;
%     end
    data2.label = {'chan01';'chan02';'chan03';'chan07';'chan08';'chan09'};
    data_conn.label  = {'chan04';'chan05';'chan06'};
    data = ft_appenddata([],data_conn,data2);
    [srt,ix] = sort(data.label);
    data.label = srt;
    for k = 1:numel(data.trial)
      data.trial{k} = data.trial{k}(ix,:);
    end
    
    % make a sens array
    sens.chanpos = rand(numel(data.label),3);
    sens.elecpos = sens.chanpos;
    sens.label   = data.label;
    sens = ft_datatype_sens(sens);
    data.elec = sens;
   
end
