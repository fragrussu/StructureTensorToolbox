function [SToutput] = ExtractStructureTensorStatistics(STinput,mask,PatchWidth,PatchHeight,OrBinsPerPatch,AIBinsPerPatch)
% Extract directional statistics characterising pixelwise ST analysis.
%
% [SToutput] = ExtractStructureTensorStatistics(STinput,mask,... 
%                  ...PatchWidth,PatchHeight,OrBinsPerPatch,AIBinsPerPatch)
%
% This functions evaluate statistics on ST maps patch-by-patch. The image
% is divided into patches of specified size and circular statistics are
% calculated in each patch. For each patch, six models are evaluated: Von
% Mises model of orientations; weighted-Von Mises model (Von Mises weighted 
% by AI); Watson model of the orientations; weighted-Watson model
% (Watson weighted by AI).
%
% INPUTS
% STinput: a ST as returned by ApplyStructureTensorStruct();
%
% mask: a logical image the same size as the image on which STinput was
%       obtained. mask should yield true in pixels you want to include to
%       calculate the statistics, whereas it should yield false in pixels
%       you want to discard.
% 
% PatchWidth: the width of a patch in number of pixels.
%
% PatchHeight: the height of a patch in number of pixels.
%
% nrAngBins: number of bins for orientation map binning (it must be even).  
%
% nrAIBins: number of bins for AI map binning.
%
% OUTPUT
% SToutput: a copy of STinput where the field stats has been added.
%           The field stats is a cell array where each element corresponds
%           to a patch. Each element contains the following subfields:
%           -  VonMises, yielding stats for Von Mises model;
%           -  WeightedVonMises, yielding stats from weighted-Von Mises model;
%           -  Watson, yielding stats from Watson model;
%           -  WeightedWatson, yielding stats from weighted-Watson model;
%           -  Gaussian, yielding stats from Gaussian model;
%           -  WeightedGaussian, yielding stats from weighted-Gaussian model;
%           -  OrientationMarginal: the observed marginal distribution of
%              orientations;
%           -  AIMarginal: the observed marginal distribution of AI;
%           -  RowIndices, a 2-element array with minimum and maximum row
%              indices of pixels in the patch;
%           -  ColumnIndices, a 2-element array with minimum and maximum row
%              indices of pixels in the patch.
%
%           If all pixels in a patch were masked out, the corresponding 
%           element in the cell array will have a field 'info' instead of 
%           fields VonMises, weightedVonMises, Watons, WeightedWatson, 
%           Gaussian, WeightedGaussian, OrientationMarginal and AIMarginal.
%
%           Circular mean, circular variance, concentration kappa and 
%           log-likelihood at maximum are reported for Watson and Von Mises 
%           model as well as for their weighted counterparts.
%
%           Mean, spread and log-likelihood at maximum are reported for the
%           Gaussian and weighted-Gaussian models.
%
%           For orientation and AI marginals, the bins, the a posteriori
%           probability and the expected value are reported from their 
%           histograms.  
%
%           The bins used to approximate the orientation marginal will be 
%           OrBinsPerPatch + 1, since an extra bin corresponding to 2*pi is
%           added. 
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%%% Check inputs

% Throw an error in case of wrong number of inputs
if(nargin~=6)
    error('ExtractStructureTensorStatistics(): wrong number of input arguments.')
end
% Throw an error if nrAngBins is not numeric and scalar
if((isnumeric(OrBinsPerPatch)~=true) || (isscalar(OrBinsPerPatch)~=true))
    error('ExtractStructureTensorStatistics(): OrBinsPerPatch must be a numeric scalar.')
end

% Throw an error if nrAngBins is odd
if(  (ceil(OrBinsPerPatch/2) - OrBinsPerPatch/2)~=0  )
    error('ExtractStructureTensorStatistics(): OrBinsPerPatch must be an even number.')
end

% Throw an error if nrAIBins is not numeric and scalar
if((isnumeric(AIBinsPerPatch)~=true) || (isscalar(AIBinsPerPatch)~=true))
    error('ExtractStructureTensorStatistics(): AIBinsPerPatch must be a numeric scalar.')
end

% Throw an error if the patch sizes are not compatible with the image size
if( (size(STinput.Tensor.Orientation,2)<PatchWidth) || (size(STinput.Tensor.Orientation,1)<PatchHeight) )
    error('ExtractStructureTensorStatistics(): either PatchWidth or PatchHeight is bigger than the actual image size.')
end

% Throw an error if the size of the map is not compatible
if( ( size(STinput.Tensor.Orientation,1)~=size(mask,1) ) || ( size(STinput.Tensor.Orientation,2)~=size(mask,2) ) )
    error('ExtractStructureTensorStatistics(): your mask has a wrong size.')
end


%%% Get patches vertices indices
imgW = size(STinput.Tensor.Orientation,2);
imgH = size(STinput.Tensor.Orientation,1);
hVertices = 1:PatchHeight-1:imgH;  % Vertices along height
if(hVertices(end)~=imgH)
    hVertices = [hVertices imgH];
end
wVertices = 1:PatchWidth-1:imgW;  % Vertices along width
if(wVertices(end)~=imgW)
    wVertices = [wVertices imgW];
end

%%% Make sure image borders are masked out to remove filter2() artifacts
maxKernelDim = max(size(STinput.GaussianKernel,1),size(STinput.DoGxKernel,1));  % Dimension of the biggest filter
borderSize = ceil(maxKernelDim/2);  % Border to discard: half of maxKernelDim at each side of the image
maskNoArtifacts = mask;
maskNoArtifacts(:,1:borderSize) = 0;
maskNoArtifacts(:,end-borderSize+1:end) = 0;
maskNoArtifacts(1:borderSize,:) = 0;
maskNoArtifacts(end-borderSize+1:end,:) = 0;

%%% Set up output
SToutput = STinput;

%%% Loop thorugh patches to extract the statistics
% Get loop variables
Npatches_h = length(hVertices) - 1;
Npatches_w = length(wVertices) - 1;
SToutput.stats = cell(Npatches_h,Npatches_w);
% Do loop
for hh=1:Npatches_h    % Along height
    for ww=1:Npatches_w   % Along width
        % Get current patch's vertices
        hMin = hVertices(hh);
        hMax = hVertices(hh+1);
        wMin = wVertices(ww);
        wMax = wVertices(ww+1);
        % Extract the patch in the orientation, AI and mask images
        localOr = STinput.Tensor.Orientation(hMin:hMax,wMin:wMax);
        localAI = STinput.Tensor.AI(hMin:hMax,wMin:wMax);
        localMask = maskNoArtifacts(hMin:hMax,wMin:wMax);
        % Perform stats for the current patches
        dummyPatch = ExtractStructureTensorStatisticsPatches(localOr,localAI,localMask,OrBinsPerPatch,AIBinsPerPatch);
        % Store patch vertices coordinates
        dummyPatch.RowIndices = [hMin hMax];
        dummyPatch.ColumnIndices = [wMin wMax];        
        SToutput.stats{hh,ww} = dummyPatch;        
    end
end

end
