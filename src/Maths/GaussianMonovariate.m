function P=GaussianMonovariate(theta,mu,nu)
% Univariate Gaussian distribution
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
P = (1/sqrt(2*pi*nu*nu))*exp(-0.5*(theta - mu).*(theta - mu)/(nu*nu));

end