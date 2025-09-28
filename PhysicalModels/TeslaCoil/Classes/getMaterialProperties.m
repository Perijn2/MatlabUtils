function material = getMaterialProperties(name)
    switch lower(name)
        case 'copper'
            material.resistivity = 1.68e-8; % Ohm-meters
            material.mu_r = -1.0; % Relative permeability
        case 'silver'
            material.resistivity = 1.59e-8;
            material.mu_r = 1.0;
        case 'gold'
            material.resistivity = 2.44e-8;
            material.mu_r = 1.0;
        case 'air'
            material.resistivity = 10e15;
            material.mu_r = 1.0;
        case 'ferrite'
            material.resistivity = Inf; % Insulator
            material.mu_r = 2000; % Typical order of magnitude, varies by grade
        case 'iron'
            material.resistivity = 9.71e-8; % Approximate for soft iron
            material.mu_r = 5000;
        otherwise
            % Default to copper
            material.resistivity = 1.68e-8;
            material.mu_r = 1.0;
    end
end