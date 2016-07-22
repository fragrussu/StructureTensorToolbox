function [y] = BesselFirstKindOrderZeroPrimitive(x)
% Integral of I0(x)
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016
          y = zeros(size(x));
          
          for ii=1:length(y)
              y(ii) = integral(@BesselFirstKindOrderZero,0,x(ii)); 
          end          
          
end
