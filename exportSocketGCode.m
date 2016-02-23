function  exportSocketGCode( hObject, gcode_file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% GET DATA
model = guidata(hObject);

%% Initial Conditions Menu
% name1='Settings';
% prompt1={'Initial spindle speed:','Initial feed speed:',...
%     'Initial base feed speed:'};
% defaultanswer1={'100','500','800'}; % CHECK WITH BRAD ON THE INITIAL FEED SPEED
% answer1=inputdlg(prompt1,name1,1,defaultanswer1);
% int_spind_speed_val=cell2mat(answer1(1)); % spindle speed = extrusion rate
% int_feed_speed_val=cell2mat(answer1(2));  % feed speed = platform rotation
% base_feed_speed_val=cell2mat(answer1(3));

% PRINT SETTINGS
% BUILD LAYERS
% int_spind_speed_val=100; % spindle speed = extrusion rate
% int_feed_speed_val=500;  % feed speed = platform rotation
% % DISTAL THIRD OF THE MODEL
% end_feed_speed_val=1000;
% end_spind_speed_val=65;
% % MIDDLE THIRD OF THE MODEL
% middle_feed_speed_val=1800;
% middle_spind_speed_val=60;
% % TOP THRID OF THE MODEL
% top_feed_speed_val=2000;
% top_spind_speed_val=55;

% KEY INTERFACE LAYER
kil_feed = 500;
kil_spind = 100;
% LOCKING LAYER
ll_spind = 50;
% MODEL LAYER
int_feed_speed_val = 500;
int_spind_speed_val = 100;
top_feed_speed_val = str2num(cell2mat(model.top_feed_speed_val));
top_spind_speed_val = str2num(cell2mat(model.top_spind_speed_val));
middle_feed_speed_val = str2num(cell2mat(model.middle_feed_speed_val));
middle_spind_speed_val = str2num(cell2mat(model.middle_spind_speed_val));
end_feed_speed_val = str2num(cell2mat(model.end_feed_speed_val));
end_spind_speed_val = str2num(cell2mat(model.end_spind_speed_val));
end2_feed_speed_val=str2num(cell2mat(model.end2_feed_speed_val));
end2_spind_speed_val=str2num(cell2mat(model.end2_spind_speed_val));

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
% ESTIMATE VOLUME (ESTIMATE MODEL AS CYLINDER) AND PRINT TIME
meanR = mean(interpData(:,1));
modelVolume = max(interpData(:,2))*(pi * meanR^2)*0.001; % cc
printTime = (2 * pi * meanR * length(model.sliceHeights) * 1 / 3 / top_feed_speed_val) + ...
    (2 * pi * meanR * length(model.sliceHeights) * 1 / 3 / middle_feed_speed_val) + ...
    (2 * pi * meanR * length(model.sliceHeights) * 1 / 3 / end2_feed_speed_val);

%% EXPORT GCODE
fid = fopen(gcode_file,'wt');
fprintf(fid,'%s\n','%');
% WRITE ESTIMATED MODEL VOLUME AND PRINT TIME
fprintf(fid,'(%s)\n', 'Rigid socket');
fprintf(fid,'(%s', 'Model volume: ');
fprintf(fid,'%s',num2str(modelVolume));
fprintf(fid, ' cc)\n');
fprintf(fid,'(%s', 'Total print time: ');
fprintf(fid,'%s',num2str(printTime));
fprintf(fid, ' mins)\n');
% STARTING CUP SIZE
% SET STARTING CUP SIZE 
if any(strcmp('distalEndDia',fieldnames(model)))
    fprintf(fid,'(%s','Starting cup diameter: ');
    fprintf(fid,'%s', num2str(2*model.distalEndDia));
    fprintf(fid, ' mm)');
else
    % SET STARTING CUP SIZE FOR SOCKET
    model.distalEndRad = 46.8; % mm
    fprintf(fid,'(Starting cup: normal');
    fprintf(fid, ', %4.4f mm)', model.distalEndRad);
end
% MOVE INTO PURGING POSITION
fprintf(fid, '\n%s\n','F100');
fprintf(fid,'G1Z100\n');
fprintf(fid, 'M3S50\n');
fprintf(fid,'G4P60\n'); % purge print head for 60 s
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
fprintf(fid,'F');
fprintf(fid, num2str(end_feed_speed_val));
fprintf(fid,'M3S');
fprintf(fid, num2str(end_spind_speed_val));
fprintf(fid,'\n');
% GCODE FOR BOTTOM THIRD OF THE MODEL
numPoints = size(interpData,1);
for idx = 1:numPoints % Print first 4 layers at F 250 as done in old R&D code
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
end
% % GCODE FOR SECOND BOTTOM THIRD OF THE MODEL
% fprintf(fid,'F');
% end2_feed_speed_val=num2str(end2_feed_speed_val);
% fprintf(fid,end2_feed_speed_val);
% fprintf(fid,'S');
% end2_spind_speed_val=num2str(end2_spind_speed_val);
% fprintf(fid,end2_spind_speed_val);
% for idx = round(numPoints*1/4)+1:round(numPoints*2/4) % Print first 4 layers at F 250 as done in old R&D code
%     fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
%         ,'Z',interpData(idx,1),'A',interpData(idx,3));
% end
% % GCODE FOR THE MIDDLE THIRD OF THE MODEL
% fprintf(fid,'F');
% middle_feed_speed=num2str(middle_feed_speed_val);
% fprintf(fid,middle_feed_speed);
% fprintf(fid,'S');
% middle_spind_speed=num2str(middle_spind_speed_val);
% fprintf(fid,middle_spind_speed);
% for idx = round(numPoints*2/4)+1:round(numPoints*3/4) % Print first 4 layers at F 250 as done in old R&D code
%     fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
%         ,'Z',interpData(idx,1),'A',interpData(idx,3));
% end
% % GCODE FOR TOP THIRD OF THE MODEL
% fprintf(fid,'F');
% top_feed_speed=num2str(top_feed_speed_val);
% fprintf(fid,top_feed_speed);
% fprintf(fid,'S');
% top_spind_speed=num2str(top_spind_speed_val);
% fprintf(fid,top_spind_speed);
% for idx = round(numPoints*3/4)+1:numPoints
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

