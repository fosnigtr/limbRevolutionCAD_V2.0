function varargout = main(varargin)
% CAD MATLAB code for CAD.fig
%      CAD, by itself, creates a new CAD or raises the existing
%      singleton*.
%
%      H = CAD returns the handle to a new CAD or the handle to
%      the existing singleton*.
%
%      CAD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAD.M with the given input arguments.
%
%      CAD('Property','Value',...) creates a new CAD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CAD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CAD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CAD

% Last Modified by GUIDE v2.5 08-Oct-2015 15:00:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CAD is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CAD (see VARARGIN)

% Choose default command line output for CAD
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Display logo
%movielogo;

% % Check copy right
% flag = crprotection;

% Set GUI background color
set(handles.figure1,'color','w');
set(handles.figure1,'Name','');

% Initialize
handles = clearplots(handles);

% Change icon
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(handles.figure1,'javaframe');
jIcon=javax.swing.ImageIcon('.\Logo.png');
jframe.setFigureIcon(jIcon);

guidata(hObject, handles);
% % Change data cursor values to cylindrical cordinates
% handles.obj = datacursormode(handles.figure1);
% set(handles.obj,'UpdateFcn',@updatecursor);



% UIWAIT makes CAD wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, model)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Clear plots
handles = clearplots(handles);

%% Get .aop file
handles.file = getaopfile();

%% Get layer1
% handles.layer1 = getlayer1();

%% Read aop file
h=waitbar(0,'Loading file...');
handles.data = readaopfile(handles.file);

%% Plot model
waitbar(.5, h, 'Rendering model...');
plot3D(handles);

% plot2D(handles);

% Display .aop file name
axes(handles.axes5);
filename = sprintf('FILE NAME: %s', handles.file.fname);
text(0,.5,filename);

% Update data
figure(h)
waitbar(1,h,'Render complete');
pause(3)
close(h)
guidata(hObject, handles);


% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Tools_Callback(hObject, eventdata, handles)
% hObject    handle to Tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function Templates_Callback(hObject, eventdata, handles)
% hObject    handle to Templates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Liner_Callback(hObject, eventdata, handles)
% hObject    handle to Liner (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Landmarks_Callback(hObject, eventdata, handles)
% hObject    handle to Landmarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Change data cursor values to cylindrical cordinates

% set(axes(handles.axes2),'ButtonDownFcn',@cursorselect);


% --------------------------------------------------------------------
function uitoggletool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
% function uitoggletool2_OnCallback(hObject, eventdata, handles)
% % hObject    handle to uitoggletool2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % Change data cursor values to cylindrical cordinates
% handles.obj = datacursormode(handles.figure1);
% set(handles.obj,'Enable','on');
% set(handles.obj,'UpdateFcn',@updatecursor);
% 
% % if length(foo) ~= 0
% %     handles.pos = foo.Position;
% % end
% % handles.flag = 1;
% guidata(hObject,handles);
% figure1_WindowButtonMotionFcn(hObject, eventdata, handles)

%  function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % Update 2D images
% if length(handles.obj) ~= 0 
% %     handles.pos = foo.Position;
%     foo = getCursorInfo(handles.obj);
%     if length(foo) ~= 0
%         handles.pos = foo.Position;
%         plot2D(handles);
%     end
% end


% --------------------------------------------------------------------
% function uitoggletool2_OffCallback(hObject, eventdata, handles)
% % hObject    handle to uitoggletool2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% set(handles.obj,'Enable','off');
% handles.obj = [];
% guidata(hObject,handles);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
