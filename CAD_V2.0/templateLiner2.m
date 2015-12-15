function templateLiner2( hObject )
%% UPDATE MODEL HORIZONTAL ALINGMENT
computeCentroid( hObject );

%% UPDATE ANGULAR ALINGMENT
% *************************CHECK WITH BRAD*********************************
% When he does the angular alignment does he look at the entire model or
% the bottom third, quarter, or etc.
% Note: Finish debugging accuracy algorithm
% *************************************************************************
% SET ANGULAR ALIGNMENT
setAngularAlignment( hObject );

%% APPLY CIRCUMFERENCIAL REDUCTION
% GET DATA INFORMATION
model = guidata(hObject);

% SET LANDMARKS LOCATION AND REDUCTION
numSlices = length(model.sliceHeights);
model.dxLandMark = 50;

model.guiLandMarks = model.sliceHeights(1):model.dxLandMark:floor(max(model.sliceHeights));
model.guiPerRed = 1;
for idx = 1:length(model.guiLandMarks)-1
    model.guiPerRed(idx+1) = model.guiPerRed(idx) - .01;
end
model.guiPerRed = cat(2, model.guiPerRed, mean(diff(model.guiPerRed))...
    /model.dxLandMark * max(model.sliceHeights) + 1);
model.guiLandMarks = cat(2, model.guiLandMarks, max(model.sliceHeights));
model.guiPerRed = interpn(model.guiLandMarks,model.guiPerRed,model.sliceHeights);

% SAVE DATA
guidata( hObject , model );

% ADJUST CIRCUMFERENCE
adjustCir( hObject );

%% SAVE MODEL FOR INNER MOLD MODIFICATIONS
innerMold = model.data;

%% APPLY LINER THICKNESS PROFILE
% %% UNDO STEP "PREPARE INNER MOLD DISTAL END"
% model.data = model.undo;
% 
% % UPDATE DATA
% guidata(hObject,model);

% GET DATA INFORMATION
model = guidata(hObject);

% COMPUTE LINER THICKNESS PROFILE
numSlices = length(model.sliceHeights);

%******************LINER THICKNESS PROFILE INLINE FUNCTIONS****************
tmp = 0:261;
z = @(x) (x-131)./75.49;
linerThicknessProfile = @(z) 0.0012223.*z.^6+0.1277.*z.^5+0.2887.*z.^4+...
    0.1493.*z.^3-0.07867.*z.^2+0.538.*z+8.82;
%**************************************************************************
x1 = linspace(0,261,numSlices);
model.guiPerRed = linerThicknessProfile(z(tmp));
model.guiPerRed = fliplr(interp1(tmp,model.guiPerRed,x1)); % downsample-ish

tmpData = reshape(model.data(:,1:2),model.numSlicePoints,numSlices,2);
model.guiPerRed = bsxfun(@times,abs(tmpData)./tmpData,model.guiPerRed); % unit vector
model.guiPerRed = 1+(model.guiPerRed./tmpData);
model.guiPerRed = reshape(model.guiPerRed,model.numSlicePoints*numSlices,2);

% SAVE DATA
guidata(hObject,model);

% APPLY LINER THICKNESS PROFILE
adjustCir( hObject );

%% ADD CYLINDIRCAL ADAPTER
addCylAdap( hObject );

%% EXTEND MOLD
% GET DATA INFORMATION
model = guidata(hObject);

% SET EXTEND TO VALUES
modelHeight = model.data(end,end);
modelEndHeight = model.data(1,3);
model.guiZEnvelope = 600;
model.guiExtend = model.guiZEnvelope - modelHeight; % 600 mm is the printer z envelope
model.guiExtendPoint1 = [0 0 modelEndHeight];
model.guiExtendPoint2 = [0 0 modelHeight];

% SAVE DATA
guidata(hObject,model);

% EXTEND MODEL
extendModel( hObject );

%% ADD MOLD KEYS
% GET DATA INFORMATION
model = guidata(hObject);

% USER DEFINED VALUES
model.guiMoldKeysOffSet = 50; % mm

% GET MOLD KEYS
model = addMoldKeys( hObject, model );

% SAVE DATA
guidata(hObject,model);

% ADD MOLD KEYS
adjustCir( hObject );

%% SAVE OUTER MOLD
[file,path] = uiputfile('.mat','Save model as .mat','OUTERMOLD_lastName_firstName_yyyymmdd');
model.fnMat = file;
model.pnMat = path;
save([model.pnMat, model.fnMat],'model');

%% PREPARE INNER MOLD DISTAL END
%***************************CHECK WITH BRAD********************************
% Get the cap height from Brad.
%**************************************************************************
% GET DATA INFORMATION
model = guidata(hObject);

% GET INNER MOLD DATA
model.data = innerMold;

% USER DEFINED VARIABLES
cap1 = 37.5; cap2 = 40; cap3 = 50; % mm
model.capHeight = 25; % mm
model.capSet = cat(2 ,cap1, cap2, cap3);

% SAVE DATA
guidata(model);

% PREPARE INNER MOLD DISTAL END
addDistalEndCup( hObject );

% %% EXTEND MODEL
% % USER DEFINED VALUES
% modelHeight = model.data(end,3);
% model.guiZEnvelope = 563;
% model.guiExtend = model.guiZEnvelope - modelHeight; % 563 mm is the printer z envelope
% model.guiExtendPoint1 = [0 0 modelHeight];
% model.guiExtendPoint2 = [0 0 modelHeight];
% 
% % SAVE DATA
% guidata(hObject,model);
% 
% % EXTEND INNER MOLD
% extendLinerModel( hObject );

%% EXTEND MOLD
% GET DATA INFORMATION
model = guidata(hObject);

% SET EXTEND TO VALUES
modelHeight = model.data(end,end);
modelEndHeight = model.data(1,3);
model.guiZEnvelope = 600;
model.guiExtend = model.guiZEnvelope - modelHeight; % 600 mm is the printer z envelope
model.guiExtendPoint1 = [0 0 modelEndHeight];
model.guiExtendPoint2 = [0 0 modelHeight];

% SAVE DATA
guidata(hObject,model);

% EXTEND MODEL
extendModel( hObject );

%% ADD MOLD KEYS
% GET DATA INFORMATION
model = guidata(hObject);

% USER DEFINED VALUES
model.guiMoldKeysOffSet = 50; % mm

% GET MOLD KEYS
model = addMoldKeys( hObject, model );

% SAVE DATA
guidata(hObject,model);

% ADD MOLD KEYS
adjustCir( hObject );

%% SAVE INNER MOLD
[file,path] = uiputfile('.mat','Save model as .mat','INNERMOLD_lastName_firstName_yyyymmdd');
model.fnMat = file;
model.pnMat = path;
save([model.pnMat, model.fnMat],'model');

end