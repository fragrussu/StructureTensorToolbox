function [P] = WeightedWatsonBivariate(Theta,AI,k,mu)
% Bivariate weighted-Watson distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = cHat(k)*exp(k*AI.*(cos(Theta-mu).^2));
end