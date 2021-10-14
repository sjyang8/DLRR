function [accracy_SVM2,TPR_SVM2,Kappa_SVM2] = demo_DLRR_single_test(img_name,num_Pixel,seg_ratio_thresh_hold,max_segs,ith_iter,lambda_uni,beta,max_iters,per_ratio,Use_sample_train)
% main funtion for the 2-step algorithm framework: 
% (1) Classification-guided superpixel segmentation and (2) Discriminative low-rank representation
%written by Shujun Yang (yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk)
%% prepare for addpath
addpath(genpath('.\classification_code\'));
addpath('./common/');
addpath(genpath(cd));
addpath('./Entropy Rate Superpixel Segmentation/');

%% data identification

%% read file
R=importdata([img_name '_corrected.mat']);
gt=importdata([img_name '_gt.mat']);
[m,n,d]=size(R);
indexes_v=[1:m*n];
gt_v=reshape(gt,[m*n 1]);
zeros_index=find(gt_v==0);
gt_v(zeros_index)=[];
indexes_v(zeros_index)=[];
GroundT(1:length(indexes_v),1)=indexes_v;
GroundT(1:length(indexes_v),2)=gt_v;

C=max(gt(:));
%% initialize the train number for each class; and generate the train and test indexes
C_total=[];
for class=1:C
    no_class(class)=length(find(gt==class));
    C_total=[C_total  no_class(class)];
end
CTrain=ceil(C_total*per_ratio);
if Use_sample_train~=1
	[loc_train, loc_test, CTest] = Generating_training_testing(gt,CTrain);
else
	[loc_train, loc_test, CTest] = load_sample_train(img_name,per_ratio);
end

%% step1-- over segmentation based on ERS
data3D=R;
ori_num_Pixel=num_Pixel;
%% max normalize before segment
data3D = data3D./max(data3D(:));

%% super-pixels segmentation
labels = cubseg(data3D,num_Pixel);
labels=labels+1;

%% the 0-th iteration: Classification-guided superpixel segmentation using original feature

[accracy_SVM1,TPR_SVM1,Kappa_SVM1,accracy_SVM2,TPR_SVM2,Kappa_SVM2,Predict_SVM1,Predict_SVM2] = my_Classification_V2_single_iter(R,R,CTrain,CTest,loc_train,loc_test);
[ensemble_predictions_map] = combine_predict_newmap(R,GroundT,gt,loc_test,Predict_SVM1);
[final_need_revise_segs_pred{floor(seg_ratio_thresh_hold*10)},predict_seg_max_ratio,predict_seg_class_dis_ratio_vector]=combine_seg_and_predict(labels,ensemble_predictions_map,C,seg_ratio_thresh_hold);
% recut noisy superpixels into more sub-superpixels and generate new superpixel map
if length(final_need_revise_segs_pred{floor(seg_ratio_thresh_hold*10)})>0
    [labels_updated,current_num_pixels,cores_seg_id]=recut_segments(data3D,final_need_revise_segs_pred{floor(seg_ratio_thresh_hold*10)},labels,gt,max_segs);
else
    labels_updated=labels;
    current_num_pixels=num_Pixel;
end

pixel_id_v=unique(labels_updated);
updated_num_pixels=0;
for id=1:length(pixel_id_v)
    pos=find(labels_updated==pixel_id_v(id));
    updated_num_pixels=updated_num_pixels+1;
    labels_updated(pos)=updated_num_pixels;
end
num_Pixel=updated_num_pixels;

lambda=[ ones(num_Pixel,1)*lambda_uni];


%% cut into multiple sub images according to segment labels
[sub_I,size_subimage,position_2D]=Partition_into_subimages_superpixel(R,labels_updated);
%% parepare for data matrix
X=[];
for cur=1:num_Pixel
    X=[X;sub_I{cur}];
    sub_cluster_n(cur)=size(sub_I{cur},1);
end


%% save path setting
save_path=[img_name '_results/' img_name 'per_class' num2str(per_ratio) 'each_iter' '/'  ];
if ~exist(save_path,'dir')
    mkdir(save_path);
end

%% main loop 
for iter=2:(max_iters+1)%% 1~T_max iterations in paper
    %% step1--Discriminative low-rank representation
    %% generate the clean part for image
    %% parameter setting
    maxiter=10^4;
    rho=1.1;
    maxtau = 10^12;
    para.maxiter=maxiter;
    para.lambda=lambda;%  sparse error term coffecient
    para.beta=beta; %
    para.rho=rho;
    para.maxtau=maxtau;
	para.DEBUG=0;
    S=[];E=[];
    [S,E,L,Err,X_i,conv_iter,isfinite_flag,obj] = DLRR(X',sub_cluster_n,para,num_Pixel);
    
    %% remap the low rank S to the original postition, then we get the low ranked 2D data map S_spe_m for the original data
    
    S_trans=S';
    S_spe_m=zeros(size(S_trans));
    for cur=1:num_Pixel
        S_spe_m(position_2D{cur},:)=S_trans((sum(sub_cluster_n(1:cur-1))+1:sum(sub_cluster_n(1:cur))),:);
    end
    S_spe_m=reshape(S_spe_m,[m n d]);
    
    %% we run SVM for per_ratio data
    
    [accracy_SVM1,TPR_SVM1,Kappa_SVM1,accracy_SVM2,TPR_SVM2,Kappa_SVM2,Predict_SVM1,Predict_SVM2] = my_Classification_V2_single_iter(R,S_spe_m,CTrain,CTest,loc_train,loc_test);
    if para.DEBUG==0
		save([save_path img_name 'train' num2str(ith_iter) 'iters' num2str(iter-1) '_result_svm.mat'],...
			'CTrain','CTest','loc_train','loc_test', 'para','ori_num_Pixel','num_Pixel', 'accracy_SVM1','TPR_SVM1','Kappa_SVM1','accracy_SVM2','TPR_SVM2','Kappa_SVM2','Predict_SVM1','Predict_SVM2');
    else
		save([save_path img_name 'train' num2str(ith_iter) 'iters' num2str(iter-1) '_result_svm.mat'],...
			'CTrain','CTest','loc_train','loc_test', 'para','ori_num_Pixel','num_Pixel', 'accracy_SVM1','TPR_SVM1','Kappa_SVM1','accracy_SVM2','TPR_SVM2','Kappa_SVM2','Predict_SVM1','Predict_SVM2','obj');
	end
    %% step2-- Classification-guided superpixel segmentation 
    %% max normalize before segment
    data3D_new = S_spe_m./max(S_spe_m(:));
    
    %% super-pixels segmentation
    labels = cubseg(data3D_new,num_Pixel);
    labels=labels+1;
    
    % %% classification map
    [ensemble_predictions_map] = combine_predict_newmap(R,GroundT,gt,loc_test,Predict_SVM2);
    
    [final_need_revise_segs_pred{floor(seg_ratio_thresh_hold*10)},predict_seg_max_ratio,predict_seg_class_dis_ratio_vector]=combine_seg_and_predict(labels,ensemble_predictions_map,C,seg_ratio_thresh_hold);
    if length(final_need_revise_segs_pred{floor(seg_ratio_thresh_hold*10)})
        [labels_updated,current_num_pixels,cores_seg_id]=recut_segments(data3D_new,final_need_revise_segs_pred{floor(seg_ratio_thresh_hold*10)},labels,gt,max_segs);
    else
        labels_updated=  labels;
        current_num_pixels=num_Pixel;
    end
    
    pixel_id_v=unique(labels_updated);
    updated_num_pixels=0;
    for id=1:length(pixel_id_v)
        pos=find(labels_updated==pixel_id_v(id));
        updated_num_pixels=updated_num_pixels+1;
        labels_updated(pos)=updated_num_pixels;
    end
    num_Pixel=updated_num_pixels;
    %% cut into multiple sub images according to segment labels
    [sub_I,size_subimage,position_2D]=Partition_into_subimages_superpixel(R,labels_updated);
    %% parepare for data matrix
    X=[];
    for cur=1:num_Pixel
        X=[X;sub_I{cur}];
        sub_cluster_n(cur)=size(sub_I{cur},1);
    end
    lambda=[ ones(num_Pixel,1)*lambda_uni];
    
    
end
end




