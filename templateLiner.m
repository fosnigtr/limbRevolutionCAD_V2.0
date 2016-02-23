function templateLiner()
% LINER TEMPLATE
cd('C:\Users\Tyler Fosnight\Documents\Tyler Documents\PDI\CAD');
% javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');

%% RECORD LINER MACRO
% prompt = {'Command window'};
% dlg_title = '';
% num_lines = 20;
% l1 = 'Description {command}\n';
% space = '\n';
% l2 = 'Circumferencial percent reduction landmark heights (mm) {L [0 5 10 20]}\n';
% l3 = 'Landmark circumferencial reduction (percent) {P- [0 1 2 3]}\n';
% l4 = 'Circumferencial percent increase landmark heights (mm) {L [0 5 10 20]}\n';
% l5 = 'Landmark circumferenical reduction (percent) {P+ [100 101 102 103]}\n';
% l6 = 'Extend (mm) {E [3]}\n';
% l7 = 'Extend between heights (mm) {EH [4 5]}\n';
% start = '------------Type your code below-----------------';
%
% string = sprintf(strcat(l1,space,space,l2,l3,l4,l5,l6,l7,start));
% defaultans = {string};
% answerInnerMold = inputdlg(prompt,dlg_title,num_lines,defaultans, 'on');
% clear all; close all;
% cd('C:\Users\Tyler Fosnight\Documents\Tyler Documents\PDI\CAD');
hObject = figure;
set(hObject,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
set(hObject,'color',[50/255 56/255 59/255]);
set(hObject,'position', [2590 -98  637 877]);
set(hObject,'Resize','on');
% set(hObject,'position', [2545 -248 617 883]);
set(hObject,'MenuBar','none');
set(hObject,'ToolBar','none');
set(hObject,'name','limbRevolution.CAD');
set(hObject,'NumberTitle','off');
cmap = [1 93/255 13/255; .2 .2 .2];
set(hObject,'colormap',cmap);

% INITIALIZE AXES
model = guidata(hObject);
model.axes1 = axes('Parent',hObject,...
    'Color',[0.247058823529412 0.247058823529412 0.247058823529412],...
    'ZColor',[0 0 0],...
    'YColor',[0 0 0],...
    'XColor',[0 0 0],...
    'GridAlpha',1,...
    'GridColor',[0 0 0],...
    'CameraViewAngle',4); % change this so that it is not hard coded
axis off;
axis equal;
% box(model.axes1,'on');
set(model.axes1,'XTickLabel','');
set(model.axes1,'YTickLabel','');
% grid(model.axes1,'on');
% hold(model.axes1,'on');

% SET DEFAULTS
model.LANDMARK = false;
model.idxAP = 1; 
model.idxML = 1;
model.mouseDown = false;

% SAVE DATA
guidata(hObject,model);

%% GET .AOP FILE
getAopFile( hObject );

%% READ .AOP FILE
readAopFile( hObject );

%% SET VIEW PORT
model = guidata(hObject);

%****************change these so they're not hard coded in*****************
% model.minX = -100; model.homeMinX = model.minX;
% model.maxX = 100; model.homeMaxX = model.maxX;
% model.minY = 0; model.homeMinY = model.minY;
% model.maxY = 223; model.homeMaxY = model.maxY;
% xlim([model.minX, model.maxX]); ylim([model.minY, model.maxY]);
%**************************************************************************
% SAVE DATA
guidata(hObject,model);

%% MESH MODEL (USE SQUARE AS PRIMITIVE SHAPE, DESIGNATE NORMAL POINTING OUTWARD)
model = guidata(hObject);

model.faces = bsxfun(@plus, ones(model.numSlicePoints*(length(model.sliceHeights)-1)-1,4),...
    (0:(model.numSlicePoints*(length(model.sliceHeights)-1)-2))');
model.faces = bsxfun(@plus,model.faces,[0,1,1+model.numSlicePoints,model.numSlicePoints]);

model.numFaces = size(model.faces,1);

% SAVE DATA
guidata(hObject,model);

%% INITIALIZE PATCH
model = guidata(hObject);

model.handlePatch = patch('Faces',model.faces,'Vertices',model.data);
light('Style','infinite');
model.hLight = camlight('headlight');
% [0.870588235294118 0.623529411764706 0.0431372549019608] - model color
% [0 0 0] - model black
% [0 106/255 255/255] - assembly color
set(model.handlePatch,'FaceColor','Flat');
model.tmpLandmarks = ones(1,model.numFaces);
set(model.handlePatch,'CData',model.tmpLandmarks);
set(model.handlePatch,'CDataMapping','scaled');
set(model.handlePatch,'FaceLighting','gouraud');
% set(model.handlePatch,'BackFaceLighting','lit');
set(model.handlePatch,'EdgeColor',[0 0 0]);
% set(model.handlePatch,'EdgeColor',[0.870588235294118 0.623529411764706 0.0431372549019608]);
% set(model.handlePatch,'LineStyle',':');
set(model.handlePatch,'FaceAlpha',1);
set(model.handlePatch,'EdgeAlpha',1);
% set(model.handlePatch,'EdgeLighting','flat');
% set(model.handlePatch,'CData',1:size(model.data,1));
% set(model.handlePatch,'CDataMapping','scaled');

% model.data(:,1:2,2) = model.data(:,1:2) *.8;
% model.data(:,3,2) = model.data(:,3,1);
%
% model.handlePatch2 = patch('Faces',model.faces,'Vertices',model.data(:,:,2));
% light('Position',[0 -300 0],'Style','infinite')
% % [0.870588235294118 0.623529411764706 0.0431372549019608]
% set(model.handlePatch2,'FaceColor',[255/255 85/255 0]);
% set(model.handlePatch2,'FaceLighting','gouraud');
% set(model.handlePatch2,'BackFaceLighting','lit');
% set(model.handlePatch2,'EdgeColor','none');
% % set(model.handlePatch,'EdgeColor',[0.870588235294118 0.623529411764706 0.0431372549019608]);
% % set(model.handlePatch,'LineStyle',':');
% set(model.handlePatch2,'FaceAlpha',1);
% set(model.handlePatch2,'EdgeAlpha',1);
% % set(model.handlePatch,'EdgeLighting','flat');
% % set(model.handlePatch,'CData',1:size(model.data,1));
% % set(model.handlePatch,'CDataMapping','scaled');

% ML, AP AND HEIGHT UI
hFigCoordGUI = figure;
axis off;
name = 'ML, AP and height indicator';
set(hFigCoordGUI,'Resize','off');
set(hFigCoordGUI,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
set(hFigCoordGUI,'name',name);
set(hFigCoordGUI,'NumberTitle','off');
set(hFigCoordGUI,'MenuBar','none');
set(hFigCoordGUI,'ToolBar','none');
set(hFigCoordGUI,'Position',[2738 589 329 43]);

% PUSH BUTTON (SELECT TOP OF SECTION)
model.hCoordUI = uicontrol('style','text','units',...
    'pixel','position',[15 10 300 20],...
    'string','0','string', ['ML = ', 'NA', '(mm), ', ...
    'AP = ', 'NA', '(mm), ', 'Height = ', 'NA', '(mm)']);

% SET UI CALLBACKS
set(hObject,'WindowButtonDownFcn',{@handleMouseDown});
set(hObject,'WindowButtonUpFcn',{@handleMouseUp});
set(hObject,'WindowButtonMotionFcn',{@handleMouseMove});
set(hObject,'KeyPressFcn',{@handleKeyDown});
set(hObject,'KeyReleaseFcn',{@handleKeyUp});

% SAVE DATA
guidata(hObject,model);

%% UPDATE MODEL HORIZONTAL ALINGMENT
computeCentroid( hObject );

% UPDATE DATA
% model = guidata(hObject);
% model.data = bsxfun(@minus,model.data,model.centroid);
% model.zUndo = model.centroid(3);

% SAVE DATA
% guidata(hObject,model);

% UPDATE MODEL CENTROID
% computeCentroid( hObject );

%% UPDATE ANGULAR ALINGMENT
% *************************CHECK WITH BRAD*********************************
% When he does the angular alignment does he look at the entire model or
% the bottom third, quarter, or etc.
% Note: Finish debugging accuracy algorithm
% *************************************************************************
% model = guidata(hObject);

% model.guiTheta0 = 5;

% SAVE DATA
% guidata(hObject,model);

setAngularAlignment( hObject );

%% TRIM LINE 
% trimLine( hObject );

%% APPLY LINER THICKNESS PROFILE
% numSlices = length(model.sliceHeights);
% 
% %******************LINER THICKNESS PROFILE INLINE FUNCTIONS****************
% tmp = 0:261;
% z = @(x) (x-131)./75.49;
% linerThicknessProfile = @(z) 0.0012223.*z.^6+0.1277.*z.^5+0.2887.*z.^4+...
%     0.1493.*z.^3-0.07867.*z.^2+0.538.*z+8.82;
% %**************************************************************************
% x1 = linspace(0,261,numSlices);
% model.guiPerRed = linerThicknessProfile(z(tmp));
% model.guiPerRed = fliplr(interp1(tmp,model.guiPerRed,x1)); % downsample-ish
% 
% tmpData = reshape(model.data(:,1:2),model.numSlicePoints,numSlices,2);
% model.guiPerRed = bsxfun(@times,abs(tmpData)./tmpData,model.guiPerRed); % unit vector
% model.guiPerRed = 1+(model.guiPerRed./tmpData);
% model.guiPerRed = reshape(model.guiPerRed,model.numSlicePoints*numSlices,2);
% 
% % SAVE DATA
% guidata(hObject,model);
% 
% adjustCir( hObject );
% 
% model = guidata(hObject);
% 
% set(model.handlePatch,'vertices',model.data);
% drawnow;

%% EXTEND MOLD
% model = guidata(hObject);
%
% modelHeight = model.data(end,end);
% modelEndHeight = model.data(1,3);
% model.guiZEnvelope = 600;
% model.guiExtend = model.guiZEnvelope - modelHeight; % 600 mm is the printer z envelope
% model.guiExtendPoint1 = [0 0 modelEndHeight];
% model.guiExtendPoint2 = [0 0 modelHeight];
%
% % SAVE DATA
% guidata(hObject,model);
%
% extendModel( hObject );

%% ADD CYLINDIRCAL ADAPTER
% addCylAdap( hObject );

%% EXTEND MODEL
% USER DEFINED VALUES
modelHeight = model.data(end,3);
model.guiZEnvelope = 563;
model.guiExtend = model.guiZEnvelope - modelHeight; % 563 mm is the printer z envelope
model.guiExtendPoint1 = [0 0 modelHeight];
model.guiExtendPoint2 = [0 0 modelHeight];
model.LANDMARK = true;

% SAVE DATA
guidata(hObject,model);

% EXTEND INNER MOLD
extendModel( hObject );

%% COMPUTE SLICE HEIGHT
model = guidata(hObject);

model.sliceStep = mean(diff(model.sliceHeights));

% SAVE DATA
guidata(hObject,model);

%% APPLY CIRCUMFERENCIAL REDUCTION
% GET DATA INFORMATION
model = guidata(hObject);

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
guidata( hObject );

adjustCir( hObject );

%% PREPARE INNER MOLD DISTAL END
%***************************CHECK WITH BRAD********************************
% Get the cap height from Brad.
%**************************************************************************
% USER DEFINED VARIABLES
cap1 = 37.5; cap2 = 40; cap3 = 50; % mm
model.capHeight = 25; % mm
model.capSet = cat(2 ,cap1, cap2, cap3);

% SAVE DATA
guidata(model);

addDistalEndCup( hObject );

%% ADD MOLD KEYS
% USER DEFINED VALUES
model.guiMoldKeysOffSet = 50; % mm

% GET MOLD KEYS
model = addMoldKeys( hObject, model );

% SAVE DATA
guidata(hObject,model);

% ADD MOLD KEYS
adjustCir( hObject );

%% SAVE INNER MOLD
model.data;
uisave('model');

%% UNDO STEP "PREPARE INNER MOLD DISTAL END"
model.data = model.undo;

% UPDATE DATA
guidata(hObject,model);

%% SAVE OUTER MOLD
uisave('model');

function handleMouseDown( hObject, varArgIn )
model = guidata(hObject);
persistent chk
% CHECK FOR SINGLE OR DOUBLE CLICK
if isempty(chk)
    chk = 1;
    pause(0.2);
    if chk == 1
        chk = [];
        %           props.WindowButtonMotionFcn = get(hObject,'WindowButtonMotionFcn');
        %           props.WindowButtonUpFcn = get(hObject,'WindowButtonUpFcn');
        %           setappdata(hObject,'callBacks',props);
        tmp = get(hObject,'CurrentPoint');
        model.lastMouseX = tmp(1);
        model.lastMouseY = tmp(2);
        model.mouseDown = true;
        guidata(hObject, model);
        %           set(hObject,'WindowButtonMotionFcn',{@handleMouseMove})
        %           set(hObject,'WindowButtonUpFcn',{@handleMouseUp})
    end
else
    chk = [];
    if model.LANDMARK
        %           % SET LANDMARKS
        %           tmp = get(model.axes1,'currentpoint');
        %           t = 0:.01:1;
        %           x = (tmp(2,1)-tmp(1,1)).*t+tmp(1,1);
        %           y = (tmp(2,2)-tmp(1,2)).*t+tmp(1,2);
        %           z = (tmp(2,3)-tmp(1,3)).*t+tmp(1,3);
        %           v = [x' y' z'];
        %           lastM = 1e6;
        %           for idx = 1:101
        %               [m, loc] = min(sum(abs(bsxfun(@minus,model.data',v(idx,:)')),1));
        %               if m < lastM
        %                   lastM = m;
        %                   lastLoc = loc;
        %               end
        %           end
        [~,~,~,idxLandmark] = getCord(hObject);
        tmpIdx = round(idxLandmark/model.numSlicePoints); % round vertex index to the nearest slice index (results in 0.9 mm resolution)
        idxLandmark = (tmpIdx-1) * model.numSlicePoints + 1;
        model.tmpLandmarks(idxLandmark:idxLandmark+model.numSlicePoints-1)=0;
        set(model.handlePatch,'CData',model.tmpLandmarks);
        drawnow;
        guidata(hObject,model);
    end
end

function handleMouseMove( hObject, varArgIn )
model = guidata(hObject);
if model.mouseDown 
    tmp = get(hObject,'CurrentPoint');
    model.newX = tmp(1);
    model.newY = tmp(2);
    model.deltaX = - model.lastMouseX + model.newX;
    model.deltaY = - model.lastMouseY + model.newY;
    model.lastMouseX = model.newX;
    model.lastMouseY = model.newY;
    guidata(hObject, model);
    tick(hObject);
else
    %UPDATE ML, AP AND HEIGHT INDICATOR
    [~,~,z,~] = getCord(hObject);
    idxZ = model.numSlicePoints*round(z/model.sliceHeightStep)+1;
    lengthML = round(norm(model.data(idxZ+model.idxML,1:2))...
        +norm(model.data(idxZ+model.idxML+round(model.numSlicePoints/2),1:2)));
    lengthAP = round(norm(model.data(idxZ+model.idxAP,1:2))...
        +norm(model.data(idxZ+model.idxAP+round(model.numSlicePoints/2),1:2)));
    z = round(z);
    set(model.hCoordUI,'string', ['ML = ', num2str(lengthML), '(mm), ', ...
        'AP = ', num2str(lengthAP), '(mm), ', 'Height = ', num2str(z), '(mm)']);
end

function handleMouseUp( hObject, varArgIn )
model = guidata(hObject);
model.mouseDown = false;
% props = getappdata(hObject,'callBacks');
% set(hObject,props);
guidata(hObject,model);

function handleKeyDown( hObject, varArgIn )
model = guidata(hObject);
model.currentlyPressedKeys = varArgIn.Key;
guidata(hObject,model);
handleKeys(hObject);

function handleKeyUp( hObject, varArgIn )
model = guidata(hObject);
model.currentlyPressedKeys = false;
guidata(hObject,model);

function handleKeys( hObject )
model = guidata(hObject);
model.x = 0;
model.z = 0;
if strcmp(model.currentlyPressedKeys,'uparrow');
    model.deltaY = 1;
    model.deltaX = 0;
elseif strcmp(model.currentlyPressedKeys,'downarrow');
    model.deltaY = -1;
    model.deltaX = 0;
elseif strcmp(model.currentlyPressedKeys,'rightarrow');
    model.deltaX = -1;
    model.deltaY = 0;
elseif strcmp(model.currentlyPressedKeys,'leftarrow');
    model.deltaX = 1;
    model.deltaY = 0;
elseif strcmp(model.currentlyPressedKeys,'a');
    % anterior view (assume homeData is anterior view)
    model.data = model.homeData;
    model.minX = model.homeMinX;
    model.maxX = model.homeMaxX;
    model.minY = model.homeMinY;
    model.maxY = model.homeMaxY;
elseif strcmp(model.currentlyPressedKeys,'p');
    % posterior view
    model.data = model.homeData;
    model.z = 180;
    model.data = model.homeData;
    model.minX = model.homeMinX;
    model.maxX = model.homeMaxX;
    model.minY = model.homeMinY;
    model.maxY = model.homeMaxY;
elseif strcmp(model.currentlyPressedKeys,'m');
    % medial view (assume right leg)
    model.data = model.homeData;
    model.z = -45;
    model.data = model.homeData;
    model.minX = model.homeMinX;
    model.maxX = model.homeMaxX;
    model.minY = model.homeMinY;
    model.maxY = model.homeMaxY;
elseif strcmp(model.currentlyPressedKeys,'l');
    % lateral view (assume right leg)
    model.data = model.homeData;
    model.z = 45;
    model.data = model.homeData;
    model.minX = model.homeMinX;
    model.maxX = model.homeMaxX;
    model.minY = model.homeMinY;
    model.maxY = model.homeMaxY;
elseif strcmp(model.currentlyPressedKeys,'d');
    % distal view
    model.data = model.homeData;
    model.x = 90;
    model.minX = model.homeMinX;
    model.maxX = model.homeMaxX;
    model.minY = model.homeMinX;
    model.maxY = model.homeMaxX;
elseif strcmp(model.currentlyPressedKeys,'s');
    % superior/proximal view
    model.data = model.homeData;
    model.x = -90;
    model.minX = model.homeMinX;
    model.maxX = model.homeMaxX;
    model.minY = model.homeMinX;
    model.maxY = model.homeMaxX;
elseif strcmp(model.currentlyPressedKeys,'add');
    model.minX = model.minX + 10;
    model.maxX = model.maxX - 10;
    model.maxY = model.maxY - 10;
elseif strcmp(model.currentlyPressedKeys,'subtract');
    model.minX = model.minX - 10;
    model.maxX = model.maxX + 10;
    model.maxY = model.maxY + 10;
end
model.newRotationMatrix = roty(model.z)*rotx(model.x);
guidata(hObject,model);
tick(hObject);

function tick( hObject )
model = guidata(hObject);
camorbit(model.deltaX,model.deltaY);
camlight(model.hLight,'headlight');

