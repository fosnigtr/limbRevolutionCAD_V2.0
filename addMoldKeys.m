function addMoldKeys( hObject )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% GET DATA
model = guidata(hObject);

numSlices = length(model.sliceHeights); 
slicePerStep = model.data(end,end)/numSlices; % unit per step

%*******************Remove hard coded angles*******************************
% angleIdx = [1, round(model.numSlicePoints*.25),round(model.numSlicePoints*.5)...
%     round(model.numSlicePoints*.75), model.numSlicePoints]; 
% angleIdx = [1:10:model.numSlicePoints-2];
%**************************************************************************
r = model.data(end-model.numSlicePoints+1:end,1:2);
r = diff(r);
r = sqrt(sum(r.^2,2));
totalDist = sum(r); 
dDist = totalDist/3;
cumSumR = cumsum(r);
[~,key2] = min(abs(cumSumR-dDist*1));
[~,key3] = min(abs(cumSumR-dDist*2));
angleIdx = [1,key2,key3];
tmpPt = (model.data(end,end) - model.guiExtendPoint1(3))/2 ...
    + model.guiExtendPoint1(3);
point1 = round(tmpPt / slicePerStep); % step
point2 = round(model.data(end,end) / slicePerStep); % step
n = point2 + 1 - point1;
y = linspace(1,300,n);
model.guiPerRed = model.guiMoldKeysOffSet/log10(300)*log10(y);

% MAKE KEYS
pad = 20; % add padding (i.e., 20) for convolution
tmpGuiPerRed = ones(pad+model.numSlicePoints,numSlices); 
tmpGuiPerRed(angleIdx+(pad/2+1),(point1:point2)) = bsxfun(@plus,...
    tmpGuiPerRed(angleIdx+(pad/2+1),(point1:point2)), model.guiPerRed);
sigma = 2;
model.guiPerRed = imgaussfilt(tmpGuiPerRed,sigma);
model.guiPerRed = model.guiPerRed((pad/2+1)+1:(pad/2)+1+model.numSlicePoints,:);
absMax = max(max(model.guiPerRed));
[~,col] = find(model.guiPerRed==absMax);
model.guiPerRed = model.guiPerRed(:,1:col(1));
zeroPad = ones(model.numSlicePoints,numSlices-col(1));
model.guiPerRed = cat(2,zeroPad,model.guiPerRed);

tmpData = reshape(model.data(:,1:2),model.numSlicePoints,numSlices,2);
model.guiPerRed = bsxfun(@times,abs(tmpData)./tmpData,model.guiPerRed); % unit vector
model.guiPerRed = 1+(model.guiPerRed./tmpData);
model.guiPerRed = reshape(model.guiPerRed,model.numSlicePoints*numSlices,2);
model.guiPerRed = model.guiPerRed(model.numSlicePoints+1:end,:);

% SAVE DATA
guidata(hObject,model);
end

