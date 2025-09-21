classdef (Abstract) BaseCoil < handle
    properties (SetAccess = protected)
        type
        N           % number of turns
        mu0, mu     % permeability constants
        pose        % 4x4 transformation matrix
        geometry    % geometry parameters struct
        material    % material properties struct
    end
    
    properties (Abstract, SetAccess = protected)
        resistance  % frequency-dependent resistance
        inductance  % self-inductance
        capacitance % parasitic capacitance
    end
    
    methods (Abstract)
        L = calcSelfInductance(obj)
        R = calcResistance(obj, frequency)
        C = calcParasiticCapacitance(obj)
        curve = parameterizeCurve(obj, n_points)
        flux = calcFluxTo(obj, other_coil, current)
    end
    
    methods
        function obj = BaseCoil(type, params)
            obj.type = type;
            obj.N = params.N;
            obj.mu0 = 4*pi*1e-7;
            obj.mu = obj.mu0 * getfield(params, 'mu_r', 1);
            obj.pose = getfield(params, 'pose', eye(4));
            obj.geometry = params.geometry;
            obj.material = getfield(params, 'material', struct());
        end
        
        function M = mutualInductance(obj, other, alignment)
            % Calculate mutual inductance using appropriate method
            if nargin < 3, alignment = struct('type', 'coaxial'); end
            M = calcMutualInductance(obj, other, alignment);
        end
        
        function k = couplingCoefficient(obj, other, alignment)
            M = obj.mutualInductance(other, alignment);
            k = M / sqrt(obj.inductance * other.inductance);
        end
    end
end