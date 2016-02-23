function computeCentroid( hObject )
%COMPUTECENTROID Summary of this function goes here
%   Detailed explanation goes here
model = guidata(hObject);

% COMPUTE CENTROID
model.centroid = mean(model.data,1);

% CENTER MODEL
model.data = bsxfun(@minus,model.data,model.centroid);
model.data(:,3) = model.data(:,3) - min(model.data(:,3));

% COMPUTE NEW CENTROID
model.centroid = mean(model.data,1);

% DRAW SCENE
set(model.handlePatch,'vertices',model.data);
drawnow;

% UPDATE DATA
guidata(hObject,model);
end

