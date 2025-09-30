classdef Resistor < CircuitNode
    % Resistor implementation
    % Enhanced version of your original Resistor class
    
    properties (Constant)
        element_type = 'R';
    end
    
    methods
        function obj = Resistor(name, nodes, value)
            % Constructor: Resistor('R1', [1, 2], sym('R'))
            obj@CircuitNode(name, nodes, value);
        end
        
        function Z = getImpedance(obj, s)
            % Resistor impedance is frequency-independent
            Z = obj.value;
        end
        
        function Y = getAdmittance(obj, s)
            % Admittance Y = 1/R
            Y = 1 / obj.value;
        end
        
        function stampMNA(obj, G, B, s, node_map)
            % Stamp resistor into MNA matrices
            % G is the conductance matrix, B is the input vector
            
            % Get matrix indices for the nodes
            n1 = obj.nodes(1);
            n2 = obj.nodes(2);
            
            % Convert node numbers to matrix indices (skip ground = 0)
            if n1 ~= 0
                i = node_map(n1);
            else
                i = 0;
            end
            
            if n2 ~= 0
                j = node_map(n2);
            else
                j = 0;
            end
            
            % Conductance value
            g = 1 / obj.value;
            
            % Stamp into conductance matrix
            if i > 0 && j > 0  % Both nodes are non-ground
                G(i,i) = G(i,i) + g;
                G(j,j) = G(j,j) + g;
                G(i,j) = G(i,j) - g;
                G(j,i) = G(j,i) - g;
            elseif i > 0  % Only first node is non-ground
                G(i,i) = G(i,i) + g;
            elseif j > 0  % Only second node is non-ground
                G(j,j) = G(j,j) + g;
            end
        end
        
        function eq = getKVLEquation(obj, current_var)
            % Return KVL equation: V = R * I
            eq = obj.value * current_var;
        end
        
        function eq = getKCLEquation(obj, voltage_vars)
            % Return KCL equation: I = (V1 - V2) / R
            V1 = voltage_vars(1);
            V2 = voltage_vars(2);
            eq = (V1 - V2) / obj.value;
        end
    end
end