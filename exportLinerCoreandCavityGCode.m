function  exportLinerCoreandCavityGCode( hObject, gcode_file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% GET DATA
model = guidata(hObject);

%% Initial Conditions Menu
% feed speed = plateform rotation
% spind speed = extrusion rate

% KEY INTERFACE LAYER
kil_feed = 500;
kil_spind = 100;
% LOCKING LAYER
ll_spind = 50;
% MODEL LAYER
% ml_feed = 2000; 
% ml_spind = 55; 
ml_feed =  str2double(model.top_feed_speed_val); 
ml_spind = str2double(model.top_spind_speed_val); 

%% OUTER MODEL
% GET DATA
tmp = model.outerModel;
% CENTER MODEL DISTAL END 
distalEnd = tmp.data(1:tmp.numSlicePoints-1,:);
Xc = ((max(distalEnd(:,1)) - min(distalEnd(:,1))) /2) + min(distalEnd(:,1));
Yc = ((max(distalEnd(:,2)) - min(distalEnd(:,2))) /2) + min(distalEnd(:,2));
tmp.data(:,1)=tmp.data(:,1)-Xc;
tmp.data(:,2)=tmp.data(:,2)-Yc;
% OUTER MOLD INTERPOLATE MESH IN Z TO 0.01 MM RESOLUTION
newStep = 0.01; % z resolution from point to point (mm) 
modelHeight = tmp.data(end,end); % mm
numNew = modelHeight / newStep;
numNew = round(numNew / tmp.numSlicePoints) * tmp.numSlicePoints; % keep angle resolution of the orginal model (i.e., if the angle resolution is 4 degrees then interpolate the model so that the angle resolution is unchanged)
% scaleFac = round(oldStep / step);
numSliceHeights = size(tmp.data,1);
tmp.data(:,3) = tmp.data(:,3) - tmp.data(1,3);
tmpData = reshape(tmp.data,tmp.numSlicePoints,numSliceHeights/tmp.numSlicePoints,3);
z = tmpData(:,:,3);
% interpZ = linspace(0,tmp.data(end,end),tmp.numSliceHeights*scaleFac);
interpZ = linspace(0,modelHeight,numNew); % mm
% interpZ = reshape(interpZ,tmp.numSlicePoints,tmp.numSliceHeights/tmp.numSlicePoints*scaleFac);
interpZ = reshape(interpZ,tmp.numSlicePoints,numNew/tmp.numSlicePoints);
% INITIALIZE BUFFER
interpData = zeros(tmp.numSlicePoints,length(interpZ),2);
% INTERPOLATE IN Z
for idxAxis = 1:2
    for idx = 1:tmp.numSlicePoints
        interpData(idx,:,idxAxis) = interp1(z(idx,:),squeeze(tmpData(idx,:,idxAxis)),interpZ(idx,:));
    end
end
% CONVERT TO CYLINDRICAL COORDINATES
interpRData = sqrt(sum(interpData.^2,3));
lastAngle = (tmp.numSlicePoints*tmp.angleStep)-tmp.angleStep;
angle = (0:tmp.angleStep:lastAngle)';
angle = repmat(angle,1,size(interpZ,2));
interpData = cat(3,interpRData,interpZ,angle);
numNew2 = numNew;
% interpData = reshape(interpData,tmp.numSliceHeights*scaleFac,3);
interpData = reshape(interpData,numNew,3);
interpData(:,2) = interpData(:,2) + max(diff(interpData(:,2)));
% ESTIMATE VOLUME (ESTIMATE MODEL AS CYLINDER) AND PRINT TIME
meanR = mean(interpData(:,1));
outerModelVolume = max(interpData(:,2))*(pi * meanR^2)*0.001; % cc
outerModelPrintTime = 2 * pi * meanR * length(tmp.sliceHeights) / ml_feed; % mins 

%% INNER MODEL
% GET DATA
tmp = model.innerModel;

% ADD TOOLING HEIGHT 
toolingHeight = 17; % mm
capHeight = tmp.capHeight(3);
tmp.data(:,3) = tmp.data(:,3);

% CENTER MODEL DISTAL END 
distalEnd = tmp.data(1:tmp.numSlicePoints-1,:);
Xc = ((max(distalEnd(:,1)) - min(distalEnd(:,1))) /2) + min(distalEnd(:,1));
Yc = ((max(distalEnd(:,2)) - min(distalEnd(:,2))) /2) + min(distalEnd(:,2));
tmp.data(:,1)=tmp.data(:,1)-Xc;
tmp.data(:,2)=tmp.data(:,2)-Yc;

% INNER MOLD INTERPOLATE MESH IN Z TO 0.01 MM RESOLUTION
newStep = 0.01; % z resolution from point to point (mm) 
modelHeight = tmp.data(end,end); % mm
numNew = modelHeight / newStep;
numNew = round(numNew / tmp.numSlicePoints) * tmp.numSlicePoints; % keep angle resolution of the orginal model (i.e., if the angle resolution is 4 degrees then interpolate the model so that the angle resolution is unchanged)
% scaleFac = round(oldStep / step);
numSliceHeights = size(tmp.data,1);
% tmp.data(:,3) = tmp.data(:,3) - tmp.data(1,3);
tmpData = reshape(tmp.data,tmp.numSlicePoints,numSliceHeights/tmp.numSlicePoints,3);
z = tmpData(:,:,3);
% interpZ = linspace(0,tmp.data(end,end),tmp.numSliceHeights*scaleFac);
interpZ = linspace(tmp.data(1,3),modelHeight,numNew); % mm
% interpZ = reshape(interpZ,tmp.numSlicePoints,tmp.numSliceHeights/tmp.numSlicePoints*scaleFac);
interpZ = reshape(interpZ,tmp.numSlicePoints,numNew/tmp.numSlicePoints);
% INITIALIZE BUFFER
interpData2 = zeros(tmp.numSlicePoints,length(interpZ),2);
% INTERPOLATE IN Z
for idxAxis = 1:2
    for idx = 1:tmp.numSlicePoints
        interpData2(idx,:,idxAxis) = interp1(z(idx,:),squeeze(tmpData(idx,:,idxAxis)),interpZ(idx,:));
    end
end
% CONVERT TO CYLINDRICAL COORDINATES
interpRData = sqrt(sum(interpData2.^2,3));
lastAngle = (tmp.numSlicePoints*tmp.angleStep)-tmp.angleStep;
angle = (0:tmp.angleStep:lastAngle)';
angle = repmat(angle,1,size(interpZ,2));
interpData2 = cat(3,interpRData,interpZ,angle);
% interpData = reshape(interpData,tmp.numSliceHeights*scaleFac,3);
interpData2 = reshape(interpData2,numNew,3);
interpData2(:,2) = interpData2(:,2) + max(diff(interpData2(:,2)));
% ESTIMATE VOLUME (ESTIMATE MODEL AS CYLINDER) AND PRINT TIME
meanR = mean(interpData2(:,1));
innerModelVolume = max(interpData2(:,2))*(pi * meanR^2)*0.001; % cc
modelVolume = outerModelVolume - innerModelVolume;
innerModelPrintTime = 2 * pi * meanR * length(tmp.sliceHeights) / ml_feed; % mins 
printTime = outerModelPrintTime + innerModelPrintTime;

%% EXPORT GCODE
fid = fopen(gcode_file,'wt');
% WRITE ESTIMATED MODEL VOLUME AND PRINT TIME
fprintf(fid,'%s\n','%');
fprintf(fid,'(%s', 'Model volume: ');
fprintf(fid,'%s',num2str(modelVolume));
fprintf(fid, ' cc)\n');
fprintf(fid,'(%s', 'Total print time: ');
fprintf(fid,'%s',num2str(printTime));
fprintf(fid, ' mins)\n');
% STARTING CUP SIZE
% SET STARTING CUP SIZE FOR INNER MOLD
fprintf(fid,'(%s','Starting cap radius: ');
switch model.innerModel.distalEndRad
    case 38.25 %37
        radius = 'small';
    case 44.25 %40
        radius = 'medium';
    case 50.5 %44
        radius = 'large';
end
fprintf(fid,'%s', radius);
fprintf(fid, ', %4.4f mm)\n', model.innerModel.distalEndRad);

% SET STARTING CUP SIZE FOR OUTER MOLD
model.outerModel.distalEndRad = 46.8; % mm
fprintf(fid,'(Starting cup radius: normal');
fprintf(fid, ', %4.4f mm)', model.outerModel.distalEndRad);
% MOVE INTO PURGING POSITION
fprintf(fid, '\n%s\n','F800');
fprintf(fid,'G1Z100\n');
fprintf(fid,'G1X-10\n'); % move to purging position
fprintf(fid, 'M3S50\n'); % purge print head for 60 s
fprintf(fid,'G4P60\n');
% PRINT KEY INTERFACE LAYER
fprintf(fid, 'G0X0A0\n'); 
fprintf(fid,'F');
fprintf(fid,num2str(kil_feed));
fprintf(fid,'\n');
fprintf(fid,'G0Z60X5\n');
fprintf(fid,'M3S');
fprintf(fid,num2str(kil_spind));
fprintf(fid,'\n');
fprintf(fid,'G1X0Z%4.2fA0\n',model.outerModel.distalEndRad-10);
fprintf(fid,'G1X0Z%4.2fA359\n',model.outerModel.distalEndRad-10);
% PRINT LOCKING LAYER
fprintf(fid,'M3S');
fprintf(fid,num2str(ll_spind));
fprintf(fid,'\n');
fprintf(fid,'G1X1.2Z%4.2fA0\n',model.outerModel.distalEndRad-10+2);
fprintf(fid,'G1X1.2Z%4.2fA359\n',model.outerModel.distalEndRad-10+2);
fprintf(fid,'M7\n');
% PRINT MODEL
fprintf(fid,'M3S');
fprintf(fid,num2str(ml_spind));
fprintf(fid,'\n');
fprintf(fid,'F');
fprintf(fid,num2str(ml_feed));
%% GCODE FOR CORE AND CAVITY
% START THE OUTER MOLD
stop = (toolingHeight + capHeight) / (newStep * model.outerModel.numSlicePoints) * model.outerModel.numSlicePoints;
for idx = 1:stop % Print first 4 layers at F 250 as done in old R&D code
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
end
% INNER MOLD
% PAUSE FOR TOOLING CHANGE
fprintf(fid,'\nG4P60\n');
fprintf(fid,'(Add inner mold tooling)\n');
fprintf(fid,'(%s','Starting cap radius: ');
fprintf(fid,'%s', radius);
fprintf(fid, ', %4.4f mm)\n', model.innerModel.distalEndRad);
% PRINT KEY INTERFACE LAYER
innerStart = interpData2(1,3);
fprintf(fid, 'G0X%4.2fA0\n',innerStart); 
fprintf(fid,'F');
fprintf(fid,num2str(kil_feed));
fprintf(fid,'\n');
fprintf(fid,'G0Z60X%4.2f\n',innerStart+5);
fprintf(fid,'M3S');
fprintf(fid,num2str(kil_spind));
fprintf(fid,'\n');
fprintf(fid,'G1X%4.2fZ%4.2fA0\n',innerStart,model.innerModel.distalEndRad-10);
fprintf(fid,'G1X%4.2fZ%4.2fA359\n',innerStart,model.innerModel.distalEndRad-10);
% PRINT LOCKING LAYER
fprintf(fid,'M3S');
fprintf(fid,num2str(ll_spind));
fprintf(fid,'\n');
fprintf(fid,'G1X%4.2fZ%4.2fA0\n',innerStart+1.2,model.innerModel.distalEndRad-10+2);
fprintf(fid,'G1X%4.2fZ%4.2fA359\n',innerStart+1.2,model.innerModel.distalEndRad-10+2);
fprintf(fid,'M7\n');
% PRINT MODEL
fprintf(fid,'M3S');
fprintf(fid,num2str(ml_spind));
fprintf(fid,'\n');
fprintf(fid,'F');
fprintf(fid,num2str(ml_feed));
% START PRINTING BOTH THE INNER AND OUTER MOLD
numPoints = model.outerModel.numSlicePoints;
% stop = round(stop/numPoints);
% stop2 = round(numNew2/numPoints);
% for idx = stop+1:stop2-2 % Print first 4 layers at F 250 as done in old R&D code
stop = round(stop/numPoints);
stop2 = size(interpData2,1)/numPoints;
for idx = 1:stop2
    % Switch layer
    fprintf(fid,'M5');
    firstTime = true;
    secondTime = true;
    for idx2 = ((idx+stop)*numPoints)+1:numPoints*(idx+stop+1)
        % Move to next layer
        if firstTime == true
            fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx2,2)...
                ,'Z',interpData(idx2,1),'A',interpData(idx2,3));
            idx2 = idx2 + 1;
            fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx2,2)...
                ,'Z',interpData(idx2,1),'A',interpData(idx2,3));
            fprintf(fid,'M3S65');
            firstTime = false;
        end
        % Print layer
        idx2 = idx2 + 1;
        fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx2,2)...
            ,'Z',interpData(idx2,1),'A',interpData(idx2,3));
    end
    
    % Switch layer
    fprintf(fid,'M5');
    firstTime = true;
    for idx2 = (idx*numPoints)+1:numPoints*(idx+1)
        % Move to next layer
        if firstTime == true
            fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData2(idx2,2)...
                ,'Z',interpData2(idx2,1),'A',interpData2(idx2,3));
            idx2 = idx2 + 1;
            fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData2(idx2,2)...
                ,'Z',interpData2(idx2,1),'A',interpData2(idx2,3));
            fprintf(fid,'M3S65');
            firstTime = false;
        end
        % Print layer
        idx2 = idx2 + 1;
        fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData2(idx2,2)...
            ,'Z',interpData2(idx2,1),'A',interpData2(idx2,3));
    end
end
% POSITION THE PRINTER HEAD AT HOME
fprintf(fid, '\n%s\n%s\n%s\n', 'G0X564Z147A0','M5M9', '%');
% CLOSE .TAP FILE
fclose(fid);
% PROMPT USER ON STATUS
h = msgbox('Export complete');
pause(1);
delete(h);
end