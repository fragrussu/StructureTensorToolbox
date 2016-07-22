function [P] = WeightedGaussianBivariate(theta,AI,nu,mu)
% Bivariate weighted-Gaussian distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = 1/( (nu*exp(1/nu) - nu - 1)*sqrt(2*pi*nu*nu)  )*sqrt(AI).*( exp(AI/nu) - 1 ).*exp( -0.5*(theta - mu).*(theta - mu).*AI/(nu*nu)  );

end
