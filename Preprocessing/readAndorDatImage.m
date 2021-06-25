%% This has been downloaded from Matworks on the 2021-05-27
%% I changed few things to make it work, e.g. the part with the C++ code was not working

function [andorImage, bFileDoesNotExist] = readAndorDatImage(rawDataFileName, param_file_name)
%param_file_name = '/acquisitionmetadata.ini';
%rawDataFileName = '/XXXXXspool.dat';

% parse the paramFile here
param_ch1 = struct('fileName', param_file_name);
param_file_ptr = fopen (param_file_name, 'r');
tokeniser = '=';
file = textscan(param_file_ptr,'%s','Delimiter','\n');
file = file{1};
for i = 1:length(file)
    line = file{i};
    if ~isempty(line) && ~contains(line,'[')
        paramValue = line ((strfind (line, tokeniser) + 2):end);
        paramName = line (1:(strfind (line, tokeniser) - 2));
        if (contains(paramName, 'AOI'))
            paramValue = str2double(paramValue);
        end
        if (contains(paramName, 'Bytes'))
            paramValue = str2double(paramValue);
        end
        if (contains(paramName, 'ImagesPerFile'))
            paramValue = str2double(paramValue);
        end
        param_ch1.(paramName) = paramValue;
    end
end
fclose(param_file_ptr);

% Original:Call C function to readAndor dat file
% Here I created a m version instead of c
filePtr = fopen(rawDataFileName);
if (filePtr == -1)
    bFileDoesNotExist = 1;
else
    bFileDoesNotExist = 0;
    fclose (filePtr);
end
if (bFileDoesNotExist)
    andorImage = zeros(param_ch1.AOIWidth, param_ch1.AOIHeight);
else
    andorImage = readAndorDatFile(rawDataFileName,param_ch1);
end

andorImage = uint16(andorImage);

end
