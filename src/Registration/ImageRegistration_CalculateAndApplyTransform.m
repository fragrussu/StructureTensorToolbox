function [imgMoved, xfm] = ImageRegistration_CalculateAndApplyTransform(imgMoving, imgFixed, PointsMoving, PointsFixed, varargin)
% Warp an an image to another given a set of corresponding points. 
%
% [imgMoved, xfm] = ...
% ImageRegistration_CalculateAndApplyTransform
%                          (imgMoving, imgFixed, PointsMoving, PointsFixed)
%
% [imgMoved, xfm] = ...
% ImageRegistration_CalculateAndApplyTransform
%    (imgMoving, imgFixed, PointsMoving, PointsFixed, TransformType, Param)
%
% [imgMoved, xfm] = ...
% ImageRegistration_CalculateAndApplyTransform
%    (imgMoving, imgFixed, PointsMoving, PointsFixed, xfm)
%
% This function takes as inputs the image to be warped, the reference
% image, a set of matching fiducial points from both images and calculates
% the registration transformation wrapping the image to be registered to the target.
% The calculated transformation is also applied and the warped image
% returned. By default it calculates a piece-wise linear transformation,
% but local-weighted means and polynomial transformations are also
% supported.
%
% INPUTS
% 1) imgMoving:                the image to be registered, on which warping 
%                              will be performed (it must have the same 
%                              size as imgFixed);
%
% 2) imgFixed:                 the target image for the registration (it 
%                              must have the same size as imgMoving); 
%  
% 3) PointsMoving:             coordinates of a set of points in imgMoving,
%                              as returned by
%                              ImageRegistration_GetMatchingPoints(); 
%
% 4) PointsFixed:              the corresponding points in the fixed image, 
%                              as returned by 
%                              ImageRegistration_GetMatchingPoints(); 
% 
% 5) TransformType (optional): it can be either the string 'polynomial' or
%                              the string 'lwm', to be passed to the
%                              function when the default piece-wise linear
%                              transformation are not suitable and either
%                              polinomial or local-weighted mean type of
%                              trasnformations are needed.
%
% 6) Param (optional):         if TransformType is passed, then Param 
%                              specifies either the polynomial order if 
%                              TransformType = 'polynomial' or the number of points
%                              to be used in the local-weighted mean calculation,
%                              if TransformType = 'lwm'.
%
% 7) xfm (optional):           a warping transformation estimated with
%                              fitgeotrans()
%
% OUTPUTS
% 1) imgMoved:                 imgMoving warped to imgFixed;
% 2) xfm:                      an object storing the transformation warping
%                              imgMoving to imgFixed. This transformation
%                              can be applied to any other image in the
%                              same space of imgMoving with imwarp().
%
% Note that imgMoving and imgFixed must have the same size. You may resize
% one of the two with imresize() prior to calling this function.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors
% Throw an error in case of wrong number of inputs
if( (nargin~=4)&&(nargin~=6)&&(nargin~=5) )
    error('ImageRegistration_EstimateTransform(): wrong numbers of inputs.')
end
% Throw an error in case of image sizes
if ( ( size(imgMoving,1) ~= size(imgFixed,1) )||( size(imgMoving,2) ~= size(imgFixed,2) )  )
        error('ImageRegistration_EstimateTransform(): the two input images must have the same size.')
end


%%% Estimate the registration transformation
if(nargin==4)
    % Only 4 inputs: the user requires a piece-wise linear transform
    %fprintf('\n\nImageRegistration_EstimateTransform(): estimating a piecewise linear transform. Please wait...\n\n');
    xfm = fitgeotrans(PointsMoving, PointsFixed,'pwl');
elseif(nargin==6)
    % 6 inputs: the user requires a different transforms and specifies a parameter    
    xfmStr = varargin{1};
    xfmParm = varargin{2};
    switch xfmStr
        case 'polynomial' 
              fprintf('\n\nImageRegistration_EstimateTransform(): estimating a polynomial transformation of order %d. Please wait...\n\n',xfmParm);
        case 'lwm' 
              fprintf('\n\nImageRegistration_EstimateTransform(): estimating a local weighted mean transformation of order %d. Please wait...\n\n',xfmParm);
        otherwise 
              fprintf('The transformation you chose is not supported. Returning...');
              return
    end
    xfm = fitgeotrans(PointsMoving, PointsFixed,xfmStr,xfmParm);
elseif(nargin==5)
    % 5 inputs: the user provides a transform already estimated with
    % fitgeotrans()
    xfm = varargin{1};
end

%%% Wrap the moving image with the estimated transformation
imgMoved = imwarp(imgMoving,xfm,'OutputView',imref2d(size(imgFixed)));


end
