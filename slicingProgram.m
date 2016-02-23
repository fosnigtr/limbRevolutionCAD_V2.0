function slicingProgram( hObject )

%% INTERPOLATE MESH IN Z TO 0.01 MM RESOLUTION
scaleFac = 4;
numSliceHeights = size(model.data,1);
tmpData = reshape(model.data,model.numSlicePoints,numSliceHeights/model.numSlicePoints,3);
z = tmpData(:,:,3);
interpZ = linspace(0,model.data(end,end),model.numSliceHeights*scaleFac);
interpZ = reshape(interpZ,model.numSlicePoints,model.numSliceHeights/model.numSlicePoints*scaleFac);
% INITIALIZE BUFFER
interpData = zeros(model.numSlicePoints,length(interpZ),2);
% INTERPOLATE IN Z
for idxAxis = 1:2
    for idx = 1:model.numSlicePoints
        interpData(idx,:,idxAxis) = interp1(z(idx,:),squeeze(tmpData(idx,:,idxAxis)),interpZ(idx,:));
    end
end
% CONVERT TO CYLINDRICAL COORDINATES
interpRData = sqrt(sum(interpData.^2,3));
lastAngle = (model.numSlicePoints*model.angleStep)-model.angleStep;
angle = (0:model.angleStep:lastAngle)';
angle = repmat(angle,1,size(interpZ,2));
interpData = cat(3,interpRData,interpZ,angle);
interpData = reshape(interpData,model.numSliceHeights*scaleFac,3);

end