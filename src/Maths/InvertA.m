function [kOptimum] = InvertA(Ainput)
% Invert function A = I1/I0
%
% A = I1/I0: ratio of modified Bessel functions of of 1st kind, orders 1 and 0
% Useful for Watson and Von-Mises fits
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

nPoints = length(Ainput);
kOptimum = zeros(size(Ainput));

%%% Load data for the grid search
load('lookup_A.mat');
kVal = GridData(1,:); % Values of k
AVal = GridData(2,:); % Corresponding values A(k)

for ii=1:nPoints    % Calculate the inverse function element-wise
        
    %%% Grid search: find a suitable initial guess for fminserach() with a grid search
    myA = Ainput(ii); % Current value from which estimate the inverse function
    GridError = (myA - AVal).^2;  % Squared error
    kGuess = kVal(GridError==min(GridError)); % Find the value of the dependent variable which minimises the error in the grid search table
    kGuess = kGuess(1);  % Because of discrete sampling, the error can potentially be minimised by more than one value of k. Just pick one.
    
    %%% Find a more precise estimate of k with fminsearch()
    kOptimum(ii) = fminsearch(@(k) SquaredErrorA(k,myA),kGuess);
    
end


end
