% script to read eScan data
% Julio Lobo (May 2014)
clear; clc; close all;

[f,p] = uigetfile('*.*');
% % can pick any array of frame numbers to read
% planeNum = 40;
% fpp = 20;
% frameNumbers = (planeNum-1)*(fpp-1)+(1:(fpp-1));
frameNumbers = 1:500;
[data, header] = ReadEscanDataBlock(fullfile(p,f),frameNumbers);
% [data, header] = ReadEscanData(fullfile(p,f));


% % the following function will just read the whole file
% [data, header] = ReadEscanData(fullfile(p,f));
if header(2) == 14 % timeStamp data
    data = squeeze(data);
    plot(data)
elseif header(2) ==3 % absolute elasticity
    maxVal = 50;
    data(data>maxVal) = maxVal; % scale data
    DisplayDataGui(data)
elseif header(2) == 7 % time disp
%     maxVal = 5e-5;
%     minVal = -5e-5;
%     maxVal = 15e-5;
%     minVal = -15e-5;
%     data(data>maxVal) = maxVal;
%     data(data<minVal) = minVal;
    DisplayDataGui(data)
elseif header(2) == 8 % abs phasor
    maxVal = 15e-5;
    data(data>maxVal) = maxVal; % scale data
    DisplayDataGui(data)

else
    DisplayDataGui(data)
end

