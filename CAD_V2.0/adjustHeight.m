function [ model ] = adjustHeight( model )

% GET MODEL INFORMATION
data = model.data;
numSlices = model.numSlices;
landmarks = model.landmarks;
adjust = model.adjParamHeight;

% ADJUST HEIGHT
data() = data 

% UPDATE MODEL