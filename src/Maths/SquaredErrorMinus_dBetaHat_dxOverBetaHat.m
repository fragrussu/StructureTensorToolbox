function [SquaredError] = SquaredErrorMinus_dBetaHat_dxOverBetaHat(x,a)
% Error for function Minus_dBetaHat_dxOverBetaHat
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
SquaredError = (a - Minus_dBetaHat_dxOverBetaHat(x)).^2;
end