function readAopFile( hObject )
%READAOPFILE Summary of this function goes here
%   Detailed explanation goes here
model = guidata(hObject);
% GET FILE ID
fid = fopen([model.pname model.fname], 'r'); 
mark = 0;
match = {'A','B','C','D','E','F','G','H','I','J','L','M','N',...
    'O','P','Q','R','S','T','U','V','W','X','Y','Z'};
% READ MODEL DATA INFORMATION
while feof(fid) == 0 
    % READ LINE FROM .AOP FILE
    tline = fgetl(fid); 
    fword = sscanf(tline, '%s '); 
    % FINDS "END OF COMMENTS" FLAG IN .AOP FILE
    if strncmpi(fword, 'E', 1) == 1; 
        % SKIP LANDMARK INFORMATION
        while strncmpi(fword, match, 1) == 1; 
            fget1(fid);
            fget1(fid);
            fget1(fid);
            fget1(fid);
            fword = fgetl(fid);
        end
        % READ MODEL ANGLE INFORMATION
        i=1;
        num=zeros(20,1);
        circ=0;
        while circ ~= 360 %steps through until angle data is found
            i=i+1;
            tline = fgetl(fid);
            linescan = sscanf(tline, '%e ');
            if ~isempty(linescan)
                num(i,1) = linescan;
                circ = num(i-1,1)*num(i,1);
            end
            
        end
        numSlicePoints = num(i-1,1); %number of divisions of 1 revolution
        angleStep = num(i,1); %angle increment per measurement
        % READ MODEL RADIUS INFORMATION
        tline = fgetl(fid);
        slices = sscanf(tline, '%e '); %number of slices in z
        tline = fgetl(fid);
        sliceHeights=zeros(slices,1);
        while mark < slices
            mark=mark+1;
            tline = fgetl(fid);
            single_slice = sscanf(tline, '%e ');
            sliceHeights(mark,1)= single_slice; %store values for slice heights
        end
        data=zeros(slices*numSlicePoints,3);
        datatest=zeros(slices,numSlicePoints);
        mark3=0;
        count=0;
        while mark3 < slices
            mark3=mark3+1;
            mark4=0;
            while mark4 < numSlicePoints
                mark4=mark4+1;
                count=count+1;
                tline=fgetl(fid);
                point=sscanf(tline, '%e ');
                rad=point(1,1); %reads radius from file
                theta = (mark4-1)*angleStep;
                vertexX=rad * cosd(theta);
                vertexY=rad * sind(theta);
                vertexZ=sliceHeights(mark3);
%                 datatest((mark3-1)*numSlicePoints+mark4,:) = rad;
                data((mark3-1)*numSlicePoints+mark4,:)=[vertexX,vertexY,vertexZ];
                datatest(mark3,mark4)=rad;%store data values
            end
%             data(mark3,slice_points+1)=data(mark3,1);%stores starting point again
        end
    end
end
% ROUND TO THE NEAREST 100THS OF A MILLIMETER
data = round(data*100)/100;

fclose(fid);
% UPDATE INFORMATION
model.numSlicePoints = numSlicePoints;
model.angleStep = angleStep;
model.sliceHeights = sliceHeights;
model.sliceHeightStep = mean(diff(sliceHeights));
model.numSliceHeights = length(sliceHeights)*numSlicePoints;
model.data = data;
model.datatest = datatest;
guidata(hObject, model);
end