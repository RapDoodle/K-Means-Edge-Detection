%% Introduction
% This script is used to debug the edge detection algorithm.
% Additionally, it can be used to provide more insights into the algorithm.

%% Load the image
% The image will be loaded as an grayscale image and resized to 512*512
img = loadImg('14.jpg', [512, 512], true);
% Show the loaded image
imshow(img);

%% Define the parameters
minDim = 3;
stepSize = 4;
iter = 8;

%% Show raw filters
opt = [];
opt.showRawMasks = true;
edgeDetection(img, minDim, stepSize, iter, opt);

%% Show filters
opt = [];
opt.showMasks = true;
edgeDetection(img, minDim, stepSize, iter, opt);

%% Show the product of adjacent filters
opt = [];
opt.showMaskProd = true;
edgeDetection(img, minDim, stepSize, iter, opt);