Zhaoyang Jin, Jiuwen Cao, Mei Zhang, Qing-San Xiang, Using High-Pass Filter to Enhance Scan Specific Learning for MRI Reconstruction without Any Extra Training Data, NeuroImage, 2024, 120926, ISSN 1053-8119, https://doi.org/10.1016/j.neuroimage.2024.120926
(https://www.sciencedirect.com/science/article/pii/S1053811924004233)


There are three steps for HP-RAKI reconstruction.

Step 1: 
Running ProduceHPRAKIData.m file: applying an HP filter to the under-sampled k-space data.
 
Step 2:
Training and prediction using RAKI software.

RAKI software used in this study was coded using pytorch, which was modified from the original RAKI code (using tensorflow). Considering the copyright statement of the original RAKI code, our pytorch code for RAKI have not been uploaded here. Original RAKI code can be downloaded at the link below.
https://github.com/zczam/RAKI
 
Step 3:
Running ReconHPRAKI.m file: applying an inverse HP filter to the predicted data from RAKI, and replacement with the original data wherever available.


Data used in this study was downloaded at the link below.
https://fastmri.med.nyu.edu/

An IDFT operation was performed on the downloaded multi-coil k-space datasets (320×640×16) to reconstruct MR images, which were resized to 320×320×16 after excluding air region. The dimensions of the reconstructed images were 320×320 per slice, all acquired with 16 coils. The DFT transform were applied on 320×320 images to obtain fully sampled k-space data, and various skip sizes N were used to obtain under-sampled k-space data with ACS lines fully sampled near k-space center.
