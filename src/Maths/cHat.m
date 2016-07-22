function [cHatVal]=cHat(x)
% Function required for the normalisation of the weighted-Watson model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

cHatVal = x./(2*pi*ExpI0Primitive(x));
end