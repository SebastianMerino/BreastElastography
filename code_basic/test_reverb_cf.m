function [R_squeare_real_axial,R_squeare_real_later,k_axial,k_lateral] = test_reverb_cf(M_filtered,res_x,res_y,mode,correc)
if mode==1
    %tic
    corre = xcorr2(M_filtered);
    %toc
end
if mode==2
    corre = autocorr2d(M_filtered);
end
corre = corre./correc;
% corre = corre./correc;
corre = corre./(abs(corre(round((size(corre,1)+1)/2),round((size(corre,2)+1)/2))));
y_v = (-floor(size(corre,1)/2):1:floor(size(corre,1)/2))*res_y;
x_v = (-floor(size(corre,2)/2):1:floor(size(corre,2)/2))*res_x;

R_cc_ax = real(corre(:,round((size(corre,2)+1)/2)));
I_cc_ax = imag(corre(:,round((size(corre,2)+1)/2)));
R_cc_la = real(corre(round((size(corre,1)+1)/2),:));
I_cc_la = imag(corre(round((size(corre,1)+1)/2),:));

track = 0.01;
location1 = (abs(y_v+track)==min(abs(y_v+track)));  
loc1(1) = find(location1==1);
location1 = (abs(y_v-track)==min(abs(y_v-track)));  
loc1(2) = find(location1==1);

y_v2 = y_v(loc1(1):loc1(2));
R_cc_1 = R_cc_ax(loc1(1):loc1(2));
I_cc_1 = I_cc_ax(loc1(1):loc1(2));
% [~, idz1] = min(abs(real(R_cc_1((length(R_cc_1)+1)*0.5:end))-0.9));
% [~, idz2] = min(abs(real(R_cc_1(0<y_v2 & y_v2<4e-3))-0.15));
% limit1z=y_v2((length(R_cc_1)+1)*0.5 + idz1-1);
% limit2z=y_v2((length(R_cc_1)+1)*0.5 + idz2-1);

location1 = (abs(x_v+track)==min(abs(x_v+track)));  
loc1(1) = find(location1==1);
location1 = (abs(x_v-track)==min(abs(x_v-track)));  
loc1(2) = find(location1==1);

x_v2 = x_v(loc1(1):loc1(2));
R_cc_2 = R_cc_la(loc1(1):loc1(2));
I_cc_2 = I_cc_la(loc1(1):loc1(2));

% [~, idx1] = min(abs(real(R_cc_2((length(R_cc_2)+1)*0.5:end))-0.9));
% [~, idx2] = min(abs(real(R_cc_2(0<x_v2 & x_v2<4e-3))-0.15));
% limit1x=x_v2((length(R_cc_2)+1)*0.5 + idx1-1);
% limit2x=x_v2((length(R_cc_2)+1)*0.5 + idx2-1);

[fitresult1, gof1] = createFit_atenuation_axial_RSWE(y_v2, R_cc_1',I_cc_1',-0.01,0.01);
[fitresult2, gof2] = createFit_atenuation_lateral_RSWE(x_v2, R_cc_2,I_cc_2,-0.01,0.01);

R_squeare_real_axial = gof1(1).rsquare;
R_squeare_real_later = gof2(1).rsquare;

k_axial = fitresult1.k;
k_lateral = fitresult2.k;
