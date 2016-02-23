function printSettings( hObject )
% CALIBRATION INPUT
% FATEST SPINDLE SPEED AND FEED RATE TO ACHIEVE
% LINER
% 2 mm wall
% SOCKET
% 2 mm wall (top of socket)
% 4.5 mm wall (middle of socket)
% 7 mm wall (bottom of socket)
model = guidata(hObject);

prompt = {'2 mm wall spindle speed:',...
    '2 mm wall feedrate (mm/min):',...
    '4 mm wall spindle speed:',...
    '4 mm wall feedrate (mm/min):',...
    '6 mm wall spindle speed: ',...
    '6 mm wall feedrate (mm/min):',...
    '7 mm wall spindle speed:',...
    '7 mm wall feedrate (mm/min):'};

dlgTitle = 'Settings';
numLines = 1;
defaultAns = {'45',...
    '2000',...
    '50',...
    '1800',...
    '50',...
    '1200',...
    '55',...
    '1000'};

if model.printerSettingsChanged == true
    answer = inputdlg(prompt,dlgTitle,numLines,defaultAns);
    % TOP THRID OF THE MODEL
    model.top_feed_speed_val=answer(2);
    model.top_spind_speed_val=answer(1);
    % MIDDLE THIRD OF THE MODEL
    model.middle_feed_speed_val=answer(4);
    model.middle_spind_speed_val=answer(3);
    % SECOND DISTAL THIRD OF THE MODEL
    model.end2_feed_speed_val=answer(6);
    model.end2_spind_speed_val=answer(5)
    % DISTAL THIRD OF THE MODEL
    model.end_feed_speed_val=answer(8);
    model.end_spind_speed_val=answer(7);
else
    % TOP THRID OF THE MODEL
    model.top_feed_speed_val=2000;
    model.top_spind_speed_val=55;
    % MIDDLE THIRD OF THE MODEL
    model.middle_feed_speed_val=1800;
    model.middle_spind_speed_val=60;
    % SECOND DISTAL THIRD OF THE MODEL
    model.end2_feed_speed_val=1200;
    model.end2_spind_speed_val=60;
    % DISTAL THIRD OF THE MODEL
    model.end_feed_speed_val=1000;
    model.end_spind_speed_val=65;
end

% SAVE PRINTER SETTINGS
guidata(hObject,model);
end