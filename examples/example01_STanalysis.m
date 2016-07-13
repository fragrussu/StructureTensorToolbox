%% Example 01: calculate pixel-wise structure tensor and tensor statistics
%
% This script shows how to calculate the structure tensor of an image
% and how to extract path-by-path directional statistics.
% The script divides the image in three patches, horizontally, from left to
% right, and prints information about the orientation distrobution in each
% patch.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

% Add the toolbox
toolboxdir = fileparts(pwd);
addpath(genpath(toolboxdir));

%% Load data

% Parameters for structure tensor analysis and statistics
sigma_DoG = 0.27;  % Standard deviation of derivative-of-gaussian (DoG) kernels [pixel]
sigma_gauss = 3;   % Standard deviation of Gaussian kernel [pixel]
patch_width = 152;   % Patch width: we divide the image in three patches
patch_height = 158;  % Patch height: we divide the image in three patches
nbins_or = 128;     % Number of bins for orientation histogram
nbins_ai = 128;     % Number of bins for anisotropy histogram

% Load data
I = imread('lines.png');
img = PreprocessInputImage(I);
ColourWheel = imread('HueCircleFull_alpha.png');

% Load maks: evaluate statistics using only pixels belonging to the lines
mymask = logical(imread('lines_binarymask.png'));

%% Perform ST analysis and directional statistics

% Create Structure Tensor struct
ST = CreateStructureTensorStruct(sigma_gauss,sigma_DoG,true);

% Calculate the Structure Tensor (an additional input for multi-thread
% processing can be added)
ST = ApplyStructureTensorStruct(img,ST);

% Extract patch-wise directional statistics
ST = ExtractStructureTensorStatistics(ST,mymask,patch_width,patch_height,nbins_or,nbins_ai);

% Get HSV representation of ST where the saturation channel encodes
% anisotropy
Ihsv = Tensor2HSNegativeV(rgb2gray(I),ST,0,1);

% Get maps in handy variables (maps at original resolution and at
% patch-by-patch, or paxel, resolution)
[STmaps_pixel_Watson, STmaps_paxel_Watson] = GetSTPatchwiseStatsMaps(ST,'Watson');
[STmaps_pixel_WeighWatson, STmaps_paxel_WeighWatson] = GetSTPatchwiseStatsMaps(ST,'WeightedWatson');
[STmaps_pixel_VonMises, STmaps_paxel_VonMises] = GetSTPatchwiseStatsMaps(ST,'VonMises');
[STmaps_pixel_WeighVonMises, STmaps_paxel_WeighVonMises] = GetSTPatchwiseStatsMaps(ST,'WeightedVonMises');
[STmaps_pixel_Gauss, STmaps_paxel_Gauss] = GetSTPatchwiseStatsMaps(ST,'Gaussian');
[STmaps_pixel_WeighGauss, STmaps_paxel_WeighGauss] = GetSTPatchwiseStatsMaps(ST,'WeightedGaussian');

%% Plot some information about the local orientations

% Show image and structure tensor
figure; 
subplot(2,1,1);
imshow(cat(1,I,Ihsv)); title('Top: image; bottom: HSV encoding of ST');
subplot(2,1,2);
imshow(ColourWheel); title('Colour-orientation map');

% Print some information for the different patches
fprintf('\n****************************************************\n')
fprintf('Directional statistics of image\n')
fprintf('****************************************************\n\n')

for pp=1:3
fprintf('\nPatch %d (from left to right)\n',pp)
fprintf('      Watson model:\n')
fprintf('          Mean = %f deg; CV = %f\n',STmaps_paxel_Watson.CircularMean(pp)*180/pi,STmaps_paxel_Watson.CircularVariance(pp))
fprintf('      weighted-Watson model:\n')
fprintf('          Mean = %f deg; CV = %f\n',STmaps_paxel_WeighWatson.CircularMean(pp)*180/pi,STmaps_paxel_WeighWatson.CircularVariance(pp))
fprintf('      Von Mises model:\n')
fprintf('          Mean = %f deg; CV = %f\n',STmaps_paxel_VonMises.CircularMean(pp)*180/pi,STmaps_paxel_Watson.CircularVariance(pp))
fprintf('      weighted-Von Mises model:\n')
fprintf('          Mean = %f deg; CV = %f\n',STmaps_paxel_WeighVonMises.CircularMean(pp)*180/pi,STmaps_paxel_WeighVonMises.CircularVariance(pp))
fprintf('      Gaussian model:\n')
fprintf('          Mean = %f deg; SD = %f deg\n',STmaps_paxel_Gauss.Mean(pp)*180/pi,STmaps_paxel_Gauss.Std(pp)*180/pi)
fprintf('      weighted-Gaussian model:\n')
fprintf('          Mean = %f deg; SD = %f deg\n',STmaps_paxel_WeighGauss.Mean(pp)*180/pi,STmaps_paxel_WeighGauss.Std(pp)*180/pi)
end
