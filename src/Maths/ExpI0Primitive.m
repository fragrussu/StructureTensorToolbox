function [y] = ExpI0Primitive(x)
% Function required for the normalisation of the weighted-Watson model
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

          y = zeros(size(x));
          
          for ii=1:length(y)
              y(ii) = integral(@ExpI0,0,x(ii)); 
          end  

end