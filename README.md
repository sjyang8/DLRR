# DLRR
The code is for the work:  
[1] S.-J. Yang J.-H. Hou , Y.-H. Jia, S.-H. Mei, Q. Du. Superpixel Induced Discriminative Low rank Representation of Hyperspectral Images. Oct 2021, In: IEEE Transactions on Image 
Processing (TIP)  
1)  Get Started  
For DLRR,  you can call the "Call_DLRR_single_test_indian_data" function to run the algorithm for Indian_pines dataset\. You can also choose to call the "Call_DLRR_single_test_paviau_data" or "Call_DLRR_single_test_salinas_data" functions for other two datasets. After above procedure, you can see the on-screen instructions for showing the result, such as "the performance for this time: OA=\*,AA=\*,Kappa=\*"\.  

2). Details  

For DLRR,  the "Call_DLRR_single_test_indian_data" will automatically create a new folder for saving the detailed results,  i\.e\., "Indian_pines_results/Indian_pinesper_class0.05each_iter/"\. In such folder, for example, the result file "Indian_pines_train1_iters3_result_svm.mat" saves the results for 3rd learning iteration of 1th run\.  In the following, we also show the detailed description for the variables that stored in the result file\.  

Variable description:  
accuracy_SVM1 	-------- 	OA on original feature  
accuracy_SVM2  	-------- 	OA on denoising feature by DLRR  
Kappa_SVM1     	--------	Kappa on original feature  
Kappa_SVM2    	--------	Kappa on denoising feature by DLRR  
TPR_SVM1         	--------	Accuracy of each class on original feature  
TPR_SVM2  	--------    Accuracy of each class on denoising feature by DLRR  
Predict_SVM1	--------	The prediction on original feature  
Predict_SVM2	--------	The prediction on denoising feature by DLRR  
para		--------	The parameters  
ori_num_pixel	--------    The original number of superpixels    
num_superpixel 	--------	The updated number of superpixels by DLRR  
CTrain		--------	The number of samples on each class for training data  
CTest 		--------	The number of samples on each class for testing data  
loc_train		--------	The positions of training samples  
loc_test		--------	The positions of testing samples  

Dependancies:  
1)Entropy Rate Superpixel Segmentation  
2)MATLAB toolboxes on my PC that you may need:  
-----------Deep Learning Toolbox  
-----------Image Processing Toolbox  
-----------Mapping Toolbox  
-----------Optimization Toolbox  
-----------Statistics and Machine Learning Toolbox  
-----------Symbolic Math Toolbox  

Acknowledgement  
1) Thanks to the paper "SuperPCA: A Superpixelwise PCA Approach for Unsupervised Feature Extraction of Hyperspectral Imagery", we refer some codes of it that saved in the folder "common"\.  
2) Thanks to the paper "Simultaneous spatial and spectral low-rank representation of hyperspectral images for classification", we refer the classification codes of it that saved in the folder "classification_code"\.  

ATTN:  
- This package is free for academic usage. You can run it at your own risk\.  
  
- This package was developed by Ms. Shu-Jun Yang (yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk). For any problem concerning the code, please feel free to contact Ms. Yang\.  

------------------------------------------------------------------------------------------
