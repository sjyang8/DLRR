function [ensemble_predictions_map] = combine_predict_newmap(img,GroundT,DataClass,loc_test,predict)
% the funtion for combine the predict to generate new label map
%---------------------------------------------
%written by Shujun Yang (yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk)
%---------------------------------------------
[m,n]=size(DataClass);
[no_lines, no_rows, no_bands] = size(img);
GroundT=GroundT';

test_indexes=[];
for i2=1:length(loc_test)
    test_indexid=find(GroundT(1,:)==loc_test(i2));
    test_indexes=[test_indexes test_indexid];
end

test_SL = GroundT(:,test_indexes);
test_SL(2,:)=predict;

gnd=reshape(DataClass,[m*n 1]);
ensemble_predictions_map=gnd;
ensemble_predictions_map(test_SL(1,:))=predict;
ensemble_predictions_map=reshape(ensemble_predictions_map,[no_lines  no_rows]);
end

