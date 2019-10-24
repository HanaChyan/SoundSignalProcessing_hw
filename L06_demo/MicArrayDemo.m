function varargout = MicArrayDemo(varargin)
% MICARRAYDEMO M-file for MicArrayDemo.fig
%      MICARRAYDEMO, by itself, creates a new MICARRAYDEMO or raises the existing
%      singleton*.
%
%      H = MICARRAYDEMO returns the handle to a new MICARRAYDEMO or the handle to
%      the existing singleton*.
%
%      MICARRAYDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK d0 MICARRAYDEMO.M with the given input arguments.
%
%      MICARRAYDEMO('Property','Value',...) creates a new MICARRAYDEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MicArrayDemo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MicArrayDemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MicArrayDemo

% Last Modified by GUIDE v2.5 30-Mar-2016 20:07:24
clc
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MicArrayDemo_OpeningFcn, ...
                   'gui_OutputFcn',  @MicArrayDemo_OutputFcn, ...
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


% --- Executes just before MicArrayDemo is made visible.
function MicArrayDemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined d0 a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MicArrayDemo (see VARARGIN)

% Choose default command line output for MicArrayDemo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MicArrayDemo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MicArrayDemo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined d0 a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global res;
global w;
global fr;
global d0;
global M;
global t0;
global wt;

w = 0:1:180;
res = zeros(size(w));

list = get(handles.popupFrequency,'String');
val = get(handles.popupFrequency, 'Value');
fr = str2num(list(val,:));
list = get(handles.popupArrayNum,'String');
val = get(handles.popupArrayNum, 'Value');
M = str2num(list(val,:));
list = get(handles.popupInterval,'String');
val = get(handles.popupInterval, 'Value');
d0 = str2num(list(val,:));
list = get(handles.popupTargetAngle,'String');
val = get(handles.popupTargetAngle, 'Value');
t0 = str2num(list(val,:));
list = get(handles.popupWindow,'String');
val = get(handles.popupWindowv, 'Value');
wt = list(val,:);

RefreshPlot(handles)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change d0 popupFrequency.
function popupFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to popupFrequency (see GCBO)
% eventdata  reserved - to be defined d0 a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fr;

list = get(hObject,'String');
val = get(hObject, 'Value');
fr = str2num(list(val,:));

RefreshPlot(handles)



function RefreshPlot(handles)

global res;
global w;
global fr;
global d0;
global M;
global t0;
global wt;

c = 344;

fa = exp(-1i*2*pi*fr*(0:M-1)'*d0*cos(t0/180*pi)/c)/M;
if(strcmp(wt,'Hamming'))
    win = hamming(M);
elseif(strcmp(wt,'Hanning'))
    win = hanning(M);
elseif(strcmp(wt,'Chebyshev'))
    win = chebwin(M);
elseif(strcmp(wt,'Blackman'))
    win = blackman(M);
elseif(strcmp(wt,'Flattopwin'))
    win = flattopwin(M);
elseif(strcmp(wt,'Kaiser'))
    win = kaiser(M,3);
else
    win = ones(M,1);
end
fa = win.*fa;
for i = 1:length(w)
    d = exp(1i*2*pi*fr*(0:M-1)'*d0*cos(w(i)/180*pi)/c);
    res(i) = fa.'*d;
end
res = res/max(abs(res));

figure(handles.figure1)
plot(w,10*log10(abs(res)));
axis([0,180,-60,5])
grid on
box on

% plot(1:fr,rand(fr,1))

% Hints: contents = cellstr(get(hObject,'String')) returns popupFrequency contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFrequency


% --- Executes during object creation, after setting all properties.
function popupFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupFrequency (see GCBO)
% eventdata  reserved - to be defined d0 a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

str=100:100:8000;
set(hObject,'string',str,'value',1);
set(hObject, 'Value',find(str==5000));
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined d0 a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change d0 popupInterval.
function popupInterval_Callback(hObject, eventdata, handles)
% hObject    handle to popupInterval (see GCBO)
% eventdata  reserved - to be defined d0 a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d0;
list = get(hObject,'String');
val = get(hObject, 'Value');
d0 = str2num(list(val,:));

RefreshPlot(handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupInterval contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupInterval


% --- Executes during object creation, after setting all properties.
function popupInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupInterval (see GCBO)
% eventdata  reserved - to be defined d0 a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
str=0.01:0.01:1;
set(hObject,'string',str,'value',1);
set(hObject, 'Value',find(str==0.03));
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupArrayNum.
function popupArrayNum_Callback(hObject, eventdata, handles)
% hObject    handle to popupArrayNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

list = get(hObject,'String');
val = get(hObject, 'Value');
global M
M = str2num(list(val,:));

RefreshPlot(handles)

% Hints: contents = cellstr(get(hObject,'String')) returns popupArrayNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupArrayNum


% --- Executes during object creation, after setting all properties.
function popupArrayNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupArrayNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

str=2:100;
set(hObject,'string',str,'value',1);
set(hObject, 'Value',find(str==16));

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupTargetAngle.
function popupTargetAngle_Callback(hObject, eventdata, handles)
% hObject    handle to popupTargetAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list = get(hObject,'String');
val = get(hObject, 'Value');
global t0
t0 = str2num(list(val,:));

RefreshPlot(handles)
% Hints: contents = cellstr(get(hObject,'String')) returns popupTargetAngle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupTargetAngle


% --- Executes during object creation, after setting all properties.
function popupTargetAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupTargetAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

str=0:180;
set(hObject,'string',str,'value',1);
set(hObject, 'Value',find(str==90));

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupWindow.
function popupWindow_Callback(hObject, eventdata, handles)
% hObject    handle to popupWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list = get(hObject,'String');
val = get(hObject, 'Value');
global wt
wt = list(val,:);

RefreshPlot(handles)

% Hints: contents = cellstr(get(hObject,'String')) returns popupWindow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupWindow


% --- Executes during object creation, after setting all properties.
function popupWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
str={'Rectangle','Hanning','Hamming','Chebyshev','Blackman','Flattopwin','Kaiser'};
set(hObject,'string',str,'value',1);

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
