function [InvLambda,R2_lateral,R2_axial,R2_1d]=sws_estimation(vz,win,dx,dz,correc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local wavenumber estimator 
% Inputs:  vz - Complex matrix with magnitude and phase info from RSWField
%          window   - Size of the windows kernel.
%          dx - Resolution of the x-axis (lateral) of the signal
%          dz - Resolution of the z-axis (axial) of the signal
% Outputs: InvLambda - Spatial frequency or wavenumber (k) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m,n] = size(vz);
M = win(1); 
N = win(2); 
    
al_pos_z = round(M/2):m-round(M/2); % allow locations to use in axial direction
ev_index_z = 1:2:floor(length(al_pos_z)/2)*2; % even index vector 
ev_al_pos_z = al_pos_z(ev_index_z);  % even positions from allow locations in axial direction
search_area_z = -round(M/2)+1:round(M/2)-1; % search index from kernel:lateral
 
c_la = [sqrt(5); sqrt(5/sqrt(2*pi))];%[MAoW; AoW]
c_ax = [sqrt(10); sqrt(5)]; %[MAoW; AoW]
 
% Kaprox_maow_la = zeros(length(ev_al_pos_z));
% Kaprox_maow_ax = zeros(length(ev_al_pos_z));
% Kaprox_maow_1d = zeros(length(ev_al_pos_z));
% R2_lateral = zeros(length(ev_al_pos_z));
% R2_axial = zeros(length(ev_al_pos_z));
% R2_1d = zeros(length(ev_al_pos_z));
% Kcf_ax = zeros(length(ev_al_pos_z));
% Kcf_la = zeros(length(ev_al_pos_z));
% Klp = zeros(length(ev_al_pos_z));
% K1d = zeros(length(ev_al_pos_z));
% Kzci = zeros(length(ev_al_pos_z));
for k = 1:length(ev_al_pos_z)
%  2D cross-corralation of the reverberant particle velocity. 
%  Bvv (from papers) are extracted at different directions (angles)
    [vec_x,vec_y,vec_1d,Raxial,Rlateral,R1d,K_axial,K_lateral,K_laplace, K_1d, K_zci] = sws_estimation_localloop(vz(ev_al_pos_z(k)+search_area_z,:),dx,dz,N,n,M,correc);
    Kaprox_maow_la(k,:)=  vec_x*c_la(2); 
    Kaprox_maow_ax(k,:)=  vec_y*c_ax(2);
    Kaprox_maow_1d(k,:)=  0;      
    R2_lateral(k,:)=Rlateral;
    R2_axial(k,:)=Raxial;
    R2_1d(k,:)=R1d;
    Kcf_ax(k,:)=K_axial;
    Kcf_la(k,:)=K_lateral;
    Klp(k,:)=K_laplace;
    K1d(k,:)=K_1d;
    Kzci(k,:)=K_zci;

end 
 Kaprox_ave = (Kaprox_maow_la+Kaprox_maow_ax)/2;
 Kcf_ave=(Kcf_ax+Kcf_la)/2;

 InvLambda{1}=Kaprox_maow_ax;
 InvLambda{2}=Kaprox_maow_la;
 InvLambda{3}=Kaprox_ave;
 InvLambda{4}=Kcf_ax;
 InvLambda{5}=Kcf_la;
 InvLambda{6}=Kcf_ave;
 InvLambda{7}=Klp;
 InvLambda{8}=K1d;
 InvLambda{9}=Kaprox_maow_1d;
 InvLambda{10}=Kzci;

end