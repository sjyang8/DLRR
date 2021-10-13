function [ sub_gra_nuclear_norm_A ] = subgradient_nuclear_norm( A )
%  the function to compute the subgradient of ||A||_*
%% Input:
%	A	-	the matrix A
%% Output:
%	sub_gra_nuclear_norm_A	- the subgradient of ||A||_*
%---------------------------------------------
% reference code:
% related paper: Learning Transformations for Clustering and Classification
% refer to the code of the above paper 
% \bf{Reorganizing} by Shujun Yang(yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk)
%---------------------------------------------

eigThd = 0.005;
Obj_sub1 = NaN(1,1);
Grd_sub1 = NaN(size(A));
[m, n]=size(A);
[U, Sigma, V] = svd((A), 'econ');
Obj_sub1(1) = sum(diag(Sigma));
F_rank=min([m,n]);
r = sum(diag(Sigma)<=eigThd);
if r==0
    r=r+1;
end
if F_rank-r==0
    r=r-1;
end
RndMat = orth(rand(r, r))*diag(rand(r, 1))*orth(rand(r, r))';
U1 = U(:, 1:end-r);
V1 = V(:, 1:end-r);
U2 = U(:, end-r+1:end);
V2 = V(:, end-r+1:end);
W = U2*RndMat*V2';
UU=U1*V1';
Grd_sub1 = (UU + W);
sub_gra_nuclear_norm_A=Grd_sub1;
end

