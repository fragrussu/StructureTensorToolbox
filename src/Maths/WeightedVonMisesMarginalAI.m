function [P] = WeightedVonMisesMarginalAI(AI,k)
% Marginal distribution of anisotropy for the weighted-Von Mises model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = k*BesselFirstKindOrderZero(k*AI)/BesselFirstKindOrderZeroPrimitive(k);
end