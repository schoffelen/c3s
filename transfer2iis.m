function transfer2iis(H, freq, labelcmb)

if nargin<3
  labelcmb = [];
end

% do a check on the input data
siz = size(H);
if numel(siz)==3 && siz(1)==siz(2)
  % assume chan_chan_freq
  isfull = true;
elseif numel(siz)==2
  % assume chancmb_freq
  isfull = false;
  assert(~isempty(labelcmb), 'input data appears to be chancmb_freq, but labelcmb is missing');
else
  error('dimensionality of input data is not supported');
end

dfreq = round(diff(freq)*1e5)./1e5; % allow for some numeric issues
if ~all(dfreq==dfreq(1))
  error('FieldTrip:transfer2iis', 'frequency axis is not evenly spaced');
end

if freq(1)~=0
  ft_warning('FieldTrip:transfer2iis', 'when converting the transfer function to coefficients, the frequency axis should ideally start at 0, zero padding the spectral density'); 
  dfreq = mean(dfreq);
  npad  = freq(1)./dfreq;
  
  % update the freq axis and keep track of the frequency bins that are
  % expected in the output
  selfreq  = (1:numel(freq)) + npad;
  freq     = [(0:(npad-1))./dfreq freq];
  if isfull
    H = cat(3, zeros(siz(1),siz(2),npad), H);
  else
    H = cat(2, zeros(siz(1),npad), H);
  end
else
  selfreq  = 1:numel(freq);
end

% deal with the two different types of input
if isfull
  % check whether the last frequency bin is strictly real-valued.
  % if that's the case, then it is assumed to be the Nyquist frequency
  % and the two-sided spectral density will have an even number of
  % frequency bins. if not, in order to preserve hermitian symmetry,
  % the number of frequency bins needs to be odd.
  Hend = H(:,:,end);
  N    = numel(freq);
  m    = size(H,1);
  if all(imag(Hend(:))<abs(trace(Hend)./size(Hend,1)*1e-9))
    N2 = 2*(N-1);
  else
    N2 = 2*(N-1)+1;
  end

  % preallocate memory for efficiency
  Harr   = zeros(m,m,N2) + 1i.*zeros(m,m,N2);

  % the input cross-spectral density is assumed to be weighted with a
  % factor of 2 in all non-DC and Nyquist bins, therefore weight the
  % DC-bin with a factor of sqrt(2) to get a correct two-sided representation
  Harr(:,:,1) = H(:,:,1).*sqrt(2);
  for k = 2:N
    Harr(:,:,       k) = H(:,:,k);
    Harr(:,:,(N2+2)-k) = conj(H(:,:,k));
  end
  
  % the input cross-spectral density is assumed to be weighted with a
  % factor of 2 in all non-DC and Nyquist bins, therefore weight the
  % Nyquist bin with a factor of sqrt(2) to get a correct two-sided representation
  if mod(size(Harr,3),2)==0
    Harr(:,:,N) = Harr(:,:,N).*sqrt(2);
  end
  
  % invert the transfer matrix to get the fourier representation of the
  % coefficients, and add an identity matrix 
  I = eye(siz(1));
  for k = 1:size(Harr,3)
    Harr(:,:,k) = I-inv(Harr(:,:,k));
  end
  
  % take the inverse fft to get the coefficients
  A = ifft(reshape(permute(Harr, [3 1 2]), N2, []), 'symmetric');
  
  
  
else
end
