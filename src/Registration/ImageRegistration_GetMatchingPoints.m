function [Points1, Points2] = ImageRegistration_GetMatchingPoints(img1, img2)
% Select manually matching points in two images. 
%
% [Points1, Points2] = ImageRegistration_GetMatchingPoints(img1, img2)
%
% This function will open a GUI that allows the selection of matching
% points between two input images img1, img2
%
% INPUTS
% 1) img1: input image 1 (es. histological image to be registered MRI).
% 2) img2: input image 2 (es. MRI image).
%
% OUTPUTS:
% 1) Points1: points selected by the user in input image 1.
% 2) Points2: points selected by the user in input image 2.
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

[Points1, Points2] = cpselect(img1,img2,'Wait',true);

end