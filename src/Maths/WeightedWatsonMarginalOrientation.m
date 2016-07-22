function [P] = WeightedWatsonMarginalOrientation(Theta,k,mu)
% Marginal distribution of orientation for the weighted-Watson model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = ( exp( k*(cos(Theta-mu).^2) ) - 1)./(2*pi*(cos(Theta-mu).^2)*ExpI0Primitive(k));
end