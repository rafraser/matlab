function [x, y] = randwalk(t, n)
    %RANDWALK Generates a 2D random walk
    % t: number of time steps to simulate
    % n: number of jump options
    % OUT x: vector of t+1 x positions
    % OUT y: vector of t+1 y positions
    
    % Initialise empty vectors
    x = zeros(t+1, 1);
    y = zeros(t+1, 1);
    length = 1;
    q = (2 * pi)/n;
    
    % Simulate over time
    for i = 2:t+1
        k = randi(n, 1) - 1;
        ang = k * q;
        
        x(i) = x(i-1) + length * cos(ang);
        y(i) = y(i-1) + length * sin(ang);
    end
end

