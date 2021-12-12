function img = imageSegmentation(img, k)
% Segments an image into k regions based on its intensity
% Arguments:
%   img: A grayscale image. Should contain the intensity values of the
%       image.
%   k: The number of regions that is expected to be segmented based 
%       on the image's intensity.
% Handle default values
if nargin < 2
    k = 8;
end

% Perform K-Means clustering
res = kMeans(double(img(:)), k);

% Set the intensity of each region to its mean
% asOr: Assignments in the shape that matches the original image:
%   from a vector to a matrix
asOr = reshape(res.assignments, size(img));
for i=1:length(res.centroids)
    % For each centroid, find the matching values
    matchedPos = find(asOr == i);
    
    % Calculate the mean of the region
    instVal = mean(img(matchedPos));
    
    % Set the intensity of the region to its mean
    img(matchedPos) = instVal;
end
end