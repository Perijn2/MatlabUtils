classdef MutualInductor < CircuitNode
    % Mutual Inductor implementation
    % Enhanced version of your original MutualInductor class
    
    properties (Constant)
        element_type = 'M';
    end
    
    properties
        inductor1_name    % Name of first coupled inductor
        inductor2_name    % Name of second coupled inductor
        mutual_value      % Mutual inductance value M
        coupling_coeff    % Coupling coefficient k (optional)
    end
    
    methods
        function obj = MutualInductor(name, ind1_name, ind2_name, mutual_value, coupling_coeff)
            % Constructor: MutualInductor('M1', 'L1', 'L2', sym('M'), sym('k'))
            % nodes parameter is not used for mutual inductors
            obj@CircuitNode(name, [], mutual_value);
            obj.inductor1_name = ind1_name;
            obj.inductor2_name = ind2_name;
            obj.mutual_value = mutual_value;
            
            if nargin > 4
                obj.coupling_coeff = coupling_coeff;
            else
                obj.coupling_coeff = [];
            end
        end
        
        function Z = getImpedance(obj, s)
            % Mutual impedance: Z = sM
            Z = s * obj.mutual_value;
        end
        
        function Y = getAdmittance(obj, s)
            % Mutual admittance: Y = 1/(sM)
            Y = 1 / (s * obj.mutual_value);
        end
        
        function stampMNA(obj, G, B, s, node_map)
            % Stamp mutual inductance into MNA matrices
            % This requires knowledge of the coupled inductors' nodes
            % Implementation depends on how inductors are handled in MNA
            
            % For mutual inductance, we need to add coupling terms
            % This is typically done by modifying the inductor stamps
            % after all inductors have been processed
            
            % Placeholder - actual implementation requires access to
            % the coupled inductors and their node connections
            fprintf('Mutual inductance stamping requires special handling\n');
        end
        
        function eq = getMutualVoltageEquation(obj, current1_var, current2_var)
            % Return mutual voltage equation: V_mutual = sM * I_coupled
            syms s
            eq1 = s * obj.mutual_value * current2_var;  % V1_mutual due to I2
            eq2 = s * obj.mutual_value * current1_var;  % V2_mutual due to I1
            eq = [eq1; eq2];
        end
        
        function [ind1, ind2] = getCoupledInductors(obj)
            % Return names of coupled inductors
            ind1 = obj.inductor1_name;
            ind2 = obj.inductor2_name;
        end
        
        function M_val = getMutualValue(obj)
            % Get mutual inductance value
            M_val = obj.mutual_value;
        end
        
        function k_val = getCouplingCoefficient(obj)
            % Get coupling coefficient
            k_val = obj.coupling_coeff;
        end
        
        function setFromCouplingCoeff(obj, L1_value, L2_value, k_value)
            % Calculate M from coupling coefficient: M = k*sqrt(L1*L2)
            obj.mutual_value = k_value * sqrt(L1_value * L2_value);
            obj.coupling_coeff = k_value;
        end
        
        function displayInfo(obj)
            % Display mutual inductor information
            fprintf('%s: %s = %s, Coupled: %s-%s\n', ...
                    obj.element_type, obj.name, ...
                    char(obj.mutual_value), ...
                    obj.inductor1_name, obj.inductor2_name);
            
            if ~isempty(obj.coupling_coeff)
                fprintf('  Coupling coefficient k = %s\n', char(obj.coupling_coeff));
            end
        end
    end
end