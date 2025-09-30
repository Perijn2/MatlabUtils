classdef Inductor < CircuitNode
    % Inductor implementation
    % New class to add to your architecture
    
    properties (Constant)
        element_type = 'L';
    end
    
    methods
        function obj = Inductor(name, nodes, value)
            % Constructor: Inductor('L1', [1, 2], sym('L'))
            obj@CircuitNode(name, nodes, value);
        end
        
        function Z = getImpedance(obj, s)
            % Inductor impedance: Z = sL
            Z = s * obj.value;
        end
        
        function Y = getAdmittance(obj, s)
            % Inductor admittance: Y = 1/(sL)
            Y = 1 / (s * obj.value);
        end
        
        function stampMNA(obj, G, B, s, node_map)
            % Stamp inductor into MNA matrices
            
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
            
            % Admittance value Y = 1/(sL)
            y = 1 / (s * obj.value);
            
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
            % Return KVL equation: V = sL * I
            syms s
            eq = s * obj.value * current_var;
        end
        
        function eq = getKCLEquation(obj, voltage_vars)
            % Return KCL equation: I = (V1 - V2)/(sL)
            syms s
            V1 = voltage_vars(1);
            V2 = voltage_vars(2);
            eq = (V1 - V2) / (s * obj.value);
        end
        
        function is_state = isStateVariable(obj)
            % Inductor current is a state variable
            is_state = true;
        end
        
        function state_var = getStateVariable(obj)
            % Return symbolic state variable for inductor current
            state_var = sym(['i_' obj.name], 'real');
        end
        
        function deriv_eq = getStateDerivative(obj, voltage_var)
            % Return state derivative: di/dt = v/L
            state_var = obj.getStateVariable();
            deriv_eq = state_var == (voltage_var / obj.value);  % di/dt = v/L
        end
    end
end