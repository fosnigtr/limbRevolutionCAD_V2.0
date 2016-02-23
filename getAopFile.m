function getAopFile( hObject )
model = guidata(hObject);
% GET FILE
[name pname]=uigetfile({'*.aop';'*.stl'},'Import .aop or binary .stl file');
model.pname = pname; model.fname = name;
% ERROR CHECKING
while strcmp(name(end-3:end),'.aop') == 0 && strcmp(name(end-3:end),'.stl') == 0;
    h=errordlg('Import .aop or binary .stl file');
    pause(1);
    delete(h);
    [name pname]=uigetfile({'*.aop';'*.stl'},'Import .aop or binary .stl file');
    model.pname = pname; model.fname = name;
end
model.id=fopen([pname name], 'r');
while model.id == -1
    h=errordlg('File could not be opened, check name or path.','File Import Error');
    delete(h);
    model.name=uigetfile({'*.aop';'*.stl'},'Import .aop or binary .stl file');
    pause(2);
end
fclose(model.id);
% UPDATE INFORMATION
guidata(hObject, model);
end

