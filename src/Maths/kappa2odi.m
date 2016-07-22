function [ODI] = kappa2odi(kappa)
% Convert a concentration parameter into an orientation dispersion index
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

ODI = (2/pi)*atan2(1,kappa);
end
