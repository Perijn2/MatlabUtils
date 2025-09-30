classdef Circuit < handle
    % Circuit class for managing circuit elements and topology
    % Enhanced version of your original Circuit class
    
    properties
        elements        % Cell array of CircuitNode objects
        nodes          % Array of unique node numbers
        node_map       % Map from node number to matrix index
        name           % Circuit name/identifier
    end
    
    methods
        function obj = Circuit(name)
            % Constructor
            if nargin < 1
                obj.name = 'UnnamedCircuit';
            else
                obj.name = name;
            end
            
            obj.elements = {};
            obj.nodes = [];
            obj.node_map = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
        end
        
        function addElement(obj, element)
            % Add a circuit element to the circuit
            if ~isa(element, 'CircuitNode')
                error('Element must inherit from CircuitNode');
            end
            
            obj.elements{end+1} = element;
            
            % Update node list (exclude mutual inductors which don't have nodes)
            if ~strcmp(element.element_type, 'M')
                element_nodes = element.getNodes();
                % Only add non-ground nodes (node 0 is ground)
                non_ground_nodes = element_nodes(element_nodes ~= 0);
                obj.nodes = unique([obj.nodes, non_ground_nodes]);
            end
            
            obj.updateNodeMap();
        end
        
        function removeElement(obj, element_name)
            % Remove an element by name
            element_idx = obj.findElementIndex(element_name);
            if element_idx > 0
                obj.elements(element_idx) = [];
                obj.updateNodes();
            else
                warning('Element %s not found', element_name);
            end
        end
        
        function element = getElement(obj, element_name)
            % Get an element by name
            element = [];
            for i = 1:length(obj.elements)
                if strcmp(obj.elements{i}.getName(), element_name)
                    element = obj.elements{i};
                    return;
                end
            end
        end
        
        function elements = getElementsByType(obj, element_type)
            % Get all elements of a specific type
            elements = {};
            for i = 1:length(obj.elements)
                if strcmp(obj.elements{i}.element_type, element_type)
                    elements{end+1} = obj.elements{i};
                end
            end
        end
        
        function addResistor(obj, name, nodes, value)
            % Convenience method to add a resistor
            resistor = Resistor(name, nodes, value);
            obj.addElement(resistor);
        end
        
        function addCapacitor(obj, name, nodes, value)
            % Convenience method to add a capacitor
            capacitor = Capacitor(name, nodes, value);
            obj.addElement(capacitor);
        end
        
        function addInductor(obj, name, nodes, value)
            % Convenience method to add an inductor
            inductor = Inductor(name, nodes, value);
            obj.addElement(inductor);
        end
        
        function addVoltageSource(obj, name, nodes, value)
            % Convenience method to add a voltage source
            source = VoltageSource(name, nodes, value);
            obj.addElement(source);
        end
        
        function addMutualInductance(obj, name, ind1_name, ind2_name, mutual_value)
            % Convenience method to add mutual inductance
            mutual = MutualInductor(name, ind1_name, ind2_name, mutual_value);
            obj.addElement(mutual);
        end
        
        function state_vars = getStateVariables(obj)
            % Get all state variables in the circuit
            state_vars = [];
            
            for i = 1:length(obj.elements)
                element = obj.elements{i};
                if ismethod(element, 'isStateVariable') && element.isStateVariable()
                    state_var = element.getStateVariable();
                    state_vars = [state_vars; state_var];
                end
            end
        end
        
        function inputs = getInputSources(obj)
            % Get all input sources (voltage/current sources)
            inputs = {};
            
            for i = 1:length(obj.elements)
                element = obj.elements{i};
                if ismember(element.element_type, {'V', 'I'})
                    inputs{end+1} = element;
                end
            end
        end
        
        function displayCircuit(obj)
            % Display circuit information
            fprintf(' \n=== CIRCUIT: %s === \n', obj.name);
            fprintf('Nodes: %s \n', mat2str(obj.nodes));
            fprintf('Elements: %d \n', length(obj.elements));
            
            fprintf(' \nElement List: \n');
            for i = 1:length(obj.elements)
                fprintf('  %d. ', i);
                obj.elements{i}.displayInfo();
            end
            
            % Display state variables
            state_vars = obj.getStateVariables();
            if ~isempty(state_vars)
                fprintf(' \nState Variables: \n');
                for i = 1:length(state_vars)
                    fprintf('  %s \n', char(state_vars(i)));
                end
            end
        end
        
        function validateCircuit(obj)
            % Basic circuit validation
            fprintf(' \nValidating circuit... \n');
            
            % Check for duplicate element names
            names = {};
            for i = 1:length(obj.elements)
                names{i} = obj.elements{i}.getName();
            end
            
            if length(unique(names)) ~= length(names)
                warning('Duplicate element names detected');
            end
            
            % Check for mutual inductors referencing non-existent inductors
            mutual_inductors = obj.getElementsByType('M');
            inductors = obj.getElementsByType('L');
            inductor_names = {};
            
            for i = 1:length(inductors)
                inductor_names{i} = inductors{i}.getName();
            end
            
            for i = 1:length(mutual_inductors)
                [ind1, ind2] = mutual_inductors{i}.getCoupledInductors();
                if ~ismember(ind1, inductor_names)
                    warning('Mutual inductor %s references non-existent inductor %s', ...
                            mutual_inductors{i}.getName(), ind1);
                end
                if ~ismember(ind2, inductor_names)
                    warning('Mutual inductor %s references non-existent inductor %s', ...
                            mutual_inductors{i}.getName(), ind2);
                end
            end
            
            fprintf('Circuit validation complete. \n');
        end
        
        function saveCircuit(obj, filename)
            % Save circuit to a .mat file
            circuit_data = struct();
            circuit_data.name = obj.name;
            circuit_data.elements = obj.elements;
            circuit_data.nodes = obj.nodes;
            
            save(filename, 'circuit_data');
            fprintf('Circuit saved to %s \n', filename);
        end
        
        function loadCircuit(obj, filename)
            % Load circuit from a .mat file
            loaded_data = load(filename);
            
            obj.name = loaded_data.circuit_data.name;
            obj.elements = loaded_data.circuit_data.elements;
            obj.nodes = loaded_data.circuit_data.nodes;
            obj.updateNodeMap();
            
            fprintf('Circuit loaded from %s \n', filename);
        end
    end
    
    methods (Access = private)
        function updateNodeMap(obj)
            % Update the mapping from node numbers to matrix indices
            obj.node_map = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
            sorted_nodes = sort(obj.nodes);
            
            for i = 1:length(sorted_nodes)
                if sorted_nodes(i) ~= 0  % Skip ground node
                    obj.node_map(sorted_nodes(i)) = i;
                end
            end
        end
        
        function updateNodes(obj)
            % Update node list after element removal
            obj.nodes = [];
            for i = 1:length(obj.elements)
                if ~strcmp(obj.elements{i}.element_type, 'M')
                    element_nodes = obj.elements{i}.getNodes();
                    non_ground_nodes = element_nodes(element_nodes ~= 0);
                    obj.nodes = unique([obj.nodes, non_ground_nodes]);
                end
            end
            obj.updateNodeMap();
        end
        
        function idx = findElementIndex(obj, element_name)
            % Find the index of an element by name
            idx = 0;
            for i = 1:length(obj.elements)
                if strcmp(obj.elements{i}.getName(), element_name)
                    idx = i;
                    return;
                end
            end
        end
    end
end