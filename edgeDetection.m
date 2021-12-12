function mask = edgeDetection(img, minDim, stepSize, iter, opt)
% Perform edge detection based on the image's standard deviation.
% Arguments:
%   img: A grayscale image. Should contain the intensity values of the
%       image.
%   minDim: The minimum dimension of the standard deviation calculation 
%       filter.
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
if nargin < 2 || ~isempty(minDim)
    minDim = 3;
end
if nargin < 3 || ~isempty(stepSize)
    stepSize = 4;
end
if nargin < 4 || ~isempty(iter)
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
if ~isfield(opt, 'p')
    opt.p = 0.2;
end

% Calculate the values to be used in subsequent calculations
[m, n] = size(img);
maxDim = minDim + stepSize*(iter-1);
numSteps = (maxDim-minDim)/stepSize;

% Used to record the masks generated on each iteration
% The first mask in the cell is the one calculated with the largest filter
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
    if length(find(asOr == 1)) < length(find(asOr == 2))
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

% The following for-loop solves the problem that when the filter size 
% is large, images containing a lot of edges may incorrectly identify 
% the backgrounds and edges: the naive assumption above may guide the 
% algorithm to identify the edges as background when the number of pixels 
% for edges is more than that for the actual backgrounds. 
% 
% The following for-loop assumes that there are fewer edges than 
% backgrounds in the smallest filter. It iteratively checks whether there 
% is a flip between the i-th filter and (i-1)-th mask.
% 
% A “flip” means most of the pixels that classified as background in the 
% i-th mask became the edges in the (i-1)-th mask. This phenomenon can be 
% indicated by checking the element-wise multiplication of the two masks. 
% If the resulting mask contains drastically less edges (1s), then we can 
% determine there is a “flip.” In such cases, the algorithm flips all the 
% values in the (i-1)-th mask, setting all ones to zeros and all zeros to 
% ones.
% At the same time, compute the final mask: the element-wise multiplication
% of all masks.
mask = masks{numSteps};
for i=numSteps:-1:2
    % Check the i-th and (i-1)-th mask
    maskProd = masks{i} .* masks{i-1};
    
    % Count the number of edges (pixels) in the (i-1)-th mask
    cmn = length(find(masks{i-1} == 1));
    
    % Count the number of edges after element-wise multiplication
    cmo = length(find(maskProd == 1));
    
    if cmn * opt.p > cmo
        masks{i-1} = abs(masks{i-1} - 1);
    end
    
    % Update the final mask
    mask = mask .* maskProd;
    
    % Debug: Show the element-wise multiplication between the two adjacent 
    % masks
    if opt.showMaskProd
        dim = maxDim - stepSize*(i-1);
        dim2 = maxDim - stepSize*(i-2);
        figure
        imshow(masks{i});
        title(sprintf("Mask product between dimension %d*%d and %d*%d", ...
            dim, dim, dim2, dim2));
    end
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

