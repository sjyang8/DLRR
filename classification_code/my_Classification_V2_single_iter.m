function [accracy_SVM1,TPR_SVM1,Kappa_SVM1,accracy_SVM2,TPR_SVM2,Kappa_SVM2,Predict_SVM1,Predict_SVM2] = my_Classification_V2_single_iter(org_data,re_data,CTrain,CTest,loc_train,loc_test)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% function: compare the classification performance on org_data and re_data using SVM and SVM_CK classifier
%% Input:
    %% org_data: original hyperspectral image
    %% re_data: processed hyperspectral image
	%% CTrain: the number of training samples for each class
	%% CTest: the number of testing samples per class
	%% loc_train: locations for training samples
	%% loc_test: locations for testing samples
%% Output:
    %% accracy_SVM1:  Overall accuracy by SVM classifier on org_data;
    %% accracy_SVM2:  Overall accuracy by SVM classifier on re_data;
    %% TPR_SVM1:   Accuracy on each class by SVM classifier on org_data;
    %% TPR_SVM2:   Accuracy on each class by SVM classifier on re_data;
    %% Kappa_SVM1: Kappa coefficient by SVM classifier on org_data;
    %% Kappa_SVM2: Kappa coefficient by SVM classifier on re_data;
    %% Predict_SVM1: Prediction by SVM classifier on org_data;
    %% Predict_SVM2: Prediction by SVM classifier on re_data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m n d] = size(org_data);
Data_R1 = reshape(org_data,m*n,d);
Data_R2 = reshape(re_data,m*n,d);

accracy_SVM1 = [];
accracy_SVM2 = [];

Kappa_SVM1 = [];
Kappa_SVM2 = [];
%% 
Predict_SVM1=[];
Predict_SVM2=[];
%%

TPR_SVM1 = [];
TPR_SVM2 = [];

%% SVM
[accur11, Kappa11,TPR11,Predict11] = Excute_SVM2(Data_R1, loc_train, CTrain, loc_test, CTest);
accracy_SVM1 = [accracy_SVM1 accur11];
TPR_SVM1 = [TPR_SVM1;TPR11];
Kappa_SVM1 = [Kappa_SVM1 Kappa11];
Predict_SVM1= [Predict_SVM1 Predict11];

[accur12, Kappa12,TPR12,Predict12] = Excute_SVM2(Data_R2, loc_train, CTrain, loc_test, CTest);
accracy_SVM2 = [accracy_SVM2 accur12];
TPR_SVM2 = [TPR_SVM2;TPR12];
Kappa_SVM2 = [Kappa_SVM2 Kappa12];
Predict_SVM2= [Predict_SVM2 Predict12];


%