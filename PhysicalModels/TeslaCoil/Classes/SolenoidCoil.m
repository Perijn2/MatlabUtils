classdef SolenoidCoil < BaseCoil
    properties (SetAccess = protected)
        wire_diameter
        winding_density
        core_material
        end_effects
        interlayer_capacitance
    end
    
    methods
        function obj = SolenoidCoil(params)
            obj@BaseCoil('solenoid', params);
            obj.wire_diameter = params.wire_diameter;
            obj.winding_density = getfield(params, 'density', 'single_layer');
            obj.core_material = getfield(params, 'core', 'air');
            obj.end_effects = getfield(params, 'end_effects', true);
            obj.updateProperties();
        end
        
        function L = calcSelfInductance(obj)
            % Wheeler's formula with corrections for finite length
            a = obj.geometry.radius;
            l = obj.geometry.length;
            N = obj.N;
            
            % Basic inductance
            L_basic = obj.mu * N^2 * pi * a^2 / l;
            
            % End effect correction (Nagaoka coefficient)
            k_N = nagaokaCoeff(2*a/l);
            
            % Multi-layer correction if applicable
            if strcmp(obj.winding_density, 'multi_layer')
                k_ML = multiLayerCorrection(obj);
                L = L_basic * k_N * k_ML;
            else
                L = L_basic * k_N;
            end
            
            obj.inductance = L;
        end
        
        function R = calcResistance(obj, frequency)
            % DC resistance + skin effect + proximity effect
            if nargin < 2, frequency = 0; end
            
            l_wire = obj.N * 2*pi*obj.geometry.radius;  % wire length
            rho = getMaterialProperty(obj.material, 'resistivity');
            A_wire = pi * (obj.wire_diameter/2)^2;
            
            R_dc = rho * l_wire / A_wire;
            
            if frequency > 0
                % Skin depth
                delta = sqrt(2*rho / (2*pi*frequency*obj.mu0));
                
                % Skin effect factor
                if obj.wire_diameter/2 > delta
                    k_skin = (obj.wire_diameter/2) / delta;
                else
                    k_skin = 1;
                end
                
                % Proximity effect (simplified)
                k_prox = proximityFactor(obj, frequency);
                
                R = R_dc * k_skin * k_prox;
            else
                R = R_dc;
            end
            
            obj.resistance = R;
        end
    end
end
