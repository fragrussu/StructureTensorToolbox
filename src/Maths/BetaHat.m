function [BetaHatVal]=BetaHat(x)
% Function required for the normalisation of the Weighted-Von Mises model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

BetaHatVal = x./(2*pi*BesselFirstKindOrderZeroPrimitive(x));
end