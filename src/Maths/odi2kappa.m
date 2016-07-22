function [kappa]=odi2kappa(ODI)
% Convert an orientation dispersion index into a concentration parameter
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

kappa = 1./(tan(0.5*pi*ODI));
end
