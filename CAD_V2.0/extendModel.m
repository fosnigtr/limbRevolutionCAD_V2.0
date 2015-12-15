function extendModel( hObject )
% This function allows the user to extend the model between to landmarks
% which are defined by the user. 
model = guidata(hObject);

% SET DEFAULTS
orgData = model.data;
orgSliceHeights = model.sliceHeights;

prompt();
    function prompt()
        hPrompt = figure;
        axis off;
        name = 'Extend model';
        set(hPrompt,'Resize','off');
        set(hPrompt,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
        set(hPrompt,'name',name);
        set(hPrompt,'NumberTitle','off');
        set(hPrompt,'MenuBar','none');
        set(hPrompt,'ToolBar','none');
        hObjectPos=get(hObject,'Position');
        set(hPrompt,'Position',[hObjectPos(1)-329 hObjectPos(2) 329 140]);
        set(hPrompt,'CloseRequestFcn',@closehPrompt);
        
        % PUSH BUTTON (SELECT TOP OF SECTION)
        hTopOfSection = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 110 300 20],...
            'string','0','string','Select top of section',...
            'Callback',@topCallBack);
        
        % PUSH BUTTON (SELECT BOTTOM OF SECTION)
        hButtomOfSection = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 80 300 20],...
            'string','0','string','Select bottom of section',...
            'Callback',@bottomCallBack);
        
        % EXTEND MODEL BY (TEXT)
        hExtendBy = uicontrol('style','text','units',...
            'pixel','position',[15 50 140 20],...
            'string','Extend by (mm):');
        
        % EXTEND MODEL BY (UI INPUT)
        hExtendBy = uicontrol('style','edit','units',...
            'pixel','position',[175 50 140 20],...
            'string','0',...
            'Callback',@extendByCallBack);
        
        % PUSH BUTTON (OK)
        hOK = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 20 150 20],...
            'string','0','string','OK',...
            'Callback',@OK);
        
        % PUSH BUTTON (Cancel)
        hCancel = uicontrol('style','pushbutton','units',...
            'pixel','position',[165 20 150 20],...
            'string','0','string','Cancel',...
            'Callback',@Cancel);
        
        % WAIT FOR USER INPUT
        uiwait;
        
        function topCallBack( handle, event )
            % DUMMY FUNCTION
        end
        
        function bottomCallBack( handle, event )
            % DUMMY FUNCTION
        end
        
        function extendByCallBack( handle, event )
            extend(handle);
        end
        
        function OK( handle, event )
            model = guidata(hObject);
            % UPDATE COLOR MAP
            model.numFaces = size(model.faces,1);
            model.tmpLandmarks = ones(1,model.numFaces);
            set(model.handlePatch,'CData',model.tmpLandmarks);
            % SAVE DATA
            guidata(hObject,model);
            % CLEAN UP
            delete(hPrompt);
            uiresume;
        end
        
        function Cancel( handle, event )
            model = guidata(hObject);
            % UNDO MODIFACTIONS
            model.data = orgData;
            model.sliceHeights = orgSliceHeights;
            % RE-MESH MODEL
            model.faces = bsxfun(@plus, ones(model.numSlicePoints*(length(model.sliceHeights)-1)-1,4),...
                (0:(model.numSlicePoints*(length(model.sliceHeights)-1)-2))');
            model.faces = bsxfun(@plus,model.faces,[0,1,1+model.numSlicePoints,model.numSlicePoints]);
            % UPDATE COLOR MAP
            model.numFaces = size(model.faces,1);
            model.tmpLandmarks = ones(1,model.numFaces);
            set(model.handlePatch,'vertices',model.data,'faces',model.faces,...
                'CData',model.tmpLandmarks);
            % SAVE DATA
            guidata(hObject,model);
            % CLEAN UP
            delete(hPrompt);
            uiresume;
        end
        
        function closehPrompt( handle, event )
            % FORCE USER TO USE THE CANCEL BUTTON
        end
        
        function extend( handle )
            % CHECK THAT THE BOTTOM AND TOP SECTIONS ARE SELECTED
            model = guidata(hObject);
            locLandmark = find(model.tmpLandmarks == 0);
            numLandmarks = round(length(locLandmark)...
                /model.numSlicePoints);
            if numLandmarks > 2
                errordlg('Choose one or two landmarks');
                model.tmpLandmarks(locLandmark) = 1;
                set(model.handlePatch,'CData',model.tmpLandmarks);
                drawnow;
                guidata(hObject,model);
            elseif numLandmarks == 1
                % code
            elseif numLandmarks == 2
                extendBy = round(str2double(handle.String)/model.sliceHeightStep)*model.sliceHeightStep; % extend by multiples of height resolution (mm)
                bottomOfSection = locLandmark(1);
                topOfSection = locLandmark(2*model.numSlicePoints);
                % GET SECTION BELOW AND ABOVE SECTION SELECTED TO
                % EXTEND. CATCH INSTANCES WHERE THE LANDMARK IS THE FIRST OR LAST SLICE
                if bottomOfSection == 1
                    orgBottom = [];
                elseif bottomOfSection == model.numSlicePoints*(model.numSliceHeights-1)+1
                    orgBottom = [];
                else
                    orgBottom = model.data(1:bottomOfSection-1,:);
                end
                if topOfSection == model.numSlicePoints
                    orgTop = [];
                elseif topOfSection == model.numSlicePoints*model.numSliceHeights
                    orgTop = [];
                else
                    orgTop = model.data(topOfSection+1:end,:);
                    orgTop(:,3) = orgTop(:,3)+extendBy;
                end
                % GET SECTION TO EXTEND
                section = model.data(bottomOfSection:topOfSection,:);
                numPoints = round(extendBy/model.sliceHeightStep); % extend in steps equal to slice height step resolution
                % EXTEND SECTION
                tmpLen = size(section,1);
                tmpNumSliceHeights = tmpLen/model.numSlicePoints;
                tmpNewNumSliceHeights = tmpNumSliceHeights+numPoints;
                v = 1:tmpNumSliceHeights;
                xq = linspace(1,tmpNumSliceHeights,tmpNewNumSliceHeights);
                % RESHAPE THE NEW X AND Y SECTIONS FOR INTERPOLATION
                tmpSectionX = reshape(section(:,1),model.numSlicePoints,tmpNumSliceHeights);
                tmpSectionY = reshape(section(:,2),model.numSlicePoints,tmpNumSliceHeights);
                tmpSectionZ = reshape(section(:,3),model.numSlicePoints,tmpNumSliceHeights);
                % EXTEND SECTION
                newSectionX = interp1(v,tmpSectionX',xq)';
                newSectionY = interp1(v,tmpSectionY',xq)';
%                 newSectionZ = interp1(v,tmpSectionZ',xq)';
                newSectionZ = linspace(tmpSectionZ(1,1),tmpSectionZ(1,end)+extendBy,tmpNewNumSliceHeights);
                newSectionZ = repmat(newSectionZ,model.numSlicePoints,1);
                newSectionX = reshape(newSectionX,model.numSlicePoints*tmpNewNumSliceHeights,1);
                newSectionY = reshape(newSectionY,model.numSlicePoints*tmpNewNumSliceHeights,1);
                newSectionZ = reshape(newSectionZ,model.numSlicePoints*tmpNewNumSliceHeights,1);
                model.data = cat(1,orgBottom,[newSectionX, newSectionY, newSectionZ],...
                    orgTop);
                % UPDATE DATA
                %                 model.sliceHeights =
                % RE-MESH MODEL
                model.faces = bsxfun(@plus, ones(model.numSlicePoints*(length(model.sliceHeights)-1)-1,4),...
                    (0:(model.numSlicePoints*(length(model.sliceHeights)-1)-2))');
                model.faces = bsxfun(@plus,model.faces,[0,1,1+model.numSlicePoints,model.numSlicePoints]);
                % UPDATE CMAP
                model.numFaces = size(model.faces,1);
                model.tmpLandmarks = ones(1,model.numFaces);
                model.tmpLandmarks([model.numSlicePoints*numPoints+1+locLandmark, locLandmark]) = 0;
                % DRAW SCENE
                set(model.handlePatch,'vertices',model.data,'faces',model.faces);
                drawnow;
            end
        end
    end
end