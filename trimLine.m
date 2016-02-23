function trimLine( hObject )
% This function allows the user to draw trim lines on the model. The trim
% lines are then applied to the model by adjust the circumference of the
% model above the trim lines drawn by the user. 
model = guidata(hObject);

% SET DEFAULTS
idx = 0;
trimLineExpandFlag = false;
orgdata = model.data;
x = []; y = []; z = [];
firstTime = true;
orgData = model.data;
orgSliceHeights = model.sliceHeights;

prompt();
    function prompt()
        hPrompt = figure;
        axis off;
        name = 'Trim lines';
        set(hPrompt,'Resize','off');
        set(hPrompt,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
        set(hPrompt,'name',name);
        set(hPrompt,'NumberTitle','off');
        set(hPrompt,'MenuBar','none');
        set(hPrompt,'ToolBar','none');
        hObjectPos=get(hObject,'Position');
        set(hPrompt,'Position',[hObjectPos(1)-329 hObjectPos(2) 329 121]);
        set(hPrompt,'CloseRequestFcn',@closehPrompt);
        
        % PUSH BUTTON (START ADD TRIM LINES)
        hDrawTrimLines = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 95 300 20],...
            'string','0','string','Draw trim lines',...
            'Callback',@drawTrimLines);
        
        % TRIMLINE EXTEND BY
        hCycAdapHeight = uicontrol('style','text','units',...
            'pixel','position',[15 65 150 20],...
            'string','Extend by (mm)');
        
        % TRIMLINE EXTEND BY INPUT
        hCycAdapHeightInput = uicontrol('style','edit','units',...
            'pixel','position',[170 65 20 20],...
            'string','2',...
            'Callback',@extendTrimLines);
        
        % PUSH BUTTON (ADD TRIM LINES)
        hAddTrimLines = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 35 300 20],...
            'string','0','string','Add trim lines',...
            'Callback',@addTrimLines);
        
        % PUSH BUTTON (OK)
        hOK = uicontrol('style','pushbutton','units',...
            'pixel','position',[15 5 140 20],...
            'string','0','string','OK',...
            'Callback',@OK);
        
        % PUSH BUTTON (CANCEL)
        hCancel = uicontrol('style','pushbutton','units',...
            'pixel','position',[176 5 140 20],...
            'string','0','string','Cancel',...
            'Callback',@Cancel);
        
        % WAIT FOR USER INPUT
        uiwait;
        
        function drawTrimLines( handle, event )
            set(hObject,'WindowButtonDownFcn',{@draw});
        end
        
        function extendTrimLines( handle, event )
            model = guidata(hObject);
            model.trimLineExpand = str2double(handle.String);
            trimLineExpandFlag = true;
            guidata(hObject,model);
        end
        
        function addTrimLines( handle, event )
            model = guidata(hObject);
            if trimLineExpandFlag == true
                if any(strcmp('trimLines',fieldnames(model)))
                    model.data = orgdata;
                    tmp = find(model.trimLines(:,3)>0);
                    model.trimLines = model.trimLines(tmp,:);
                    theta = atand(model.trimLines(1,2)/model.trimLines(1,1));
                    theta = round(theta/model.angleStep);
                    numSlices = model.numSliceHeights/model.numSlicePoints;
                    [m n] = size(model.trimLines);
                    v = 1:m;
                    xq = linspace(1,m,model.numSlicePoints);
                    % INTERPOLATE TRIM LINE X, Y AND Z DATA
                    newTLZ = interp1(v,model.trimLines(:,3),xq);
                    newTLX = interp1(v,model.trimLines(:,1),xq);
                    newTLY = interp1(v,model.trimLines(:,2),xq);
                    [~, loc] = min(abs(atan2d(newTLY,newTLX)));
                    newTLZ = circshift(newTLZ',model.numSlicePoints-loc);
                    % ADD TRIM LINES
                    tmpDataHeight = reshape(model.data(:,3),model.numSlicePoints,...
                        numSlices);
                    model.guiPerRed = model.trimLineExpand * bsxfun(@ge,tmpDataHeight,newTLZ);
                    tmpData = reshape(model.data(:,1:2),model.numSlicePoints,numSlices,2);
                    model.guiPerRed = bsxfun(@times,abs(tmpData)./tmpData,model.guiPerRed); % unit vector
                    model.guiPerRed = 1+(model.guiPerRed./tmpData);
                    model.guiPerRed = reshape(model.guiPerRed,model.numSlicePoints*numSlices,2);
                    model.guiPerRed = model.guiPerRed(model.numSlicePoints+1:end,:); % don't adjust the last slice. This keeps the distal end closed.
                    guidata(hObject,model);
                    adjustCir( hObject );
                    % DRAW SCENE
                    model = guidata(hObject);
                    set(model.handlePatch,'vertices',model.data);
                    drawnow;
                else
                    % CATCH NO TRIM LINE ERROR
                    errordlg('Draw trim line');
                end
            else
                % CATCH NO EXPAND VALUE
                errordlg('Enter expand value');
            end
        end
        
        function draw( hObject, varArgIn )
            model = guidata(hObject);
            idx = idx + 1;
            [xn,yn,zn,~] = getCord(hObject);
            x = [x, xn];
            y = [y, yn];
            z = [z, zn];
            if firstTime == false
                set(model.hl,'XData',x,'YData',y,'ZData',z,...
                        'Marker','.','Color','m','MarkerSize',20);
            elseif firstTime == true
                    model.hl = line('XData',x,'YData',y,'ZData',z,...
                        'Marker','.','Color','m','MarkerSize',20);
                    firstTime = false;
            end
            drawnow;
            model.trimLines(idx,1) = xn;
            model.trimLines(idx,2) = yn;
            model.trimLines(idx,3) = zn;
            guidata(hObject,model);
        end
        
        function OK( handle, event )
            model = guidata(hObject);
            % SAVE DATA
            guidata(hObject,model);
            % CLEAN
            if any(strcmp('hl',fieldnames(model)))
                delete(model.hl);
            end
            delete(hPrompt);
            uiresume;
        end
        
        function Cancel( handle, event )
            model = guidata(hObject);
            % UNDO MODIFICATIONS
            model.data = orgData;
            model.sliceHeights = orgSliceHeights;
            % SAVE DATA
            guidata(hObject, model);
            % DRAW SCENE
            set(model.handlePatch,'vertices',model.data);
            drawnow;
            % CLEAN UP
            if any(strcmp('hl',fieldnames(model)))
                delete(model.hl);
            end
            delete(hPrompt);
            uiresume;
        end
        
        function closehPrompt( handle, event )
            % FORCE USER TO USE CANCEL BUTTON
        end
        
    end
end

