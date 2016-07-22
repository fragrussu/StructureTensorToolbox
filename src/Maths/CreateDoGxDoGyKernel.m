function [DoGx, DoGy] = CreateDoGxDoGyKernel(sigma)
% Create 2D Derivative of Gaussians (DoGs) Kernels in the space domain.
%
% [DoGx, DoGy] = CreateDoGxDoGyKernel(sigma)
%
% INPUT
% sigma: standard deviation of the 2D Guassian whose derivatives with 
%        respect to x and y will be the filter coefficients provided as 
%        outputs. It must be numeric, > 0 and in pixel units.
%
% OUTPUT
% DoGx: filter coefficients for derivative with respect to x.
% DoGy: filter coefficients for derivative with respect to y.
%
% ALGORITHM
% For a given sigma, the output masks will have 2R + 1 coefficients, with 
% R = ceil( 3.57160625*sigma ), s.t. the smallest filter coefficient 
% in the central row and column will be 1% of the peak amplitude, in 
% absolute value.
%
% For a given sigma, the following formula is implemented:
%
% DoGx(x,y) = -(x/(2*pi*sigma^4))*exp(-(x^2 + y^2)/(2*sigma^2))
% DoGy(x,y) = -(y/(2*pi*sigma^4))*exp(-(x^2 + y^2)/(2*sigma^2))
%
% for x = -R, -R+1, ..., 0 , R-1, R  and  y = -R, -R+1, ..., 0 , R-1, R.
%
% x refers to the horizontal direction in the image space domain;
% y refers to the vertical direction in the image space domain.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors

% Throw an error in case of wrong number of input parameters
if(nargin~=1)
    error('CreateDoGxDoGyKernel(): wrong number of input arguments.');
end

% Throw an error if sigma is not numeric
if(isnumeric(sigma)~=true)
    error('CreateDoGxDoGyKernel(): sigma must be numeric.');
end

% Throw an error if sigma is not > 0
if(sigma<=0)
    error('CreateDoGxDoGyKernel(): sigma must be > 0.');
end


%%% Calculate 2D DoG coefficients
R = ceil(3.57160625*sigma);  % Filter size
[X,Y] = meshgrid(-R:1:R,-R:1:R);
DoGx = -(X/(2*pi*sigma*sigma*sigma*sigma)).*exp(-(X.^2 + Y.^2)/(2*sigma*sigma));
DoGy = -(Y/(2*pi*sigma*sigma*sigma*sigma)).*exp(-(X.^2 + Y.^2)/(2*sigma*sigma));

end
