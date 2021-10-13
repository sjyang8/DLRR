function [final_need_revise_segs,predict_seg_max_ratio,predict_seg_class_dis_ratio_vector]=combine_seg_and_predict(seg_map,predict,C,max_ratio_thresh)
%% search the noisy superpixel segments
%---------------------------------------------
%written by Shujun Yang (yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk)
%---------------------------------------------
max_superpixel_num=max(unique(seg_map));
for cnt=1:max_superpixel_num
    pos{cnt}=find(seg_map==cnt);
    predict_seg{cnt}=predict(pos{cnt});
    [predict_seg_max_ratio(cnt),predict_seg_class_dis_ratio_vector{cnt}]=compute_max_ratio(predict_seg{cnt},C);
end
%% find the segments which max ratio is less than max_ratio_thresh
less_than_thresh_cnt1=find(predict_seg_max_ratio(:)>0);
less_than_thresh_cnt2=find(predict_seg_max_ratio(less_than_thresh_cnt1)<max_ratio_thresh);
final_need_revise_segs=less_than_thresh_cnt1(less_than_thresh_cnt2);
end
function [max_ratio,class_ratio_vector]=compute_max_ratio(labels_v,C)

for class_id=1:C
    class_cnt(class_id)=length(find(labels_v==class_id));
end
sum_class_cnt=sum(class_cnt(:));
if sum_class_cnt>0
    for class_id=1:C
        class_ratio_vector(1,class_id)=class_cnt(class_id)./sum_class_cnt;
    end
    max_ratio=max(class_ratio_vector(:));
else
    class_ratio_vector=zeros(1,C);
    max_ratio=0;
end

end