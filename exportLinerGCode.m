function  exportLinerGCode( hObject, gcode_file )
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

%% CENTER MODEL DISTAL END 
distalEnd = model.data(1:model.numSlicePoints-1,:);
Xc = ((max(distalEnd(:,1)) - min(distalEnd(:,1))) /2) + min(distalEnd(:,1));
Yc = ((max(distalEnd(:,2)) - min(distalEnd(:,2))) /2) + min(distalEnd(:,2));
model.data(:,1)=model.data(:,1)-Xc;
model.data(:,2)=model.data(:,2)-Yc;

%% INTERPOLATE MESH IN Z TO 0.01 MM RESOLUTION
newStep = 0.01; % z resolution from point to point (mm) 
modelHeight = model.data(end,end); % mm
numNew = modelHeight / newStep;
numNew = round(numNew / model.numSlicePoints) * model.numSlicePoints; % keep angle resolution of the orginal model (i.e., if the angle resolution is 4 degrees then interpolate the model so that the angle resolution is unchanged)
% scaleFac = round(oldStep / step);
numSliceHeights = size(model.data,1);
model.data(:,3) = model.data(:,3) - model.data(1,3);
tmpData = reshape(model.data,model.numSlicePoints,numSliceHeights/model.numSlicePoints,3);
z = tmpData(:,:,3);
% interpZ = linspace(0,model.data(end,end),model.numSliceHeights*scaleFac);
interpZ = linspace(0,modelHeight,numNew); % mm
% interpZ = reshape(interpZ,model.numSlicePoints,model.numSliceHeights/model.numSlicePoints*scaleFac);
interpZ = reshape(interpZ,model.numSlicePoints,numNew/model.numSlicePoints);
% INITIALIZE BUFFER
interpData = zeros(model.numSlicePoints,length(interpZ),2);
% INTERPOLATE IN Z
for idxAxis = 1:2
    for idx = 1:model.numSlicePoints
        interpData(idx,:,idxAxis) = interp1(z(idx,:),squeeze(tmpData(idx,:,idxAxis)),interpZ(idx,:));
    end
end
% CONVERT TO CYLINDRICAL COORDINATES
interpRData = sqrt(sum(interpData.^2,3));
lastAngle = (model.numSlicePoints*model.angleStep)-model.angleStep;
angle = (0:model.angleStep:lastAngle)';
angle = repmat(angle,1,size(interpZ,2));
interpData = cat(3,interpRData,interpZ,angle);
% interpData = reshape(interpData,model.numSliceHeights*scaleFac,3);
interpData = reshape(interpData,numNew,3);
interpData(:,2) = interpData(:,2) + max(diff(interpData(:,2)));
% ESTIMATE VOLUME (ESTIMATE MODEL AS CYLINDER) AND PRINT TIME
meanR = mean(interpData(:,1));
modelVolume = max(interpData(:,2))*(pi * meanR^2)*0.001; % cc
printTime = 2 * pi * meanR * length(model.sliceHeights) / ml_feed; % mins 

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
if any(strcmp('distalEndRad',fieldnames(model)))
    fprintf(fid,'(%s','Starting cap radius: ');
    switch model.distalEndDia
        case 37
            radius = 'small';
        case 40
            radius = 'medium';
        case 44
            radius = 'large';
    end
    fprintf(fid,'%s', radius);
    fprintf(fid, ', %4.4f mm)', model.distalEndRad);
else
    % SET STARTING CUP SIZE FOR OUTER MOLD
    model.distalEndRad = 46.8; % mm
    fprintf(fid,'(Starting cup: normal');
    fprintf(fid, ', %4.4f mm)', model.distalEndRad);
end
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
fprintf(fid,'G1X0Z%4.2fA0\n',model.distalEndRad-10);
fprintf(fid,'G1X0Z%4.2fA359\n',model.distalEndRad-10);
% PRINT LOCKING LAYER
fprintf(fid,'M3S');
fprintf(fid,num2str(ll_spind));
fprintf(fid,'\n');
fprintf(fid,'G1X1.2Z%4.2fA0\n',model.distalEndRad-10+2);
fprintf(fid,'G1X1.2Z%4.2fA359\n',model.distalEndRad-10+2);
fprintf(fid,'M7\n');
% PRINT MODEL
fprintf(fid,'M3S');
fprintf(fid,num2str(ml_spind));
fprintf(fid,'\n');
fprintf(fid,'F');
fprintf(fid,num2str(ml_feed));
% GCODE FOR DISTAL END OF THE MODEL
for idx = 1:numNew% Print first 4 layers at F 250 as done in old R&D code
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
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

