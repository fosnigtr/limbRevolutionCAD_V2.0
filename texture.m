function texture( hObject )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

model = guidata(hObject);

% SET DEFAULTS
orgData = model.data;
orgSliceHeights = model.sliceHeights;
textureDepth =  .9;
textureHorzSpacing = 1;
textureVertSpacing = 1;

prompt();
    function prompt()
        hPrompt = figure;
        axis off;
        name = 'Texture model';
        set(hPrompt,'Resize','off');
        set(hPrompt,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
        set(hPrompt,'name',name);
        set(hPrompt,'NumberTitle','off');
        set(hPrompt,'MenuBar','none');
        set(hPrompt,'ToolBar','none');
        hObjectPos=get(hObject,'Position');
        set(hPrompt,'Position',[hObjectPos(1)-329 hObjectPos(2) 329 200]);
        set(hPrompt,'CloseRequestFcn',@closehPrompt);
        
        % PUSH BUTTON (SELECT TOP OF SECTION)
        hTopOfSection = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 170 300 20],...
            'string','0','string','Select top of section',...
            'Callback',@topCallBack);
        
        % PUSH BUTTON (SELECT BOTTOM OF SECTION)
        hButtomOfSection = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 140 300 20],...
            'string','0','string','Select bottom of section',...
            'Callback',@bottomCallBack);
        
        % TEXTURE MODEL BY (TEXT)
        hExtendBy = uicontrol('style','text','units',...
            'pixel','position',[15 110 140 20],...
            'string','% reduction:');
        
        % TEXTURE MODEL BY (UI INPUT)
        hExtendBy = uicontrol('style','edit','units',...
            'pixel','position',[175 110 140 20],...
            'string','.1',...
            'Callback',@textureDepthCallBack);
        
        % TEXTURE HORZ. SPACING (TEXT)
        hExtendBy = uicontrol('style','text','units',...
            'pixel','position',[15 80 140 20],...
            'string','Relative horz. spacing:');
        
        % TEXTURE HORZ. SPACING (UI INPUT)
        hExtendBy = uicontrol('style','edit','units',...
            'pixel','position',[175 80 140 20],...
            'string','1',...
            'Callback',@textureHorzSpaceCallBack);
        
        % TEXTURE VERT. SPACING BY (TEXT)
        hExtendBy = uicontrol('style','text','units',...
            'pixel','position',[15 50 140 20],...
            'string','Relative vert. spacing:');
        
        % TEXTURE VERT. SPACING (UI INPUT)
        hExtendBy = uicontrol('style','edit','units',...
            'pixel','position',[175 50 140 20],...
            'string','1',...
            'Callback',@textureVertSpacingCallBack);
        
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
        
        function textureDepthCallBack( handle, event )
%             model.data = orgData;
%             guidata(hObject,model);
%             % DRAW SCENE
%             set(model.handlePatch,'vertices',model.data);
%             drawnow;
            textureDepth = 1-str2double(handle.String);
            addTexture(handle);
        end
        
        function textureHorzSpaceCallBack( handle, event )
%             model.data = orgData;
%             guidata(hObject,model);
%             % DRAW SCENE
%             set(model.handlePatch,'vertices',model.data);
%             drawnow;
            textureHorzSpacing = str2double(handle.String);
            addTexture(handle);
        end
        
        function textureVertSpacingCallBack( handle, event )
%             model.data = orgData;
%             guidata(hObject,model);
%             % DRAW SCENE
%             set(model.handlePatch,'vertices',model.data);
%             drawnow;
            textureVertSpacing = str2double(handle.String);
            addTexture(handle);
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
        
        function addTexture( handle )
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
                bottomOfSection = locLandmark(1);
                topOfSection = locLandmark(2*model.numSlicePoints);
                % GET SECTION TO EXTEND
                section = model.data(bottomOfSection:topOfSection,1:2);
                % GENERATE TEXTURE
                model.guiPerRed = ones(length(model.data),2);
                window = bottomOfSection:textureVertSpacing:topOfSection;
                window(1:textureHorzSpacing:end) = ...
                    window(1:textureHorzSpacing:end);
                model.guiPerRed(window,1:2) = ...
                    model.guiPerRed(window,1:2) .* textureDepth;
                model.guiPerRed = model.guiPerRed(model.numSlicePoints+1:end,1:2);
                % SAVE DATA
                guidata(hObject,model);
                % APPLY TEXTURE
                adjustCir( hObject );
            end
        end
    end
end

