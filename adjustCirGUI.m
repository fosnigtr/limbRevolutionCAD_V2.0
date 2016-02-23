function adjustCirGUI( hObject )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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
        name = 'Adjust model circ.';
        set(hPrompt,'Resize','on');
        set(hPrompt,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
        set(hPrompt,'name',name);
        set(hPrompt,'NumberTitle','off');
        set(hPrompt,'MenuBar','none');
        set(hPrompt,'ToolBar','none');
        hObjectPos=get(hObject,'Position');
        set(hPrompt,'Position',[hObjectPos(1)-329 hObjectPos(2) 329 110]);
        set(hPrompt,'CloseRequestFcn',@closehPrompt);
        
        % PUSH BUTTON (SELECT CROSS SECTIONs TO ADJUST)
        hButtomOfSection = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 80 300 20],...
            'string','0','string','Select cross sections',...
            'Callback',@crosssecCallBack);
        
        % ADJUST CROSS SECTIONS
        hAdjustByCallBack = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 50 300 20],...
            'string','0','string','Adjust sections',...
            'Callback',@adjustByCallBack);
        
        %         % EXTEND MODEL BY (TEXT)
        %         hExtendBy = uicontrol('style','text','units',...
        %             'pixel','position',[15 50 140 20],...
        %             'string','Adjust by (%):');
        
        %         % EXTEND MODEL BY (UI INPUT)
        %         hExtendBy = uicontrol('style','edit','units',...
        %             'pixel','position',[175 50 140 20],...
        %             'string','0',...
        %             'Callback',@adjustByCallBack);
        
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
        
        function crosssecCallBack( handle, event )
            % DUMMY FUNCTION
        end
        
        function adjustByCallBack( handle, event )
            adjust(handle);
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
        
        function adjust( handle )
            % CHECK THAT THE BOTTOM AND TOP SECTIONS ARE SELECTED
            model = guidata(hObject);
            locLandmark = find(model.tmpLandmarks == 0);
            model.numLandmarks = round(length(locLandmark)...
                /model.numSlicePoints);
            locLandmark = round(locLandmark./model.numSlicePoints);
            if model.numLandmarks < 1
                errordlg('Choose at least one landmark');
                model.tmpLandmarks(locLandmark) = 1;
                set(model.handlePatch,'CData',model.tmpLandmarks);
                drawnow;
                guidata(hObject,model);
            else
                % SAVE DATA
                guidata(hObject,model);
                % APPLY ADJUSTMENT
                getPerAdjust();
                x = cat(2,model.sliceHeights(1),locLandmark,floor(max(model.sliceHeights)));
                f = cat(2,1,model.landmarkPerAdj,1);
                model.guiPerRed = interpn(x,f,model.sliceHeights);
                % GET SECTION TO EXTEND
%                 [a, ~, ~] = size(model.data);
%                 model.guiPerRed = ones(a,2);
%                 model.guiPerRed(crossSection:crossSection+model.numSlicePoints,1:2) = ...
%                     model.guiPerRed(crossSection:crossSection+model.numSlicePoints,1:2).*adjustBy;
%                 model.guiPerRed = model.guiPerRed(model.numSlicePoints+1:end,:);
                % SAVE DATA
                guidata(hObject,model);
                % APPLY % ADJUSTMENT
                adjustCir(hObject);
            end
        end
        
        function getPerAdjust()
            % GET PERCENT ADJUSTMENT AT EACH LANDMARK
            model = guidata(hObject);
            dlgTitle = 'Adjust %';
            numLines = 1;
            for idx = 1:model.numLandmarks
                string = sprintf('Landmark %2.0f',idx);
                prompt{idx} = string;
                defaultAns{idx} = num2str(.9);
            end
            model.landmarkPerAdj = inputdlg(prompt,dlgTitle,numLines,defaultAns);
            for idx = 1:model.numLandmarks
                landmarkPerAdj(idx) = str2double(cell2mat(model.landmarkPerAdj(1)));
            end
            model.landmarkPerAdj = landmarkPerAdj;
            % SAVE DATA
            guidata(hObject,model);
        end
    end
end


