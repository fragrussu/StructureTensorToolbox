function [AINativeRes, AIPatches] = ExtractStructureTensorAIStats(AImap,mask,PatchWidth,PatchHeight)
% Extract statistics characterising a ST AI map.
%
% [AINativeRes, AIPatches] = ExtractStructureTensorAIStats(AImap,mask,AIth,PatchWidth,PatchHeight)
%
% This function extracts statistics from an anisotropy index (AI) map derived from a Structure Tensor. 
% The input AI map is divided into patches and for each patch the mean AI
% is calculated. 
%
% INPUTS
% AImap: an AImap (it must be a 2D numeric matrix with elements ranging in [0;1]).
%
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
% AINativeRes: the mean AI within each patch, at the same resolution as input AI map. 
%              Pixels within the same patch will be characterised by the 
%              same mean silver staining intensity.
%
% AIPatches:   the mean AI within each patch at the single-patch resolution level 
%              (each element in AIPatches corresponds to a patch).
%
%
%
% NOTICE: NaN values in outputs AINativeRes, AIPatches indicate that all pixels within that patch were 
% masked out and it was not possible to estimate the maps.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%%% Check inputs
% Throw an error in case of wrong number of inputs
if(nargin~=4)
    error('ExtractStructureTensorAIStats(): wrong number of input arguments.')
end

% Throw an error if the patch sizes are not compatible with the image size
if( (size(AImap,2)<PatchWidth) || (size(AImap,1)<PatchHeight) )
    error('ExtractStructureTensorAIStats(): either PatchWidth or PatchHeight is bigger than the actual AI map size.')
end

% Throw an error if your input image is not a 2D map
if( (isnumeric(AImap)~=1)||(ismatrix(AImap)~=1))
    error('ExtractStructureTensorAIStats(): your input AI map is not plausible: it should be a 2D matrix of numbers ranging in [0;1].')
end

% Throw an error if your input has different size than the mask
if((size(AImap,1)~=size(mask,1)) || (size(AImap,2)~=size(mask,2)) ) 
    error('ExtractStructureTensorAIStats(): the size of your input image and of the mask do not match.')
end


%%% Get patches vertices indices
imgW = size(AImap,2);
imgH = size(AImap,1);
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
AINativeRes = zeros(imgH,imgW);  % Mean AI map within a patch, native resolution
AIPatches = zeros(Npatches_h,Npatches_w); % Mean AI map within a patch, patches



% Do loop
for hh=1:Npatches_h    % Along height
    for ww=1:Npatches_w   % Along width
        % Get current patch's vertices
        hMin = hVertices(hh);
        hMax = hVertices(hh+1);
        wMin = wVertices(ww);
        wMax = wVertices(ww+1);
        % Extract the patch in the AI and in the in the mask
        localAI = AImap(hMin:hMax,wMin:wMax);  % AI map
        localMask = mask(hMin:hMax,wMin:wMax); % Mask
        % Calculate the mean AI after masking
        localAImasked = localAI(logical(localMask));
        localAImasked_mean =  mean(localAImasked);
        % Save the mean AI within the patch, unless everything was masked out
        AINativeRes(hMin:hMax,wMin:wMax) = localAImasked_mean*ones( length([hMin:hMax]) , length([wMin:wMax]) );
        AIPatches(hh,ww) = localAImasked_mean;
        
    end
end


end
