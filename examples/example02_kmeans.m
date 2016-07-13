%% Example 02: segment the darkest area of an image using kmeans on RGB values
%
% This script segments a target region depending on the image intensity
% with k-means approach applied to the RGB values. Afterwards, the fraction
% of segmented pixels within patches of specificed regions is calculated
% and shown as a quantitative patch-wise fraction map.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

toolboxdir = fileparts(pwd);
addpath(genpath(toolboxdir));

%% Load data
I = imread('rectangles_color.tif');
mymask = true(size(I,1),size(I,2));
PW = size(I,2); % Patch-width
PH = size(I,1); % Patch-height
nclusters = 5;  % There are 5 different colours
nsegm = 10; % Repeat the segmentation 10 times to avoid local minima

%% Segment darkest rectangle
binaryimage = PerformPatchwiseKMeans_NClusters(I,mymask,PW,PH,nclusters,'cityblock',nsegm);


%% Extract patch-by-patch segmented fraction
myPatchWidth = 60;  % Patch width in number of pixels
myPatchHeight = 30; % Patch height in number of pixels 
[FracNativeRes, FracPathRes] = ExtractPatchwiseSegmentedFraction(binaryimage,ones(size(binaryimage)),myPatchWidth,myPatchHeight);  % Get segmented pixel fraction within the patches

%% Plot segmentation
figure, 
subplot(3,1,1)
imshow(I)
title('Original image')
subplot(3,1,2)
imshow(cat(3,binaryimage,binaryimage,binaryimage));
title('Segmented image: find the darkest rectangle')
subplot(3,1,3)
imagesc(FracNativeRes,[0 1]); axis image; colorbar;
title('Patch-wise segmented pixel fraction map')
set(gca,'XTick',[],'YTick',[]);
