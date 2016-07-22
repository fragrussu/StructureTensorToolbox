function [imgMerged1,imgMerged2,imgMerged3,imgMerged4] = ImageRegistration_MergeQuarters(inputimg1,inputimg2)
% Merge images for visual inspection of the results of registration.
%
% [imgMerged1,imgMerged2,imgMerged3,imgMerged4] = ...
%                      ImageRegistration_MergeQuarters(inputimg1,inputimg2)
%
% The function divides inputimg1 and inputimg2 in 4 quarters and combines the
% quarters in 4 different ways. The two input images are both rescaled in the
% range [0;255] to make the visualisation easier. 
%
% INPUTS
% 1) inputimg1:  input image number 1 (es. registered image);
% 1) inputimg2:  input image number 2 (es. target to which img1 was registered).
%
% 
%
% OUTPUTS
% Defining the 4 qarters of the output images
%
%              Q1   Q2
%
%              Q3   Q4
%
% then the output images are as follow.
%
% 1) imgMerged1: Q1 = inputimage1; Q2 = inputimage1; 
%                Q3 = inputimage2; Q4 = inputimage2.
%
% 2) imgMerged2: Q1 = inputimage1; Q2 = inputimage1; 
%                Q3 = inputimage2; Q4 = inputimage2.
%
% 3) imgMerged3: Q1 = inputimage1; Q2 = inputimage2; 
%                Q3 = inputimage2; Q4 = inputimage1.
%
% 4) imgMerged4: Q1 = inputimage2; Q2 = inputimage1; 
%                Q3 = inputimage1; Q4 = inputimage2.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors
if(nargin~=2)
   error('ImageRegistration_MergeQuarters(): wrong number of input arguments.') 
end

if( (isnumeric(inputimg1)~=1)||(isnumeric(inputimg2)~=1) )
   error('ImageRegistration_MergeQuarters(): inputs must be numeric.') 
end

if( (ismatrix(inputimg1)~=1)||(ismatrix(inputimg2)~=1)  )
   error('ImageRegistration_MergeQuarters(): inputs must be matrices.') 
end

if( (size(inputimg1,1)~=size(inputimg2,1))||(size(inputimg1,2)~=size(inputimg2,2)) )
   error('ImageRegistration_MergeQuarters(): inputs must have the same size.') 
end

%%% Get image size and allocate outputs
[R,C] = size(inputimg1);

RHalf = round(R/2);
CHalf = round(C/2);

imgMerged1 = zeros(R,C);
imgMerged2 = zeros(R,C);
imgMerged3 = zeros(R,C);
imgMerged4 = zeros(R,C);

%%% Rescale input images in range [0; 255]
MaxVal = max( max( double( reshape( inputimg1, 1, numel( inputimg1 ) ) ) )  , max( double( reshape( inputimg2, 1, numel( inputimg2 ) ) ) ) );
MinVal = min( min( double( reshape( inputimg1, 1, numel( inputimg1 ) ) ) )  , min( double( reshape( inputimg2, 1, numel( inputimg2 ) ) ) ) );

img1 = (255/(MaxVal - MinVal))*(double(inputimg1) - MinVal);
img2 = (255/(MaxVal - MinVal))*(double(inputimg2) - MinVal);

%%% Merge rescaled input images
imgMerged1(1:RHalf,:) =  img1(1:RHalf,:);
imgMerged1(RHalf+1:R,:) =  img2(RHalf+1:R,:);

imgMerged2(:,1:CHalf) =  img1(:,1:CHalf);
imgMerged2(:,CHalf+1:C) =  img2(:,CHalf+1:C);

imgMerged3(1:RHalf,1:CHalf) = img1(1:RHalf,1:CHalf);
imgMerged3(RHalf+1:R,CHalf+1:C) = img1(RHalf+1:R,CHalf+1:C);
imgMerged3(1:RHalf,CHalf+1:C) = img2(1:RHalf,CHalf+1:C);
imgMerged3(RHalf+1:R,1:CHalf) = img2(RHalf+1:R,1:CHalf);

imgMerged4(1:RHalf,1:CHalf) = img2(1:RHalf,1:CHalf);
imgMerged4(RHalf+1:R,CHalf+1:C) = img2(RHalf+1:R,CHalf+1:C);
imgMerged4(1:RHalf,CHalf+1:C) = img1(1:RHalf,CHalf+1:C);
imgMerged4(RHalf+1:R,1:CHalf) = img1(RHalf+1:R,1:CHalf);

end