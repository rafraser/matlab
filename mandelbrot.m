% Global variables for simulation
xrange = [-2, 1];
yrange = [-2, 2];
resolution = 500;
maxiterate = 100;

% Calculate the grid of points
xG = linspace(xrange(1), xrange(2), resolution);
yG = linspace(yrange(1), yrange(2), resolution);
results = zeros(resolution);

% Iterate over each point in the image
for yp = 1:length(yG)
    yy = yG(yp);
    for xp = 1:length(xG)
        xx = xG(xp);
        z0 = xx + 1i*yy;
        n = iterate(z0, maxiterate);
        results(yp, xp) = n;
    end
end

% Display the grid of results
imagesc(results);
axis off

% Iteration function
% Performs the test z(n+1) = z(n)^2 + c
% Returns number of iterations until either the max is reached
% or abs(z) exceeds z (escapes)
function n = iterate(z0, maxiterate)
    n = 0;
    z = z0;
    while n < maxiterate
        z = z.*z + z0;
        if abs(z) > 2
            return
        else
            n = n + 1;
        end
    end
end