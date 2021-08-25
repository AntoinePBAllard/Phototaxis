clearvars
workingDir = 'E:\ELN\AA024 - Eyespot photostimulation of CC125 held in pipette\2021-08-17\';
cd(workingDir)
warning('off', 'MATLAB:MKDIR:DirectoryExists');
storageDir = [workingDir 'Tiff\'];
mkdir(storageDir)
addpath(workingDir); addpath(storageDir);
vidNames = dir(fullfile(workingDir, '*.avi'));

for j=1:length(vidNames)
%     if vidNames(j).bytes > 4e8
        folderName = sprintf('%s', vidNames(j).name);
        folderName = folderName(1:end-4); % This removes .avi 
        mkdir([storageDir, folderName])
        SMV = VideoReader([workingDir vidNames(j).name]);

        for f = 1:SMV.NumFrames
            filename = [sprintf('img%05d',f) '.tiff'];
            fullname = fullfile(storageDir, folderName, filename);
            if ~isfile(fullname)
                img = read(SMV,f); % The camera save in rgb, but image is grey. b = mean, r = mean-1 and g = mean+1
                img = img(:,:,3);
                imwrite(img, fullname)
            end
        end
%     end
end
warning('on', 'MATLAB:MKDIR:DirectoryExists');