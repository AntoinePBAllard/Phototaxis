function [x,y,u,v,snr,su,sv,gu,gv,lu,lv,fu,fv] = doPIV(img1,img2,interrogation_window,overlap)
    [x,y,u,v,snr]=matpiv(img1,img2,interrogation_window,1,overlap,'multin');
    [su,sv]=snrfilt(x,y,u,v,snr,1.3);%signal to noise filter
    [gu,gv]=globfilt(x,y,su,sv,5);%Global filter running - with limit: 5 *std [U V]
    [lu,lv]=localfilt(x,y,gu,gv,3,'median',3);
    [fu,fv]=naninterp(lu,lv,'cubic');
end
