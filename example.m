%% Introduction
% This script contains examples of how to invoke the routines
% Authors:
%   Bohui WU, Rui LIU

%% Load the images
% The image will be loaded as an grayscale image and resized to 512*512
img = loadImg('05.jpg', [512, 512], true);
% Show the loaded image
imshow(img);

%% Perform image segmentation (optional)
% This is just part of our assignment. Feel free to ignore ths section.
% It has nothing to do with image segmentation
% Perform image segmentation
k = 4;
imgSeg = imageSegmentation(img, k);

% Show the segmented image
figure
imshow(imgSeg);
title('k = ' + string(k));

%% Perform Edge Detection
% Perform edge detection
mask = edgeDetection(img);

% Plot the original image along with the mask
imgMergePlot(img, ones(size(img)).*mask);

