clc; clear; close all;

%%%%%%%%% Number of Cell Required %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define battery configuration
S = 3;  % Number of cells in series
P = 3;  % Number of cells in parallel


total_cells = S * P;  % Total number of cells

%%%%%%%%%% 18650 Cell %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define 18650 cell dimensions (mm)
cell_diameter = 18;  
cell_radius = cell_diameter / 2;
row_spacing = cell_diameter + 1;  % Vertical spacing (stacked)
col_spacing = cell_diameter * cos(pi/6);  % Horizontal shift for honeycomb

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define color map for series groups
colors = lines(S);  % Generates S distinct colors

% Variables to store the best configuration
min_volume = inf;  
best_rows = 0;
best_cols = 0;
best_width = 0;
best_height = 0;

% Try different configurations of rows and columns
for rows = 1:total_cells
    for cols = 1:total_cells
        if rows * cols >= total_cells
            % Calculate bounding box dimensions
            width = (cols - 1) * col_spacing + cell_diameter;
            height = (rows - 1) * row_spacing * 0.866 + cell_diameter;
            volume = width * height * 70;  % Assume 70mm height for busbars

            % Find smallest bounding box
            if volume < min_volume
                min_volume = volume;
                best_rows = rows;
                best_cols = cols;
                best_width = width;
                best_height = height;
            end
        end
    end
end

% Compute honeycomb positions with proper parallel-group wiring
x = [];
y = [];
wiring_order = zeros(1, total_cells);
series_group = zeros(1, total_cells);  % Store which series group each cell belongs to
cell_count = 0;

% Fill honeycomb grid with correct wiring order
for s = 1:S  % Iterate through series groups
    for p = 1:P  % Iterate through parallel cells in each series group
        r = floor(cell_count / best_cols);  % Row index
        c = mod(cell_count, best_cols);  % Column index

        if mod(r,2) == 0  % Even rows
            x_pos = c * col_spacing;
        else  % Odd rows (shifted)
            x_pos = c * col_spacing + col_spacing / 2;
        end
        y_pos = r * row_spacing * 0.866;  

        % Store cell position
        x = [x, x_pos];
        y = [y, y_pos];

        % Assign wiring order & series group
        wiring_order(cell_count + 1) = cell_count + 1;  
        series_group(cell_count + 1) = s;  

        cell_count = cell_count + 1;
        if cell_count >= total_cells
            break;
        end
    end
    if cell_count >= total_cells
        break;
    end
end

% Center the layout around (0,0)
x = x - mean(x);
y = y - mean(y);

% Plot the layout with parallel-group coloring
figure;
hold on;
axis equal;

for i = 1:total_cells
    % Assign color based on series group (parallel grouping)
    color_index = series_group(i);  
    fill_color = colors(color_index, :);  
    
    % Draw the cell
    rectangle('Position', [x(i)-cell_radius, y(i)-cell_radius, cell_diameter, cell_diameter], ...
              'Curvature', [1,1], 'FaceColor', fill_color, 'EdgeColor', 'k', 'LineWidth', 1.5);
    
    % Label the cell with its wiring order
    text(x(i), y(i), num2str(wiring_order(i)), 'HorizontalAlignment', 'center', ...
         'Color', 'w', 'FontWeight', 'bold');
end

title(['Optimized Honeycomb Battery Pack Layout (', num2str(S), 'S', num2str(P), 'P)']);
xlabel('Width (mm)');
ylabel('Height (mm)');
grid on;
hold off;

% Display results
disp(['Optimal rows: ', num2str(best_rows)]);
disp(['Optimal columns: ', num2str(best_cols)]);
disp(['Minimum volume: ', num2str(min_volume), ' mm^3']);
disp(['Minimum volume: ', num2str(min_volume/1e3), ' cm^3'])
disp(['Width: ', num2str(best_width), ' mm'])
disp(['Height: ', num2str(best_height), ' mm'])
disp(['Length: ', num2str(70), ' mm'])