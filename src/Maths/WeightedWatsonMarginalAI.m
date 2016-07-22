function [P] = WeightedWatsonMarginalAI(AI,k)
% Marginal distribution of anisotropy for the weighted-Watson model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = k*ExpI0(k*AI)/ExpI0Primitive(k);
end