function mask = edgeDetection(img, minDim, stepSize, iter, opt)
% Perform edge detection based on the image's standard deviation.
% Arguments:
%   img: A grayscale image. Should contain the intensity values of the
%       image.
%   minDim: The minimum dimension of the window used to calculation the 
%       standard deviation window.
%   stepSize: The size of each step. Determines the maxDim, which is
%       minDim + stepSize*(iter-1)
%   iter: The number of iterations. Determines the maxDim. See stepSize.
%   opt: Options for debugging.
%       showMasks (logical): Show the masks after each iteration (previous 
%           backgrounds will be ignored)
%       showRawMasks (logical): Show the masks after each iteration 
%           (previous backgrounds will NOT be ignored)
%       p: A value between 0 and 1. By default, 0.2.
% Create a parallel pool on demand
if isempty(gcp('nocreate'))
    parpool;
end

% Handle default values
if nargin < 2 || isempty(minDim)
    minDim = 7;
end
if nargin < 3 || isempty(stepSize)
    stepSize = 4;
end
if nargin < 4 || isempty(iter)
    iter = 8;
end
if nargin < 5
    opt = [];
end
if ~isfield(opt, 'showMasks')
    opt.showMasks = false;
end
if ~isfield(opt, 'showRawMasks')
    opt.showRawMasks = false;
end
if ~isfield(opt, 'showMaskProd')
    opt.showMaskProd = false;
end

% Calculate the values to be used in subsequent calculations
[m, n] = size(img);
maxDim = minDim + stepSize*(iter-1);
numSteps = max(((maxDim-minDim)/stepSize), 1);

% Used to record the masks generated on each iteration
% The first mask in the cell is the one calculated with the largest window
% size.
masks = cell(numSteps, 1);

% Compute all the masks in parallel.
parfor i=1:numSteps
    % Caclulate the dimension of the current iteration
    dim = maxDim - stepSize*(i-1);
    
    % Use stdFilter to calculate the standard deviations of the image
    % The imgStds has the same dimension as the original image
    imgStds = stdFilter(img, [dim, dim]);
    
    % Use the k-means clustering algorithm to identify the backgrounds and
    % edges (k=2).
    % By default, the algorithm will try to perform k-means clustering
    % a maximum of 10 times. For each attempt, the algorithm checks whether
    % there are two clusters (borders, and backgrounds). If there is only
    % one cluster, continue until two clusters are formed.
    maxAttempt = 10;
    attempt = 0;
    res = [];
    while attempt < maxAttempt
        res = kMeans(imgStds(:), 2);
        attempt = attempt + 1;
        
        % When two clusters have formed, end the loop
        if (~all(res.assignments == 1) && ~all(res.assignments == 2))
            break;
        end
    end
    
    % asOr: Assignments in the shape that matches the original image:
    %   from a vector to a matrix
    asOr = reshape(res.assignments, size(img));
    
    % *Naively* assume the number of pixels in the region for edges is 
    % less than the number of pixels in the background region.
    if res.centroids(1) > res.centroids(2)
        bgCluster = 2;
    else
        bgCluster = 1;
    end
    
    % Initialize the mask for the current iteration
    masks{i} = ones(m, n);
    
    % Set the background regions to 0. The other region indicates there may
    % be edges in there.
    masks{i}(asOr == bgCluster) = 0;
end

% Debug: Show the uncorrected masks
if opt.showRawMasks
    for i=1:numSteps
        dim = maxDim - stepSize*(i-1);
        figure
        imshow(masks{i});
        title(sprintf("Raw mask for dimension %d*%d", dim, dim));
    end
end

% Debug: Show the element-wise multiplication between the two adjacent 
% masks
if opt.showMaskProd
    for i=numSteps:-1:2
        dim = maxDim - stepSize*(i-1);
        dim2 = maxDim - stepSize*(i-2);
        figure
        imshow(masks{i} .* masks{i-1});
        title(sprintf("Mask product between dimension %d*%d and %d*%d", ...
            dim, dim, dim2, dim2));
    end
end

mask = ones(m, n);
for i=1:numSteps
    mask = mask .* masks{i};
end

% Debug tool: Show the masks after the correction algorithm
if opt.showMasks
    dMask = ones(size(img));
    for i=1:numSteps
        dim = maxDim - stepSize*(i-1);
        dMask = dMask .* masks{i};
        figure
        imshow(dMask);
        title(sprintf("Mask for dimension %d*%d", dim, dim));
    end
end
end

