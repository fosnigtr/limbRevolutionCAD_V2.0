function LayerWidthCalibrationModels( hObject, gcode_file )
%% Test cyclinders for PDI printer

% %% Gcode filename
% gcode_file = 'C:\Users\Tyler Fosnight\Documents\Tyler Documents\PDI\CAD_V2.0\TestFiles\calibrationTest.tap';

%% Initial Conditions Menu
name1='Settings';
prompt1={'Initial spindle speed:','Initial feed speed:',...
    'Initial base feed speed:'};
defaultanswer1={'100','500','800'}; % CHECK WITH BRAD ON THE INITIAL FEED SPEED
answer1=inputdlg(prompt1,name1,1,defaultanswer1);
int_spind_speed_val=cell2mat(answer1(1)); % spindle speed = extrusion rate
int_feed_speed_val=cell2mat(answer1(2));  % feed speed = platform rotation
base_feed_speed_val=cell2mat(answer1(3));

%% Create cylinder and slice cyliner
dTheta = 4; % degrees
r = 39.5; % radius in millimeters (equivalent radius of cup)
h = 153; % height of model in millimeters
dz = 0.05; % height resolution in millimeters (test dz: 0.005,0.01,0.05)
alignmentPlateOffSet = 1.21;
% Create cyliner and slices
% Angle data
theta = 0:dTheta:360-dTheta;
% Generate height data
z = 0:dz:h;
numPoints = length(theta); % number of point in each slice
numSlicePoints = round(length(z)/numPoints); % number of slices in model
z = z(1:numSlicePoints*numPoints)+alignmentPlateOffSet;
% Generate angle data
theta = repmat(theta',1,numSlicePoints);
theta = reshape(theta,numSlicePoints*numPoints,1);
% Generate radius data
r = ones(numPoints*numSlicePoints,1) .* r;
% Generate calibration model
interpData = cat(2,r,z',theta);

interpData2 = interpData;
interpData2(:,1) = interpData(:,1) - 9.5;

%% Generate g-code

fid = fopen(gcode_file,'wt');
fprintf(fid,'%s\n','%');
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
for idx = 1:numSlicePoints*4 % Print first 4 layers at F 250 as done in old R&D code
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData2(idx,2)...
        ,'Z',interpData2(idx,1),'A',interpData2(idx,3));
end
% GCODE FOR MODEL F800
fprintf(fid,'F');
base_feed_speed=num2str(base_feed_speed_val);
fprintf(fid,base_feed_speed);
for idx = numSlicePoints*4+1:numSlicePoints*numPoints
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData(idx,2)...
        ,'Z',interpData(idx,1),'A',interpData(idx,3));
    fprintf(fid,'\n%s%7.4f%s%7.4f%s%4.1f', 'G1X',interpData2(idx,2)...
        ,'Z',interpData2(idx,1),'A',interpData2(idx,3));
end
% POSITION THE PRINTER HEAD AT HOME
fprintf(fid, '\n%s\n%s\n%s\n', 'G0X564Z147A0','M5M9', '%');
% CLOSE .TAP FILE
fclose(fid);
% PROMPT USER ON STATUS
h = msgbox('Export complete');
pause(1);
delete(h);