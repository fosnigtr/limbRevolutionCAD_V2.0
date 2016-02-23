function blendModel( hObject )
model = guidata(hObject);

sigma = 1;

tmp = reshape(model.data(:,1:2),model.numSlicePoints,model.numSliceHeights...
    /model.numSlicePoints,2);

tmpX = imgaussfilt(tmp(:,:,1),sigma);
tmpY = imgaussfilt(tmp(:,:,2),sigma);

tmpX = reshape(tmpX,model.numSliceHeights,1);
tmpY = reshape(tmpY,model.numSliceHeights,1);

model.data(:,1) = tmpX;
model.data(:,2) = tmpY;

guidata(hObject,model);
end