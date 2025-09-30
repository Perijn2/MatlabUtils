classdef CircuitNode < handle
    % Abstract base class for all circuit elements
    % Enhanced version of your original CircuitNode
    
    properties (SetAccess = protected)
        name            % Component identifier
        nodes          % Connected node numbers [node1, node2]
        value          % Component value (can be symbolic)
    end
    
    properties (Abstract, Constant)
        element_type   % Type identifier ('R', 'L', 'C', 'M', etc.)
    end
    
    methods (Abstract)
        % Each component must implement these methods
        Z = getImpedance(obj, s)           % Symbolic impedance Z(s)
        Y = getAdmittance(obj, s)          % Symbolic admittance Y(s)
        stampMNA(obj, G, B, s, node_map)   % Stamp into MNA matrices
    end
    
    methods
        function obj = CircuitNode(name, nodes, value)
            % Constructor for circuit elements
            obj.name = name;
            obj.nodes = nodes;
            obj.value = value;
        end
        
        function setSymbolicValue(obj, sym_value)
            % Allow setting symbolic variables
            obj.value = sym_value;
        end
        
        function val = getValue(obj)
            % Get the current value (numeric or symbolic)
            val = obj.value;
        end
        
        function node_list = getNodes(obj)
            % Get connected nodes
            node_list = obj.nodes;
        end
        
        function type_str = getType(obj)
            % Get element type
            type_str = obj.element_type;
        end
        
        function name_str = getName(obj)
            % Get element name
            name_str = obj.name;
        end
        
        function displayInfo(obj)
            % Display element information
            fprintf('%s: %s = %s, Nodes: [%s]\n', ...
                    obj.element_type, obj.name, ...
                    char(obj.value), mat2str(obj.nodes));
        end
    end
end