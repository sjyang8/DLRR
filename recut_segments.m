function [labels_updated,current_num_pixels,cores_seg_id]=recut_segments(data3D,final_need_revise_segs_preds,labels,gt,max_segs)
% recut the noisy superpixels into more subsegments; generate new superpixel map
%---------------------------------------------
%written by Shujun Yang (yangsj3@sustech.edu.cn; sjyang8-c@my.cityu.edu.hk)
%---------------------------------------------
max_num_pixels=max(unique(labels));
labels_updated=labels;
[m n]=size(labels); current_num_pixels=max_num_pixels;
for id=1:length(final_need_revise_segs_preds)
    cnt=final_need_revise_segs_preds(id);
    pos=find(labels==cnt);
    [min_x,max_x,min_y,max_y,pos_xy]=min_max_position(pos,m,n);
    data_seg_new{id}=data3D(min_x:max_x,min_y:max_y,:);
    [m1,n1,d1]=size(data_seg_new{id});
    gt_sub_matrix{id}=gt(min_x:max_x,min_y:max_y);
    %% detect background pixels
    back_pixel_pos=find(gt_sub_matrix{id}==0);
    data2D=reshape(data_seg_new{id},[m1*n1 d1]);
    data2D(back_pixel_pos,:)=0;
    data_seg_new{id}=reshape(data2D,[m1 n1 d1]);
    
    labels_new{id}=new_region(data_seg_new{id},max_segs);%%
    cores_seg_id{id}=cnt;
    [labels_sub,label_sub_x,label_sub_y]= extract_superpixel_label(labels_new{id},pos_xy,min_x,max_x,min_y,max_y);
    increase_num_pixels=max(unique(labels_sub))-1;
    [labels_sub_new]=increase_seg_cnt_id(labels_sub,cnt,increase_num_pixels,current_num_pixels);
    current_num_pixels=current_num_pixels+increase_num_pixels;
    labels_ori=labels(min_x:max_x,min_y:max_y);
    pos_seg=find(labels_ori==cnt);
    labels_ori(pos_seg)=labels_sub_new(pos_seg);
    labels_updated(min_x:max_x,min_y:max_y)=labels_ori;
end

end
function [min_x,max_x,min_y,max_y,pos_xy]=min_max_position(pos_v,row,column)
min_x=+Inf;
max_x=-Inf;
min_y=+Inf;
max_y=-Inf;
for id=1:length(pos_v)
    pos=pos_v(id);
    x=mod(pos,row);
    if x==0
        x=row;
    end
    y=(pos-x)/row+1;
    
    
    pos_xy(id,1)=x;
    pos_xy(id,2)=y;
    if x<min_x
        min_x=x;
    end
    if x>max_x
        max_x=x;
    end
    if y<min_y
        min_y=y;
    end
    if y>max_y
        max_y=y;
    end
end

end
function [labels_new]= new_region(data_seg,max_segs)
labels_new = cubseg(data_seg,max_segs);
labels_new=labels_new+1;
end
function [labels_sub,label_sub_x,label_sub_y]= extract_superpixel_label(label_matrix,pos_xy,min_x,max_x,min_y,max_y)
labels_sub=zeros(size(label_matrix));
for id=1:size(pos_xy,1)
    label_sub_x(id)=pos_xy(id,1)-min_x+1;
    label_sub_y(id)=pos_xy(id,2)-min_y+1;
    labels_sub(label_sub_x(id),label_sub_y(id))=label_matrix(label_sub_x(id),label_sub_y(id));
end

end
function  [labels_sub_new]=increase_seg_cnt_id(labels_sub,cnt,increase_num_pixels,current_num_pixels)
labels_sub_new=labels_sub;
pos=find(labels_sub==1);
labels_sub_new(pos)=cnt;
for j=1:increase_num_pixels
    pos=find(labels_sub==(j+1));
    labels_sub_new(pos)=current_num_pixels+j;
end
end
