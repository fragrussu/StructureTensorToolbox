function Idetrended = DetrendIntensityHorizontally(I,BinaryMask)
% Remove the linear component of horizontal trend channel-wise
%
% Idetrended = DetrendIntensityHorizontally(I,BinaryMask)
%
% INPUTS
% 1) I: RGB histological image
% 2) BinaryMask: mask flaging with 1 pixels in I belonging to the
%    histological sample, 0 otherwise.
%
% OUTPUT
% Idetrended: RGB image where the linear component of horizontal trends
%    have been removed from I in the three channel separately. Pixels
%    outside the tissue (i.e. pixels where BinaryMask = 0) are not changed.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

% Extract the three channels
R = I(:,:,1); G = I(:,:,2); B = I(:,:,3); 

% Clear some memory
clear I;  

% Create an image storing the indices of the columns
[rows,cols] = size(R);
colsMat = single( repmat( 1:cols , rows , 1 ) );  % Matrix storing the column index of each pixel 


% Extract pixels within the tissue mask and corresponding column index
redPixels = single(R(BinaryMask==1)); 
greenPixels = single(G(BinaryMask==1));
bluePixels = single(B(BinaryMask==1));

% Extract indices of columns within the tissue mask
columnsPixels = single(colsMat(BinaryMask==1));

% Fit a linear trend as a function of the column index
polCoeffsRed = polyfit(columnsPixels,redPixels,1);
polCoeffsGreen = polyfit(columnsPixels,greenPixels,1);
polCoeffsBlue = polyfit(columnsPixels,bluePixels,1);

% Clear some memory
clear columnsPixels redPixels greenPixels bluePixels

% Remove linear trends
Rdetrended = uint8(single(R) - polCoeffsRed(1)*colsMat);
Gdetrended = uint8(single(G) - polCoeffsGreen(1)*colsMat);
Bdetrended = uint8(single(B) - polCoeffsBlue(1)*colsMat);

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