function main()
% Description: http://undocumentedmatlab.com/blog/using-pure-java-gui-in-deployed-matlab-apps

% Add Java library if it is not already on the dynamic Java classpath
if isempty(which('my.contacteditor.ContacteditorUI'))
    folder = fileparts(mfilename('fullpath'));
    javaaddpath([folder '\ContactEditor.jar']);
end

isdeployed = 1;

% Get example Java window from the library
jFrame = my.contacteditor.ContactEditorUI();

% Get Java buttons
% Note: see http://undocumentedmatlab.com/blog/matlab-callbacks-for-java-events-in-r2014a
% HOME NAVIGATION
openButton = handle(jFrame.getOpenFileButton(), 'CallbackProperties');
importButton = handle(jFrame.getImportButton(), 'CallbackProperties');
saveAsButton = handle(jFrame.getSaveAsButton(), 'CallbackProperties');
saveButton = handle(jFrame.getSaveButton(), 'CallbackProperties');
smallSaveButton = handle(jFrame.getSmallSaveButton(), 'CallbackProperties');
exportButton = handle(jFrame.getExportButton(), 'CallbackProperties');
helpButton = handle(jFrame.getHelpButton(), 'CallbackProperties');
gitHubButton = handle(jFrame.getGitHubButton(), 'CallbackProperties');

% TOOLS NAVIGATION
alignButton = handle(jFrame.getAlignButton(), 'CallbackProperties');
extendButton = handle(jFrame.getExtendButton(), 'CallbackProperties');
adjustButton = handle(jFrame.getAdjustButton(), 'CallbackProperties');
trimLinesButton = handle(jFrame.getTrimLinesButton(), 'CallbackProperties');
adapterButton = handle(jFrame.getAdapterButton(), 'CallbackProperties');

% ASSEMBLY TOOLS NAVIGATION
assemblyButton = handle(jFrame.getAssemblyButton(), 'CallbackProperties');

% TEMPLATE NAVIGATION
linerTemplateButton = handle(jFrame.getLinerTemplateButton(), 'CallbackProperties');

% PRINT PROJECT NAVIGATION
printProjectButton = handle(jFrame.getPrintProjectHelpButton(), 'CallbackProperties');

% Set Java button callbacks
% HOME NAVIGATION
set(openButton, 'ActionPerformedCallback', @getFile);
set(importButton, 'ActionPerformedCallback', @getImportFile);
set(saveAsButton, 'ActionPerformedCallback', @getSaveAs);
set(saveButton,'ActionPerformedCallback', @getSave);
set(smallSaveButton,'ActionPerformedCallback', @getSave);
set(exportButton,'ActionPerformedCallback', @getExport);
set(helpButton, 'ActionPerformedCallback', @goToHelp);
set(gitHubButton, 'ActionPerformedCallback', @goToGitHub);

% TOOLS NAVIGATION
set(alignButton,'ActionPerformedCallback', @getAlign);
set(extendButton,'ActionPerformedCallback', @getExtend);
set(adjustButton,'ActionPerformedCallback', @getAdjust);
set(trimLinesButton,'ActionPerformedCallback', @getTrimLines);
set(adapterButton,'ActionPerformedCallback', @getAdapter);

% ASSEMBLY TOOLS NAVIGATION
set(assemblyButton, 'ActionPerformedCallback', @getAssembly);

% TEMPLATE NAVIGATION
set(linerTemplateButton,'ActionPerformedCallback', @getLinerTemplate);

% PRINT PROJECT NAVIGATION
set(printProjectButton,'ActionPerformedCallback', @goToPrintProjectHelp);

%     node = uitreenode(handle(jFrame.getDesignTree()),'my root','C:\Users\Tyler Fosnight\Documents\Tyler Documents\PDI\CAD\javaGUI',false);
%     set(handle(jFrame.getDesignTree()),'Root',node);

% Display the Java window
jFrame.setVisible(true);
if isdeployed
%     waitfor(jFrame);
end

% INITIALIZE CANVAS
hObject = figure;
set(hObject,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
set(hObject,'color',[50/255 56/255 59/255]);
% set(hObject,'position', [2590 -98  637 877]);
set(hObject,'Resize','on');
set(hObject,'MenuBar','none');
set(hObject,'ToolBar','none');
set(hObject,'name','limbRevolution.CAD V2.0');
set(hObject,'NumberTitle','off');
cmap = [1 93/255 13/255; .2 .2 .2];
set(hObject,'colormap',cmap);

% SET EXIT HANDLING
set(hObject,'CloseRequestFcn',@closelimbRevCAD);

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
set(model.axes1,'XTickLabel','');
set(model.axes1,'YTickLabel','');

% SET DEFAULTS
LANDMARK = false;
model.idxAP = 1;
model.idxML = 1;
model.mouseDown = false;
toggleAlign = true;
toggleExtend = true;
toggleAdjust = true;
toggleTrimLine = true;
toggleCylAdap = true;
zm = [];

% ML, AP AND HEIGHT INDICATOR
model.hCoordUI = uicontrol('style','text','units',...
    'pixel','position',[15 10 300 20],...
    'string','0','string', ['ML = ', 'NA', '(mm), ', ...
    'AP = ', 'NA', '(mm), ', 'Height = ', 'NA', '(mm)']);

% SAVE DATA
guidata(hObject,model);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HOME NAVIGATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IMPORT FILE
    function getImportFile(hJava, hEventData)
        getAopFile( hObject );
        
        readAopFile( hObject );
        
        % CLEAR CANVAS
        cla;
        
        %% MESH MODEL (USE SQUARE AS PRIMITIVE SHAPE, DESIGNATE NORMAL POINTING OUTWARD)
        model = guidata(hObject);
        
        model.faces = bsxfun(@plus, ones(model.numSlicePoints*(length(model.sliceHeights)-1)-1,4),...
            (0:(model.numSlicePoints*(length(model.sliceHeights)-1)-2))');
        model.faces = bsxfun(@plus,model.faces,[0,1,1+model.numSlicePoints,model.numSlicePoints]);
        
        model.numFaces = size(model.faces,1);
        
        %% INITIALIZE PATCH
        model.handlePatch = patch('Faces',model.faces,'Vertices',model.data);
        light('Style','infinite');
        model.hLight = camlight('headlight');
        set(model.handlePatch,'FaceColor','Flat');
        model.tmpLandmarks = ones(1,model.numFaces);
        set(model.handlePatch,'CData',model.tmpLandmarks);
        set(model.handlePatch,'CDataMapping','scaled');
        set(model.handlePatch,'FaceLighting','gouraud');
        set(model.handlePatch,'EdgeColor','None');
        set(model.handlePatch,'FaceAlpha',1);
        set(model.handlePatch,'EdgeAlpha',1);
        
        % SET ML, AP AND HEIGHT INDICATOR UI CALLBACKS
        set(hObject,'WindowButtonDownFcn',{@handleMouseDown});
        set(hObject,'WindowButtonUpFcn',{@handleMouseUp});
        set(hObject,'WindowButtonMotionFcn',{@handleMouseMove});
        set(hObject,'KeyPressFcn',{@handleKeyDown});
        set(hObject,'KeyReleaseFcn',{@handleKeyUp});
        
        % SAVE DATA
        guidata(hObject,model);
        
        % CENTER MODEL
        computeCentroid( hObject );
    end

% OPEN FILE
    function getFile(hJava, hEventData)
        [fn,pn,~] = uigetfile('*.mat','Open .mat file');
        
        % ERROR CHECKING
        while strcmp(fn(end-3:end),'.mat') == 0;
            h=errordlg('Open .mat file');
            pause(1);
            delete(h);
            [fn,pn,~]=uigetfile('*.mat','Open .mat file');
        end
        
        % OPEN FILE
        model = guidata(hObject);
        output = open([pn,fn]);
        model = output.model;
        
        % SAVE DATA
        guidata(hObject,model);
        
        % CLEAR CANVAS
        cla;
        
        %% MESH MODEL (USE SQUARE AS PRIMITIVE SHAPE, DESIGNATE NORMAL POINTING OUTWARD)
        %         model = guidata(hObject);
        %
        %         model.faces = bsxfun(@plus, ones(model.numSlicePoints*(length(model.sliceHeights)-1)-1,4),...
        %             (0:(model.numSlicePoints*(length(model.sliceHeights)-1)-2))');
        %         model.faces = bsxfun(@plus,model.faces,[0,1,1+model.numSlicePoints,model.numSlicePoints]);
        %
        %         model.numFaces = size(model.faces,1);
        
        %% INITIALIZE PATCH
        model.handlePatch = patch('Faces',model.faces,'Vertices',model.data);
        light('Style','infinite');
        model.hLight = camlight('headlight');
        set(model.handlePatch,'FaceColor','Flat');
        model.tmpLandmarks = ones(1,model.numFaces);
        set(model.handlePatch,'CData',model.tmpLandmarks);
        set(model.handlePatch,'CDataMapping','scaled');
        set(model.handlePatch,'FaceLighting','gouraud');
        set(model.handlePatch,'EdgeColor','None');
        set(model.handlePatch,'FaceAlpha',1);
        set(model.handlePatch,'EdgeAlpha',1);
        
        % SET ML, AP AND HEIGHT INDICATOR UI CALLBACKS
        set(hObject,'WindowButtonDownFcn',{@handleMouseDown});
        set(hObject,'WindowButtonUpFcn',{@handleMouseUp});
        set(hObject,'WindowButtonMotionFcn',{@handleMouseMove});
        set(hObject,'KeyPressFcn',{@handleKeyDown});
        set(hObject,'KeyReleaseFcn',{@handleKeyUp});
        
        % SAVE DATA
        guidata(hObject,model);
        
        % CENTER MODEL
        computeCentroid( hObject );
    end

% SAVE FILE AS
    function getSaveAs(hJava, hEventData)
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            model = guidata(hObject);
            [file,path] = uiputfile('.mat','Save model as .mat','lastName_firstName_yyyymmdd');
            model.fnMat = file;
            model.pnMat = path;
            save([model.pnMat, model.fnMat],'model');
            guidata(hObject,model);
        else
            return;
        end
    end

% SAVE FILE
    function getSave(hJava, hEventData)
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            model = guidata(hObject);
            if any(strcmp('fnMat',fieldnames(model)))
                save([model.pnMat, model.fnMat],'model');
            else
                [file,path] = uiputfile('.mat','Save model as .mat','lastName_firstName_yyyymmdd');
                model.fnMat = file;
                model.pnMat = path;
                save([model.pnMat, model.fnMat],'model');
                guidata(hObject,model);
            end
        else
            return;
        end
    end

% SAVE EXPORT FILE
    function getExport(hJava, hEventData)
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            % GET EXPORT FILE AND PATH NAME
            [file,path] = uiputfile({'*.tap';'*.stl'},...
                'Export file','lastName_firstName_type_yyyymmdd');
            % ERROR CHECKING
            while strcmp(file(end-3:end),'.tap') == 0 || strcmp(file(end-3:end),'.stl');
                h=errordlg('Export .tap or .stl file');
                pause(1);
                delete(h);
                [file,path,~]=uigetfile({'*.tap';'*.stl'},...
                    'Export file','lastName_firstName_type_yyyymmdd');
            end
            if strcmp(file(end-3:end),'.tap')
                gcode_file = [path file];
                exportGCode( hObject, gcode_file );
            elseif strcmp(file(end-3:end),'.stl');
                return
            end
        else
            errordlg('Load file');
        end
    end

% OPEN LIMBREVOLUTION.CAD HELP DOCUMENT
    function goToHelp( hJava, hEventData )
        winopen('./Manual/limbRevolutionCADHelp.pdf');
    end

% GOT TO SOURCE CODE AND DOCUMENTATION
    function goToGitHub( hJava, hEventData )
        url = 'https://github.com/fosnigtr/limbRevolutionCAD/wiki';
        web(url,'-browser')
    end

% OPEN LIMBREVOLUTION.PRINT HELP DOCUMENT
    function goToPrintProjectHelp( hJava, hEventData )
        winopen('./Manual/limbRevolutionPrintHelp.pdf');
    end

% EXIT LIMBREVOLUTION.CAD
    function closelimbRevCAD( hJava, hEventData )
        selection = questdlg('Exit limbRevolution.CAD? Your work won''t be saved.',...
            '',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                delete(hObject);
                % FIGURE THIS OUT LATER-TYLER FROM THE PAST :)
                %                 delete(jFrame);
            case 'No'
                return
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOOLS NAVIGATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET ANGULAR ALIGNMENT
    function getAlign( hJava, hEventData )
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            switch toggleAlign
                case true
                    set(hObject,'WindowButtonMotionFcn','');
                    setAngularAlignment( hObject );
                    set(hObject,'WindowButtonMotionFcn',{@handleMouseMove});
                    toggleAlign = false;
                case false
                    toggleAlign = true;
            end
        else
            return;
        end
    end

% EXTEND MODEL
    function getExtend( hJava, hEventData )
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            switch toggleExtend
                case true
                    LANDMARK = true;
                    extendModel( hObject );
                    toggleExtend = false;
                    LANDMARK = false;
                case false
                    toggleExtend = true;
            end
        else
            return;
        end
    end

% ADJUST MODEL CIRCUMFERENCE
    function getAdjust( hJava, hEventData )
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            switch toggleAdjust
                case true
                    adjustCir( hObject );
                    toggleAdjust = false;
                case false
                    toggleAdjust = true;
            end
        else
            return;
        end
    end

% DRAW TRIM LINES
    function getTrimLines( hJava, hEventData )
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            switch toggleTrimLine
                case true
                    trimLine( hObject );
                    set(hObject,'WindowButtonDownFcn',{@handleMouseDown});
                    toggleTrimLine = false;
                case false
                    toggleTrimLine = true;
            end
        else
            return;
        end
    end

% SET ADAPTER
    function getAdapter( hJava, hEventData )
        model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            switch toggleCylAdap
                case true
                    addCylAdap( hObject );
                    toggleCylAdap = false;
                case false
                    toggleCylAdap = true;
            end
        else
            return;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMPLATE NAVIGATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function getLinerTemplate( hJava, hEventData )
        % This function builds the inner and outer molds for a Revolution
        % liner. The inner and outer molds are based on a imported model.
        
       model = guidata(hObject);
        if any(strcmp('data',fieldnames(model)))
            %% UPDATE MODEL HORIZONTAL ALINGMENT
            computeCentroid( hObject );
            
            %% UPDATE ANGULAR ALINGMENT
            % *************************CHECK WITH BRAD*********************************
            % When he does the angular alignment does he look at the entire model or
            % the bottom third, quarter, or etc.
            % Note: Finish debugging accuracy algorithm
            % *************************************************************************
            % SET ANGULAR ALIGNMENT
            toggleAlign = true;
            getAlign([],[]);
            
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
            model.guiPerRed = model.guiPerRed(2:end,:); % don't adjust the last slice
            
            % SAVE DATA
            guidata( hObject , model );
            
            % ADJUST CIRCUMFERENCE
            toggleAdjust = true;
            getAdjust([],[]);
            
            %% SAVE MODEL FOR INNER MOLD MODIFICATIONS
            innerMoldData = model.data;
            innMoldSliceHeights = model.sliceHeights;
            
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
            model.guiPerRed = model.guiPerRed(model.numSlicePoints+1:end,:);
            
            % SAVE DATA
            guidata(hObject,model);
            
            % APPLY LINER THICKNESS PROFILE
            toggleAdjust = true;
            getAdjust([],[]);
            
            %% ADD CYLINDIRCAL ADAPTER
            toggleCylAdap = true;
            getAdapter([],[]);
            
            %% EXTEND MOLD
            % GET DATA INFORMATION
            model = guidata(hObject);
            
            % SET EXTEND TO VALUES
            modelHeight = model.data(end,end);
            modelEndHeight = model.data(1,3);
            model.guiZEnvelope = 600;
            model.guiExtend = model.guiZEnvelope - modelHeight; % 600 mm is the printer z envelope
            model.guiExtendPoint1 = [0 0 modelHeight]; % modelEndHeight
            model.guiExtendPoint2 = [0 0 modelHeight];
            
            % SAVE DATA
            guidata(hObject,model);
            
            % EXTEND MODEL
            extendLinerModel( hObject );
            
            %% ADD MOLD KEYS
            % GET DATA INFORMATION
            model = guidata(hObject);
            
            % USER DEFINED VALUES
            model.guiMoldKeysOffSet = 50; % mm
            guidata(hObject,model);
            
            % GET MOLD KEYS
            addMoldKeys( hObject );
            
            % ADD MOLD KEYS
            toggleAdjust = true;
            getAdjust([],[]);
            
            %% SAVE OUTER MOLD
            model = guidata(hObject);
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
            model.data = innerMoldData;
            model.sliceHeights = innMoldSliceHeights;
            
            % USER DEFINED VARIABLES
            cap1 = 37.5; cap2 = 40; cap3 = 50; % mm
            model.capHeight = 25; % mm
            model.capSet = cat(2 ,cap1, cap2, cap3);
            
            % SAVE DATA
            guidata(hObject,model);
            
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
            model.guiExtendPoint1 = [0 0 modelHeight];
            model.guiExtendPoint2 = [0 0 modelHeight];
            
            % SAVE DATA
            guidata(hObject,model);
            
            % EXTEND MODEL
            extendLinerModel( hObject );
            
            %% ADD MOLD KEYS
            % GET DATA INFORMATION
            model = guidata(hObject);
            
            % USER DEFINED VALUES
            model.guiMoldKeysOffSet = 50; % mm
            guidata(hObject,model);
            
            % GET MOLD KEYS
            addMoldKeys( hObject );
            
            % ADD TAPER TO INNER MOLD KEYS
            model = guidata(hObject);
            numSlices = size(model.guiPerRed,1)/model.numSlicePoints;
            innerKeyCirExtend = zeros(model.numSlicePoints,numSlices,2);
            window = round(numSlices/2):numSlices;
            tmp = linspace(0,.05,length(window));
            tmp = repmat(tmp,model.numSlicePoints,1);
            tmp = cat(3, tmp, tmp);
            innerKeyCirExtend(:,window,:) = tmp;  % mm
            tmpData = reshape(model.guiPerRed(:,1:2),model.numSlicePoints,numSlices,2);
            model.guiPerRed = tmpData + innerKeyCirExtend;
            model.guiPerRed = reshape(model.guiPerRed,model.numSlicePoints*numSlices,2);
            guidata(hObject, model);
            
            % ADD MOLD KEYS
            toggleAdjust = true;
            getAdjust([],[]);
            
            %% SAVE INNER MOLD
            model = guidata(hObject);
            [file,path] = uiputfile('.mat','Save model as .mat','INNERMOLD_lastName_firstName_yyyymmdd');
            model.fnMat = file;
            model.pnMat = path;
            save([model.pnMat, model.fnMat],'model');
        else
            return;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSEMBLY TOOLS NAVIGATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function getAssembly( hJava, hEventData )
        % LOAD INNER MOLD
        [fn,pn,~] = uigetfile('.mat','Open INNERMOLD.mat file');
        output = open([pn,fn]);
        model = guidata(hObject);
        model = output.model;
        
        % SAVE DATA
        guidata(hObject,model);
        
        % CENTER MODEL
        computeCentroid( hObject );
        
        % CLEAR CANVAS
        cla;
        
        % INITIALIZE PATCH
        model.handlePatch = patch('Faces',model.faces,'Vertices',model.data);
        light('Style','infinite');
        model.hLight = camlight('headlight');
        set(model.handlePatch,'FaceColor',[0 106/255 255/255]);
        %         model.tmpLandmarks = ones(1,model.numFaces);
        %         set(model.handlePatch,'CData',model.tmpLandmarks);
        set(model.handlePatch,'CDataMapping','scaled');
        set(model.handlePatch,'FaceLighting','gouraud');
        set(model.handlePatch,'EdgeColor','None');
        set(model.handlePatch,'FaceAlpha',1);
        set(model.handlePatch,'EdgeAlpha',1);
        
        %% LOAD OUTER MOLD
        [fn,pn,~] = uigetfile('.mat','Open OUTERMOLD.mat file');
        output = open([pn,fn]);
        model = guidata(hObject);
        model = output.model;
        
        % SAVE DATA
        guidata(hObject,model);
        
        % CENTER MODEL
        computeCentroid( hObject );
        
        % SAVE DATA
        guidata(hObject,model);
        
        % INITIALIZE PATCH
        model.handlePatch = patch('Faces',model.faces,'Vertices',model.data);
        light('Style','infinite');
        model.hLight = camlight('headlight');
        set(model.handlePatch,'FaceColor',[176/255 59/255 23/255]);
        %         model.tmpLandmarks = ones(1,model.numFaces);
        %         set(model.handlePatch,'CData',model.tmpLandmarks);
        set(model.handlePatch,'CDataMapping','scaled');
        set(model.handlePatch,'FaceLighting','gouraud');
        set(model.handlePatch,'EdgeColor','None');
        set(model.handlePatch,'FaceAlpha',.3);
        set(model.handlePatch,'EdgeAlpha',1);
        
        % SET ML, AP AND HEIGHT INDICATOR UI CALLBACKS
        set(hObject,'WindowButtonDownFcn',{@handleMouseDown});
        set(hObject,'WindowButtonUpFcn',{@handleMouseUp});
        set(hObject,'WindowButtonMotionFcn',{@handleMouseMove});
        set(hObject,'KeyPressFcn',{@handleKeyDown});
        set(hObject,'KeyReleaseFcn',{@handleKeyUp});
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HANDLE CALLBACK EVENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function handleMouseDown( hObject, varArgIn )
        model = guidata(hObject);
        persistent chk
        % CHECK FOR SINGLE OR DOUBLE CLICK
        if isempty(chk)
            chk = 1;
            pause(0.2);
            if chk == 1
                chk = [];
                tmp = get(hObject,'CurrentPoint');
                model.lastMouseX = tmp(1);
                model.lastMouseY = tmp(2);
                model.mouseDown = true;
                guidata(hObject, model);
            end
        else
            chk = [];
            if LANDMARK
                [~,~,~,idxLandmark] = getCord(hObject);
                tmpIdx = round(idxLandmark/model.numSlicePoints); % round vertex index to the nearest slice index (results in 0.9 mm resolution)
                idxLandmark = (tmpIdx-1) * model.numSlicePoints + 1;
                model.tmpLandmarks(idxLandmark:idxLandmark+model.numSlicePoints-1)=0;
                guidata(hObject,model);
                set(model.handlePatch,'CData',model.tmpLandmarks);
                drawnow;
            end
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
    end

    function handleMouseUp( hObject, varArgIn )
        model = guidata(hObject);
        model.mouseDown = false;
        guidata(hObject,model);
    end

    function handleKeyDown( hObject, varArgIn )
        model = guidata(hObject);
        model.currentlyPressedKeys = varArgIn.Key;
        guidata(hObject,model);
        handleKeys(hObject);
    end

    function handleKeyUp( hObject, varArgIn )
        model = guidata(hObject);
        model.currentlyPressedKeys = false;
        guidata(hObject,model);
    end

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
            zm = 1.01;
            camzoom(zm);
            return;
        elseif strcmp(model.currentlyPressedKeys,'subtract');
            zm = 0.99;
            camzoom(zm);
            return;
        end
        model.newRotationMatrix = roty(model.z)*rotx(model.x);
        guidata(hObject,model);
        tick(hObject);
    end

    function tick( hObject )
        model = guidata(hObject);
        camorbit(model.deltaX,model.deltaY);
        camlight(model.hLight,'headlight');
    end

% Note: use jFrame.dispose() to close jFrame, otherwise Matlab will exit!
end

