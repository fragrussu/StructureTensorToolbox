function [Aval]=A(x)
% A = dI0(x)dx / I0(x) required in the Watson and Von Mises models.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

Aval = BesselFirstKindOrderOne(x)./BesselFirstKindOrderZero(x);
end
