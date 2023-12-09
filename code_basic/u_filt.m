function [fu1,Wave_z,Frames1] = u_filt(u_new,f,f_band,dinf,cs_min,cs_max)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% temporal filtering process of particle velocity signals: a median filter
% to reduce noise and peppper noise and the a bandpass Hamming FIR filter are applied
% Inputs:  f       - vibration freqeuncy
%          f_band  - the frequency range for the bandpass cuttoffs are +-
%                    2*f_band
%          u_new   - particle velocity data with 10 periods
% Outputs: fu      - filtered particle velocity signal
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fs = dinf.PRFe;                         % Sampling frequency
%$  A 50th-order FIR bandpass filter with bandpass [fv-10 dv+10]/Fs cutoffs. 
ord = 200;
b = fir1(ord,[2*(f-f_band)/Fs 2*(f+f_band)/Fs],tukeywin(ord+1,1)); 
fu = zeros(size(u_new));
for ii=1:size(fu,1)
    for jj=1:size(fu,2)
        s1 = squeeze(u_new(ii,jj,:));
        fu(ii,jj,:) = filter(b,1,s1);
    end
end

%%

Fs = dinf.PRFe;                        % Sampling frequency
L = 1e4;                               % Length of signal
df= Fs/L;                              % frequency resolution
f1= (-round(L/2):1:round(L/2)-1)*df;   % frequency axis
[ ~, ix ] = min( abs( f1-f ));  % find index for closest frequency to the vibration frequency
peak = ix;
[Frames0,~] = spatial_fil_phase_extrac(fu,peak,L);

%%
sigma = 300; 
Fs1 = 1/dinf.dz;                            % Sampling spatial frequency
Fs2 = 1/dinf.dx;

% Vw1 = squeeze(fu(:,:,5));
% Spatial frequencies cutoffs estimation base on  the relationship  k=2pi/c 
[k1,k2] = freqspace(size(Frames0),'meshgrid');
k1 = k1*(2*pi*Fs1);
k2 = k2*(2*pi*Fs2);

Hd = ones(size(Frames0)); 
r = sqrt(k1.^2 + k2.^2);
kl = (2*pi*f/cs_max); kh = (2*pi*f/cs_min);

Hd((r<kl)|(r>kh)) = 0;
win = fspecial('gaussian',size(Frames0),sigma); 
win = win ./ max(win(:));  % Make the maximum window value be 1.
h = fwind2(Hd,win);        % Using the 2-D window, design the filter that best produces the desired frequency response
% mask2 = abs(real(fftshift(fft2(ifftshift(h)))));

 
% mask filtering in spatial frequency domain 
% for ii=1:size(fu,3)
%     un1 = fu(:,:,ii);
%     un1 = medfilt2(abs(Frames0),[11 7]);
    Wave_z = filter2(h,Frames0);
% end

omega = 2*pi*f;
resT = 1/Fs; % 
Tmax = 60*1e-3; % 
t = 0:resT:Tmax;
fu1 = zeros([size(Wave_z),length(t)]);
for kk = 1:length(t)
    fu1(:,:,kk) = abs(Wave_z).*cos(angle(Wave_z)+omega*t(kk));
end

Frames1 = exp(1i*angle(Wave_z));
end