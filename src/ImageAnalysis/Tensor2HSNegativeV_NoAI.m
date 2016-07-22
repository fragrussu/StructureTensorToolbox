function [imgHSV] = Tensor2HSNegativeV_NoAI(img,ST,HueThetaZero,HueThetaPi)
% Create an image where ST information is encoded in the HSV space.
% 
%      [imgHSV] = Tensor2HSNegativeV_NoAI(img,ST,HueThetaZero,HueThetaPi)
%
% Creates an image where tensor orientation encodes Hue and image intensity
% encodes 1 - Value. Saturation is set to 1 for all pixels.
%
% INPUTS
%
% img:          a grayscale image 
%               (it must be a 2D uint8 matrix ranging in 0-255);
% ST:           the ST relative to image img;
% HueThetaZero: the hue intensity to be mapped to values of 
%               ST.Tensor.Orientation equal to 0;
% HueThetaPi:   the hue intensity to be mapped to values of 
%               ST.Tensor.Orientation equal to pi.
%
% OUTPUT
% imgHSV:       the image where orientation and 
%               intensity respectively encode H and 1 - V. Image is fully
%               saturated.
%
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

% Check for errors
if(nargin~=4)
   error('Tensor2HSNegativeV_NoAI(): wrong number of input arguments.'); 
end

if( (size(img,3)~=1)||(isinteger(img)~=1))
    error('Tensor2HSNegativeV_NoAI(): input img must be a integer, grayscale image - use rgb2gray().');
end

if( (isnumeric(HueThetaZero)==0)||(isscalar(HueThetaZero)==0)||(isnumeric(HueThetaPi)==0)||(isscalar(HueThetaPi)==0) )
    error('Tensor2HSNegativeV_NoAI(): HueThetaZero and HueThetaPi must be numeric scalars.');
end

if((HueThetaZero<0)||(HueThetaZero>=1)||(HueThetaPi<=0)||(HueThetaPi>1)||(HueThetaZero>=HueThetaPi))
    error('Tensor2HSNegativeV_NoAI(): HueThetaZero must range in [0; 1) and HueThetaPi in (0;1] with HueThetaPi>HueThetaZero.');
end

% Map Tensor Orientation and image intensity as H and 1 - V
H = HueThetaZero + (1/pi)*(HueThetaPi - HueThetaZero)*ST.Tensor.Orientation;
S = ones(size(img,1),size(img,2));
V = 1 - double(img)/255;
% Convert from HSV to RGB
imgHSV = hsv2rgb(cat(3,H,S,V));
imgHSV = uint8(255*imgHSV);

end

