function addMoldKeys( hObject )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% GET DATA
model = guidata(hObject);

numSlices = length(model.sliceHeights); 
slicePerStep = model.data(end,end)/numSlices; % unit per step

%*******************Remove hard coded angles*******************************
angleIdx = [1, round(model.numSlicePoints*.25),...
    round(model.numSlicePoints*.75), model.numSlicePoints]; 
%**************************************************************************

point1 = round(model.guiExtendPoint1(3) / slicePerStep)*2; % step
point2 = round(model.data(end,end) / slicePerStep); % step
n = point2 + 1 - point1;
y = linspace(1,300,n);
model.guiPerRed = model.guiMoldKeysOffSet/log10(300)*log10(y);

% MAKE KEYS
pad = 50; % add padding (i.e., 20) for convolution
tmpGuiPerRed = ones(pad+model.numSlicePoints,numSlices); 
tmpGuiPerRed(angleIdx+(pad/2+1),(point1:point2)) = bsxfun(@plus,...
    tmpGuiPerRed(angleIdx+(pad/2+1),(point1:point2)), model.guiPerRed);
model.guiPerRed = imgaussfilt(tmpGuiPerRed,2);
model.guiPerRed = model.guiPerRed((pad/2+1)+1:(pad/2)+1+model.numSlicePoints,:);

tmpData = reshape(model.data(:,1:2),model.numSlicePoints,numSlices,2);
model.guiPerRed = bsxfun(@times,abs(tmpData)./tmpData,model.guiPerRed); % unit vector
model.guiPerRed = 1+(model.guiPerRed./tmpData);
model.guiPerRed = reshape(model.guiPerRed,model.numSlicePoints*numSlices,2);
model.guiPerRed = model.guiPerRed(model.numSlicePoints+1:end,:);

% SAVE DATA
guidata(hObject,model);
end

