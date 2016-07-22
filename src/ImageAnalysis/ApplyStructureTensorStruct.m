function [SToutput] = ApplyStructureTensorStruct(img,STinput,varargin)
% Perform Structure Tensor (ST) analysis on a gray scale double prec. image
%
% [SToutput] = ApplyStructureTensorStruct(img,STinput)
% [SToutput] = ApplyStructureTensorStruct(img,STinput,nWorkers)
%
% INPUTS
% img:     it is a gray scale image in double precision format, for instance as
%          provided by the PreprocessInputImage() function.
%
% STinput: a ST struct, for instance as returned by CreateStructureTensorStruct().
%
% nWorkers: optional input which specifies the number of cores to be used
%           if parallel computing is needed. 
%
% OUTPUT
% SToutput: a copy of STinput with the following fields.
%
%           1) field Tensor.Orientation will be contain with the primary 
%              orientation of the ST. It is a RxC matrix, where each 
%              element (r,c) is the orientation at location (r,c), ranging 
%              in [0; pi] radians. 
%
%           2) Tensor.AI will be contain the anisotropy index (AI) of the ST. 
%              It is a a RxC matrix, where each element (r,c) is a the AI 
%              at location (r,c), defined as 
%
%                              (L1 - L2)/(L1 + L2) .  
%
%              Being L1>=L2 the two eigenvalues of the ST at location
%              (r,c).
%                    
%
% ALGORITHM 
% For each pixel of input image img, the ST is defined as the 2x2 matrix
% 
%      | Jxx  Jxy |
% J =  |          |
%      | Jxy  Jyy |
%       
% with 
%      Jxx = w * (Ix Ix)
%      Jxy = w * (Ix Iy)
%      Jyy = w * (Iy Iy)
%
% Above, 
% * is the convolution operator;
%
%
% w is an isotropic Gaussian kernel with standard deviation s;
%
%
% Ix and Iy are estimates of the partial derivatives of
% img with respect to x and y, obtained convolving img 
% with derivative of Gaussian (DoG) kernels.
%
%
% For a given J, the anisotropy index is
%
%   AI = (L1 - L2)/(L1 + L2)
%
% having defined L1 and L2 as the largest and smallest eigenvalues of J.
%
% The primary orientation of J in degrees is defined as the orientation of
% the eigenvector associated to L2, in the range [0; pi] degrees.
%
%
% REFERENCES
% [1] Matthew D. Budde and Joseph A. Frank, NeuroImage, Volume 63, Issue 1, 
% 15 October 2012, Pages 1 - 10:
% "Examining brain microstructure using structure tensor analysis of 
%  histological sections". 
%
% [2] Josef Bigun and Gosta H. Granlund, Proceedings of the IEEE, first
% International Conference on Computer Vision, London, June 1987:
% "Optimal orientation detection of linear simmetry".
%
%
% Author: Francesco Grussu, <f.grussu@ucl.ac.uk> <francegrussu@gmail.com>
%         UCL Institute of Neurology, University College London
%         London, United Kingdom
%
%         Code developed between January 2013 and July 2016

%%% Check for errors

% Throw an error in case of wrong number of input parameters
if((nargin~=2)&&(nargin~=3))
    error('ApplyStructureTensorStruct(): wrong number of input arguments.');
end

% Throw an error in case input image is not numeric
if( (isnumeric(img)~=1)||(size(img,3)~=1))
    error('ApplyStructureTensorStruct(): input image must be 2D numeric.');
end

% Throw an error in case input image is not 2D (gray scale).
if( ( length(size(img))>2 ) || (isvector(img)==1)  )
    error('ApplyStructureTensorStruct(): input image must be 2D (grayscale, single or double precision).');
end

%%% Evaluate ST for input image

% Allocate empty fields
[R,C] = size(img);
SToutput = STinput;
img = single(img);
SToutput.Tensor.Orientation = zeros(R,C,'single');
SToutput.Tensor.AI = zeros(R,C,'single');

% Calculate spatial derivatives with respect to x and y employing DoG
% kernels
dImage_dx = filter2(single(SToutput.DoGxKernel),img);
dImage_dy = filter2(single(SToutput.DoGyKernel),img);

clear img   % Release some memory

% Calculate the ST integrating neighbourhood information from the spatial
% derivatives. Use filter2() with SToutput.GaussianKernel as set of filter
% coefficients (such filter is isotropic and both filter2() and conv2() 
% would work the same way).
Ixx = (dImage_dx).*(dImage_dx);
Ixy = (dImage_dx).*(dImage_dy);
Iyy = (dImage_dy).*(dImage_dy);

clear dImage_dx dImage_dy   % Release some memory

Jxx = filter2(single(SToutput.GaussianKernel),Ixx); 
Jxy = filter2(single(SToutput.GaussianKernel),Ixy);
Jyy = filter2(single(SToutput.GaussianKernel),Iyy); 

clear Ixx Ixy Iyy   % Release some memory

%%% Evaluate ST eigensystem. If L1 and L2 are ST eigenvalues, arrange data s.t. L1 >= L2 .

% Loop through all possible 2x2 ST at all locations: calculate the
% eigensystem

% Implementation without parallel computing
if nargin==2
    dummyEigenvalues11 = zeros(R,C,'single');
    dummyEigenvalues22 = zeros(R,C,'single');
    for rr=1:R
        for cc=1:C
            % Get eigensystem
            J_rr_cc = [Jxx(rr,cc) Jxy(rr,cc); Jxy(rr,cc) Jyy(rr,cc)];
            Vals = eig(J_rr_cc);
            % Arrange data s.t. first eigenvalue is bigger than second one
            dummyEigenvalues11(rr,cc) = single(Vals(2));
            dummyEigenvalues22(rr,cc) = single(Vals(1));
        end    
    end
    
% Implementation with parallel computing    
elseif nargin==3
    
    % Total number of pixels
    totParIter = R*C;
    
    % Create pointers to the row and column positions (use appropiate data
    % type to save memory)
    if(R<2^8)     
       rowPtr = uint8( reshape( repmat( 1:R , C , 1 ) , 1 , totParIter ) ); % Pointer to rows;       
    elseif((R>=2^8)&&(R<2^16))
       rowPtr = uint16( reshape( repmat( 1:R , C , 1 ) , 1 , totParIter ) ); % Pointer to rows;     
    elseif((R>=2^16)&&(R<2^32))
       rowPtr = single( reshape( repmat( 1:R , C , 1 ) , 1 , totParIter ) ); % Pointer to rows;  
    elseif(R>=2^32)
       rowPtr = reshape( repmat( 1:R , C , 1 ) , 1 , totParIter ) ; % Pointer to rows; 
    end
    
    if(C<2^8)     
       colPtr = uint8( repmat( 1:C , 1 , R ) );  % Pointer to columns       
    elseif((C>=2^8)&&(C<2^16))
       colPtr = uint16( repmat( 1:C , 1 , R ) );  % Pointer to columns     
    elseif((C>=2^16)&&(C<2^32))
       colPtr = single( repmat( 1:C , 1 , R ) );  % Pointer to columns  
    elseif(C>=2^32)
       colPtr = repmat( 1:C , 1 , R );  % Pointer to columns 
    end   
    
    % Dummy variabls for the parfor loop
    dummyEigenvalues11 = zeros(1,totParIter,'single');
    dummyEigenvalues22 = zeros(1,totParIter,'single');  
    
    % Number of cores to be used
    nWorkers = varargin{1};    
    
    % Open the matlab pool with nWorkers cores
    versStr = version;
    versStr = versStr(end-7:end-2); versStr = str2num(versStr);
    if(versStr<2014)
        matlabpool('open',nWorkers);   % Syntax for previous versions
    else
        myPool = parpool(nWorkers);    % Syntax for versions 2014 or older
    end
    
    % Loop through different voxels: fix a row, go through columns; update row  
    parfor vv=1:totParIter    
           % Get pointers to row and column
           rr = rowPtr(vv);
           cc = colPtr(vv);
           % Get eigensystem at the current location
           J_rr_cc = [Jxx(rr,cc) Jxy(rr,cc); Jxy(rr,cc) Jyy(rr,cc)];
           Vals = eig(J_rr_cc);
           % Arrange data s.t. first eigenvalue is bigger than second one, copying data in two dummy buffers
           dummyEigenvalues11(vv) = single(Vals(2));
           dummyEigenvalues22(vv) = single(Vals(1)); 
    end
    
     
    % Close the matlab pool since the job is done        
    if(versStr<2014)
        matlabpool close force;   % Syntax for previous versions
    else
        delete(myPool);           % Syntax for versions 2014 or older
    end
    
    clear rowPtr colPtr   % Release memory
    
    % Reconstruct the 4D data structure storing the eigensystem
    dummyEigenvalues11 = transpose( reshape(dummyEigenvalues11,C,R) );
    dummyEigenvalues22 = transpose( reshape(dummyEigenvalues22,C,R) );
    
end

%%% Calculate ST metrics (orientation and AI).

% Primary orientation calculated according to reference [2] but with a tiny correction:
% the published algorithm is modified slightly to get angles in the range 
% [0; pi] radians, whereas in the original work they are mapped onto [-pi; pi] radians
bufferPhi = 0.5*angle( ( Jyy - Jxx  ) + 1i*2*Jxy);  % Apply Bigun and Grandlund formula (ref [2]) providing anles in [-pi;pi]
bufferPhi(bufferPhi<0) = angle( exp(1i*bufferPhi(bufferPhi<0))*exp(1i*pi)  );  % Remap negative angles in the positive range, so that angles will be in [0; pi]
SToutput.Tensor.Orientation = bufferPhi; % Save the orientation map in radians

clear Jxx Jxy Jyy bufferPhi    % Release some memory

% Anisotropy index
SToutput.Tensor.AI = abs( dummyEigenvalues11 - dummyEigenvalues22 ) ./ abs( dummyEigenvalues11 + dummyEigenvalues22 ); % Save the anisotropy map

end