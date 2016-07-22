function [Iout] = PreprocessInputImage(Iin)
% Preprocessing for the HistologyImgProcToolbox.
%
% [Iout] = PreprocessInputImage(Iin)
%
% INPUT:
% Iin, a gray scale or RGB image as returned by imread().
% It must be either a 2D (gray scale) or 3D (RGB) image.
%
% OUTPUT:
% Iout, preprocessed version of Iin.
% Iout is the conversion of Iin to gray scale first (if Iin is RGB) and 
% then to double precision. It will be a matrix of double precision data
% with size size(Iin,1) x size(Iin,2) 
%
% WARNING:
% PreprocessInputImage() will only deal with 2D or 3D inputs. 
% A 2D input will be considered as a gray scale image.
% A 3D input will be considered as a RGB image.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors

% Throw an error in case of wrong number of input parameters
if(nargin~=1)
    error('PreprocessInputImage(): wrong number of input arguments.');
end

% Throw an error in case input image is not numeric
if( isnumeric(Iin)~=1)
    error('PreprocessInputImage(): input image must be numeric.');
end

% Throw an error in case input image is not 2D (gray scale) or 3D (RGB)
if( ( length(size(Iin))>3 ) || (isvector(Iin)==1)  )
    error('PreprocessInputImage(): input image must be either 2D (grayscale) or 3D (RGB).');
end

%%% Convert image to gray scale (if rgb) and then to double precision
if(length(size(Iin))==2)  % Gray scale image
   Iout = double(Iin);
elseif(length(size(Iin))==3) % RGB image
   Iout = double(rgb2gray(Iin));
end


end