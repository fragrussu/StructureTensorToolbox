function [y] = Minus_dcHat_dxOvercHat(x)
% Function useful for weighted-Watson distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

          y = ( x.*ExpI0(x)  -  ExpI0Primitive(x) )./( x.*ExpI0Primitive(x) );
end