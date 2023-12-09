function A=autocorr2d(I)
% Compute the 2D spatial autocorrelation of a matrix or image I using the 
% Wiener - Khintchine Theorem. The output is the normalized correlation
% coefficient -1 < C < 1.
%
% The center pixel of A will have C = 1. Using images with odd dimensions 
% will give results that are easier to interpret.
%
% ref: http://mathworld.wolfram.com/Wiener-KhinchinTheorem.html
%
I=double(I); %convert to double
I=I-mean(I(:)); %subtract mean
I=I/sqrt(sum(I(:).^2)); %normalize magnitude

fft_I=fft2(I,size(I,1)*2-1,size(I,2)*2-1); %compute fft2

A=fftshift(ifft2(fft_I.*conj(fft_I))); %compute autocorrelation

% figure;
% subplot(1,2,1)
% imagesc(I)
% axis equal tight
% box on
% xlabel('Z')
% xticks([0 50 100 150 200 250 300 350 400 450 500])
% xticklabels(-2.5:0.5:2.5);
% ylabel('X')
% yticks([0 50 100 150 200 250 300 350 400 450 500])
% yticklabels(-2.5:0.5:2.5);
% title('Particles Velocity (m/s)')
% colorbar
% 
% subplot(1,2,2)
% d_max=size(I,1)/2 +1;
% imagesc(-size(I,2)/2:size(I,2)/2-1,-size(I,1)/2:size(I,1)/2-1,A,[-1,1])
% axis equal tight
% box on
% xlabel('Z')
% xticks([-250 -200 -150 -100 -50 0 50 100 150 200 250])
% xticklabels(-2.5:0.5:2.5);
% ylabel('X')
% yticks([-250 -200 -150 -100 -50 0 50 100 150 200 250])
% yticklabels(-2.5:0.5:2.5);
% title('Normalized Spatial Autocorrelation')
% colorbar
end
