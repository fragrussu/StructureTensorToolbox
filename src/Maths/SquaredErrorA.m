function [SquaredError] = SquaredErrorA(x,a)
% Error for function A(x)
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
SquaredError = (a - A(x)).^2;
end