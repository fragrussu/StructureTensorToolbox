function [kOptimum] = InvertMinus_dcHat_dxOvercHat(Cinput)
% Invert function dcHat_dxOvercHat, useful for Weighted Watson fit
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

nPoints = length(Cinput);
kOptimum = zeros(size(Cinput));

%%% Load data for the grid search
load('lookup_Minus_dcHat_dxOvercHat.mat');
kVal = GridData(1,:); % Values of k
CVal = GridData(2,:); % Corresponding values C(k)

for ii=1:nPoints    % Calculate the inverse function element-wise
        
    %%% Grid search: find a suitable initial guess for fminserach() with a grid search
    C = Cinput(ii); % Current value from which estimate the inverse function
    GridError = (C - CVal).^2;  % Squared error
    kGuess = kVal(GridError==min(GridError)); % Find the value of the dependent variable which minimises the error in the grid search table
    kGuess = kGuess(1);  % Because of discrete sampling, the error can potentially be minimised by more than one value of k. Just pick one.
    
    %%% Find a more precise estimate of k with fminsearch()
    kOptimum(ii) = fminsearch(@(k) SquaredErrorMinus_dcHat_dxOvercHat(k,C),kGuess);
    
end




end
