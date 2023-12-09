clear, clc
addpath('./ElastographyFunctions/')

%% Acquiring RF data
p = 'C:\Users\sebas\Documents\MATLAB\Elastography\Vibroelastography\p08\toma2-80-90-100';
f = 'rfData_acq0';

[rf, header] = ReadEscanData(fullfile(p,f));
Bmode = db(hilbert(rf));

framesPerPlane = header(8);
numPlanes = header(9);
NUM_SWEEPS_PER_ACQ = header(10);

%% Plotting Bmode
figure,
for it = 1:numPlanes:size(rf,3)
    imagesc(Bmode(:,:,it), [30 90])
    colormap gray
    pause(1/10)
end

%% Acquiring time vector
f = 'timeStamp_acq0frame';
[timeVec, header] = ReadEscanData(fullfile(p,f));
figure, tiledlayout(2,1)
nexttile,
plot(squeeze(timeVec))
xlabel('Frame number')
ylabel('Time [ms]')
axis tight

nexttile,
offset = diff(squeeze(timeVec)); 
plot(offset)
xlabel('Frame number')
ylabel('\Deltat [ms]')
axis tight

% Observed parameters
PRI = 1E-3;
PRF = 1/PRI;
timePerPlane = 10e-3;
timePerSweep = 44.5e-3;

%% IQ demodulation
% Selecting block
% rfBlock = rf(:,:,25:48);
rfBlock = rf(:,:,697:720);

% Carrier
fe = 0.1; % Frequency of emission is approx
n = (1:size(rfBlock,1))'.*ones(size(rfBlock));
carrier = exp(-2j*pi*fe.*n);
rfDemod = rfBlock.*carrier;

% Downsampling
D = 5;
newSize = floor(size(rfBlock,1)/D);
IQ = zeros([newSize,size(rfBlock,[2,3])]);
[b,a] = butter(2,fe);
for it = 1:size(rfBlock,3)
    for ix = 1:size(rfBlock,2)
        filtLine = filtfilt(b,a,rfDemod(:,ix,it));
        IQ(:,ix,it) = filtLine(1:D:end);
    end
end

figure, tiledlayout(3,1)
nexttile,
spectrumRf = abs(fft(rfBlock));
meanSpectrumRf = fftshift(mean(mean(spectrumRf,2),3));
Nz = size(rfBlock,1);
f = (0:Nz-1)'/Nz - 0.5;
plot(f,meanSpectrumRf)

nexttile,
spectrumDemod = abs(fft(rfDemod));
meanSpectrumDemod = fftshift(mean(mean(spectrumDemod,2),3));
plot(f,meanSpectrumDemod)

nexttile,
spectrumIQ = abs(fft(IQ));
meanSpectrumIQ = fftshift(mean(mean(spectrumIQ,2),3));
Nz = size(IQ,1);
f = (0:Nz-1)'/Nz - 0.5;
plot(f,meanSpectrumIQ)

%% Plotting Bmode

% Properties from sonix acquisition
% Fs = 40e6;
% Fe = 6.66e6;
dz = 1.9444e-04;
dx = 3.0800e-04;

BmodeIQ = db(IQ);
BmodeIQ = BmodeIQ - max(BmodeIQ(:));
x = (1:size(IQ,2)) *dx;
z = (1:size(IQ,1)) *dz;
for it = 1:size(IQ,3)
    imagesc(x,z,BmodeIQ(:,:,it), [-60 0])
    colormap gray
    axis image
    pause(1/10)
end


%% Particle Velocity
dinf.dz = dz;
[pv,dinf] = pv_cal(IQ,dinf,1);

%% Plotting
for it = 1:size(pv,3)
    imagesc(x,z,pv(:,:,it), 2e-6*[-1 1])
    colormap parula
    axis image
    pause(1/2)
end

%% Particle velocity FT
[Nz,Nx,Nt] = size(pv);
figure, tiledlayout(2,1),
nexttile,
t = (1:Nt)*PRI;
pvPoint = squeeze(pv(floor(Nz/2),floor(Nx/2),:)); 
plot(t*1000,pvPoint)
xlabel('Time [ms]')

nexttile,
pvFT = fftshift(abs(fft(pvPoint)));
f = ((0:Nt-1)/Nt - 0.5)*PRF ;
plot(f,pvFT)
xlabel('Freq [Hz]')
%plot(pvFT)






