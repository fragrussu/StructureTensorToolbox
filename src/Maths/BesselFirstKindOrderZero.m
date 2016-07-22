function [y]=BesselFirstKindOrderZero(x)
% I0(x) - modified Bessel function of the first kind and order zero
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
y = besseli(0,x);
end