function addDistalEndCup( hObject )
%DISTALENDCUP Summary of this function goes here
%   Detailed explanation goes here
model = guidata(hObject);

% GET DATA INFORMATION
numSliceHeights = length(model.sliceHeights);
numCapRadii = length(model.capSet);

% INTIALIZE BUFFERS
idxHeight = zeros(numCapRadii,1);

% FIND OPTIMAL CUP
tmpR = reshape(model.data,model.numSlicePoints,numSliceHeights,3);
tmpR = mean(sqrt(sum(tmpR(:,:,1:2).^2,3)),1);

for idx = 1:numCapRadii;
    [~, locR] = min(abs(tmpR-model.capSet(idx)));
    idxHeight(idx) = locR;
end

% GET CAP THAT MINIMIZES HEIGHT ERROR
[~, idxCap] = min(abs(model.sliceHeights(idxHeight)-model.capHeight));
idxSliceHeight = idxHeight(idxCap);

% ROUND TO NEAREST SLICE HEIGHT
idxHeight = (idxSliceHeight-1)*model.numSlicePoints+1; 

% UPDATE INFORMATION
model.undo = model.data;
model.idxHeight = idxHeight;
model.data = model.data(idxHeight:end,:);
model.sliceHeights = model.sliceHeights(idxSliceHeight:end);
model.distalEndDia = model.capSet(idxCap);

% RE-MESH MODEL
model.faces = bsxfun(@plus, ones(model.numSlicePoints*(length(model.sliceHeights)-1)-1,4),...
    (0:(model.numSlicePoints*(length(model.sliceHeights)-1)-2))');
model.faces = bsxfun(@plus,model.faces,[0,1,1+model.numSlicePoints,model.numSlicePoints]);

% UPDATE COLOR MAP
model.numFaces = size(model.faces,1);
model.highlight = ones(1,model.numFaces);
set(model.handlePatch,'CData',model.highlight);

% DRAW SCENE
set(model.handlePatch,'vertices',model.data,'faces',model.faces);
drawnow;

% SAVE DATA
guidata(hObject,model);
end

