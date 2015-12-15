function setAngularAlignment( hObject )
%SETANUGULARALIGNMENT Summary of this function goes here
%   Detailed explanation goes here
model = guidata(hObject);

% SET DEFAULTS
set(model.hCoordUI,'string', ['ML = ', 'NA', '(mm), ', ...
    'AP = ', 'NA', '(mm), ', 'Height = ', 'NA', '(mm)']);
orgData = model.data;
orgSliceHeights = model.sliceHeights;

% model.guiTheta0 = 5;
% % Algorithm from Patent US7033327
%
% % DEFINE ICOSAHEDRON
% % vertices
% V = [0        0         0;...
%     0.8507         0    0.5257;...
%     0.2629    0.8090    0.5257;...
%     -0.6882    0.5000    0.5257;...
%     -0.6882   -0.5000    0.5257;...
%     0.2629   -0.8090    0.5257;...
%     0.6882    0.5000    1.3764;...
%     -0.2629    0.8090    1.3764;...
%     -0.8507    0.0000    1.3764;...
%     -0.2629   -0.8090    1.3764;...
%     0.6882   -0.5000    1.3764;...
%     0         0    1.9021];
% % faces
% F = [1     3     2;...
%     1     4     3;...
%     1     5     4;...
%     1     6     5;...
%     1     2     6;...
%     2     3     7;...
%     3     4     8;...
%     4     5     9;...
%     5     6    10;...
%     6     2    11;...
%     7     3     8;...
%     8     4     9;...
%     9     5    10;...
%     10     6    11;...
%     11     2     7;...
%     7     8    12;...
%     8     9    12;...
%     9    10    12;...
%     10    11    12;...
%     11     7    12];
%
% numFaces = size(F,1);
% V = V+model.centroid(3);
%
% % CALCULATE FACE CENTROIDS
% for idx = 1:numFaces
%     faceCentroids(idx,:) = mean(V(F(idx,:),:),1);
% end
%
% % COMPUTE MOMENTS OF INTERIA ABOUT COORDINATE AXES
% Ixx = sum(sum(model.data(:,[2,3]).^2,2),1); % moment of inertia about x-axis
% Iyy = sum(sum(model.data(:,[3,1]).^2,2),1); % moment of inertia about y-axis
% Izz = sum(sum(model.data(:,[1,2]).^2,2),1); % moment of inertia about z-axis
%
% % COMPUTE PRODUCTS OF INERTIA
% Ixy = -sum(prod(model.data(:,[1,2]),2),1); Iyx = Ixy;
% Iyz = -sum(prod(model.data(:,[2,3]),2),1); Izy = Iyz;
% Ixz = -sum(prod(model.data(:,[1,3]),2),1); Izx = Ixz;
%
% % CONTRUCT MOMENT OF INTERIA TENSOR
% I = [Ixx, Ixy, Ixz;...
%     Iyx, Iyy, Iyz;...
%     Izx, Izy, Izz];
%
% % CACULATE MOMENT OF THE MODEL ABOUT EACH AXIS LINE
% for idx = 1:numFaces
%     nHat = faceCentroids(idx,:)/norm(faceCentroids(idx,:));
%     moments(idx) = nHat*I*nHat';
% end
%
% % FIND MOMENT MINIMIZING AXIS AND THE ASSOCIATED AXIS
% [minMoment, locMinMoment] = min(abs(moments));
% momentMinAxis = faceCentroids(locMinMoment,:);
%
% % DETERMINE TRIANGLE VERTEX LINE
% vertexLine = V(F(locMinMoment,1),:);
%
% % DETERMINE ANGLE OF ACCURACY
% cosTheta = dot(vertexLine,momentMinAxis)...
%     /(norm(vertexLine)*norm(momentMinAxis));
% theta = acosd(cosTheta);
%
% % DETERMINE IF ANGLE FOR ROTATION IS GOOD ENOUGH
% % while model.guiTheta0<= theta
% %
% %     % GET FACE VERTICES FOR MOMENT MINIMIZING AXIS
% %     v0 = vertexLine;
% %     v1 = V(F(locMinMoment,2));
% %     v2 = V(F(locMinMoment,3));
% %     sphereRadius = abs(v1);
% %
% %     % COMPUTE MIDPOINTS
% %     m01 = (v0+v1)/2;
% %     m12 = (v1+v2)/2;
% %     m20 = (v2+v0)/2;
% %
% %     % DEFINE NEW VERTICES
% %     V = cat(1,v0,v1,v2,m01,m12,m20);
% %
% %     % COMPUTE RAISED MIDPOINTS
% %     m01Raised = m01 + (m01 - (m01/norm(m01).*sphereRadius));
% %     m12Raised = m12 + (m12 - (m12/norm(m01).*sphereRadius));
% %     m20Raised = m20 + (m20 - (m20/norm(m20).*sphereRadius));
% %
% %     % DEFINE DOME TRIANGLES
% %     T0 = cat(1, v1, m01Raised, m12Raised);
% %     T1 = cat(1, m01Raised, m12Raised, m20Raised);
% %     T2 = cat(1, m12Raised, m20Raised, v2);
% %     T3 = cat(1, m01Raised, m20Raised, v0);
% %     F = [1, 4, 5;...
% %         4, 5, 6;...
% %         5, 6, 3;...
% %         4, 6, 2];
% %
% %     % COMPUTE DOME TRIANGLES CENTROIDS
% %     centroidT = cat(1, mean(T0,1), mean(T1,1),...
% %         mean(T2,1), mean(T3,1));
% %
% %     % CACULATE MOMENT FOR EACH AXIS LINE
% %     for idx = 1:4
% %         moments(idx) = abs(model.modelCentroid .* centroidT(idx,:));
% %     end
% %
% %     % FIND MOMENT MINIMIZING AXIS AND THE ASSOCIATED AXIS
% %     [minMoment, locMinMoment] = min(abs(moments));
% %     momentMinAxis = centroidT(locMinMoment,:);
% %
% %     % DETERMINE TRIANGLE VERTEX LINE
% %     vertexLine = V(F(locMinMoment,1));
% %
% %     % DETERMINE ANGLE OF ACCURACY
% %     cosTheta = dot(vertexLine,momentMinAxis)...
% %         /(norm(vertexLine)*norm(momentMinAxis));
% %     theta = acosd(cosTheta);
% % end
%
% % COMPUTE AXIS ANGLE BETWEEN TWO VECTORS
% % (http://stackoverflow.com/questions/15101103/euler-angles-between-two-3d-vectors0
% momentMinAxis = momentMinAxis/norm(momentMinAxis); % normalized vector
% model.centroid = model.centroid/norm(model.centroid); % normalized vector
% v = cross(momentMinAxis,model.centroid); % axis of rotation
% angle = dot(momentMinAxis,model.centroid)...
%     /(norm(momentMinAxis)*norm(model.centroid)); % angle of rotation
%
% % CONVERT AXIS-ANGLE TO EULER ANGLES ALPHA, BETA, AND GAMMA
% % (WWW.EUCLIDEANSPACE.COM)
% s = sin(angle); c = cos(angle); t = 1 - c;
% x = v(1); y = v(2); z = v(3);
% % north pole singularity detected
% if ((x*y*t + z*s) > 0.998)
%     alpha = 0;
%     beta = 2*atan2(x*sin(angle/2),cos(angle/2));
%     gamma = pi/2;
%     % south pole singularity detected
% elseif ((x*y*t + z*s) < -0.998)
%     alpha = 0;
%     beta = -2*atan2(x*sin(angle/2),cos(angle/2));
%     gamma = -pi/2;
% else
%     alpha = atan2(x*s-y*z*(1-c),1-(x^2+z^2)*(1-c)); % bank
%     beta = atan2(y*s-x*y*(1-c),1-(y^2+z^2)*(1-c)); % heading
%     gamma = asin(x*y*(1-c)+z*s); % attitude
% end
%
% % COMPUTE ROTATION MATRIX
% R = rotx(alpha*180/pi)*roty(beta*180/pi)*rotz(gamma*180/pi);
%
% % MAKE MOMENT MINIMIZING AXIS THE MODEL CENTROID
% for idx = 1:size(model.data,1);
%     model.data(idx,:) = R*model.data(idx,:)';
% end
%
% % TRANSLATE MODEL DISTAL END TO ORIGIN
% model.data(:,3) = model.data(:,3) - min(model.data(:,3));
%
% % SMOOTH OUT HEIGHT DATA
% numSliceHeights = length(model.sliceHeights);
% x = (1:size(model.data,1))';
% b = x\model.data(:,3);
% model.data(:,3) = x * b - b;
% model.sliceHeights = linspace(0,model.data(end,3),numSliceHeights);
%
% SET DEFAULT VALUES FOR ANGULAR ALINGMENT UI
lastThetaX = 0.5;
lastThetaY = 0.5;

% DRAW SCENE
set(model.handlePatch,'vertices',model.data);
drawnow;

% CALL SLIDER UI (ANGULAR ALIGNMENT)
slider()
    function slider()
        hSlider = figure;
        axis off;
        name = 'Angular alignment';
        set(hSlider,'Resize','off');
        set(hSlider,'color',[0.192156862745098 0.188235294117647 0.188235294117647]);
        set(hSlider,'name',name);
        set(hSlider,'NumberTitle','off');
        set(hSlider,'MenuBar','none');
        set(hSlider,'ToolBar','none');
        hObjectPos=get(hObject,'Position');
        set(hSlider,'Position',[hObjectPos(1)-329 hObjectPos(2) 329 172]);
        set(hSlider,'CloseRequestFcn',@closehSlider);
        
        % AP UI SLIDER LABEL
        hAPSliText = uicontrol('style','text','units',...
            'pixel','position',[15 140 300 20],...
            'String','A-P angular alignment');
        
        % AP UI SLIDER
        hAPSli = uicontrol('style','slider','units',...
            'pixel','position',[15 110 300 20],...
            'Max',1,'Min',0,'Value',0.5,...
            'Callback',@apSliderCallBack);
        
        % ML UI SLIDER LABEL
        hMLSliText = uicontrol('style','text','units',...
            'pixel','position',[15 80 300 20],...
            'String','M-L angular alignment');
        
        % ML UI SLIDER LABEL
        hMLSli = uicontrol('style','slider','units',...
            'pixel','position',[15 50 300 20],...
            'Max',1,'Min',0,'Value',0.5,...
            'Callback',@mlSliderCallBack);
        
        % PUSH BUTTON (OK)
        hPsh = uicontrol('style','pushbutton',...
            'String','Ok',...
            'position',[15 20 150 20],...
            'Callback',@pushOKCallBack);
        
        % PUSH BUTTON (CANCEL)
        hPsh = uicontrol('style','pushbutton',...
            'String','Cancel',...
            'position',[165 20 150 20],...
            'Callback',@pushCancelCallBack);
        uiwait;
    end

    function apSliderCallBack( handle, event )
        align(handle);
    end

    function mlSliderCallBack( handle, event )
        align(handle);
    end

    function pushOKCallBack( handle, event )
        % TRANSLATE MODEL DISTAL END TO ORIGIN (USE THIS IF ALGORITHM IS
        % IMPLEMENTED
%         model.data(:,3) = model.data(:,3) - min(model.data(:,3));
        % DRAW SCENE
        set(model.handlePatch,'vertices',model.data);
        drawnow;
        % SAVE DATA
        guidata(hObject,model);
        % CLEAN UP
        delete(handle.Parent);
        uiresume;
    end

    function pushCancelCallBack( handle, event )
        model = guidata(hObject);
        % UNDO MODIFICATIONS
        model.data = orgData;
        model.sliceHeights = orgSliceHeights;
        % SAVE DATA
        guidata(hObject,model);
        % DRAW SCENE
        set(model.handlePatch,'vertices',model.data);
        drawnow;
        % CLEAN UP
        delete(handle.Parent);
        uiresume
    end

    function closehSlider( handle, event )
        % FORCE USER TO USE THE CANCEL BUTTON
    end

    function align(handle)
        
        switch(func2str(handle.Callback));
            case('setAngularAlignment/apSliderCallBack')
                
                % MANUALLY SET THE ANGULAR ALIGNMENT
                model = guidata(hObject);
                newThetaY = handle.Value - lastThetaY;
                lastThetaY = handle.Value;
                
                R = roty(newThetaY*90); % and x
                for idx = 1:model.numSliceHeights
                    model.data(idx,:) = model.data(idx,:) * R;
                end
                
            case('setAngularAlignment/mlSliderCallBack')
                
                % MANUALLY SET THE ANGULAR ALIGNMENT
                model = guidata(hObject);
                newThetaX = handle.Value - lastThetaX;
                lastThetaX = handle.Value;
                
                R = rotx(newThetaX*90); % and x
                for idx = 1:model.numSliceHeights
                    model.data(idx,:) = model.data(idx,:) * R;
                end
        end
        
        % SMOOTH OUT HEIGHT DATA
        numSliceHeights = length(model.sliceHeights);
        x = (1:size(model.data,1))';
        b = x\model.data(:,3);
        model.data(:,3) = x * b - b;
        model.sliceHeights = linspace(0,model.data(end,3),numSliceHeights);
        
        % DRAW SCENE
        set(model.handlePatch,'vertices',model.data);
        drawnow;
        
        % SAVE DATA
        guidata(hObject,model);
    end
end

