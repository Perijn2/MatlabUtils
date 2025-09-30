classdef Capacitor < CircuitNode
    % Capacitor implementation
    % Enhanced version of your original Capacitor class
    
    properties (Constant)
        element_type = 'C';
    end
    
    methods
        function obj = Capacitor(name, nodes, value)
            % Constructor: Capacitor('C1', [1, 0], sym('C'))
            obj@CircuitNode(name, nodes, value);
        end
        
        function Z = getImpedance(obj, s)
            % Capacitor impedance: Z = 1/(sC)
            Z = 1 / (s * obj.value);
        end
        
        function Y = getAdmittance(obj, s)
            % Capacitor admittance: Y = sC
            Y = s * obj.value;
        end
        
        function stampMNA(obj, G, B, s, node_map)
            % Stamp capacitor into MNA matrices
            
            % Get matrix indices for the nodes
            n1 = obj.nodes(1);
            n2 = obj.nodes(2);
            
            % Convert node numbers to matrix indices
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
            
            % Admittance value Y = sC
            y = s * obj.value;
            
            % Stamp into conductance matrix
            if i > 0 && j > 0  % Both nodes are non-ground
                G(i,i) = G(i,i) + y;
                G(j,j) = G(j,j) + y;
                G(i,j) = G(i,j) - y;
                G(j,i) = G(j,i) - y;
            elseif i > 0  % Only first node is non-ground
                G(i,i) = G(i,i) + y;
            elseif j > 0  % Only second node is non-ground
                G(j,j) = G(j,j) + y;
            end
        end
        
        function eq = getKVLEquation(obj, current_var)
            % Return KVL equation: V = I/(sC)
            syms s
            eq = current_var / (s * obj.value);
        end
        
        function eq = getKCLEquation(obj, voltage_vars)
            % Return KCL equation: I = sC*(V1 - V2)
            syms s
            V1 = voltage_vars(1);
            V2 = voltage_vars(2);
            eq = s * obj.value * (V1 - V2);
        end
        
        function is_state = isStateVariable(obj)
            % Capacitor voltage is a state variable
            is_state = true;
        end
        
        function state_var = getStateVariable(obj)
            % Return symbolic state variable for capacitor voltage
            state_var = sym(['v_' obj.name], 'real');
        end
        
        function deriv_eq = getStateDerivative(obj, current_var)
            % Return state derivative: dv/dt = i/C
            state_var = obj.getStateVariable();
            deriv_eq = current_var / obj.value;  % dv/dt = i/C
        end
    end
end