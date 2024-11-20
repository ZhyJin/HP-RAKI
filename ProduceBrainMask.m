% 2021-09-27
function BW=ProduceBrainMask(Image)

    T = graythresh(Image);
    BW=single(Image>T);
    
    BW= imfill(BW,'holes');
%   figure;imshow(BW,[]);










