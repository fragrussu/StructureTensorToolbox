function [kOptimum] = InvertMinus_dBetaHat_dxOverBetaHat(Binput)
% Invert function dBetaHat_dxOverBetaHat, useful for Weighted Von-Mises fit
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

nPoints = length(Binput);
kOptimum = zeros(size(Binput));

%%% Load data for the grid search
load('lookup_Minus_dBetaHat_dxOverBetaHat.mat');
kVal = GridData(1,:); % Values of k
BVal = GridData(2,:); % Corresponding values B(k)

for ii=1:nPoints    % Calculate the inverse function element-wise
        
    %%% Grid search: find a suitable initial guess for fminserach() with a grid search
    B = Binput(ii); % Current value from which estimate the inverse function
    GridError = (B - BVal).^2;  % Squared error
    kGuess = kVal(GridError==min(GridError)); % Find the value of the dependent variable which minimises the error in the grid search table
    kGuess = kGuess(1);  % Because of discrete sampling, the error can potentially be minimised by more than one value of k. Just pick one.
    
    %%% Find a more precise estimate of k with fminsearch()
    kOptimum(ii) = fminsearch(@(k) SquaredErrorMinus_dBetaHat_dxOverBetaHat(k,B),kGuess);
    
end


end
