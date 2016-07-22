function P = WeightedGaussianMarginalAI(AI,nu)
% Marginal distribution of anisotropy for weighted-Gaussian model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = (exp(AI/nu) - 1) / (nu*exp(1/nu) - nu - 1);

end
