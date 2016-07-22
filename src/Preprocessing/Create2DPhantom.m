function [img] = Create2DPhantom(thetaRot, NX, NY, T)
% Create a 2D cosinusoidal grid to test local estimates of orientation. 
%
% [img] = Create2DPhantom(thetaRot, NX, NY, T)
%
% INPUT
% thetaRot: orientation of grid stripes (in degrees). thetaRot = 0 implies
%           horizontal stripes (i.e. constant gray values along the 
%           horizontal axis). Positive/negative values of thetaRot rotate the 
%           horizontal stripes counter-clockwise/clockwise.
% NX:       number of pixels along the x axis (horizontal direction).
% NY:       number of pixels along the y axis (vertical direction). 
% T:        period of the grid (in pixel). 
%
% OUTPUT
% img:      a NY x NX matrix of double precision numbers representing the 
%           desired grid. Values range in [0;255].
%
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors

% Throw an error in case of wrong number of input parameters
if(nargin~=4)
    error('Create2DPhantom(): wrong number of input arguments.');
end

% Throw an error in case of non-numeric inputs
if( (isnumeric(thetaRot)~=1 ) || (isnumeric(NX)~=1 ) || (isnumeric(NY)~=1 ) || (isnumeric(T)~=1 ) )
    error('Create2DPhantom(): all input arguments must be numeric.');
end

% Throw an error in case of non-scalar inputs
if( (isscalar(thetaRot)~=1 ) || (isscalar(NX)~=1 ) || (isscalar(NY)~=1 ) || (isscalar(T)~=1 ) )
    error('Create2DPhantom(): all input arguments must be scalars.');
end

% Throw an error in case of non-positive image sizes or grid period
if( (NX <=0 ) || (NY <= 0) || ( T<=0 ) )
    error('Create2DPhantom(): image size and grid period must be > 0.');
end


%%% Get the grid 

% Generate a grid with horizontal stripes, 5 times bigger than the desidered size of the output
mm = 5;   
img = zeros(NY*mm,NX*mm);
t = 1:mm*NY;
for cc=1:mm*NX
    
    img(:,cc) = cos(2*pi*(t/T));
    
end

% Rotate the grid of the specified angle
img = imrotate(img,thetaRot,'bilinear');

% Crop the image to the desired size
img = 255*( img(2*NY:3*NY-1,2*NX:3*NX-1) +1)/2;

end