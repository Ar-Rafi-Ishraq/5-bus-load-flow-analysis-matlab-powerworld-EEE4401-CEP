%% Gauss-Seidel Power Flow Analysis with Line Flows
clear all;
clc;
% Impedance data
zdata = [1 2 0.02 0.06; 
         1 3 0.08 0.24; 
         2 3 0.06 0.18; 
         2 4 0.06 0.18; 
         2 5 0.04 0.12; 
         3 4 0.01 0.03; 
         4 5 0.08 0.24];

% Bus types and parameters
bus_type = {'slack', 'generator', 'generator', 'load', 'load'};
P_injected = [0; 40; 30; -50; -80]; % Real power injected (MW)
Q_injected = [0; 10; 15; -30; -40]; % Reactive power injected (MVar)

% Gauss-Seidel method parameters
max_iter = 100;
tol = 1e-6;

% Initialize variables
num_buses = max(max(zdata(:, 1)), max(zdata(:, 2)));
bus_voltages = ones(num_buses, 1);
bus_angles = zeros(num_buses, 1);
line_currents = zeros(size(zdata, 1), 1);
line_power_flows = zeros(size(zdata, 1), 1);

% Perform Gauss-Seidel power flow analysis
for iter = 1:max_iter
    max_change = 0;
    for i = 1:num_buses
        if i == 1 % Slack bus
            continue;
        end
        % Initialize net complex power injection
        S_net = 0;
        % Calculate net complex power injection
        for j = 1:num_buses
            if i ~= j
                % Get impedance between buses
                idx = find((zdata(:, 1) == i & zdata(:, 2) == j) | (zdata(:, 1) == j & zdata(:, 2) == i));
                if ~isempty(idx)
                    Z = zdata(idx, 3) + 1i * zdata(idx, 4); % Impedance (R + jX)
                    V = bus_voltages(j) * exp(1i * bus_angles(j));
                    S_net = S_net + (V / Z);
                end
            end
        end
        % Add injected power at the bus
        S_net = S_net + (P_injected(i) + 1i * Q_injected(i));
        % Update bus voltage magnitude and angle
        prev_voltage = bus_voltages(i);
        prev_angle = bus_angles(i);
        bus_voltages(i) = abs(S_net);
        bus_angles(i) = angle(S_net);
        % Check convergence
        change = max(abs(bus_voltages(i) - prev_voltage), abs(bus_angles(i) - prev_angle));
        if change > max_change
            max_change = change;
        end
    end
    % Check convergence
    if max_change < tol
        disp(['Convergence achieved after ', num2str(iter), ' iterations.']);
        break;
    end
    % Handle non-convergence
    if iter == max_iter
        disp('Warning: Power flow analysis did not converge within maximum iterations.');
    end
end

% Calculate line currents and power flows
for i = 1:size(zdata, 1)
    from_bus = zdata(i, 1);
    to_bus = zdata(i, 2);
    % Get impedance between buses
    idx = find((zdata(:, 1) == from_bus & zdata(:, 2) == to_bus) | (zdata(:, 1) == to_bus & zdata(:, 2) == from_bus));
    if ~isempty(idx)
        Z = zdata(idx, 3) + 1i * zdata(idx, 4); % Impedance (R + jX)
        V_from = bus_voltages(from_bus) * exp(1i * bus_angles(from_bus));
        V_to = bus_voltages(to_bus) * exp(1i * bus_angles(to_bus));
        if abs(Z) > 0 % Check if impedance is not zero
            line_currents(i) = (V_from - V_to) / Z;
            line_power_flows(i) = line_currents(i) * conj(V_from - V_to);
        else
            % Handle zero impedance case (line is short-circuited)
            line_currents(i) = 0;
            line_power_flows(i) = 0;
        end
    end
end

% Display results
disp('Convergence achieved after iteration:');
disp(iter);
disp('Bus Voltages:');
disp(bus_voltages);
disp('Bus Angles (radians):');
disp(bus_angles);
disp('Line Currents (complex):');
disp(line_currents);
disp('Line Power Flows (complex):');
disp(line_power_flows);
