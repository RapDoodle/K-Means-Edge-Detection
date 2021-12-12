function res = kMeans(data, k, opt)
% Perform K-Means clustering
% Authors: 
%   Bohui WU, Rui LIU
% Arguments:
%   data: The data with shape (m, n) where n is the numebr of dimensions
%   k: The number of clusters
%   options (optional): The options struct containing additional
%       information. Here are the available options
%       randomInit: true or false (default: true). In such cases, provide
%       the 'centroids'.
%       centroids: The initial centroids.
%       randomMethod: random method (default: random). 
%           1. random: Randomly initilize to values between min and
%              max.
%           2. randomPoints: Randomly choose points in the data set.
%       closenessMetric: Here are the available options
%           'euclidean': The Euclidean distance.
%           
% =======================================================================
% Handle default values
if nargin < 3
    opt.randomInit = true;
    opt.randomMethod = 'random';
end
if ~isfield(opt, 'closenessMetric')
    opt.closenessMetric = 'euclidean';
end

res.randomInit = opt.randomInit;
res.k = k;
res.min = min(min(data));
res.max = max(max(data));
[m, n] = size(data);
if opt.randomInit
    centroids = rand(k, n) * (res.max - res.min) + res.min;
else
    if ~isfield(opt, 'centroids')
        error(['Centroids not specified when random initialization ', ...
               'mode is set to false.']);
    end
    centroids = opt.centroids;
    assert(size(centroids, 1) == k);
    assert(size(centroids, 2) == n);
end
if strcmp(opt.closenessMetric, 'euclidean')
    closenessMetric = 1;
else
    error('Unknown metric.');
end

% The K-Means clustering algorithm
prevAssignments = -1 * ones(m ,1);
assignments = zeros(m, 1);
ds = zeros(m, 1);
stepCount = 0;
while true
    stepCount = stepCount + 1;
    dSum = 0;
    
    % Go through each point in the data set
    for p=1:m
        % Check for the distance closeness with each centroid
        dMin = double(intmax);
        closestCentroid = -1;
        for c=1:k
            if closenessMetric == 1
                d = sqrt(sum((data(p, :)-centroids(c, :)) .^ 2));
            end
            if d < dMin
                dMin = d;
                closestCentroid = c;
            end
        end
        assignments(p) = closestCentroid;
        ds(p) = dMin;
        dSum = dSum + dMin;
    end
    
    % Move the centroids to their new centroids
    for c=1:k
        matchedFilter = assignments == c;
        matchedPoints = data(matchedFilter, :);
        centroids(c, :) = mean(matchedPoints);
    end
    
    % Check for changes in dSum
    if all(prevAssignments == assignments)
        break;
    end
    prevAssignments = assignments;
end

res.centroids = centroids;
res.assignments = assignments;
res.stepCount = stepCount;
end

