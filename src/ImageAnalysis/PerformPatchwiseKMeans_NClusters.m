function [KmeansImg] = PerformPatchwiseKMeans_NClusters(img,mask,PatchWidth,PatchHeight,Nclusters,DistanceMetric,NrReplicates)
% Perform patch-wise kmeans tissue segmentation.
%
% [KmeansImg] = ...
%  PerformPatchwiseKMeans_NClusters(img,mask,PatchWidth,PatchHeight,...
%                                    Nclusters,DistanceMetric,NrReplicates)
%
% This functions perform kmeans clustering patch-by-patch in order to separate 
% the background from the stained tissue. It relies on the hypothesis that the 
% stained tissue is dark, overlaind onto bright background. The function allows
% the generic clustering into N clusters. However, the stained tissue will always 
% be identified as the darkest cluster.   
% 
% INPUTS
% img: a stained histological image (it must be RGB).
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
% Nclusters: number of clusters.
%
% DistanceMetric: a string specifying the distance metrics to be used for 
%                 clustering. Choose one among
%                 'sqeuclidean','cityblock','cosine','correlation'.
%
% NrReplicates: number of times clustering should be repeated using new initial 
%             cluster centroid positions. Running the clustering several 
%             times can help to avoid local minima.
%
%
% OUTPUT
% 
%
% KmeansImg:   binarised image (uint8 data type). 255 is stored in pixel
%              identified as stained material, whereas 0 is stored in background and
%              areas which were not included for analysis.
%
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%%% Check inputs

% Throw an error in case of wrong number of inputs
if(nargin~=7)
    error('PerformPatchwiseKMeans_NClusters(): wrong number of input arguments.')
end

% Throw an error if the patch sizes are not compatible with the image size
if( (size(img,2)<PatchWidth) || (size(img,1)<PatchHeight) )
    error('PerformPatchwiseKMeans_NClusters(): either PatchWidth or PatchHeight is bigger than the actual image size.')
end

% Throw an error if your input image is not RGB
if((size(img,3)~=3) || (isinteger(img)~=1))
    error('PerformPatchwiseKMeans_NClusters(): your input image is not RGB.')
end

% Throw an error if your input has different size than the mask
if((size(img,1)~=size(mask,1)) || (size(img,2)~=size(mask,2)) ) 
    error('PerformPatchwiseKMeans_NClusters(): the size of your input image and of the mask do not match.')
end

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
KmeansImg = uint8(zeros(size(img,1),size(img,2)));  % Binarised image

% Do loop
for hh=1:Npatches_h    % Along height
    for ww=1:Npatches_w   % Along width
        % Get current patch's vertices
        hMin = hVertices(hh);
        hMax = hVertices(hh+1);
        wMin = wVertices(ww);
        wMax = wVertices(ww+1);
        % Extract patch in image and in mask
        localPatch = img(hMin:hMax,wMin:wMax,:);  % Staining intensity
        localMask = mask(hMin:hMax,wMin:wMax); % Mask
        localMask = logical(localMask);
        Nvoxrows = size(localMask,1); Nvoxcols = size(localMask,2); Nvoxpatch = Nvoxcols*Nvoxrows;
        % Check if there are pixels left after masking
        if(length(localMask(localMask==1))<=2)             % No pixels available: save 0 in the binarised image and NaN in the maps
            tissuePatch = zeros(Nvoxrows,Nvoxcols);  % Empty patch!
        else   % Pixels available: perform the kmeans-based segmentation. 
            % Put NaN in voxels not to be included in the analysis
            redCh = single(localPatch(:,:,1)); greenCh = single(localPatch(:,:,2)); blueCh = single(localPatch(:,:,3));
            redCh(localMask~=true) = NaN; greenCh(localMask~=true) = NaN; blueCh(localMask~=true) = NaN;
            % Create input data for kmeans of current patch
            inputKmeans = cat(2,reshape(redCh,Nvoxpatch,1),reshape(greenCh,Nvoxpatch,1),reshape(blueCh,Nvoxpatch,1));
            % Perform Kmeans of current patch with Nclusters clusters and kmeans++ cluster initialisation
            [labels, centroids] = kmeans(inputKmeans,Nclusters,'Distance',DistanceMetric,'Replicates',NrReplicates);
            % Find label of darkest cluster, describing the stained material
            centroidPower = zeros(1,Nclusters);
            for kidx=1:Nclusters
                centroidPower(kidx) = norm(centroids(kidx,:));    % Get squared Euclidian norm of cluster centroids
            end
            [~,tissueIdx] = min(centroidPower);     % Pick the cluster with smallest norm (i.e. the darkest)
            % Create the segmentation of the patch
            tissuePatch = zeros(size(labels));
            tissuePatch(labels==tissueIdx) = 255;
            tissuePatch = reshape(tissuePatch,Nvoxrows,Nvoxcols);      
        end
        % Save the binarised patch as a uint8
        KmeansImg(hMin:hMax,wMin:wMax) = uint8(tissuePatch);
    end
end


end
