% Useful variables
radius = 1;

% Prepare the dots figure
fig_dots = figure('Name', 'Dots', 'Position', [100 380 600 600]);

% Prepare the line figure
fig_line = figure('Name', 'Animated Line', 'Position', [750 700 750 250]);
ylim([0 1]);
tracer = animatedline;
% Annotation
annotation('textbox',[.9 .5 .1 .2],'String','Expected: 0.5236','EdgeColor','none');
h = annotation('textbox',[.9 .3 .1 .2],'String','Actual: 0.5236','EdgeColor','none');

% Create the 3D view for the dot plotting
figure(fig_dots);
view(3);
axis([-1.25 1.25 -1.25 1.25 -1.25 1.25]);

% Prepare the counter
total_points = input('Number of trials: ');
inside_points = 0;
for i = 1:total_points
    % Generate random point
    px = -radius + 2*radius*rand();
    py = -radius + 2*radius*rand();
    pz = -radius + 2*radius*rand();
    r = sqrt(px^2 + py^2 + pz^2);
    hold on;
    
    % Plot the dots
    if r > radius
        plot3(px, py, pz, 'b.');
    else
        plot3(px, py, pz, 'r.');
        inside_points = inside_points + 1;
    end
    
    % Trace the line
    ratio = inside_points/total_points;
    addpoints(tracer, i, inside_points/total_points);
    set(h,'String',sprintf('Calculated: %0.4f', ratio));
    
    drawnow;
end