function [A,P,mat_comp] = amp_phs(u,ct,ct2)
% magnitude and phase extraction from temporal signals
%%%%

A = zeros(size(u,1),size(u,2)-1);
P = zeros(size(u,1),size(u,2)-1);
for ii=1:size(u,1)
    for jj=1:size(u,2)-1
        s1 = squeeze(u(ii,jj,:));
        F1= fftshift(fft(s1,ct2)); 
%         M = abs(F1);             % magnitude
        P(ii,jj) = angle(F1(ct));
        A(ii,jj) = abs(F1(ct));
    end
end
mat_comp = A.*exp(1i*P);
end 