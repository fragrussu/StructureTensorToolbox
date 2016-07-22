function [y]=BesselFirstKindOrderOne(x)
% I1(x) = d I0(x) / dx
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
y = besseli(1,x);
end