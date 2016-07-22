function MinusLogL = WeightedGaussianObj(ThetaSample,AlphaSample,muval,spreadval)
% Objective function for weighted-Gaussian fitting
%
% Objective function to estimate the spread of the weighted Gaussian
% distribution numerically.
%
% MinusLogL = WeightedGaussianObj(ThetaSample,AlphaSample,muval,spreadval)
%
% ThetaSample: sample of orientations
% AlphaSample: sample of anisotropy
% muval: mean parameter of the weighted-Gaussian distribution
% spreadval: spread parameter of the weighted-Gaussian distribution
% MinusLogL: objective function, equal to -log-likelihood
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

Nobs = length(ThetaSample);
MyLogL = -Nobs*log(  sqrt(2*pi*spreadval*spreadval)*( spreadval*exp(1/spreadval)  -   spreadval  -  1 ) ) + ...
    sum( log(sqrt(AlphaSample))  + log( exp(AlphaSample/spreadval)  - 1  ) - 0.5*AlphaSample.*(ThetaSample - muval).*(ThetaSample - muval)/(spreadval*spreadval)  );
MinusLogL = - MyLogL;

end
