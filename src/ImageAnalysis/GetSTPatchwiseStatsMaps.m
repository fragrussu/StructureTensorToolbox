function [MapsNativeRes, MapsPatches] = GetSTPatchwiseStatsMaps(ST,favouriteStats)
% Extract pixel-by-pixel and patch-by-patch (paxelwise) statistic from ST.
%
% [MapsNativeRes, MapsPatches] = GetSTPatchwiseStatsMaps(ST,favouriteStats)
%
% INPUTS
% ST: a Structure Tensor struct yielding the field stats.
%     It can be obtained calling ExtractStructureTensorStatistics() on a 
%     Structure Tensor struct returned by ApplyStructureTensorStruct().
%
% favouriteStats: a string which specifies which statstical model is meant 
%                 to be studied. It can be one in 'VonMises', 
%                'WeightedVonMises', 'Gaussian', 'Watson', 'WeightedWatson'. 
% OUTPUTS
% MapsNativeRes: a struct yielding as many fields as those of the
%                statistical model of interest.
%                Each field of MapsNativeRes is a pixelwise map having the
%                same dimension as the original image (i.e. having the same
%                size as ST.Tensor.Orientation and ST.Tensor.AI).
%                NaN values are put in areas which were masked out with
%                ExtractStructureTensorStatistics().
% 
% MapsPatches:   a struct yielding the same information as MapsNativeRes
%                but storing only a scalar per patch. Its fields are
%                paxelwise maps, rather than pixelwise (i.e. patch-wise).
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

if(isfield(ST,'stats')~=1)
    error('GetStatsPatchwiseMaps(): you still need to run ExtractStructureTensorStatistics() on your tensor before calling GetStatsPatchwiseMaps().')
end

MapsNativeRes = [];
MapsPatches = [];

Npatches_h = size(ST.stats,1);
Npatches_w = size(ST.stats,2);
imageRows = size(ST.Tensor.Orientation,1);
imageCols = size(ST.Tensor.Orientation,2);

%%% Preallocate output
MapsNativeRes.type = 'pixel';
MapsPatches.type = 'paxel';
% Find a patch with the desired output
patchFound = 0;
for hh=1:Npatches_h    % Along height
    for ww=1:Npatches_w   % Along width

        if(isfield(ST.stats{hh,ww},'info')==0)
            patchFound = 1;
            fieldList = fieldnames(getfield(ST.stats{hh,ww},favouriteStats));
            for ff=1:length(fieldList)
                eval(['MapsNativeRes.' fieldList{ff} ' = nan(imageRows,imageCols);']);   % Preallocate maps at native resolution
                eval(['MapsPatches.' fieldList{ff} ' = nan(Npatches_h,Npatches_w);']);   % Preallocate maps where each pixel corresponds to a patch (paxelwise maps)
            end
            
        end
        
        if(patchFound==1)
           break    % Get out of the loop, we've found what we needed.
        end
        
    end
    
    if(patchFound==1)
       break   % Get out of the loop, we've found what we needed.
    end
    
end

% Error: all patches are empy, can't plot any patchwise stats
if(patchFound==0)
    error('GetStatsPatchwiseMaps(): all patches are empty (see the information of any cell of field stats).');
end

%%% There is at least a non-empty patch: get maps for the choses statistics
% Loop through patches
MapsPatches.OrientationDistribution = cell(Npatches_h,Npatches_w);
MapsPatches.AIDistribution = cell(Npatches_h,Npatches_w);
for hh=1:Npatches_h    % Along height
    for ww=1:Npatches_w   % Along width
        
        curPatch = ST.stats{hh,ww};   % Get the patch
        
        % If the patch is not empty, get information
        if(isfield(curPatch,'info')==0)
            
            % Get marginals
            MapsPatches.OrientationDistribution{hh,ww} = curPatch.OrientationMarginal;
            MapsPatches.AIDistribution{hh,ww} = curPatch.AIMarginal;
            % Get chosen statistics
            myStats = getfield(curPatch,favouriteStats);
            myFields = fieldnames(myStats);
        
            for ff=1:length(myFields);    % Save the map for all fields of the stats
                ValueToFeed = getfield(myStats,myFields{ff}); 
                eval(['MapsNativeRes.' fieldList{ff} '(curPatch.RowIndices(1):curPatch.RowIndices(2),curPatch.ColumnIndices(1):curPatch.ColumnIndices(2)) = ValueToFeed;']);  % Maps at native resolution
                eval(['MapsPatches.' fieldList{ff} '(hh,ww) = ValueToFeed;']);  % Maps where each matrix element corresponds to a patch (paxelwise maps)
            end
        
        end  
                    
    end
end

end
