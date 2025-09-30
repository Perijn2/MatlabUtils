classdef VoltageSource < CircuitNode
    % Voltage Source implementation
    % New class to add to your architecture for completeness
    
    properties (Constant)
        element_type = 'V';
    end
    
    methods
        function obj = VoltageSource(name, nodes, value)
            % Constructor: VoltageSource('V1', [1, 0], sym('V_in'))
            obj@CircuitNode(name, nodes, value);
        end
        
        function Z = getImpedance(obj, s)
            % Ideal voltage source has zero impedance
            Z = 0;
        end
        
        function Y = getAdmittance(obj, s)
            % Ideal voltage source has infinite admittance
            Y = inf;
        end
        
        function stampMNA(obj, G, B, s, node_map)
            % Stamp voltage source into MNA matrices
            % Voltage sources require additional equations in MNA
            
            % Get matrix indices for the nodes
            n1 = obj.nodes(1);
            n2 = obj.nodes(2);
            
            % This is a simplified implementation
            % Full MNA with voltage sources requires expanding the matrix
            % to include voltage source current variables
            
            % For now, just mark that this needs special handling
            fprintf('Voltage source %s requires extended MNA implementation\n', obj.name);
        end
        
        function eq = getVoltageConstraint(obj)
            % Return voltage constraint equation: V+ - V- = V_source
            syms V_plus V_minus
            eq = V_plus - V_minus - obj.value;
        end
        
        function is_input = isInputSource(obj)
            % Voltage sources are typically input sources
            is_input = true;
        end
        
        function val = getSourceValue(obj)
            % Get the source voltage value
            val = obj.value;
        end
    end
end