function extendLinerModel( hObject )
%EXTENDMODEL Summary of this function goes here
%   Detailed explanation goes here
model = guidata(hObject);
point1 = model.guiExtendPoint1(3); % unit
point2 = model.guiExtendPoint2(3); % unit
numSlice = length(model.sliceHeights); % points

% EXTEND MODEL
if point1 == point2
    % get last slice data
    tmpData = model.data((numSlice-1)*model.numSlicePoints+1:end,:);
    % get new heights for extension
    tmpSliceHeights = model.sliceHeights(end)+model.sliceHeightStep:...
        model.sliceHeightStep:model.guiExtend+model.sliceHeights(end);
    for idx = 1:length(tmpSliceHeights)
        tmpData(:,3) = tmpSliceHeights(idx);
        model.data = cat(1,model.data,tmpData);
    end
    model.sliceHeights = cat(1,model.sliceHeights,tmpSliceHeights');
else
    %**********************NEEDS CHECKING****************************%
    xx = point1/slicePerStep:slicePerStep:(point2-point1+extend)/slicePerStep;  % new section length
    point1 = round(point1 *slicePerStep * numSlicePoints);
    point2 = round(point2 *slicePerStep * numSlicePoints);
    window = point1:point2;
    
    tmpData = reshape(data(window,:),lenght(window),numSlicePoints);
    tmpData = spline(tmpData,xx);
    
    data = cat(1,data(1:window(1)-1,:), tmpData, data(window(2)+1,:));
end

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