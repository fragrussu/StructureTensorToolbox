function [P] = WeightedVonMisesBivariate(Theta,AI,k,mu)
% Bivariate weighted-Von Mises distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = BetaHat(k)*exp(k*AI.*cos(Theta-mu));
end