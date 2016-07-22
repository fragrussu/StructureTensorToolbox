function [y] = Minus_dBetaHat_dxOverBetaHat(x)
% Function useful for weighted-Von Mises distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
          y = ( x.*BesselFirstKindOrderZero(x) - BesselFirstKindOrderZeroPrimitive(x))./(x.*BesselFirstKindOrderZeroPrimitive(x));
end