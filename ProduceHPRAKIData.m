%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Produce HP filtered k-space data for HPRAKI
%% Fully sampled data was uploaded to directory:  HPRAKI\Data\MulticoilData\
%% Code by Zhyjin
%% 2024-11-13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ProduceHPRAKIData()
clear all;

Hc=10;  %%% parameter c of HP filter
Hw=2;   %%% parameter w of HP filter

C=40;  % number of fully sampled lines at k-space center
N=6;   % skip size

filepath=strcat('D:\HPRAKI\Data\HPRAKIData\N=',num2str(N),'_C=',num2str(C),'\');
mkdir(filepath);

  filename='brainmulticoil_file107_slice2.mat';   % AXFLAIR     Fig4, N=4,6      
%  filename='brainmulticoil_file467_slice2.mat';   % AXT1       Fig6,N=3,5
%  filename='brainmulticoil_file799_slice3.mat';   % AXT2POST   Fig7,N=4,7

test='D:\HPRAKI\Data\MulticoilData\';
filenamenew=strcat(test,filename);
load(filenamenew);
            
dim=size(Image3D);
Yres=dim(1);  % 320
Xres=dim(2);  % 320
Cres=dim(3);  % multicoil number  % 16

L=C/2;
Mask=zeros(Yres,Xres);
Mask(1:N:end,:)=1;
Mask(Yres/2-L+1:Yres/2+L,:)=1;
% Xres*Yres/sum(Mask(:))

for ch=1:Cres; 
    temp=Image3D(:,:,ch);  
    dataRef=fftshift(fft2(temp));               
    dataRef=10000*(dataRef./max(abs(dataRef(:))));               
    dataUnder=dataRef.*Mask;
 
    %%% HP filter %%%%%%%%%%
    for m=1:Yres;
        for n=1:Xres;
            ky=m-Yres/2;
            kx=n-Xres/2;
            HdataUnder(m,n)=dataUnder(m,n).*(1-1/(1+exp((sqrt(kx.^2+ky.^2)-Hc)/Hw))+1/(1+exp((sqrt(kx.^2+ky.^2)+Hc)/Hw)));                     
        end
    end

%     imshow(abs(dataRef),[0 100]); title ('full sampled');
%     figure;imshow(abs(dataUnder),[0 100]);title ('Under-sampled k-space');        
%     figure;imshow(abs(HdataUnder),[0 100]);title ('High pass filtered');
    
    imagsRef(:,:,ch)=dataRef;
    imagsUnder(:,:,ch)=HdataUnder;
end

imags=permute(single(imagsRef),[2 1 3]);
filepathref=strcat('D:\HPRAKI\Data\RefData\');
mkdir(filepathref);
filenameref=strcat(filepathref,filename);   
save(filenameref,'imags'); 

imags=permute(single(imagsUnder),[2 1 3]);          
filenameRAKI=strcat(filepath,filename);  
save(filenameRAKI,'imags');









