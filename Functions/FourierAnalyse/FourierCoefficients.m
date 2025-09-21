function [anf, bnf, a0, an, bn] = FourierCoefficients(f_exp, t, T)
% [a_of, b_of, a0] = FourierCoefficients(f_exp, t, T)
% f_exp : symbolic expression in t over [0, T]
% t     : symbolic variable
% T     : period (positive real)
%
% a_of(k) and b_of(k) are function handles returning a_k, b_k for integer k>=1

    arguments
        f_exp sym
        t sym
        T (1,1) sym
    end

    syms n integer
    
    % Assumptions
    assumeAlso(t, 'real'); %assumeAlso(T, 'real'); assumeAlso(T > 0);

    omega = 2*pi/T;

    an = simplify((2/T) * int(f_exp * cos(n*omega*t), t, 0, T));
    bn = simplify((2/T) * int(f_exp * sin(n*omega*t), t, 0, T));
    a0  = simplify((2/T) * int(f_exp, t, 0, T));

    % Return coefficient evaluators a_of(k), b_of(k) for integer k
    anf = @(k) subs(an, n, k);
    bnf = @(k) subs(bn, n, k);

    % Clean up assumptions on n only
    assume(n, 'clear');
end