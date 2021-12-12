function imgStds = stdFilter(img, dim)
[m, n] = size(img);
imgDouble = double(img);
imgStds = zeros(m, n);
if mod(dim(1), 2) == 0 || mod(dim(2), 2) == 0
    error("Invalid dimension. The size (%d, %d) must all be odd numbers.", dim(1), dim(2));
end
fXDimShift = floor(dim(1)/2);
fYDimShift = floor(dim(2)/2);
for i=1:m
    % Slide from left to right
    for j=1:n
        left = max(1, j-fXDimShift);
        right = min(n, j+fXDimShift);
        top = max(1, i-fYDimShift);
        bottom = min(m, i+fYDimShift);
        window = imgDouble(top:bottom, left:right);
        imgStds(i, j) = std(window, 1, 'all');
    end
end
end

