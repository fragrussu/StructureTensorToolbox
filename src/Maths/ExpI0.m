function [y]=ExpI0(x)
% Function required for the normalisation of the Watson distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

y = exp(0.5*x).*BesselFirstKindOrderZero(0.5*x);
end