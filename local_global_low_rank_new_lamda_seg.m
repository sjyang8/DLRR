function [L,E,Li,Ei,Xi,conv_iter,isfinite_flag,obj2] = local_global_low_rank_new_lamda_seg(X,sub_cluster_n,para,C)
% Solve the Superpixel-guided Discriminative Low-rank Representation of Hyperspectral Images for Classification
%% min_{L,E} \sum_{i=1}^{C} ||L_i||_{*}+\lambda ||E||_1-\beta||L||_*
%% s.t. X=L+E; X=[X1,X2,....XC]; L=[L1,L2,...LC]; E=[E1,E2,...EC]
% ---------------------------------------------
%% Input:
%	X=[X1,X2,....XC]	-	(d*N);
%	sub_cluster_n=[n1,n2,n3,...nC]; N=\sum_{i=1}^{C}n_i
% 	para				-	parameter
%			para.maxiter	-   maximum number of iterations
%			para.lambda		- 	parameter for sparse error term (l1 norm)
%			para.beta		-	parameter for negative nuclear norm
%			para.rho 		-	rho>=1, ratio used to increase tau
%			para.tau		- 	stepsize for dual variable updating in ADMM
%			para.maxtau		-	maximum stepsize
%			para.DEBUG		-	0 or 1
%
%% output:
%	L=[L1,L2,...LC];  - (d*N) matrix (d*N: dimension*num_samples)
%	E=[E1,E2,...EC];  - (d*N) matrix (d*N: dimension*num_samples)
%	Li				  -  cell for store the Li{ith}(stands for L_i)
%	Ei				  -  cell for store the Ei{ith}(stands for E_i)
%	Xi				  -  cell for store the Xi{ith}(stands for X_i)
% 	conv_iter		  -  the running iterations until the algorithm converges
%	isfinite_flag	  -  check whether exists abnormal num
%	obj2 			  -  the objective function value
%---------------------------------------------
%written by Shujun Yang (yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk)
%Related papers
%[1] Learning Transformations for Clustering and Classification
%---------------------------------------------

%% initialization
maxiter = para.maxiter;
lambda  = para.lambda;
beta    = para.beta;
rho     = para.rho;
maxtau  = para.maxtau;
DEBUG   = para.DEBUG;
tau     = 10^(-4);
tol     = 1e-6;
isfinite_flag=0;

Y1=zeros(size(X));
Y2=zeros(size(X));

L=[];E=[];J=[];
for ith=1:C
    ith
    Xi{ith}=X(:,(sum(sub_cluster_n(1:ith-1))+1:sum(sub_cluster_n(1:ith))));
    Li{ith}=zeros(size(Xi{ith}));
    Ji{ith}=zeros(size(Xi{ith}));
    Ei{ith}=zeros(size(Xi{ith}));
    Y1i{ith}=zeros(size(Xi));
    Y2i{ith}=zeros(size(Xi));
    L=[L Li{ith}];
    E=[E Ei{ith}];
    J=[J Ji{ith}];
end
[ sub_gra_nuclear_norm_X ] = subgradient_nuclear_norm(X);
obj=[];obj2=[];
current_iter=para.maxiter+1;

%% main loop

for iter=1:maxiter
    tic
    newL=[];newE=[];
    for ith=1:C
        Y1i{ith}=Y1(:,(sum(sub_cluster_n(1:ith-1))+1:sum(sub_cluster_n(1:ith))));
        Y2i{ith}=Y2(:,(sum(sub_cluster_n(1:ith-1))+1:sum(sub_cluster_n(1:ith))));
        
        % updata Li
        Z1{ith}=Xi{ith}-Ei{ith}+Y1i{ith}/tau;
        
        Z2{ith}=Ji{ith}+Y2i{ith}/tau;
        Znew=(Z1{ith}+Z2{ith})/2;
        Li{ith} = Do(1/(2*tau), Znew);
        % updata Ei
        Ei{ith}=So(lambda(ith)/tau,Xi{ith}-Li{ith}+Y1i{ith}/tau);
        
        newL=[newL Li{ith}];
        newE=[newE Ei{ith}];
    end
    L=newL;
    E=newE;
    %% update J
    [ sub_gra_nuclear_norm_J ] = subgradient_nuclear_norm(J);
    
    J=beta/tau*sub_gra_nuclear_norm_J-Y2/tau+L;
    for ith=1:C
        Ji{ith}=J(:,(sum(sub_cluster_n(1:ith-1))+1:sum(sub_cluster_n(1:ith))));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% - update the auxiliary lagrange Variables
    %% updata Y
    Y1=Y1+tau*(X-L-E);
    Y2=Y2+tau*(J-L);
    
    %% updata tau
    tau=min(rho*tau,maxtau);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dX=X-L-E;
    dX2=L-J;
    err=norm(dX,'fro');
    err2=norm(dX2,'fro');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if DEBUG
        [tmp_index]=find(isfinite(L)==0);
        [d1,d2]=size(tmp_index);
        if d1==0||d2==0
            obj(iter)= -beta*norm_nuclear(J);
        else
            current_iter=iter;
            isfinite_flag=1;
            warning='find nan and inf in L'
            obj(iter)=0;
            break;
        end
        for ith=1:C
            obj(iter)=obj(iter)+norm_nuclear(Li{ith})+lambda(ith)*norm(Ei{ith}',1);
        end
        obj2(iter)=obj(iter)+tau/2*(norm(X-L-E+Y1/tau,2))^2+tau/2*(norm(J-L+Y2/tau,2))^2;
        if (iter == 1) || (mod(iter, 10) == 0) || ((err < tol) && (err2<tol))
            fprintf(1, 'iter: %d \t err: %f \t  err2: %f \t rank(L): %f \t max(E): %f \t obj: %f \n', ...
                iter,err,err2,rank(L),max(E(:)),obj2(iter));
        end
    else
        if (iter == 1) || (mod(iter, 10) == 0) || ((err < tol) && (err2<tol))
            fprintf(1, 'iter: %d \t err: %f \t  err2: %f \t rank(L): %f \t max(E): %f \n', ...
                iter,err,err2,rank(L),max(E(:)));
        end
    end
    if (iter >10 && max(max(abs(dX)))<tol ) && (max(max(abs(dX2)))<tol )
        current_iter=iter;
        break;
    end
    toc
end
if current_iter<para.maxiter
    conv_iter=current_iter;
else
    conv_iter=para.maxiter;
end
toc
end

function r = So(tau, X)
% shrinkage operator
r = sign(X) .* max(abs(X) - tau, 0);
end

function r = Do(tau, X)
% shrinkage operator for singular values
[U, S, V] = svd(X, 'econ');
r = U*So(tau, S)*V';
end
