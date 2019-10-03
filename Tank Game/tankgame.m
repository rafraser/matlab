% Tank Game
%   Robert A Fraser - 2019
%   Version 2
% Starting the Game
%   When running the game, you have the option to input world options
%   These should be self-explanatory - if unsure, just leave blank
% Controls
%   Any player can use any set of controls
%   WASD + Space
%   Arrow Keys + Enter
% Currently Implemented Features
%   Random terrain generation
%   Tank movement
%   Projectile firing
% Upcoming Features
%   Allow players to enter a name
%   Possibly support more than 2 players?
%   Victory conditions
%
% Game code starts below this line
% --------------------------------
%
% Main function for initialization
% seed: integer to generate the terrain
% width: how wide should the terrain be
% height: how high should the terrain be
function tankgame()
    % Get world parameters from user
    width = input('Width (def. 150): ');
    height = input('Height (def. 15): ');
    seed = input('World Seed: ');
    player1_name = input('Player 1 Name: ', 's');
    player2_name = input('Player 2 Name: ', 's');
    
    % Verify the values are not empty
    if isempty(width)
        width = 150;
    end
    if isempty(height)
        height = 15;
    end
    if isempty(seed)
        seed = randi([1 99999]);
    end
    if isempty(player1_name)
        player1_name = 'Red';
    end
    if isempty(player2_name)
        player2_name = 'Blue';
    end
    
    % Define the game window
    % addprop allows us to add extra variables to this figure
    % This allows us to access the terrain vector etc.
    % without declaring them as global variables
    game = figure;
    addprop(game, 'Terrain');       % Terrain vector
    addprop(game, 'Player1');       % Red tank
    addprop(game, 'Player2');       % Blue tank
    addprop(game, 'TerrainVisual'); % Area plot of terrain
    addprop(game, 'CurrentPlayer'); % Current player
    addprop(game, 'WaitingShot');   % Boolean to allow input
    addprop(game, 'GameOver');      % Game over boolean
    addprop(game, 'Tanks');         % Unused variable
    
    % Generate the random terrain
    rng(seed);
    terrain = generateLand(width, 15, height);
    set(game, 'Terrain', terrain);
    
    % Pick a random color for the terrain
    % These are actually the default MATLAB line colors
    colors = [
              0, 0.4470, 0.7410; 
              0.8500, 0.3250, 0.0980;
              0.9290, 0.6940, 0.1250;
              0.4940, 0.1840, 0.5560;
              0.4660, 0.6740, 0.1880;
              0.3010, 0.7450, 0.9330;
              0.6350, 0.0780, 0.1840
    ];
    color = randi(length(colors), 1);
    % Draw the terrain with the given color
    terrain_graph = area(terrain, 'FaceColor', colors(color,:));
    set(game, 'TerrainVisual', terrain_graph);
    
    % Adjust axis
    axis([1 width 0 height + 10]);
    set(gca, 'YTickLabel', [], 'XTickLabel', []);
    grid on;
    % Size and position the window
    set(game, 'Position', [100, 100, width * 5, height * 20]);
    movegui(game, 'center');
    
    % Create the two tank representations
    tank1 = line('color', 'r', 'Marker', '.', 'MarkerSize', 35);
    tank2 = line('color', 'b', 'Marker', '.', 'MarkerSize', 35);
    % Do all the boring variable stuff for the tanks
    prepareTank(tank1, 1);
    prepareTank(tank2, 2);
    % Set the tank names
    set(tank1, 'Name', player1_name);
    set(tank2, 'Name', player2_name);
    
    % Create HP labels
    label1 = annotation('textbox', [0 .7 .1 .2], 'EdgeColor', 'none');
    label2 = annotation('textbox', [.9 .7 .1 .2], 'EdgeColor', 'none');
    set(label1, 'HorizontalAlignment', 'center');
    set(label2, 'HorizontalAlignment', 'center');
    set(tank1, 'HPLabel', label1);
    set(tank2, 'HPLabel', label2);
    % Update the new labels
    tankUpdateLabel(tank1);
    tankUpdateLabel(tank2);
    
    % Register the tanks to the game window
    set(game, 'Player1', tank1);
    set(game, 'Player2', tank2);
    set(game, 'CurrentPlayer', tank1);
    updateTitle(game);
    
    % Set the starting positions (10 off each side)
    move(tank1, 10, terrain);
    move(tank2, width-10, terrain);
    
    % Register the keyboard handler
    % This calls keypress() whenever a key is pressed on the figure
    set(game, 'KeyPressFcn', @keypress);
end

% Do all the variable initialization for the tanks in this function
function prepareTank(tank, i)
    % Allocate variable properties to the tank
    addprop(tank, 'Arrow');    % Aiming indicator
    addprop(tank, 'AimAngle'); % Current angle
    addprop(tank, 'Health');   % Tank HP
    addprop(tank, 'HPLabel');  % HP Label
    addprop(tank, 'Name');     % Player Name (def. Red/Blue)
    
    % Set default variables for gameplay
    set(tank, 'Arrow', line());
    set(tank, 'AimAngle', pi/2);
    set(tank, 'Health', 100);
end

% Uh oh! A tank has been destroyed
function destroyTank(tank, game)
    tank1 = get(game, 'Player1');
    tank2 = get(game, 'Player2');
    if tank == tank1
        % Red player destroyed - blue wins
        winner_name = get(tank2, 'Name');
    else
        % Blue player destroyed - red wins
        winner_name = get(tank1, 'Name');
    end
    
    set(game, 'GameOver', 1);
    title([winner_name, ' wins!']);
end

% Update the title of the window
function updateTitle(game)
    waiting = get(game, 'WaitingShot');
    if waiting == 1
        title('Waiting for shot...');
    else
        p = get(game, 'CurrentPlayer');
        name = get(p, 'Name');
        title(['Your Turn, ', name, '!']);    
    end
end

% Update the drawing of the terrain visual
% This should be called after editing the terrain data structure
% game: the game window to update terrain of
function updateTerrainVisual(game)
    terrain_graph = get(game, 'TerrainVisual');
    terrain = get(game, 'Terrain');
    set(terrain_graph, 'ydata', terrain);
end

% Fire projectile
% obj: the tank that fired this projectile
% terrain: the terrain vector
function fireProjectile(obj, game)
    % Change the turn information
    set(game, 'WaitingShot', 1);
    updateTitle(game);
    % Check and cycle the players
    tank1 = get(game, 'Player1');
    tank2 = get(game, 'Player2');
    if obj == tank1
        set(game, 'CurrentPlayer', tank2);
    else
        set(game, 'CurrentPlayer', tank1);
    end
    
    % Calculate starting position & velocity
    ang = get(obj, 'AimAngle');
    xx = get(obj, 'xdata');
    yy = get(obj, 'ydata');
    xspeed = 1.5 * cos(ang);
    yspeed = 1 * sin(ang);
    grav = 0.025;
    i = 0;
    terrain = get(game, 'Terrain');
    
    % Prepare the trace line
    trace = animatedline('LineStyle', ':');
    addpoints(trace, xx, yy);
    % Prepare the projectile dot
    color = get(obj, 'color');
    dot = line('color', color, 'Marker', '.', 'MarkerSize', 10);
    set(dot, 'xdata', xx, 'ydata', yy);
    
    % Iterate movement of the projectile
    while(i<100)
        % Calculate motion
        xx = xx + xspeed;
        yy = yy + yspeed;
        yspeed = yspeed - grav;
        i = i + 1;
        
        % Check boundaries
        if xx < 1 || xx > length(terrain)
            break
        end
        
        % Check terrain collisions
        xt = round(xx);
        if yy <= terrain(xt) && i > 3
            break;
        end
        
        % Update the visuals
        addpoints(trace, xx, yy);
        set(dot, 'xdata', xx, 'ydata', yy);
        drawnow;
        pause(1/60);
    end
    
    % The projectile has landed!
    % Do some destruction!
    % Check damage to Tank 1
    tank1 = get(game, 'Player1');
    [t1x, t1y] = tankPos(tank1);
    t1d = euclidDistance(t1x, t1y, xx, yy);
    if t1d < 8
        damageTank(tank1, sqrt(10-t1d)*8, game);
    end
    
    % Check damage to Tank 2
    tank2 = get(game, 'Player2');
    [t2x, t2y] = tankPos(tank2);
    t2d = euclidDistance(t2x, t2y, xx, yy);
    if t2d < 10
        damageTank(tank2, sqrt(10-t2d)*8, game);
    end
    
    % Damage the terrain
    xx = round(xx);
    for tx = xx-15:xx+15
        terrain = damageTerrain(terrain, tx, xx, yy, 10);
    end
    delete(dot);
    
    % Update the visuals
    set(game, 'Terrain', terrain);
    updateTerrainVisual(game);
    
    % Make sure the tanks are in the right spots
    shift(tank1, 0, terrain);
    shift(tank2, 0, terrain);
    
    % Check the game isn't over & then unlock controls
    gameover = get(game, 'GameOver');
    if gameover == 1
        return
    else
        set(game, 'WaitingShot', 0);
        updateTitle(game);    
    end
end

% Simple euclidean distance check
% Takes square root of the below function
function d = euclidDistance(x1, y1, x2, y2)
    d = sqrt(distanceSquared(x1, y1, x2, y2));
end

% Euclidean distance without the square root
% Square roots are computationally expensive
% See above function for sqrt version
function ds = distanceSquared(x1, y1, x2, y2)
    ds = (x2-x1).^2 + (y2-y1).^2;
end

% Calculate damage for the given x-coordinate
function terrain = damageTerrain(terrain, tx, px, py, r)
    % Check the damage is inside the bounds
    if tx < 1 || tx > length(terrain)
        return
    end
    
    ty = terrain(tx);
    dmg = r - euclidDistance(px, py, tx, ty);
    if dmg < 0
        return
    end
    dmg = sqrt(dmg/10);
    
    terrain(tx) = max(1, ty-dmg);
end

% Take damage to a tank and reduce health
% tank: the tank to damage
% amount: the amount of damage to take
function damageTank(tank, amount, game)
    % Make sure damage is not negative
    % Tanks can't magically heal
    if amount <= 0
        return
    end
    
    % Update the HP
    old_hp = get(tank, 'Health');
    new_hp = round(old_hp - amount);
    set(tank, 'Health', new_hp);
    tankUpdateLabel(tank);
    
    % Check for destruction
    if new_hp <= 0
        set(tank, 'Health', 0);
        tankUpdateLabel(tank);
        destroyTank(tank, game);
    end
end

% Update the HP label of a tank
function tankUpdateLabel(tank)
    label = get(tank, 'HPLabel');
    name = get(tank, 'Name');
    hp = num2str(get(tank, 'Health'));
    
    set(label, 'String', {name, [hp, 'HP']});
end

% Keyboard handler
% This section is incredibly messy I'm sorry
% src: The figure that called this function
%   In this case, this will be the 'game' variable defined in main()
%   This allows us to access the terrain vector inside of this function
% event: the event information
%   This is used to figure out what key was pressed
function keypress(src, event)
    % Get useful game information
    key = event.Key;
    t = get(src, 'Terrain');
    
    % Check if we're waiting for a shot
    state = get(src, 'WaitingShot');
    if state == 1
        return
    end
    
    % Get the current player
    p = get(src, 'CurrentPlayer');
    
    % Handle keyboard
    % Significantly improved
    if key == "a" || key == "leftarrow"
        % Move left
        shift(p, -1, t);
    elseif key == "d" || key == "rightarrow"
        % Move right
        shift(p, 1, t);
    elseif key == "w" || key == "uparrow"
        % Aim counterclockwise
        a = get(p, 'AimAngle');
        set(p, 'AimAngle', min(a+pi/16, pi));
        shift(p, 0, t);
    elseif key == "s" || key == "downarrow"
        % Aim clockwise
        a = get(p, 'AimAngle');
        set(p, 'AimAngle', max(a-pi/16, 0));   
        shift(p, 0, t);
    elseif key == "space" || key == "return"
        % FIRE THE WEAPON
        fireProjectile(p, src);
    end
end

% Shift a given object by the given amount
% This is essentially a wrapper to make move() easier
% obj: tank to move
% x: change in x coordinate
% terrain: the terrain vector
function shift(obj, shift, terrain)
    current_x = get(obj, 'xdata');
    move(obj, current_x + shift, terrain);
end

% Move a given object along the terrain
% obj: tank to move
% x: new x coordinate
% terrain: the terrain vector
function move(obj, x, terrain)
    % Clamp the x to the terrain
    if x < 1
        x = 1;
    elseif x > length(terrain)
        x = length(terrain);
    end
    
    % Move the given object
    set(obj, 'xdata', x, 'ydata', terrain(x));
    drawArrow(obj);
end

% Get the X and Y coordinates of a tank
% obj: tank to get coordinates of
% Return: x and y position respectively
function [xx, yy] = tankPos(obj)
    xx = get(obj, 'xdata');
    yy = get(obj, 'ydata');
end

% Draw the targeting arrow of the tank
% obj: the tank to update arrow of
function drawArrow(obj)
    % One end should be centered in the tank
    xx = get(obj, 'xdata');
    yy = get(obj, 'ydata');
    
    % Calculate end position of arrow
    ang = get(obj, 'AimAngle');
    new_x = xx + 2*cos(ang);
    new_y = yy + 2*sin(ang);
    
    % todo: figure out why the length is unpredictable
    arrow = get(obj, 'Arrow');
    set(arrow, 'xdata', [xx new_x], 'ydata', [yy new_y]);
end

% Generate the terrain for the gameplay
% This is an implementation of perlin noise
% w: width of the game world
% s: size of each 'section'
% amp: max amplitude of the terrain
function terrain = generateLand(w, s, amp)
    % Generate starting variables
    tx = 1;
    ta = rand();
    tb = rand();
    terrain = zeros(w, 1);
    
    % Iterate until all points are generated
    while tx < w+1
        if mod(tx, s) == 0
            % Generate a random 'spike'
            ta = tb;
            tb = rand();
            terrain(tx) = ta*amp;
        else
            % Interpolate between the spikes
            terrain(tx) = cosinterpolate(ta, tb, (mod(tx, s)/s)) * amp;
        end
        tx = tx + 1;
    end
end

% Cosine interpolation
function yy = cosinterpolate(a, b, x)
    f = (1-cos(x*pi))/2;
    yy = linterpolate(a, b, f);
end

% Linear interpolation function
function yy = linterpolate(a, b, x)
    yy = a*(1-x) + b*x;
end