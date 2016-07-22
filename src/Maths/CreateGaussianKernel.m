function [h] = CreateGaussianKernel(sigma,normalizeKernel)
% Create a 2D isotropic Gaussian Kernel in the image space domain.
%
% [h] = CreateGaussianKernel(sigma,normalizeKernel)
%
% INPUT
% sigma: standard deviation of the 2D Guassian kernel. It must be numeric, 
%        > 0 and in pixel units.
% normalizeKernel: logical value enabling (when true) or disabling (when 
%                  false) the normalization of the Gaussian kernel.
%
% OUTPUT
% h: filter coefficients
%
% ALGORITHM
% For a given sigma, the mask h will have 2R + 1 coefficients, with 
% R = ceil( 2*sigma*sqrt(log(10)) ), s.t. the smallest filter coefficient 
% in the central row and column will be 1% of the peak amplitude.
%
% For a given sigma, the following formula is implemented:
%
% G(x,y) = (1/(2*pi*sigma^2))*exp(-(x^2 + y^2)/(2*sigma^2))
%
% for x = -R, -R+1, ..., 0 , R-1, R  and  y = -R, -R+1, ..., 0 , R-1, R.
%
% If normalizeKernel is true, the output is h = G/sum(sum(G)); otherwise,
% it is simply h = G.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors

% Throw an error in case of wrong number of input parameters
if(nargin~=2)
    error('CreateGaussianKernel(): wrong number of input arguments.');
end

% Throw an error if sigma is not numeric
if(isnumeric(sigma)~=true)
    error('CreateGaussianKernel(): sigma must be numeric.');
end

% Throw an error if sigma is not > 0
if(sigma<=0)
    error('CreateGaussianKernel(): sigma must be > 0.');
end

% Throw an error if normalizeKernel is not logical
if(islogical(normalizeKernel)~=true)
    error('CreateGaussianKernel(): normalizeKernel must be logical.');
end


%%% Calculate 2D Gaussian kernel coefficients
R = ceil(2*sigma*sqrt(log(10)));  % Filter size
[X,Y] = meshgrid(-R:1:R,-R:1:R);
h = (1/(2*pi*sigma*sigma))*exp(-(X.^2 + Y.^2)/(2*sigma*sigma));

if(normalizeKernel==true)
   h = h/sum(sum(h));
end
    

end
