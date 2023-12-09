% function to read a specific frame numbers from escan data.
% the user can select any array of frame numbers e.g.
% frameNumbers = [1 2 9 5] would read frames 1 2 5 and 9, that order.
% frameNumbers = [31:60] would read the 30 frames from 31 to 60 in order.
% frame numbers that re out of range are just skipped
% Julio Lobo (May 2014)

function [data, header] = ReadEscanDataBlock(filename, frameNumbers)

fid = fopen(filename);

if fid < 0
    data = -1;
    return;
end

HEADER_SIZE_V1 = 6;

% read size of V1 header (subsequent versions should be at least this size)
header = fread(fid,HEADER_SIZE_V1,'int32');

switch header(1) % check the header version
    case 1 % version 1
    	dataType =  header(2);
        date =      header(3);
        tag =       header(4);
        numDims = 2;
        dims = zeros(numDims,1);
        dims(1) =     header(5); % width
        dims(2) =     header(6); % height
    case 2 % version 2
        dataType =  header(2);
        date =      header(3);
        tag =       header(4);
        numDims =   header(5);
        dims = zeros(numDims,1);
        % read the rest of the dimensions
        dims(2:end) = fread(fid,numDims-1,'int32'); % height, framesPerPlane, numPlanes, NUM_SWEEPS_PER_ACQ, scanConverted ? 1 : 0
        % keep the first dimension
        dims(1) =   header(6); % width
        % check if scan converted dimension is available, otherwise assume
        % the data was scan converted
        if numDims < 6
            scanConvert = 1;
        else
            scanConvert = dims(6);
        end
        % concatenate rest of dims with header
        header = [header;dims(2:end)];
    otherwise
        error('ReadEscanDataBlock: Unrecognized header version.');
end

% get the position of the start of the data
dataPos = ftell(fid);
% get the position of the end of the data
fseek(fid,0,'eof');
dataEnd = ftell(fid);

DataSize = dataEnd - dataPos;

switch dataType
    case -1 % assume N/A is type int
        dataPrecision = 'int32';
        BytesPerEntry = 4;
        DataSize = DataSize/4;
    case 1 % RF
        dataPrecision = 'short';
        BytesPerEntry = 2;
        DataSize = DataSize/2;
    case 2 % Bmode
        dataPrecision = 'uchar';
        BytesPerEntry = 1;
    case 13 % accelerometer
        dataPrecision = 'double';
        BytesPerEntry = 8;
        DataSize = DataSize/8;
    otherwise % all others
        dataPrecision = 'float';
        BytesPerEntry = 4;
        DataSize = DataSize/4;
end

totalNumberOfFrames = DataSize/dims(1)/dims(2);

% read in the requested frames
data = zeros(dims(2),dims(1),length(frameNumbers));
cnt = 0;
for fr = frameNumbers
    if (fr <= totalNumberOfFrames) && (fr > 0)     
        % go to the start of the frame you want
        fseek(fid, dataPos + dims(1)*dims(2)*(fr-1)*BytesPerEntry, 'bof');
        
        data_temp = fread(fid, dims(1)*dims(2), dataPrecision);
        % reshape and transpose data to match col major format
        cnt = cnt + 1;
        if dataType == 1 ... % RF data
           || ~scanConvert
            data(:,:,cnt) = reshape(data_temp, dims(2), dims(1));
        else
            data(:,:,cnt) = reshape(data_temp, dims(1), dims(2))';
        end
    end
end

if dataType == 7 || dataType == 15 % displacement time and correlation data
    data = permute(data,[2 1 3]);
end

% remove unread data
data = data(:,:,1:cnt);

fclose(fid);