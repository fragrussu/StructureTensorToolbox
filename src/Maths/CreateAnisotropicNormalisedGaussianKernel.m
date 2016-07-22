function [h] = CreateAnisotropicNormalisedGaussianKernel(sigmaRows,sigmaCols,HalfSizeRows,HalfSizeCols)
% Create a 2D anisotropic Gaussian Kernel of specified spatial support.
%
% [h] = CreateGaussianKernel(sigmaRows,sigmaCols,nRows,nCols)
%
% INPUT
% sigmaRows: standard deviation of the kernel alonf rows [pixel].
% sigmaRows: standard deviation of the kernel alonf columns [pixel].
% HalfSizeRows: filter half-size support along rows [pixel].
% HalfSizeCols: filter half-size support along columns [pixel].
%
% OUTPUT
% h: filter coefficients (matrix of size 
%    2*HalfSizeRows+1 x 2*HalfSizeCols+1) 
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Create non-normalised filter

Rows = -HalfSizeRows:HalfSizeRows;
Cols = -HalfSizeCols:HalfSizeCols;

[ColsMesh,RowsMesh] = meshgrid(Cols,Rows);   % Recall: meshgrid(x,y) but x are columns and y are rows!

qr = 1/(sigmaRows*sigmaRows);
qc = 1/(sigmaCols*sigmaCols);

h = exp(-0.5*(qr*RowsMesh.*RowsMesh + qc*ColsMesh.*ColsMesh));         

%%% Normalise filter
h = h/sum(sum(h));


end
