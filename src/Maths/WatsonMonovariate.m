function [P] = WatsonMonovariate(Theta,k,mu)
% Univariate Watson distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = exp(k*cos(Theta-mu).^2)/(2*pi*ExpI0(k));
end