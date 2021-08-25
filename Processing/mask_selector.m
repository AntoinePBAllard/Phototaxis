%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Since MatPIV is giving some problems with the Mask. Hence, I am imposing
%the mask after obtaining the filtered vector field. This is done in the
%follwing way:
%
%I draw a the ROI region over a speckle image and the points within
%the ROI are set to NaN
%Jorge Arrieta, Esporles, 05/05/2021
%v1 Antoine Allard: implementation of a more controlled mask which is half
%a circle plus a rectangle for the pipette. Adapted from getcenter.m from
%MP and RJ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mask=mask_selector(img)

% Display the image in two subplots: one allows to change the mask, the
% second show the result
figure;
set(gcf,'units','centimeters','position',[5 5 20 10]) % width x height
C = double(img);
for i = 2:-1:1
    subplot(1,2,i)
    pcolor_Gray(C);
end

x = 1:size(img,1);
y = 1:size(img,2);
[X,Y] = meshgrid(y,x);

roi = drawcircle(gca,'Color','m',...
    'Center',floor([size(img,1) size(img,2)]/2),...
    'Radius',floor(size(img,1)/20));
 
uicontrol('Units','Normalized','Position',[0.7 0.12 0.1 0.1],'String','Select',...
               'Callback',{@select_OutputFcn});          
j=0;
while(1)
    pause(2)
    xc=roi.Center(1); %coordinates of the center.
    yc=roi.Center(2);
    Rc=roi.Radius;
    mask = ((X-xc).^2+(Y-yc).^2 > Rc^2) & ...
        ~((X > xc) & (abs(Y - yc) < Rc));
    subplot(1,2,2)
    pcolor_Gray(C.*mask)
    if j>=1
        closereq;
        break;
    end
end

function select_OutputFcn(~,~)
    j=1;
end

end
