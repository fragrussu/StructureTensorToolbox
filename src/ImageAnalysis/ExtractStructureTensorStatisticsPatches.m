function [PatchStats] = ExtractStructureTensorStatisticsPatches(OrientationMap,AIMap,mask,nrOrBins,nrAIBins)
% Extracts directional statistics characterising ST analysis from a patch.
%
% [PatchStats] = ExtractStructureTensorStatisticsPatches(OrientationMap,AIMap,mask,nrOrBins,nrAIBins)
%
% This function is called by ExtractStructureTensorStatistics() for each
% patch created in the image. 
%
% INPUTS
% OrientationMap: the orientation map extracted in the current patch.
%
% AIMap: the AI map extracted in the current patch.
%
% mask: the mask extracted in the current patch.
%
% nrAngBins: number of bins for orientation map binning (it must be even).  
%
% nrAIBins: number of bins for AI map binning.
%
% OUTPUT
% PatchStats: a struct summarising the statistics in the current patch.
%             It contains the following subfields:
%           -  VonMises, yielding stats from Von Mises model;
%           -  WeightedVonMises, yielding stats from weighted - Watson model;
%           -  Watson, yielding stats from Watons model;
%           -  WeightedWatson, yielding stats from weighted - Watson model;
%           -  Gaussian, yielding stats from Gaussian model;
%           -  WeightedGaussian, yielding stats from weighted - Gaussian model;
%           -  OrientationMarginal: the observed marginal distribution of
%              orientations;
%           -  AIMarginal: the observed marginal distribution of AI;
%
%           If all pixels in a patch were masked out, the corresponding 
%           element in the cell array will have a field 'info' instead of 
%           fields VonMises, weightedVonMises, Watons, WeightedWatson, 
%           OrientationMarginal and AIMarginal.
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
%           nrOrBins + 1, since an extra bin corresponding to 2*pi is added. 
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016


%%%% Check inputs

% Throw an error in case of wrong number of inputs
if(nargin~=5)
    error('ExtractStructureTensorStatisticsPatches(): wrong number of input arguments.')
end

% Throw an error if nrAngBins is not numeric and scalar
if((isnumeric(nrOrBins)~=true) || (isscalar(nrOrBins)~=true))
    error('ExtractStructureTensorStatisticsPatches(): nrAngBins must be a numeric scalar.')
end

% Throw an error if nrAngBins is odd
if(  (ceil(nrOrBins/2) - nrOrBins/2)~=0  )
    error('ExtractStructureTensorStatisticsPatches(): nrAngBins must be an even number.')
end

% Throw an error if nrAIBins is not numeric and scalar
if((isnumeric(nrAIBins)~=true) || (isscalar(nrAIBins)~=true))
    error('ExtractStructureTensorStatisticsPatches(): nrAIBins must be a numeric scalar.')
end

%%%% Perform directional statistics on the orientation map

%%% PREPARE FOR STATISTICS: GET RID OF SOME PIXELS WITH THE MASK
orientationNoBorders = transpose(OrientationMap(logical(mask)));
AINoBorders = transpose(AIMap(logical(mask)));

% Exit if there are no pixels left
if(isempty(orientationNoBorders))
    PatchStats.info = 'All pixels masked out';
    return
end



%%% REPHASE TO USE MONO-MODAL DISTRIBUTIONS PROPERLY
% Find offset accounting for wraps
angles_complex = exp(1i*2*orientationNoBorders);   % Complex vector after doubling 
angles_complex_mean = mean(angles_complex);
myoffset = angle(angles_complex_mean)/2;
if(myoffset < 0)
    myoffset  = myoffset + pi;
end
% Find angle between each orientation and the offset
dot_prod_or = cos(myoffset)*cos(orientationNoBorders) + sin(myoffset)*sin(orientationNoBorders);  % Dot product between vector corresponding to offset and vectors corresponding to orientations
dot_prod_or_abs = abs(dot_prod_or);   % Absolute value of dot product
dot_prod_distance_radians = acos(dot_prod_or_abs);     % Absolute distance from the offset in radians
if(isreal(dot_prod_distance_radians)==0)   % If we get a complex angle, there are orientations that have to be considered numerically equal to the offset itself 

    for qq=1:length(dot_prod_distance_radians)
       
         if( isreal(dot_prod_distance_radians(qq))==0 )
              dot_prod_distance_radians(qq) = 0;
         end
        
    end
    
end
dot_prod_or_sign = sign(dot_prod_or);    % Sign of the distance
% Rephase angles for proper use of Gaussian, Von Mises models and their weighted counterparts
angles_rephased = myoffset + dot_prod_or_sign.*dot_prod_distance_radians;
% Get complex data
angles_rephased_vec = exp(1i*angles_rephased);
% Get number of observations in this patch sample
Nsample = length(angles_rephased);


%%% GAUSSIAN DISTRIBUTION OF ORIENTATIONS AFTER DOUBLING THE ANGLES
PatchStats.Gaussian.Mean = mean(angles_rephased);
PatchStats.Gaussian.Std = mean( (angles_rephased - PatchStats.Gaussian.Mean).*(angles_rephased - PatchStats.Gaussian.Mean) );
PatchStats.Gaussian.Std = sqrt(PatchStats.Gaussian.Std);
PatchStats.Gaussian.LogLikelihood = -0.5*Nsample*log(2*pi*PatchStats.Gaussian.Std*PatchStats.Gaussian.Std) - 0.5*Nsample;


%%% VON MISES DISTRIBUTION AFTER DOUBLING AND REPHASING ANGLES
angles_rephased_vec_mean = mean(angles_rephased_vec);
vonmises_mean = angle(angles_rephased_vec_mean);
% Remap the estimated circular mean onto [pi/2, pi] if it is negative, i.e. if it ranges in [-pi/2, 0]
if(vonmises_mean<0)
    vonmises_mean = vonmises_mean + pi;
end
PatchStats.VonMises.CircularMean = vonmises_mean; 
% Calculate circular variance, ranging from 0 (all vectors are parallel) to 1 (all vectors have different orientation)
PatchStats.VonMises.CircularVariance = 1 - abs(angles_rephased_vec_mean);
% Calculate maximum likelihood estimate of k for the corresponding Von-Mises distribution
PatchStats.VonMises.Kappa = InvertA(1 - PatchStats.VonMises.CircularVariance);  
% Calculate Log-Likelihood of the model for optimum parameters
PatchStats.VonMises.LogLikelihood = Nsample*(  PatchStats.VonMises.Kappa*(1 - PatchStats.VonMises.CircularVariance) - log( 2*pi*BesselFirstKindOrderZero(PatchStats.VonMises.Kappa) )  );


%%%% WEIGHTED-VON MISES DISTRIBUTION AFTER DOUBLING AND REPHASING THE ANGLES
angles_rephased_vec_weighted_mean = mean(AINoBorders.*angles_rephased_vec);  % Weighted mean complex vector, using AI as weight
% Calculate the weighted circular mean from the weigthed mean complex vector
weighvonmises_weighmean = angle(angles_rephased_vec_weighted_mean); % Weighted mean orientation: phase of weighted mean complex vector, divided by two to account for angle doubling
% Remap the estimated weighted circular mean onto [pi/2, pi] if it is negative, i.e. if it ranges in [-pi/2, 0]
if(weighvonmises_weighmean<0)
    weighvonmises_weighmean = weighvonmises_weighmean + pi;
end
PatchStats.WeightedVonMises.CircularMean = weighvonmises_weighmean; 
% Calculate weighted circular variance, ranging from 0 (all vectors are parallel) to 1 (all vectors have different orientation)
PatchStats.WeightedVonMises.CircularVariance = 1 - abs(angles_rephased_vec_weighted_mean);
% Calculate maximum likelihood estimate of k for the corresponding weighted Von-Mises distribution
PatchStats.WeightedVonMises.Kappa = InvertMinus_dBetaHat_dxOverBetaHat(1 - PatchStats.WeightedVonMises.CircularVariance);  
% Calculate Log-Likelihood of the model for optimum parameters
PatchStats.WeightedVonMises.LogLikelihood = Nsample* ( log(BetaHat(PatchStats.WeightedVonMises.Kappa)) +  PatchStats.WeightedVonMises.Kappa*(1 - PatchStats.WeightedVonMises.CircularVariance) );


%%% WEIGHTED-GAUSSIAN DISTRIBUTION AFTER DOUBLING AND REPHASING THE ANGLES
PatchStats.WeightedGaussian.Mean = sum(AINoBorders.*angles_rephased)/sum(AINoBorders);
% Find sigma for weighted Gaussian. We use sigma of Gaussian as a starting
% point for the fminserach( ) minimisation
mymu = PatchStats.WeightedGaussian.Mean;   % fminsearch() accepts only inputs of type double
mysgm_guess = PatchStats.Gaussian.Std;     % fminsearch() accepts only inputs of type double
[mysigmaval,myobj,myexit] = fminsearch(@(mysgm) WeightedGaussianObj(double(angles_rephased),double(AINoBorders),double(mymu),mysgm),double(mysgm_guess));
if(myexit==-1)
    mysigmaval = NaN;
    myobj = NaN;
end
PatchStats.WeightedGaussian.Std = single(mysigmaval);
PatchStats.WeightedGaussian.LogLikelihood =  - single(myobj);  % Function WeightedGaussianObj calculates - loglikelihood


%%% WATSON DISTRIBUTION OF ORIENTATIONS 
% Perform angle doubling for Watson, as this reflects the squared power of the cosinus
ComplexVectorDoubled = exp(1i*2*angles_rephased);   % Complex vector after doubling
ComplexVectorDoubledMean = mean(ComplexVectorDoubled);  % Mean complex vector

% Calculate the circular mean from the mean complex vector
myMeanAngle = angle(ComplexVectorDoubledMean)/2; % Mean orientation: phase of mean complex vector, divided by two to account for previous angle doubling
% Remap the estimated circular mean onto [pi/2, pi] if it is negative, i.e. if it ranges in [-pi/2, 0]
if(myMeanAngle<0)
    myMeanAngle = myMeanAngle + pi;
end
PatchStats.Watson.CircularMean = myMeanAngle;   % Mean angle 
PatchStats.Watson.CircularVariance = 1 - abs(ComplexVectorDoubledMean); % Circular variance for Watson
PatchStats.Watson.Kappa = 2*InvertA(1 - PatchStats.Watson.CircularVariance);  % Kappa
PatchStats.Watson.LogLikelihood = Nsample*(0.5*PatchStats.Watson.Kappa*(1-PatchStats.Watson.CircularVariance) - log( 2*pi*BesselFirstKindOrderZero(0.5*PatchStats.Watson.Kappa) )  );  % Likelihood at maximum


%%% WEIGHTED WATSON DISTRIBUTION OF ORIENTATION AND ANISOTROPY
ComplexVectorDoubledAndWeighted = AINoBorders.*exp(1i*2*angles_rephased);  % Weighted complex vector, using AI as weight
ComplexVectorDoubledAndWeightedMean = mean(ComplexVectorDoubledAndWeighted);  % Mean weighted complex vector
% Calculate the weighted circular mean from the weigthed mean complex vector
MyMeanWeightedAngle = angle(ComplexVectorDoubledAndWeightedMean)/2; % Weighted mean orientation: phase of weighted mean complex vector, divided by two to account for angle doubling
% Remap the estimated weighted circular mean onto [pi/2, pi] if it is negative, i.e. if it ranges in [-pi/2, 0]
if(MyMeanWeightedAngle<0)
    MyMeanWeightedAngle = MyMeanWeightedAngle + pi;
end
meanAIvalue = mean(AINoBorders);
PatchStats.WeightedWatson.CircularMean = MyMeanWeightedAngle;    % Circular Mean
PatchStats.WeightedWatson.CircularVariance = 1 - abs(ComplexVectorDoubledAndWeightedMean);   % Circular Variance
PatchStats.WeightedWatson.Kappa = InvertMinus_dcHat_dxOvercHat(0.5*(meanAIvalue + 1 - PatchStats.WeightedWatson.CircularVariance));  % Kappa
PatchStats.WeightedWatson.LogLikelihood = Nsample*( 0.5*PatchStats.WeightedWatson.Kappa*( meanAIvalue + 1 - PatchStats.WeightedWatson.CircularVariance ) + log(cHat( PatchStats.WeightedWatson.Kappa )) );  % Likelihood at maximum



%%% EVALUATE THE EXPERIMENTAL DISTRIBUTIONS OF ORIENTATIONS AND ANISOTROPY

%%% Marginal distribution of orientation (requires an even number of histogram bins)
% Estimate the marginal distribution of orientation as rose histogram for
% visualization. Make sure the sample is diametrically bimodal before 
% performing the actual bin count
orientationNoBordersBig = [orientationNoBorders orientationNoBorders+pi]; % Make the angles diametrically bimodal, i.e. obtain angles in [0; 2*pi] such that P(th) = P(th+pi) for all th in [0; pi]. 
ODFangles = linspace(0,2*pi,nrOrBins+1);
ODFangles = ODFangles(1:end-1);
[~, ODFradii] = rose(orientationNoBordersBig,ODFangles);  % Evaluate histogram (angle count)
ODFradii = [ODFradii(3:4:end) ODFradii(3)]; % Copy the initial value to plot the density as a closed line
ODFradii = ODFradii/( sum(ODFradii)*(ODFangles(2)-ODFangles(1)) );  % Normalise bin count to get unit area after integration
ODFangles = [ODFangles 2*pi];  % Add 2*pi as final bin to plot the density as a closed line
PatchStats.OrientationMarginal.P = ODFradii;  % Save probability
PatchStats.OrientationMarginal.Bins = ODFangles;   % Save bin centres


%%% Marginal distribution of AI
% Estimate the marginal distribution of AI as histogram for visualization
PatchStats.AIMarginal.Bins = linspace(0,1,nrAIBins);  % Calculate bin centres
PatchStats.AIMarginal.P = hist(AINoBorders,PatchStats.AIMarginal.Bins); % Evaluate histogram (bin count)
PatchStats.AIMarginal.P = PatchStats.AIMarginal.P/( (PatchStats.AIMarginal.Bins(2) - PatchStats.AIMarginal.Bins(1))*sum(PatchStats.AIMarginal.P) ); % Normalise bin count to get unit area after integration 

end
