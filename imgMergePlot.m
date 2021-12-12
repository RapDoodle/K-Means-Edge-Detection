function imgMergePlot(img1, img2)
figure

% Plot the first image
ax1 = axes; 
im1 = imagesc(ax1, img2); 
im1.AlphaData = 0.8; % change this value to change the background image transparency 
axis square; 

hold all; 

% Plot the second data 
ax2 = axes; 
im2 = imagesc(ax2, img1); 
im2.AlphaData = 0.8; % change this value to change the foreground image transparency 
axis square; 

% Link the axes 
linkaxes([ax1,ax2])

% Hide the top axes
ax2.Visible = 'off'; 
ax2.XTick = []; 
ax2.YTick = []; 

% Add differenct colormap to different data if you wish 
colormap(ax1, 'winter');
colormap(ax2, 'summer');

% Set the axes and colorbar position 
set([ax1, ax2], 'Position', [.17 .11 .685 .815]); 
cb1 = colorbar(ax1, 'Position', [.05 .11 .0675 .815]); 
cb2 = colorbar(ax2, 'Position', [.88 .11 .0675 .815]); 
end