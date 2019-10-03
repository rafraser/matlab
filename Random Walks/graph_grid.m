% Prepare some basic properties
n = 200;
t = 5000;
line_array = cell(n, 1);
x = zeros(n, t+1);
y = zeros(n, t+1);
axis([-50, 50, -50, 50]);
axis square;

% Colors
num_col = 100;
cmap = jet(num_col);

% Generate the random walks
for i=1:n
    % Prepare the animated line for each walk
    color = cmap(mod(i,num_col)+1,:);
    line_array{i, 1} = animatedline;
    set(line_array{i, 1}, 'MaximumNumPoints', 50);
    set(line_array{i, 1}, 'Color', color);
    
    % Generate the random walk
    % Each walk = 1 row of the matrix
    [xx, yy] = randwalk(t, 3);
    x(i,:) = xx;
    y(i,:) = yy;
end

% One second pause for recording purposes
pause(1);

% Animate!
for tt = 1:t+1
    for i=1:n
        addpoints(line_array{i, 1}, x(i, tt), y(i, tt))
    end
    drawnow;
end
