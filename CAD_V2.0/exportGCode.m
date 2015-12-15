function  exportGCode( hObject, gcode_file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Initial Conditions Menu
name1='Settings';
prompt1={'Initial spindle speed:','Initial feed speed:',...
    'Initial base feed speed:'};
defaultanswer1={'100','350','800'};
answer1=inputdlg(prompt1,name1,1,defaultanswer1);
int_spind_speed_val=cell2mat(answer1(1)); % spindle speed = extrusion rate
int_feed_speed_val=cell2mat(answer1(2));  % feed speed = platform rotation
base_feed_speed_val=cell2mat(answer1(3));

%% INTERPOLATE MESH IN Z TO 1 MM RESOLUTION
model = guidata(hObject);
tmpData = reshape(model.data,model.numSlicePoints,model.numSliceHeights/model.numSlicePoints,3);
z = tmpData(:,:,3);
interpZ = linspace(0,model.data(end,end),model.numSliceHeights);
interpZ = reshape(interpZ,model.numSlicePoints,model.numSliceHeights/model.numSlicePoints);
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
interpData = reshape(interpData,model.numSliceHeights,3);

%% EXPORT GCODE
fid = fopen(gcode_file,'wt');
fprintf(fid, '\n%s\n%s\n', '%', 'F100');
fprintf(fid,'M3S100\n');
fprintf(fid,'G1Z100\n');
fprintf(fid, 'G0X0A0\n');
int_feed_speed=num2str(int_feed_speed_val);
fprintf(fid,'F');
fprintf(fid,int_feed_speed);
fprintf(fid,'\n');
fprintf(fid,'G0Z60X5\n');
int_spind_speed=num2str(int_spind_speed_val);
fprintf(fid,'M3S');
fprintf(fid, int_spind_speed);
fprintf(fid,'\n');
fprintf(fid,'G1X-1.2Z39.5A0\n');
fprintf(fid,'G1X-1.2Z39.5A359\n');
fprintf(fid,'M3S30\n');
fprintf(fid,'G1X0Z44A0\n');
fprintf(fid,'G1X0Z44A359\n');
fprintf(fid,'M7\n');
fprintf(fid,'M3S65\n');
fprintf(fid,'\n');
% GCODE FOR DISTAL END OF THE MODEL
for idx = 1:360 % Print first 4 layers at F 250 as done in old R&D code
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
end
% GCODE FOR MODEL F800
fprintf(fid,'F');
base_feed_speed=num2str(base_feed_speed_val);
fprintf(fid,base_feed_speed);
for idx = 361:model.numSliceHeights
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
end
% POSITION THE PRINTER HEAD AT HOME
fprintf(fid, '\n%s\n%s\n%s\n', 'G0X564Z147A0','M5M9', '%');
% CLOSE .TAP FILE
fclose(fid);
% PROMPT USER OF STATUS
h = msgbox('Export complete');
pause(1);
delete(h);
end

