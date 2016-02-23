function cutModel( hObject )
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
        name = 'Cut model';
        set(hPrompt,'Resize','off');
        set(hPrompt,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
        set(hPrompt,'name',name);
        set(hPrompt,'NumberTitle','off');
        set(hPrompt,'MenuBar','none');
        set(hPrompt,'ToolBar','none');
        hObjectPos=get(hObject,'Position');
        set(hPrompt,'Position',[hObjectPos(1)-329 hObjectPos(2) 330 110]);
        set(hPrompt,'CloseRequestFcn',@closehPrompt);
        
        % PUSH BUTTON (SELECT TOP OF SECTION)
        hSection = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 80 300 20],...
            'string','0','string','Select cutting plane',...
            'Callback',@sectionCallBack);
        
        % PUSH BUTTON (CUT)
        hCut = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 50 300 20],...
            'string','0','string','Cut',...
            'Callback',@cutCallBack);
        
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
        
        function sectionCallBack( handle, event )
            % DUMMY FUNCTION
        end
        
        function cutCallBack( handle, event )
            cut( handle );
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
        
        function cut( handle )
            % CHECK THAT THE BOTTOM AND TOP SECTIONS ARE SELECTED
            model = guidata(hObject);
            locLandmark = find(model.tmpLandmarks == 0);
            numLandmarks = round(length(locLandmark)...
                /model.numSlicePoints);
            if numLandmarks > 1
                errordlg('Choose one landmark');
                model.tmpLandmarks(locLandmark) = 1;
                set(model.handlePatch,'CData',model.tmpLandmarks);
                drawnow;
                guidata(hObject,model);
            elseif numLandmarks == 1
                section = locLandmark(1);
                % CUT MODEL
                model.data = model.data(section:end,:);
                model.data(:,3) = model.data(:,3) - model.data(1,3);
                 % UPDATE DATA
                model.sliceHeights = model.data(1:model.numSlicePoints:end-model.numSlicePoints+1,3);
                model.numSliceHeights = size(model.data,1);
                % RE-MESH MODEL
                model.faces = bsxfun(@plus, ones(model.numSlicePoints*(length(model.sliceHeights)-1)-1,4),...
                    (0:(model.numSlicePoints*(length(model.sliceHeights)-1)-2))');
                model.faces = bsxfun(@plus,model.faces,[0,1,1+model.numSlicePoints,model.numSlicePoints]);
                % UPDATE CMAP
                model.numFaces = size(model.faces,1);
                model.tmpLandmarks = ones(1,model.numFaces);
%                 model.tmpLandmarks([model.numSlicePoints*numPoints+1+locLandmark, locLandmark]) = 0;
                % DRAW SCENE
                set(model.handlePatch,'vertices',model.data,'faces',model.faces,'CData',model.tmpLandmarks);
                drawnow;
                % SAVE DATA
                guidata(hObject,model);
            end
        end
    end
end




