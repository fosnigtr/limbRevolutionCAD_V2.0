function [ model ] = adjRotationAlign( hObject, model )
%ADJROTATIONALIGN Summary of this function goes here
%   Detailed explanation goes here

% GET MODEL INFORMATION
adjXYZ = model.guiadjRotationAling;

% 
if strcmp(adjXYZ(1),'default');
    model = computeCentriod( hObject, model );
    model.data = model.data(:,1) - model.distalEndX;
    model.data = model.data(:,2) - model.distalEndY;
else
    mo
end

end

