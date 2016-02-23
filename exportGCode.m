function  exportLinerGCode( hObject, gcode_file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Initial Conditions Menu
name1='Settings';
prompt1={'Initial spindle speed:','Initial feed speed:',...
    'Initial base feed speed:'};
defaultanswer1={'100','500','800'}; % CHECK WITH BRAD ON THE INITIAL FEED SPEED
answer1=inputdlg(prompt1,name1,1,defaultanswer1);
int_spind_speed_val=cell2mat(answer1(1)); % spindle speed = extrusion rate
int_feed_speed_val=cell2mat(answer1(2));  % feed speed = platform rotation
base_feed_speed_val=cell2mat(answer1(3));

%% GET DATA
model = guidata(hObject);

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
interpData(:,2) = interpData(:,2) + max(diff(interpData(:,2))) + 1.2;

%% EXPORT GCODE
fid = fopen(gcode_file,'wt');
fprintf(fid,'%s\n','%');
if any(strcmp('distalEndDia',fieldnames(model)))
    fprintf(fid,'(%s','Starting cup diameter: ');
    fprintf(fid,'%s', num2str(2*model.distalEndDia));
    fprintf(fid, ' mm)');
end
fprintf(fid, '\n%s\n','F100');
fprintf(fid,'G1Z100\n');
fprintf(fid, 'M3S50\n'); % purge print head for 60 s
fprintf(fid,'G4P60\n');
fprintf(fid, 'G0X0A0\n'); 
% fprintf(fid,'M3S100\n');
int_feed_speed=num2str(int_feed_speed_val);
fprintf(fid,'F');
fprintf(fid,int_feed_speed);
fprintf(fid,'\n');
fprintf(fid,'G0Z60X5\n');
fprintf(fid,'M3S');
int_spind_speed=num2str(int_spind_speed_val);
fprintf(fid, int_spind_speed);
fprintf(fid,'\n');
fprintf(fid,'G1X0Z39.5A0\n');
fprintf(fid,'G1X0Z39.5A359\n');
fprintf(fid,'M3S30\n');
fprintf(fid,'G1X1.2Z44A0\n');
fprintf(fid,'G1X1.2Z44A359\n');
fprintf(fid,'M7\n');
fprintf(fid,'M3S65\n');
fprintf(fid,'\n');
% GCODE FOR DISTAL END OF THE MODEL
fprintf(fid,'F');
base_feed_speed=num2str(int_feed_speed_val);
fprintf(fid,base_feed_speed);
for idx = 1:model.numSlicePoints*4 % Print first 4 layers at F 250 as done in old R&D code
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
end
% for idx = 1:360*scaleFac % Print first 4 layers at F 250 as done in old R&D code
%     fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
%         ,'Z',interpData(idx,1),'A',interpData(idx,3));
% end
% GCODE FOR MODEL F800
fprintf(fid,'F');
base_feed_speed=num2str(base_feed_speed_val);
fprintf(fid,base_feed_speed);
for idx = model.numSlicePoints*4+1:numNew
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
end
% for idx = 361*scaleFac:model.numSliceHeights*scaleFac
%     fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
%         ,'Z',interpData(idx,1),'A',interpData(idx,3));
% end
% POSITION THE PRINTER HEAD AT HOME
fprintf(fid, '\n%s\n%s\n%s\n', 'G0X564Z147A0','M5M9', '%');
% CLOSE .TAP FILE
fclose(fid);
% PROMPT USER ON STATUS
h = msgbox('Export complete');
pause(1);
delete(h);
end

