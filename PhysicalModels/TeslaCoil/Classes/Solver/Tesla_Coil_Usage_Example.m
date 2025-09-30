%% Usage Example - Tesla Coil Analysis with Enhanced OOP Architecture
% This demonstrates how to use your circuit analysis architecture

clear; clc;

%% Define symbolic variables
syms s R_p L_p C_p R_s L_s C_s C_top M k V_in real positive

fprintf('=== TESLA COIL CIRCUIT ANALYSIS ===\\n');

%% Step 1: Create the circuit
tesla_circuit = Circuit('Tesla_Coil_Circuit');

%% Step 2: Add circuit elements

% Primary side components
tesla_circuit.addVoltageSource('V1', [1, 0], V_in);        % Input voltage
tesla_circuit.addResistor('R_primary', [1, 2], R_p);       % Primary resistance
tesla_circuit.addInductor('L_primary', [2, 0], L_p);       % Primary inductance  
tesla_circuit.addCapacitor('C_primary', [1, 0], C_p);      % Primary tank capacitor

% Secondary side components
tesla_circuit.addInductor('L_secondary', [3, 4], L_s);     % Secondary inductance
tesla_circuit.addResistor('R_secondary', [4, 0], R_s);     % Secondary resistance
tesla_circuit.addCapacitor('C_secondary', [3, 0], C_s);    % Secondary self-capacitance

% Top load capacitor (this is what you wanted to add)
tesla_circuit.addCapacitor('C_topload', [3, 0], C_top);    % Top electrode capacitance

% Mutual inductance between primary and secondary
tesla_circuit.addMutualInductance('M1', 'L_primary', 'L_secondary', M);

%% Step 3: Display the circuit
tesla_circuit.displayCircuit();

%% Step 4: Create solver and analyze
solver = CircuitSolver(tesla_circuit);

% Build the system matrices
solver.buildMNAMatrix();

% Solve for node voltages
solver.solveNodeVoltages();

% Calculate transfer function (secondary voltage / input voltage)
H_tesla = solver.calculateTransferFunction(1, 3);  % From node 1 to node 3

% Generate state-space model
[A, B, C, D] = solver.generateStateSpace([1], [3]);

% Display all results
solver.displayResults();

%% Step 5: Adding more components dynamically

fprintf('\\n=== ADDING ADDITIONAL COMPONENTS ===\\n');

% Add a spark gap (modeled as resistance) in series with secondary
tesla_circuit.addResistor('R_sparkgap', [4, 5], sym('R_gap'));

% Add tuning capacitor in parallel with primary
tesla_circuit.addCapacitor('C_tuning', [1, 0], sym('C_tune'));

% Re-analyze with new components
solver_enhanced = CircuitSolver(tesla_circuit);
solver_enhanced.solveNodeVoltages();
H_enhanced = solver_enhanced.calculateTransferFunction(1, 3);

fprintf('Enhanced circuit transfer function calculated\\n');

%% Step 6: Integration with your existing coil classes

fprintf('\\n=== INTEGRATION WITH EXISTING COIL CLASSES ===\\n');

% Example of how to integrate with your SolenoidCoil classes
function circuit = createCircuitFromCoils(primary_coil, secondary_coil, M_mutual, C_topload)
    % Convert your coil objects to circuit representation
    
    circuit = Circuit('Tesla_Coil_From_Objects');
    
    % Extract parameters from coil objects
    R_p_val = primary_coil.resistance;
    L_p_val = primary_coil.inductance;
    C_p_val = primary_coil.capacitance;
    
    R_s_val = secondary_coil.resistance;
    L_s_val = secondary_coil.inductance;
    C_s_val = secondary_coil.capacitance;
    
    % Add elements to circuit
    circuit.addVoltageSource('V_drive', [1, 0], sym('V_in'));
    circuit.addResistor('R_pri', [1, 2], R_p_val);
    circuit.addInductor('L_pri', [2, 0], L_p_val);
    circuit.addCapacitor('C_pri', [1, 0], C_p_val);
    
    circuit.addInductor('L_sec', [3, 4], L_s_val);
    circuit.addResistor('R_sec', [4, 0], R_s_val);
    circuit.addCapacitor('C_sec', [3, 0], C_s_val);
    circuit.addCapacitor('C_top', [3, 0], C_topload);  % Top load
    
    circuit.addMutualInductance('M_coupling', 'L_pri', 'L_sec', M_mutual);
end

% Usage would be:
% primary = SolenoidCoil(primary_params);
% secondary = SolenoidCoil(secondary_params);
% M_value = primary.MutualInductance(secondary);
% 
% circuit_from_coils = createCircuitFromCoils(primary, secondary, M_value, sym('C_topload'));
% solver_from_coils = CircuitSolver(circuit_from_coils);

%% Step 7: Different Circuit Topologies

fprintf('\\n=== EXAMPLE: DIFFERENT CIRCUIT TOPOLOGIES ===\\n');

% RLC Filter
filter_circuit = Circuit('RLC_Filter');
filter_circuit.addVoltageSource('Vin', [1, 0], sym('V_in'));
filter_circuit.addResistor('R1', [1, 2], sym('R'));
filter_circuit.addInductor('L1', [2, 3], sym('L'));
filter_circuit.addCapacitor('C1', [3, 0], sym('C'));

filter_solver = CircuitSolver(filter_circuit);
H_filter = filter_solver.calculateTransferFunction(1, 3);
fprintf('RLC filter transfer function calculated\\n');

% Op-amp circuit
opamp_circuit = Circuit('OpAmp_Circuit');
opamp_circuit.addVoltageSource('Vin', [1, 0], sym('V_in'));
opamp_circuit.addResistor('R1', [1, 2], sym('R1'));
opamp_circuit.addResistor('R2', [2, 3], sym('R2'));
opamp_circuit.addCapacitor('C1', [2, 0], sym('C1'));

opamp_solver = CircuitSolver(opamp_circuit);
H_opamp = opamp_solver.calculateTransferFunction(1, 3);
fprintf('Op-amp circuit transfer function calculated\\n');

%% Step 8: Advanced Analysis Features

fprintf('\\n=== ADVANCED ANALYSIS ===\\n');

% Frequency response analysis
if ~isempty(H_tesla)
    fprintf('Analyzing frequency response...\\n');
    % This would plot Bode plots
    % solver.analyzeFrequencyResponse(H_tesla);
end

% State-space analysis
if ~isempty(solver.state_space)
    fprintf('State-space model available:\\n');
    fprintf('  A matrix: [%dx%d]\\n', size(solver.state_space.A));
    fprintf('  B matrix: [%dx%d]\\n', size(solver.state_space.B));
    fprintf('  C matrix: [%dx%d]\\n', size(solver.state_space.C));
    fprintf('  D matrix: [%dx%d]\\n', size(solver.state_space.D));
end

%% Step 9: Export capabilities

% Save circuit for later use
tesla_circuit.saveCircuit('tesla_coil_circuit.mat');

% Export to Simulink (placeholder)
% solver.exportToSimulink('tesla_coil_model');

%% Summary

fprintf('\\n=== SUMMARY OF CAPABILITIES ===\\n');
fprintf('✓ Object-oriented circuit element design\\n');
fprintf('✓ Easy addition/removal of components\\n');
fprintf('✓ Symbolic circuit analysis\\n');
fprintf('✓ Transfer function calculation\\n');
fprintf('✓ State-space generation\\n');
fprintf('✓ Integration with existing coil classes\\n');
fprintf('✓ Support for mutual inductance\\n');
fprintf('✓ Multiple circuit topologies\\n');
fprintf('✓ Circuit validation and error checking\\n');
fprintf('✓ Save/load functionality\\n');

%% Key Benefits of Your Architecture

fprintf('\\n=== ADVANTAGES OF YOUR OOP DESIGN ===\\n');
fprintf('1. **Modularity**: Each component is a separate class\\n');
fprintf('2. **Extensibility**: Easy to add new component types\\n');
fprintf('3. **Reusability**: Components work in any circuit\\n');
fprintf('4. **Maintainability**: Clear separation of concerns\\n');
fprintf('5. **Symbolic**: Full symbolic math support\\n');
fprintf('6. **General Purpose**: Works for any linear circuit\\n');

%% Next Steps

fprintf('\\n=== SUGGESTED ENHANCEMENTS ===\\n');
fprintf('1. Add controlled sources (VCVS, CCCS, etc.)\\n');
fprintf('2. Implement complete MNA with voltage sources\\n');
fprintf('3. Add AC analysis capabilities\\n');
fprintf('4. Include noise analysis\\n');
fprintf('5. Add parameter sweeping\\n');
fprintf('6. Implement sensitivity analysis\\n');
fprintf('7. Add circuit optimization routines\\n');
fprintf('8. Include subcircuit support\\n');

fprintf('\\nAnalysis complete!\\n');