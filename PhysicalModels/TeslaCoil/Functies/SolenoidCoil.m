c1 = makeCoil('solenoid_inf', struct( ...
    'N', 2000, 'length', 0.25, 'radius', 0.02, ...
    'pose', eye(4), 'mu_r', 1));            % ideal infinite solenoid

c2 = makeCoil('toroid_ideal', struct( ...
    'N', 500, 'r_in', 0.03, 'r_out', 0.05, 'height', 0.02, ...
    'pose', eye(4), 'mu_r', 1));            % ideal toroi

function coil = makeCoil(type, p)
% Create a coil struct with model functions. Supply geometry in p (struct).
    arguments
        type (1,:) char
        p struct
    end
    mu0 = 4*pi*1e-7;
    mu  = mu0 * getfield(p, 'mu_r', 1);

    coil = struct( ...
        'type', type, 'N', p.N, 'mu0', mu0, 'mu', mu, ...
        'pose', getfield(p,'pose',eye(4)), ...
        'model', struct());

    switch type
        case 'solenoid_inf'  % ideal, radius a, length l (used in formula), N turns
            coil.radius = p.radius;
            coil.length = p.length;

            % Parameterize as N stacked circular loops for Neumann (fallback)
            coil.model.curve = @(n) loopsOnAxis(coil.radius, coil.length, coil.N, n);

            % Analytic flux from this solenoid to another (when supported)
            coil.model.flux_to = @(other, I) flux_solenoidInf_to(other, coil, I);

        case 'toroid_ideal'  % rectangular cross-section toroid
            coil.r_in   = p.r_in;   coil.r_out = p.r_out;  coil.height = p.height;

            % Parameterize as N loops at mean radius
            rmean = 0.5*(coil.r_in+coil.r_out);
            coil.model.curve = @(n) singleLoop(rmean, [0;0;0], coil.N, n);

            coil.model.flux_to = @(other, I) flux_toroidIdeal_to(other, coil, I);

        case 'loop'          % single circular loop
            coil.radius = p.radius;
            coil.model.curve = @(n) singleLoop(coil.radius, [0;0;0], coil.N, n);
            coil.model.flux_to = @(other, I) flux_neumann_generic(coil, other, I);

        otherwise
            error('Unknown coil type: %s', type);
    end
end