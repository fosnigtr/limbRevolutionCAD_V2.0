function [ handles ] = clearplots( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Initial variables
handles.obj = [];
handles.pos = [];

% Display figures
% axes(handles.axes1)
% set(gca,'xtick',[],'ytick',[])
% set(gca,'xtick',[],'ytick',[]); box off;
% set(gca,'xcolor','w'); set(gca,'ycolor','w');

axes(handles.axes2)
set(gca,'xtick',[],'ytick',[])
set(gca,'xtick',[],'ytick',[]); box off;
set(gca,'xcolor','w'); set(gca,'ycolor','w');

% axes(handles.axes3)
% set(gca,'xtick',[],'ytick',[])
% set(gca,'xtick',[],'ytick',[]); box off;
% set(gca,'xcolor','w'); set(gca,'ycolor','w');

axes(handles.axes4);
logo = imread('./LogoStatic.png');
h = imagesc(logo); axis tight; axis equal;
set(gca,'xtick',[],'ytick',[]); box off;
set(gca,'xcolor','w'); set(gca,'ycolor','w');

axes(handles.axes5)
set(gca,'xtick',[],'ytick',[])
set(gca,'xtick',[],'ytick',[]); box off;
set(gca,'xcolor','w'); set(gca,'ycolor','w');
% 
% % Save data
% guidata(hObject, handles);
end

