function [ST] = CreateStructureTensorStruct(sigmaGauss,sigmaDoG,normalizeGaussFlag)
% Create a struct for Structural Tensor (ST) analysis. 
%
% [ST]=CreateStructureTensorStruct(sigmaGauss,sigmaDoG,normalizeGaussFlag)
%
%
% INPUTS 
% sigmaGauss: standard deviation of Gaussian kernel used to weight the 
%             neighbourhood of each pixel when evaluating the local ST.
%             It must be numeric, > 0 and in pixel units.
%
% sigmaDoG: standard deviation of Derivative of Gaussians (DoGs) kernels
%           used to approximate image partial derivatives with respect to 
%           both x and y. It must be numeric, > 0 and in pixel units. 
%
% normalizeGaussFlag: logical flag to control normalization of kernels.
%                     If == true, the Gaussian kernel G(x,y) will be such
%                     that  sum_over_x(sum_over_y(  G(x,y) )  ) = 1.
%
%            
%
% OUTPUT
% ST: a Structure Tensor struct. It has the following fields fields.
%     1) ST.GaussianKernel: coefficients of the Gaussian kernel;
%     2) ST.DoGxKernel: coefficients of the DoGx kernel (derivative with 
%        respect to x);
%     3) ST.DoGyKernel: coefficients of the DoGy kernel (derivative with 
%        respect to y).
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors

% Throw an error in case of wrong number of input parameters
if(nargin~=3)
    error('CreateStructureTensorStruct(): wrong number of input arguments.');
end

% Throw an error if sigma is not numeric
if( (isnumeric(sigmaGauss)~=true) || (isnumeric(sigmaDoG)~=true) )  
    error('CreateStructureTensorStruct(): kernel standard deviations must be numeric.');
end

% Throw an error if sigma is not > 0
if( (sigmaGauss<=0) || (sigmaDoG<=0) )
    error('CreateStructureTensorStruct(): kernel standard deviations must be > 0.');
end

% Throw an error if normalizeGaussFlag is wrong.
if(islogical(normalizeGaussFlag)~=true)
       error('CreateStructureTensorStruct(): normalizeGaussFlag must be logical.');
end

%%% Create ST struct (kernel information)
ST.GaussianKernel = CreateGaussianKernel(sigmaGauss,normalizeGaussFlag);
[ST.DoGxKernel, ST.DoGyKernel] = CreateDoGxDoGyKernel(sigmaDoG);

end

