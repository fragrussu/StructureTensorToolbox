function [SquaredError] = SquaredErrorMinus_dcHat_dxOvercHat(x,a)
% Error for function Minus_dcHat_dxOVercHat
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
SquaredError = (a - Minus_dcHat_dxOvercHat(x)).^2;
end