
function ReconHPRAKI()
clear all

% addpath('C:\Program Files\MATLAB\R2018b\toolbox\images\images');
addpath('D:\HPRAKI\Code')

Hc=10;  %%% parameter c of HP filter
Hw=2;   %%% parameter w of HP filter

N=6;  % skip size
C=40; % fully sampled k-space center

allfilenames=dir(strcat('D:\HPRAKI\Data\HPRAKIData\N=',num2str(N),'_C=',num2str(C),'\*.mat'));
filepathrec=strcat('D:\HPRAKI\ReconImages\');

 slicename='brainmulticoil_file107_slice2.mat'; % Figure4 AXFLAIR 3T N=4,N=6
% slicename='brainmulticoil_file467_slice2.mat';   % Figure 6, T1, N=3, N=5
% slicename='brainmulticoil_file799_slice3.mat';   % Figure 7, AXT2POST N=4, N=7

fileslice=slicename(1:end-4);   
filepathref='D:\HPRAKI\Data\RefData\';
filenameref=strcat(filepathref,slicename);   
load (filenameref);   %%% imags
fullkspace=imags;

dim=size(imags);
Yres=dim(1);  % 320
Xres=dim(2);  % 320
Ch=dim(3);  
d1=1;

Mask=zeros(Yres,Xres,Ch);
Mask2D=zeros(Yres,Xres);
Mask2D(:,1:N:end)=1;
L=C/2;
Mask2D(:,Xres/2-L+1:Xres/2+L)=1;
for channel=1:Ch
    Mask(:,:,channel)=Mask2D;
end

filepath=strcat('D:\HPRAKI\Recon\HPRAKI\N=',num2str(N),num2str('_C='),num2str(C),'\');
filename=strcat(filepath,slicename);   
load (filename); 

%%% inverse HP filter  %%%%%%%%
for ch=1:Ch;
    for n=1:Xres;
        for m=1:Yres;
            kx=n-Xres/2;
            ky=m-Yres/2;
            kspace_recon(n,m,ch)=kspace_recon(n,m,ch)./(1-1/(1+exp((sqrt(kx.^2+ky.^2)-Hc)/Hw))+1/(1+exp((sqrt(kx.^2+ky.^2)+Hc)/Hw)));
        end
    end
end

FData=kspace_recon.*(1-Mask)+fullkspace.*Mask;   % data consistency    
Rec3D=zeros(Yres,Xres,Ch);

for ch=1:Ch;
    temp=FData(:,:,ch);
    Rec=ifft2(fftshift(temp));        
    Rec3D(:,:,ch)=Rec;      

    temp=fullkspace(:,:,ch);
    Image=ifft2(fftshift(temp)); 
    Image3D(:,:,ch)=Image;  

end

Rec3D=permute(Rec3D,[2 1 3]);
Image3D=permute(Image3D,[2 1 3]);

Stemp=double(abs(Image3D).^2);
Image=abs(sqrt(mean(Stemp,3)));
Stemp=double(abs(Rec3D).^2);
Rec=abs(sqrt(mean(Stemp,3)));

Image=Image/max(abs(Image(:)));
Rec=Rec/max(abs(Rec(:))); 

BW=ProduceBrainMask(Image); 
ImageMask=Image.*BW;
RecMask=Rec.*BW;

VSSIM=ssim(double(abs(RecMask)),double(abs(ImageMask)));
VPSNR=psnr(RecMask,ImageMask);
NMSE=immse(RecMask,ImageMask);

temp=rot90(abs(Image));
filename=strcat(filepathrec,fileslice,'_Ref_Mag.tif');
imwrite(mat2gray(double(abs(temp))),filename,'compression','none');  

temp=rot90(abs(Rec));
filename=strcat(filepathrec,fileslice,'_HPRAKI_Mag_N=',num2str(N),'_C=',num2str(C),'_Hc=',num2str(Hc),'_Hw=',num2str(Hw),'_SSIM=',num2str(VSSIM),'_PSNR=',num2str(VPSNR),'_NMSE=',num2str(NMSE),'.tif');    imwrite(mat2gray(double(abs(temp))),filename,'compression','none');  

