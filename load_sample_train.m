function [loc_train, loc_test, CTest] = load_sample_train(img_name,per_ratio)
    load_path=['./data/sample_train/'];
	file_name=[img_name num2str(per_ratio) '_sample.mat'];
	load([load_path file_name],'loc_train', 'loc_test', 'CTest');
end
