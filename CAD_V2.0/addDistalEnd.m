function [ model ] = addDistalEnd( hObject, model )
%ADDDISTALEND Summary of this function goes here
%   Detailed explanation goes here

% GET MODEL INFORMATION
data = model.data;
distalEnd = model.distalEnd;
x = model.distalEndX;
y = model.distalEndY;

% TRANSLATE DISTAL END IN X AND Y
distalEnd(:,1) = distalEnd(:,1)+x; 
distalEnd(:,2) = distalEnd(:,2)+y;

% CUT DISTAL END
radius = max(distalEnd);
cutHeight = min(abs(data(:,1:2)-radius));

% ADD DISTAL END
data(end:cutHeight,:) = distalEnd;

% UPDATE MODEL
model.data = data;

end

