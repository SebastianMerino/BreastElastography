function [x, cost, error, fide, regul] = pdo_inv_tnv(y, H, W, A, lambda, tau, maxIter, tol, numberEstimators, stableIter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Primal DualSpliting Optimization Method for linear inverse problem A*x = y 
% Cost function to minimize: arg min || Ax - y ||_2^2 + TNV (x)
% This was programmed to solve linear problems for images, i.e 2D or even 2D multichannel images
% INPUTS
%	- y		: Observed data (vector form)
%   - H,W   : Image dimensions
%	- A		: Linear operator (Array form, matrix)
% 	- lambda: regularization parameter (try powers of 10 for linear inverse problem)
% 	- tau	: second hyperparameter for proximal operators, apply grid search i.e. 0.1 0.01, 0.001
%	- maxIter: maximum number of iterations, set 10000
% 	- tol	: tolerance error for cost function
%   -numberEstimators: Defines the # of channels of the ouput image (i.e 2 for TNV-SLD)
% 	-stableIter: If you plot cost functions, depending on the problem the cost function has atypical values for 50-100 iterations
%				this could cause the algorithm to stop regularization before time, set this 50-100

% OUTPUTS
% 	- x: output data, it returns as an array, could be a 2D multichannel image
% 	- cost: cost function vector according to # iterations
%   - error: We are minimizing the cost function so we analyze the first derivative to set where the cost function is minimized
%      when error are small, cost function has achieved is local minimum.
%   - fide: fidelization term vector according to # iterations
%   - regul : regularization vector according to # iterations


% AUTHOR: Edmundo Arom Miranda
% VERSION: pdo_inv_tnv v1.0 for Sebastian Merino 

% REFERENCE:
% Based on 
% Condat, L. (2013). A primal–dual splitting method for convex optimization involving 
% Lipschitzian, proximable and linear composite terms. Journal of optimization theory and applications, 158(2), 460-479.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%rho = 1.5;		% relaxation parameter, in [1,2]
    rho = 1.2;
	sigma = 1/tau/8; % proximal parameter
    %sigma = 1/tau;
    numEstim = numberEstimators;

    AtB = A'*y;
    AtA = A'*A;
    
    [~,n] = size(A);

    izq = speye(n) + tau*(AtA);
    %inv_izq = ( izq )^-1;

	% INITIALIZATION OPTIONS TO HELP THE REGULARIZATION
    % x_ini = (A'*A)\(A'*y);% QR solver TOO FCKN SLOW
    x_ini = cgs2(AtA, AtB,1e-6,20);    % CGS solver
    % x_ini = zeros([H, W, numEstim]); % zeros initialization
    
    % FAST IMPLEMENTATION FOR CC channels
    x2 = reshape(x_ini, [H,W,numEstim]); % 2 for SLD
    %x2(:,:,1) = Y( :,:,floor(C/2) ); % 1st estimator

    u2 = zeros([size(x2) 2]);

	ee = 1;	
    error(1) = NaN;
    iter = 1;
    fide(1) = 0.5*sum((A*x2(:) - y).^2);
    regul(1) = lambda*TVnuclear_EMZ(x2);
    cost(1) = fide(1) + regul(1);
   
    disp('Itn   |    Cost   |   Delta(Cost)');
    disp('----------------------------------');
    

    while (iter < maxIter)  
        % Data fidelity
        x = prox_tau_f_generic(x2-tau*opDadj(u2), tau, izq, AtB);
		
        % Reg
        u = prox_sigma_g_conj(u2+sigma*opD(2*x-x2), lambda);
        
		x2 = x2 + rho*(x-x2);
		u2 = u2 + rho*(u-u2);
       
        fide(iter+1) = 0.5*sum((A*x2(:) - y).^2);
        regul(iter+1) = lambda*TVnuclear_EMZ(x2); 
        cost(iter+1) = fide(iter+1) + regul(iter+1);

        ee = abs(cost(iter+1) - cost(iter));      
        % error(iter+1) = ee;               % NO NORMALIZED
        error(iter+1) = ee / cost(iter+1);  % NORMALIZED
        
        if mod(iter,5)==0 % to print every 5 iterations
            % primalcost = 0.5* norm(A*x(:) - y,2).^2 + lambda*TVnuclear_EMZ(x);         
            fprintf('%4d  | %f | %e\n',iter, cost(iter+1), error(iter+1));
        end
        if (iter > stableIter && error(iter+1)<tol) % en las primeras 100 iteraciones inestable 
            break;
        end

        iter = iter+1;
    end
    x = x2;
return

% Proximal operator F 
% Inputs:  
%   v           Multichanel image 
%   B,At        Matrices from the linear system
%   tau         Hyperparameter
%   izq         Matrix of the paper for speed
% Outputs:      
%   u_3d        Next iteration multichannel image
function [u_3d] = prox_tau_f_generic(v, tau, izq, AtB)
    [H,W,numEstim] = size(v);
    der = v(:)+tau*AtB;
    %u = ( inv_izq )* ( der );
    %u = cgs2(izq,der,1e-1,10);
    %[u,~] = gmres(izq,der,[],1e-6,10);
    [u,~] = pcg(izq,der,1e-3,10);
    u_3d = reshape(u, [H W numEstim]); % reshape as image
return

% Proximal operator Gconj 
% Inputs:  
%   v       Image of Jacobians
%   lambda  Hyperparameter
% Outputs:      
%   u       Next iteration of image of Jacobians
function [u] = prox_sigma_g_conj(v, lambda)
    u = v - prox_g(v,lambda);
return

% Jacobian operator 
% Input :   Multichanel image
% Output:   Image of Jacobians
function [u] = opD(v)
    [H,W,C]=size(v);
    % u = [Dx(v), Dy(v)]; for each channel 
    u = cat(4,[diff(v,1,1);zeros(1,W,C)],[diff(v,1,2) zeros(H,1,C)]);
return

% Adjoint Jacobian operator 
% Input :   Image of Jacobians
% Output:   Multichanel image
function [u] = opDadj(v)
    % u = Dy Dx
    u = -[v(1,:,:,1);diff(v(:,:,:,1),1,1)]-[v(:,1,:,2) diff(v(:,:,:,2),1,2)];	
return

% Total nuclear variation
% Input:    Multichannel image
% Output:   Number representing TNV
function [u] = TVnuclear_EMZ(v)
    % u = norm(eig(opD(v)),1); % oversimplification, better use GIVENS ROTATION 
    Jacobian = opD(v);
    u = NuclearNorm(Jacobian); %||J(u)||_nuclear    
return

% Mixed L1-Nuclear norm
% Input:    Image of Jacobians
% Output:   Sum of nuclear norms
function val = NuclearNorm(y)
	s = diff(sum(y.^2,3),1,4);
	theta = atan2(2*dot(y(:,:,:,1),y(:,:,:,2),3),-s)/2;
	c = cos(theta);
	s = sin(theta);
    
    val = sum( sum(sqrt( sum( ( y(:,:,:,1).*c + y(:,:,:,2).*s ).^2, 3) ), 2), 1 )+...
	      sum( sum(sqrt( sum( ( y(:,:,:,2).*c - y(:,:,:,1).*s ).^2, 3) ), 2), 1 );
return

% Proximal operator G
% Inputs:  
%   v       Image of Jacobians
%   lambda  Hyperparameter
% Outputs:      
%   u       Image of Jacobians
function x = prox_g(y, lambda)
    % GIVENS ROTATION (instead of SVD decomposition)
	s = diff( sum(y.^2,3), 1, 4 );
    
	theta = atan2( 2*dot(y(:,:,:,1), y(:,:,:,2),3), -s )/2;

	c = cos(theta);
	s = sin(theta);

    % S_matrix = [c -s; 
    %             s  c];
	x = cat( 4, y(:,:,:,1).*c + y(:,:,:,2).*s, ...
		       -y(:,:,:,1).*s + y(:,:,:,2).*c ); % x diagonalization 
    
	% PROXIMAL OPERATOR l2 ball
	tmp = max( sqrt(sum(x.^2,3)), lambda );

	tmp =  x .* ( (tmp-lambda)./tmp );

    % S_matrix_T = [c  s;
    %               -s c]
    %     xx = tmp*S_matrix_T 

	x = cat(4, tmp(:,:,:,1).*c - tmp(:,:,:,2).*s, ...
		       tmp(:,:,:,1).*s + tmp(:,:,:,2).*c );
return