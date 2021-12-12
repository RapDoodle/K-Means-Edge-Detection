function img = loadImg(imgName, dim, showImg)
% Check is the folder figures in MATLAB's search path
if ~any(ismember('images', regexp(path,pathsep,'Split')))
    addpath('images');
end

% Read the image
img = imread("./images/" + imgName);

% Check if the image contains multiple color channels
if ~ismatrix(img)
    % Convert the image to grayscale
    img = rgb2gray(img);
end

% Option to resize the image
if nargin >= 2 && ~isempty(dim)
    img = imresize(img, dim);
end

% Option to show to image
if nargin >= 3 && showImg
    figure
    imshow(img);
    title('Original image');
end
end

