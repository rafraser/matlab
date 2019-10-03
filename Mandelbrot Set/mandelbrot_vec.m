% Global variables for simulation
xrange = [-2, 1];
yrange = [-2, 2];
resolution = 500;
maxiterate = 100;

% Calculate the grid of points
xx = linspace(xrange(1), xrange(2), resolution);
yy = linspace(yrange(1), yrange(2), resolution);
[xG, yG] = meshgrid(xx, yy);
results = zeros(resolution);

% Iterate over each point in the image
% This uses a vectorized approach - much faster in Matlab
z0 = xG + 1i*yG;
z = z0;
for n = 0:maxiterate
    z = z.*z + z0;
    inside = abs(z) <= 2;
    results = results + inside;
end

% Display the grid of results
imagesc(results);
axis off
% Use the custom colormap function
customMap = generateColorMap(maxiterate);
colormap(customMap);

function map = generateColorMap(maxiterate)
    % Color configuration
    rStr = 0.2;
    gStr = 0.8;
    bStr = 1;
    
    % Generate the colormap for each # of iterations
    map = zeros(maxiterate, 3);
    for n = maxiterate:-1:2
        p = n/maxiterate;
        map(n, 1) = rStr * (1-p);
        map(n, 2) = gStr * (1-p);
        map(n, 3) = bStr * (1-p);
    end
    map = flip(map);
end