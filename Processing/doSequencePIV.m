%% This code results from the combined work of Jorge Arrieta and Antoine Allard
%
% It uses MatPIV to extract the displacement field between two frames.
% MatPiv 1.7 should be added to your path before running this function
% v0: created the 23/06/2021
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INPUT
% path: (string) folder that contains .tif files
% numImage: 1xN matrix that lists the N images to analyse
% delta: 1x1 double, the number of images between 2 images for doing piv (default: 1) 
% interrogation_window: Mx2 matrix, where M is the number of pass of
% corresponding interrogation window for the PIV analysis
% overlap: 1x1 double, overlap for the PIV analysis
% pix2um: 1x1 double, conversion factor from pixel to um (magnification in um/pxls);
% frame_rate: 1x1 double, frame rate per second

function [mask,x,y,U,V,FU,FV] = doSequencePIV(path,numImage,delta,interrogation_window,overlap,mask)

addpath(genpath('E:\Codes\Matlab\MatPIV 1.7'))

if nargin < 1 || isempty(path) % If no path is specified, then ask user to select a folder
    path = uigetdir([],'Select a folder that contains .tif files');
end

% Lists the .tif (and .tiff) files
tifFiles = dir(fullfile(path,'*.tif*'));

if isempty(tifFiles)
    error('No .tif (nor .tiff) files found')
else
    tifFilesName = {tifFiles.name};
end

if nargin < 2
    numImage = listdlg('PromptString','Select >2 .tif files','ListString',tifFilesName);
end

if length(numImage) < 2
    error('Number of images should be higher than 2.')
end

if nargin < 3
    delta = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Parameters for the PIV/GPV analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
    interrogation_window = [128 128;64 64;32 32];
end

if nargin < 5
    overlap = 0.75;
end

if overlap >= 1 || overlap <= 0
    error('Overlap should be lower than 1 and positive')
end

    
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Parameters to crop the image to avoid the errors in the expansion in
%multipass 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img0 = imread(fullfile(path,tifFilesName{1}));
width=floor(size(img0,1)/(max(interrogation_window(:))))*(max(interrogation_window(:)));
height=floor(size(img0,2)/(max(interrogation_window(:))))*(max(interrogation_window(:)));
x_min=0;
y_min=0;
rect=[x_min y_min height width];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This section is devoted to calculate the median used to obtain the 
%speckle pattern
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nMed = min(100,length(numImage));
img = zeros(rect(4),rect(3),nMed);
ii = 0;
for n = numImage(1:nMed)
    ii = ii+1;
    tmp = imread(fullfile(path,tifFilesName{n}));
    img(:,:,ii) = flip(imcrop(flip(tmp,1),rect),1);
end
med_image = median(img,3);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%In this section we invoke the MatPIV algorithm with a multipass algorithm
%The number of passes is indicated by the array interrogation window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First we mask the region around the cell and the pipette and define 
%the magnification of the system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 6 || isempty(mask)
    mask = mask_selector(img(:,:,1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Then we run the PIV analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = length(numImage);
warning('off','MATLAB:inpolygon:ModelingWorldLower')
U=cell(n-delta,1);
V=U;SNR=U;SU=U;SV=U;GU=U;GV=U;LU=U;LV=U;FU=U;FV=U;
h = waitbar(0,'Remaining time: ');
for ii=1:n-delta
    tStart = tic;
    imgTmp = imread(fullfile(path,tifFilesName{numImage(ii)}));
    imgTmpCrop = flip(imcrop(flip(double(imgTmp),1),rect),1);
    img1 = imgTmpCrop - med_image;
    imgTmp = imread(fullfile(path,tifFilesName{numImage(ii+delta)}));
    imgTmpCrop = flip(imcrop(flip(double(imgTmp),1),rect),1);
    img2 = imgTmpCrop - med_image;
    [x,y,u,v,snr,su,sv,gu,gv,lu,lv,fu,fv] = doPIV(img1,img2,interrogation_window,overlap);
    U{ii} = u; V{ii} = v; SNR{ii} = snr; SU{ii} = su; SV{ii} = sv;
    GU{ii} = gu;    GV{ii} = gv;
    SU{ii} = su;    SV{ii} = sv;
    GU{ii} = gu;    GV{ii} = gv;
    LU{ii} = lu;    LV{ii} = lv;
    FU{ii} = fu;    FV{ii} = fv;
    t = toc(tStart);
    waitbar(ii/(n-1),h,['Remaining time: '...
    num2str(round(t*(n-1-ii)/60)) ' min']);
end
delete(h)
warning('on','MATLAB:inpolygon:ModelingWorldLower')
end