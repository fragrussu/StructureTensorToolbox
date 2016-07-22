function [SFNativeRes, SFPatches] = ExtractPatchwiseSegmentedFraction(img,mask,PatchWidth,PatchHeight)
% Extract the fraction of segmented histological material patch-by-patch
%
% [SFNativeRes, SFPatches] = ...
%        ExtractPatchwiseSegmentedFraction(img,mask,PatchWidth,PatchHeight)
%
% This functions provides patch-wise values of fraction of segmented 
% stained material. The input image is divided into patches and for each 
% patch the ratio between the number of pixels identified as stained
% material and the total number of pixels is calculated.
% 
% INPUTS
% img: a binary image where pixels with 255 identify segmented stained
%      material, whereas pixels with 0 identify background and 
%     non-segmented pixels. 
% mask: a logical image the same size as img.
%       mask should yield true in pixels you want to include to
%       calculate the statistics, whereas it should yield false in pixels
%       you want to discard.
% 
% PatchWidth: the width of a patch in number of pixels.
%
% PatchHeight: the height of a patch in number of pixels.
%
%
% OUTPUT
%
% SFNativeRes:  the segmented fraction at the same resolution of the input
%               image img. Pixels within the same patch will be 
%               characterised by the same mean segmented fraction.
%
% SFPatches:   the segmented fraction at the single-patch resolution level 
%               (each element in SFPatches corresponds to a patch).
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%%% Check inputs

% Throw an error in case of wrong number of inputs

if(nargin~=4)
    error('ExtractPatchwiseSegmentedFraction(): wrong number of input arguments.')
end

% Throw an error if the patch sizes are not compatible with the image size
if( (size(img,2)<PatchWidth) || (size(img,1)<PatchHeight) )
    error('ExtractPatchwiseSegmentedFraction(): either PatchWidth or PatchHeight is bigger than the actual image size.')
end

% Throw an error if your input image is not RGB
if((size(img,3)~=1) || (isinteger(img)~=1))
    error('ExtractPatchwiseSegmentedFraction(): your input image is not RGB.')
end

% Throw an error if your input has different size than the mask
if((size(img,1)~=size(mask,1)) || (size(img,2)~=size(mask,2)) ) 
    error('ExtractPatchwiseSegmentedFraction(): the size of your input image and of the mask do not match.')
end

%%% Convert img to uint8()
img = uint8(img);
%%% Get patches vertices indices
imgW = size(img,2);
imgH = size(img,1);
hVertices = 1:PatchHeight-1:imgH;  % Vertices along height
if(hVertices(end)~=imgH)
    hVertices = [hVertices imgH];
end
wVertices = 1:PatchWidth-1:imgW;  % Vertices along width
if(wVertices(end)~=imgW)
    wVertices = [wVertices imgW];
end


%%% Loop thorugh patches to extract the statistics
% Get loop variables
Npatches_h = length(hVertices) - 1;
Npatches_w = length(wVertices) - 1;

% Preallocate output
SFNativeRes = zeros(size(img));  % Staining intensity, native resolution
SFPatches = zeros(Npatches_h,Npatches_w); % Staining intensity, patches

% Loop over patches
for hh=1:Npatches_h    % Along height
    for ww=1:Npatches_w   % Along width
        % Get current patch's vertices
        hMin = hVertices(hh);
        hMax = hVertices(hh+1);
        wMin = wVertices(ww);
        wMax = wVertices(ww+1);
        % Extract segmentation within current patch
        localPatch = img(hMin:hMax,wMin:wMax);  % Segmentation
        localMask = mask(hMin:hMax,wMin:wMax); % Mask
        localPatch = localPatch.*uint8(localMask);  % Remove undersired pixels
        % Calculate the stained material fraction
        myPixels = reshape(localPatch,1,numel(localPatch));
        if(isempty(myPixels))   % No pixels left in the patch (put NaN in Otsu's threshold)
            myPixelsFraction = 0;
        else
            myPixelsFraction = length(myPixels(myPixels==255))/length(myPixels);
        end
        % Save the staining material fraction
        SFNativeRes(hMin:hMax,wMin:wMax) = myPixelsFraction*ones( length([hMin:hMax]) , length([wMin:wMax]) );
        SFPatches(hh,ww) = myPixelsFraction;
    
    
    end
end

end
