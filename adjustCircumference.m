function [ model ] = adjustCircumference( hObject, model )
%ADJUSTCIRCUMFERENCE Summary of this function goes here
%   Detailed explanation goes here

% GET MODEL INFORMATION
data = model.data;
numSlices = model.numSlices;
landmarks = model.landmarks;
adjust = model.adjustParamCir;

% ADJUST CIRCUMFERENCE
win = round(landmarks(:,3))*numSlices+1:round(landmarks(:,3))*numSlices;
data(win,:) = data(win,:).*adjust./100;

% UPDATE MODEL
model.data = data;

end
