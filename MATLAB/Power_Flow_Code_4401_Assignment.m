clear all;
clc;
% Define given data
zdata = [1 2 0.02 0.06; 1 3 0.08 0.24; 2 3 0.06 0.18; 2 4 0.06 0.18; 2 5 0.04 0.12; 3 4 0.01 0.03; 4 5 0.08 0.24];

% Number of buses
num_buses = max(max(zdata(:, 1:2)));

% Define parameters for each bus
% Bus 1: Slack bus
V = ones(num_buses, 1) * 1.06; % Voltage magnitudes (p.u.)
theta = zeros(num_buses, 1); % Voltage angles (radians)

% Bus 2: Generator bus
P_gen = zeros(num_buses, 1); % Supplied real power by generators (MW)
P_gen(2) = 40; % Supplied real power by generator at bus 2 (MW)

% Bus 3: Generator bus
P_gen(3) = 30; % Supplied real power by generator at bus 3 (MW)

% Bus 4: Load bus
P_load = zeros(num_buses, 1); % Active power injected by loads (MW)
Q_load = zeros(num_buses, 1); % Reactive power injected by loads (MVar)
P_load(4) = 50; % Load connected to bus 4 (MW)
Q_load(4) = 30; % Load connected to bus 4 (MVar)

% Bus 5: Load bus
P_load(5) = 80; % Load connected to bus 5 (MW)
Q_load(5) = 40; % Load connected to bus 5 (MVar)

% Convert admittance data to Ybus matrix
Ybus = zeros(num_buses);
for i = 1:size(zdata, 1)
    from_bus = zdata(i, 1);
    to_bus = zdata(i, 2);
    Z_line = zdata(i, 3) + 1i * zdata(i, 4);
    Ybus(from_bus, to_bus) = -1 / Z_line;
    Ybus(to_bus, from_bus) = -1 / Z_line;
end
for i = 1:num_buses
    Ybus(i, i) = -sum(Ybus(i, :));
end

% Add small perturbation to diagonal elements of Ybus
Ybus = Ybus + 1e-9 * eye(num_buses);

% Define convergence criteria
max_iter = 100;
tolerance = 1e-6;

% Initialize variables for iteration
iter = 0;
delta_V = zeros(num_buses, 1);
delta_theta = zeros(num_buses, 1);

% Perform power flow iterations (Newton-Raphson method)
while iter < max_iter
    % Calculate power injections (P and Q) at each bus
    P_inj = P_gen - P_load;
    Q_inj = zeros(num_buses, 1); % Reactive power injections (MVar)

    % Calculate mismatch (P and Q) at each bus
    S_inj = P_inj + 1i * Q_inj;
    S_calculated = Ybus * V .* V;
    S_mismatch = S_calculated - conj(S_inj);

    % Jacobian matrix
    J11 = real(diag(V) * Ybus);
    J12 = diag(V);
    J21 = imag(diag(V) * Ybus);
    J22 = real(diag(V) * Ybus);
    J = [J11 J12; J21 J22];

    % Calculate correction vectors
    correction = -J \ [real(S_mismatch); imag(S_mismatch)];

    % Update voltage magnitudes and angles
    delta_V = correction(1:num_buses);
    delta_theta = correction(num_buses+1:end);
    V = V + delta_V;
    theta = theta + delta_theta;

    % Check convergence
    if max(abs(S_mismatch)) < tolerance
        disp(['Converged after ', num2str(iter), ' iterations.']);
        break;
    end

    iter = iter + 1;
end

% Display results
disp('Voltage Magnitude (p.u.):');
disp(V);
disp('Voltage Angle (radians):');
disp(theta);

% Calculate line flows
line_flows = zeros(size(zdata, 1), 1);
for i = 1:size(zdata, 1)
    from_bus = zdata(i, 1);
    to_bus = zdata(i, 2);
    Z_line = zdata(i, 3) + 1i * zdata(i, 4);
    line_flows(i) = (V(from_bus) - V(to_bus)) / Z_line;
end
disp('Line Flows (p.u.):');
disp(line_flows);
