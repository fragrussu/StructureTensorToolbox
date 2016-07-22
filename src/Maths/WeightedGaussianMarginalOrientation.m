function P = WeightedGaussianMarginalOrientation(theta,mu,nu)
% Marginal distribution of orientation for the weighted-Gaussian model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

% Get the distribution via numerical integration
dalpha = 0.00001;
alpha = dalpha:dalpha:1;
[myA,myT] = meshgrid(alpha,theta);
P2D = WeightedGaussianBivariate(myT,myA,nu,mu);
P = dalpha*sum(P2D,2);






end
