function varargout = DisplayDataGui(varargin)
% DISPLAYDATAGUI M-file for DisplayDataGui.fig
%      DISPLAYDATAGUI, by itself, creates a new DISPLAYDATAGUI or raises the existing
%      singleton*.
%
%      H = DISPLAYDATAGUI returns the handle to a new DISPLAYDATAGUI or the handle to
%      the existing singleton*.
%
%      DISPLAYDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAYDATAGUI.M with the given input arguments.
%
%      DISPLAYDATAGUI('Property','Value',...) creates a new DISPLAYDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DisplayDataGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DisplayDataGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DisplayDataGui

% Last Modified by GUIDE v2.5 03-May-2016 17:08:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DisplayDataGui_OpeningFcn, ...
    'gui_OutputFcn',  @DisplayDataGui_OutputFcn, ...
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


% --- Executes just before DisplayDataGui is made visible.
function DisplayDataGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DisplayDataGui (see VARARGIN)

% Choose default command line output for DisplayDataGui
handles.output = hObject;

% set data from input (should do more checks here)
handles.DisplayDataOrig = varargin{1};
if nargin == 4
    handles.doTitles=false;
else
    handles.doTitles=true;
    handles.titles = varargin{2};
end

% set default dimension selection
set(handles.dim3,'Value',1);
handles.DisplayData = handles.DisplayDataOrig;

% set the ThresholdSlider slider maximum value
handles.maxValue = max(handles.DisplayDataOrig(:));
maxValStr = sprintf('%.2g',handles.maxValue);
set(handles.ThreshMaxEdit,'String',maxValStr);
handles.ThresholdValue = handles.maxValue;
set(handles.ThresholdSlider, 'Max', 100);
set(handles.ThresholdSlider, 'Min', 1);
handles.absData = min(handles.DisplayDataOrig(:)) >= 0;

% set slider step size to 1
set(handles.ThresholdSlider,'SliderStep',[0.01 0.1]);
% set initial threshold value
handles.threshSlicePos = 100;
set(handles.ThresholdSlider,'Value',handles.threshSlicePos);

threshStr = sprintf('%.2g',handles.ThresholdValue);
set(handles.threshValueText,'String',['Threshold Value: ' threshStr]);

% set the slider maximum value
handles.maxSlider = size(handles.DisplayData,3);
set(handles.sliceSlider, 'Max', handles.maxSlider);
set(handles.sliceSlider, 'Min', 1);
if handles.maxSlider == 1
    handles.slicePos = 1;
    % disable play button
    set(handles.playVolume,'Enable','off');
else    
    % set slider step size to 1
    set(handles.sliceSlider,'SliderStep',[1 10]./(handles.maxSlider-1));
    % set initial slice position
    handles.slicePos = ceil(handles.maxSlider/2);
    handles.currPlaySlice = handles.slicePos;
    set(handles.sliceSlider,'Value',handles.slicePos);
    set(handles.sliceValue,'String',['Slice ' num2str(handles.slicePos) ...
        '/' num2str(handles.maxSlider)]);
end

handles.numSubplots = size(handles.DisplayData,4);
% if there are more than one figure, make subplots
handles.numPlotCols = ceil(sqrt(handles.numSubplots));
handles.numPlotRows = ceil(handles.numSubplots/handles.numPlotCols);


% display image of current slice
for sp =1:handles.numSubplots
    subplot(handles.numPlotRows,handles.numPlotCols,sp);
    imagesc(flipud(handles.DisplayData(:,:,handles.slicePos,sp)),...
        [(~handles.absData)*-handles.ThresholdValue handles.ThresholdValue]);
    if handles.doTitles
        title(handles.titles{sp});
    end
    axis equal tight;
    colormap gray;
    colorbar
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DisplayDataGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DisplayDataGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to sliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% display image of current slice
handles.slicePos = round(get(hObject,'Value'));
% display image of current slice
for sp =1:handles.numSubplots
    subplot(handles.numPlotRows,handles.numPlotCols,sp);
    imagesc(flipud(handles.DisplayData(:,:,handles.slicePos,sp)),...
        [(~handles.absData)*-handles.ThresholdValue handles.ThresholdValue]);
    if handles.doTitles
        title(handles.titles{sp});
    end
    axis equal tight;
    colormap gray;
    colorbar
end

% set slider text
set(handles.sliceValue,'String',['Slice ' num2str(handles.slicePos) ...
    '/' num2str(handles.maxSlider)]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in playVolume.
function playVolume_Callback(hObject, eventdata, handles)
% hObject    handle to playVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(hObject,'String');

if strcmp(state,'Play Volume')
    set(hObject,'String','Stop');
    while true        
        if strcmp(get(hObject,'String'),'Play Volume')
            % if the loop is interrputed by the user then save the data and
            % quit
            guidata(hObject,handles);
            break
        end
        handles.slicePos = mod(handles.slicePos+1,handles.maxSlider+1);
        if handles.slicePos == 0
            handles.slicePos = 1;
        end
        % display image of current slice
        for sp =1:handles.numSubplots
            subplot(handles.numPlotRows,handles.numPlotCols,sp);
            imagesc(flipud(handles.DisplayData(:,:,handles.slicePos,sp)),...
        [(~handles.absData)*-handles.ThresholdValue handles.ThresholdValue]);
            if handles.doTitles
                title(handles.titles{sp});
            end
            axis equal tight;
            colormap gray;
            colorbar
        end
        pause(0.1);
        % set slider value
        set(handles.sliceSlider,'Value',handles.slicePos);
        % set slider text
        set(handles.sliceValue,'String',['Slice ' num2str(handles.slicePos) ...
            '/' num2str(handles.maxSlider)]);
    end
else
    set(hObject,'String','Play Volume');
end



% Update handles structure
guidata(hObject, handles);


% --- Executes when selected object is changed in dimensionPanel.
function dimensionPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in dimensionPanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.NewValue
    case handles.dim1
        handles.DisplayData = permute(handles.DisplayDataOrig,[3 2 1 4]);
    case handles.dim2
        handles.DisplayData = permute(handles.DisplayDataOrig,[1 3 2 4]);
    case handles.dim3
        handles.DisplayData = handles.DisplayDataOrig;
    otherwise
        handles.DisplayData = handles.DisplayDataOrig;
end

% set the slider maximum value
handles.maxSlider = size(handles.DisplayData,3);
set(handles.sliceSlider, 'Max', handles.maxSlider);
% set slider step size to 1
set(handles.sliceSlider,'SliderStep',[1 10]./(handles.maxSlider-1));
% set initial slice position
handles.slicePos = ceil(handles.maxSlider/2);
set(handles.sliceSlider,'Value',handles.slicePos);
set(handles.sliceValue,'String',['Slice ' num2str(handles.slicePos) ...
    '/' num2str(handles.maxSlider)]);

% display image of current slice
for sp =1:handles.numSubplots
    subplot(handles.numPlotRows,handles.numPlotCols,sp);
    imagesc(flipud(handles.DisplayData(:,:,handles.slicePos,sp)),...
        [(~handles.absData)*-handles.ThresholdValue handles.ThresholdValue]);
    if handles.doTitles
        title(handles.titles{sp});
    end
    axis equal tight;
    colormap gray;
    colorbar
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on slider movement.
function ThresholdSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% display image of current slice with new ThresholdSlider
threshSliderValue = round(get(hObject,'Value'));
handles.ThresholdValue = handles.maxValue*threshSliderValue/100;
% display image of current slice
for sp =1:handles.numSubplots
    subplot(handles.numPlotRows,handles.numPlotCols,sp);
    imagesc(flipud(handles.DisplayData(:,:,handles.slicePos,sp)),...
        [(~handles.absData)*-handles.ThresholdValue handles.ThresholdValue]);
    if handles.doTitles
        title(handles.titles{sp});
    end
    axis equal tight;
    colormap gray;
    colorbar
end

% set slider text
threshStr = sprintf('%.2g',handles.ThresholdValue);
set(handles.threshValueText,'String',['Threshold Value: ' threshStr]);

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function ThresholdSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function ThreshMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThreshMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of ThreshMaxEdit as a double

handles.maxValue = str2double(get(hObject,'String'));

% Update handles structure
guidata(hObject, handles);

ThresholdSlider_Callback(handles.ThresholdSlider, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ThreshMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
