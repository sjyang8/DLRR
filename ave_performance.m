function [] = ave_performance()
per_ratio=[0.05];
num_Pixel=64;
img_name='Indian_pines';
max_segs=5; %parameter for M
seg_ratio_thresh_hold=[0.7];% parameter of \delta
% per_ratio=[0.005];
% num_Pixel=50;
% img_name='Salinas';
% max_segs=3; %parameter for M
% seg_ratio_thresh_hold=[0.2];% parameter of \delta
 random_times=2;
beta=[1 ];
lambda_uni=0.05;
% lambda_uni=0.01;
max_iters=3;
save_path=[img_name '_results_' num2str(num_Pixel) 'lambda' num2str(lambda_uni) 'beta' num2str(beta) '/' img_name 'per_class' num2str(per_ratio) 'delta' num2str(seg_ratio_thresh_hold*10) 'M' num2str(max_segs) 'each_iter' '/'  ];

if exist(save_path,'dir')
	OAs=[];
	AAs=[];
	Kappas=[];
	for ith_iter=1:random_times
		load([save_path img_name 'delta' num2str(seg_ratio_thresh_hold) 'M' num2str(max_segs) 'lambda' num2str(lambda_uni) 'beta' num2str(beta) 'per_C' num2str(per_ratio) 'train' num2str(ith_iter) 'iters' num2str(max_iters) '_result_svm.mat']);
		OAs=[OAs accracy_SVM2];
		AAs=[AAs mean(TPR_SVM2)];
		Kappas=[Kappas Kappa_SVM2];
	end
	[ave_OA,std_OA]=mean_stds(OAs);
	[ave_AA,std_AA]=mean_stds(AAs);
	[ave_Kappa,std_Kappa]=mean_stds(Kappas);
end

end
function [mean_value,std_value]=mean_stds(vectors)
mean_value=mean(vectors);
std_value =std(vectors)
end

