function adjustCir( hObject )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
model = guidata(hObject);

numSlices = length(model.sliceHeights)-1;

if size(model.guiPerRed,2) ==  1
    tmpData = reshape(model.data(model.numSlicePoints+1:end,1:2),model.numSlicePoints,numSlices,2);
    tmpData = bsxfun(@times,tmpData,model.guiPerRed');
    model.data(model.numSlicePoints+1:end,1:2) = reshape(tmpData,model.numSlicePoints*numSlices,2);
else
    model.data(model.numSlicePoints+1:end,1:2) = model.data(model.numSlicePoints+1:end,1:2) .* model.guiPerRed;
end

% SAVE DATA
guidata(hObject,model);

% DRAW SCENE
set(model.handlePatch,'vertices',model.data);
drawnow;
end

