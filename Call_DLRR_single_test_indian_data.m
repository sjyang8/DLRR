function [] = Call_DLRR_single_test_indian_data()
%the main call funtion for running the whole algorithm
%written by Shujun Yang (yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk)

%% parameter setting
per_ratio=[0.05];
num_Pixel=64;
img_name='Indian_pines';    % data set name
max_segs=5; 			    % parameter for M
seg_ratio_thresh_hold=[0.7];% parameter of \delta
beta=1;lambda_uni=0.05;     % parameter for \beta and \lambda
max_iters=3;
random_times=10;

Use_sample_train=1;         %% if Use_sample_train=0; then run 10 times randomly;
                            %% when Use_sample_train=1; run 1 time that using the sample train index

%% Main loop
if Use_sample_train~=1
    for ith_iter=1:random_times %% run random_times (default=10) times randomly
        % single test
        [OA(ith_iter),CA(ith_iter,:),Kappa(ith_iter)]=demo_DLRR_single_test(img_name,num_Pixel,seg_ratio_thresh_hold,max_segs,ith_iter,lambda_uni,beta,max_iters,per_ratio,Use_sample_train);
    end
else 							%% when Use_sample_train=1; run 1 time that using the sample train index
    ith_iter=1;
    [OA(ith_iter),CA(ith_iter,:),Kappa(ith_iter)]=demo_DLRR_single_test(img_name,num_Pixel,seg_ratio_thresh_hold,max_segs,ith_iter,lambda_uni,beta,max_iters,per_ratio,Use_sample_train);
end
[mean_OA,std_OA]		=	mean_stds(OA);
[mean_AA,std_AA]		=	mean_stds(mean(CA,2));
[mean_Kappa,std_Kappa]	=	mean_stds(Kappa);
if (Use_sample_train~=1&&random_times>1)
    disp(['average performance for ' num2str(random_times) ' times: OA(mean/std)=' num2str(mean_OA) '/' num2str(std_OA) ',AA(mean/std)=' num2str(mean_AA) '/' num2str(std_AA) ...
        ',Kappa(mean/std)=' num2str(mean_Kappa) '/' num2str(std_Kappa)]);
else
    disp(['the performance for this time:' ' OA=' num2str(OA(1)) ',AA=' num2str(mean(CA,2)) ',Kappa=' num2str(Kappa(1))]);
end
end
function [mean_value,std_value]=mean_stds(vectors)
mean_value=mean(vectors);
std_value =std(vectors);
end



