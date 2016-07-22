function Idetrended = DetrendIntensityHorizontallyDownSample(I,BinaryMask,DSFactor)
% Remove the linear component of horizontal trend channel-wise
%
% Idetrended = DetrendIntensityHorizontally(I,BinaryMask)
%
% INPUTS
% 1) I: RGB histological image
% 2) BinaryMask: mask flaging with 1 pixels in I belonging to the
%    histological sample, 0 otherwise.
% 3) DSFactor: downsampling factor. Linear trends are estimated on a
%    downsampled version of the image and of the mask, to reduced the risk
%    of overfitting when very big images are employed. This parameter can
%    be controlled with DSFactor (in the range (0,1]).
%
% OUTPUT
% Idetrended: RGB image where the linear component of horizontal trends
%    have been removed from I in the three channel separately. Pixels
%    outside the tissue (i.e. pixels where BinaryMask = 0) are not changed.
%
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

% Downsample image and mask for calculation
Ismall = imresize(I,DSFactor);
BinaryMasksmall = imresize(BinaryMask,DSFactor);

% Extract the three channels
Rsmall = Ismall(:,:,1); Gsmall = Ismall(:,:,2); Bsmall = Ismall(:,:,3);
R = I(:,:,1); G = I(:,:,2); B = I(:,:,3); 

% Clear some memory
clear I;  

% Create an image storing the indices of the columns
[rows,cols] = size(Rsmall);
[rowsOrig,colsOrig] = size(R);

colsMat = single( repmat( 1:cols , rows , 1 ) );  % Matrix storing the column index of each pixel 
colsMatOrig = single( repmat( 1:colsOrig , rowsOrig , 1 ) );  % Matrix storing the column index of each pixel

% Extract pixels within the tissue mask and corresponding column index
redPixels = single(Rsmall(BinaryMasksmall==1)); 
greenPixels = single(Gsmall(BinaryMasksmall==1));
bluePixels = single(Bsmall(BinaryMasksmall==1));

% Extract indices of columns within the tissue mask
columnsPixels = single(colsMat(BinaryMasksmall==1));

% Fit a linear trend as a function of the column index
polCoeffsRed = polyfit(columnsPixels,redPixels,1);
polCoeffsGreen = polyfit(columnsPixels,greenPixels,1);
polCoeffsBlue = polyfit(columnsPixels,bluePixels,1);

% Clear some memory
clear columnsPixels redPixels greenPixels bluePixels

% Remove linear trends
Rdetrended = uint8(single(R) - DSFactor*polCoeffsRed(1)*colsMatOrig);
Gdetrended = uint8(single(G) - DSFactor*polCoeffsGreen(1)*colsMatOrig);
Bdetrended = uint8(single(B) - DSFactor*polCoeffsBlue(1)*colsMatOrig);

% Do not change values of the R, G and B channels in pixels outside the
% tissue (i.e. in the background)
Rdetrended(BinaryMask==0) = R(BinaryMask==0);
Gdetrended(BinaryMask==0) = G(BinaryMask==0);
Bdetrended(BinaryMask==0) = B(BinaryMask==0);

% Clear some memory
clear R G B colsMat

% Output
Idetrended = cat(3,Rdetrended,Gdetrended,Bdetrended);


end